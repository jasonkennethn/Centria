import logging
from django.conf import settings
from django.utils import timezone
import google.generativeai as genai
from ai_engine.models import AIConversation, AIMessage, AIUsageQuota
from documents.services import search_knowledge_base
from projects.models import Project, Task
from approvals.models import ApprovalRequest

logger = logging.getLogger('centria.ai')


def check_and_increment_quota(company, user):
    """Ensures monthly query limit is enforced per organization."""
    now = timezone.now()
    month_year = now.strftime('%Y-%m')
    quota, _ = AIUsageQuota.objects.get_or_create(
        company=company,
        user=user,
        month_year=month_year,
        defaults={'limit_queries': 1000}
    )
    if quota.is_quota_exceeded():
        return False, "Monthly AI query quota exceeded for this workspace."
    quota.queries_count += 1
    quota.save(update_fields=['queries_count'])
    return True, None


def gather_context(company, context_type, context_id):
    """Retrieves operational domain objects to enrich the AI prompt."""
    context_text = ""
    try:
        if context_type == 'project' and context_id:
            project = Project.objects.filter(company=company, id=context_id).first()
            if project:
                open_tasks = Task.objects.filter(project=project).exclude(status='done')[:10]
                tasks_summary = "\n".join([f"- [{t.key}] {t.title} ({t.status}, {t.priority})" for t in open_tasks])
                context_text = f"Context: Active Project '{project.name}' (Key: {project.key}, Status: {project.status}).\nOpen Tasks:\n{tasks_summary}\n"
        elif context_type == 'task' and context_id:
            task = Task.objects.filter(company=company, id=context_id).select_related('project', 'assignee').first()
            if task:
                context_text = f"Context: Task '{task.key}: {task.title}'\nStatus: {task.status}, Priority: {task.priority}, Assignee: {task.assignee.full_name if task.assignee else 'Unassigned'}\nDescription: {task.description}\n"
        elif context_type == 'reporting':
            active_projects = Project.objects.filter(company=company, status='active').count()
            open_issues = Task.objects.filter(company=company).exclude(status='done').count()
            pending_approvals = ApprovalRequest.objects.filter(company=company, status='pending').count()
            context_text = f"Context: Company Workspace '{company.name}' Overview:\nActive Projects: {active_projects}\nOpen Issues: {open_issues}\nPending Approvals: {pending_approvals}\n"
    except Exception as e:
        logger.warning(f"Context gathering warning: {e}")
    return context_text


def run_centria_assistant(company, user, prompt, conversation_id=None, context_type='general', context_id=''):
    """
    Executes grounding with RAG citations, queries Gemini 2.5 Flash, and logs the response.
    """
    allowed, err_msg = check_and_increment_quota(company, user)
    if not allowed:
        return {'error': err_msg, 'status_code': 429}

    # Retrieve or create conversation
    if conversation_id:
        conversation = AIConversation.objects.filter(company=company, id=conversation_id).first()
    else:
        conversation = None

    if not conversation:
        title_snippet = prompt[:45] + ('...' if len(prompt) > 45 else '')
        conversation = AIConversation.objects.create(
            company=company,
            user=user,
            title=title_snippet,
            context_type=context_type,
            context_id=context_id or ''
        )

    # 1. Record User Message
    AIMessage.objects.create(
        conversation=conversation,
        sender='user',
        content=prompt,
    )

    # 2. Retrieve Relevant Knowledge Base Chunks (RAG)
    citations = search_knowledge_base(company, prompt, top_k=3)
    rag_context = ""
    if citations:
        rag_context = "Relevant Company Documents & Knowledge Base:\n"
        for i, c in enumerate(citations):
            rag_context += f"[{i+1}] Source: {c['document_title']}\nExcerpt: {c['excerpt']}\n\n"

    # 3. Retrieve Live Operational Context
    ops_context = gather_context(company, context_type, context_id)

    # 4. Compose Grounded Prompt
    system_instruction = (
        "You are Centria AI, the intelligent Company Operating System assistant for modern software & IT teams.\n"
        "Your mission is to help teams manage projects, issues, company knowledge, and approvals with absolute clarity.\n"
        "Always be concise, professional, actionable, and grounded.\n"
        "If you use information from the provided knowledge base documents, cite the document name explicitly."
    )

    full_prompt = f"{system_instruction}\n\n{ops_context}\n{rag_context}\nUser Question: {prompt}\n\nCentria Assistant Response:"

    # 5. Call Gemini API
    api_key = getattr(settings, 'GEMINI_API_KEY', '')
    model_name = getattr(settings, 'GEMINI_MODEL', 'models/gemini-2.5-flash')
    genai.configure(api_key=api_key)

    try:
        model = genai.GenerativeModel(model_name)
        response = model.generate_content(full_prompt)
        assistant_reply = response.text.strip()
    except Exception as e:
        logger.error(f"Gemini generation error: {e}")
        assistant_reply = f"I encountered an error querying the model. Please check the workspace configuration or try again shortly. (Detail: {e})"

    # 6. Save Assistant Response Turn
    ai_msg = AIMessage.objects.create(
        conversation=conversation,
        sender='assistant',
        content=assistant_reply,
        citations=citations,
        tokens_used=len(full_prompt.split()) + len(assistant_reply.split())
    )

    return {
        'conversation_id': str(conversation.id),
        'message_id': str(ai_msg.id),
        'response': assistant_reply,
        'citations': citations,
        'context_type': context_type,
    }
