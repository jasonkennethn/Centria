import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class CopilotPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const CopilotPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends State<CopilotPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();

  bool _isSending = false;
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hello! I am Centria Copilot, powered by Google Gemini. I have real-time visibility across your Neon DB ledger, S3 documents, HRMS directory, and operations. How can I accelerate your company today?',
    }
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text.trim()});
      _isSending = true;
      _promptController.clear();
    });

    _scrollToBottom();

    final res = await _api.sendCopilotMessage(text.trim());

    if (mounted) {
      setState(() {
        _isSending = false;
        if (res.isSuccess) {
          final reply = res.data['reply'] ?? res.data['content'] ?? 'Action analyzed and executed.';
          _messages.add({'role': 'assistant', 'text': reply});
        } else {
          _messages.add({
            'role': 'assistant',
            'text': 'Error connecting to Gemini API: ${res.errorMessage ?? "Please retry."}',
          });
        }
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'AI Copilot & Co-Founder (⌘K)', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DualModeBanner(
                    title: 'Conversational Enterprise Copilot',
                    description: 'Ask complex business questions, generate legal documents, or execute actions across any module.',
                    aiButtonLabel: 'Launch 60s Genesis',
                    onAiAction: () => widget.onNavigate('/genesis'),
                  ),

                  // Chat Message List
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (ctx, idx) {
                          final msg = _messages[idx];
                          final isUser = msg['role'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(14),
                              constraints: const BoxConstraints(maxWidth: 650),
                              decoration: BoxDecoration(
                                color: isUser ? AppTheme.primary : AppTheme.darkSubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUser ? AppTheme.primary : AppTheme.darkBorder,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isUser ? Icons.person : Icons.auto_awesome,
                                        size: 14,
                                        color: isUser ? Colors.white70 : AppTheme.accent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isUser ? 'You' : 'Centria Copilot (Gemini)',
                                        style: TextStyle(
                                          color: isUser ? Colors.white70 : AppTheme.accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg['text'] ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prompt Suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPromptChip('📊 Draft Q4 Board Revenue Summary'),
                        _buildPromptChip('💰 Calculate cash burn and runway months'),
                        _buildPromptChip('📄 Generate Mutual NDA template'),
                        _buildPromptChip('🚀 Recommend engineering sprint capacity'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Box
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Ask Copilot to analyze finances, write policies, or automate tasks...',
                            prefixIcon: Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSending ? null : () => _sendMessage(_promptController.text),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                        child: _isSending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: AppTheme.darkCard,
        side: const BorderSide(color: AppTheme.darkBorder),
        label: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        onPressed: () => _sendMessage(label.replaceAll(RegExp(r'^[^\w]+'), '')),
      ),
    );
  }
}
