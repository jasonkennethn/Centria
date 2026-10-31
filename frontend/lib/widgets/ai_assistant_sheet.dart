import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/services/realtime_service.dart';

class AiAssistantSheet extends StatefulWidget {
  final String contextType;
  final String? contextId;

  const AiAssistantSheet({
    super.key,
    this.contextType = 'general',
    this.contextId,
  });

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'assistant',
      'content': "Hello! I'm Centria AI, grounded in your workspace data and documents. How can I help you move work forward today?",
      'citations': [],
    }
  ];
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _conversationId;

  Future<void> _sendPrompt() async {
    final text = _promptController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _promptController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'content': text, 'citations': []});
      // Add empty assistant response to stream into
      _messages.add({'sender': 'assistant', 'content': '', 'citations': []});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final stream = RealtimeService.instance.streamAiAssistant(
        prompt: text,
        contextType: widget.contextType,
        contextId: widget.contextId,
        conversationId: _conversationId,
        onComplete: (metadata) {
          if (mounted) {
            setState(() {
              _conversationId = metadata['conversation_id'];
              _messages.last['citations'] = metadata['citations'] ?? [];
              _isLoading = false;
            });
            _scrollToBottom();
          }
        },
      );

      stream.listen(
        (chunk) {
          if (mounted) {
            setState(() {
              _messages.last['content'] = (_messages.last['content'] as String) + chunk;
            });
            _scrollToBottom();
          }
        },
        onError: (err) async {
          debugPrint('[AI Assistant] Stream error: $err, trying HTTP fallback...');
          // Graceful fallback to HTTP if WebSocket stream fails
          final res = await ApiService.askAI(
            prompt: text,
            conversationId: _conversationId,
            contextType: widget.contextType,
            contextId: widget.contextId,
          );
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (res['success']) {
                final data = res['data'];
                _conversationId = data['conversation_id'];
                _messages.last['content'] = data['response'];
                _messages.last['citations'] = data['citations'] ?? [];
              } else {
                _messages.last['content'] = "Error: ${res['error'] ?? 'Could not complete AI request'}";
              }
            });
            _scrollToBottom();
          }
        },
      );
    } catch (e) {
      debugPrint('[AI Assistant] Exception: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.last['content'] = "Error establishing real-time connection. Please retry.";
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: AppColors.violet.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: AppColors.violetPale, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.auto_awesome, color: AppColors.violet, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Centria AI Assistant', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('Context: ${widget.contextType} · Gemini 2.5 Flash', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['sender'] == 'user';
                final citations = (m['citations'] as List?) ?? [];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: AppColors.violetPale, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.auto_awesome, color: AppColors.violet, size: 14),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUser ? AppColors.teal : const Color(0xFFF7F8F5),
                                borderRadius: BorderRadius.circular(16),
                                border: isUser ? null : Border.all(color: AppColors.line),
                              ),
                              child: Text(
                                m['content'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.55,
                                  color: isUser ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                            if (citations.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: citations.map((c) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.violetPale,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE8E2F3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.link, size: 12, color: AppColors.violet),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${c['document_title'] ?? 'Document'} (${((c['similarity_score'] ?? 0) * 100).toInt()}%)",
                                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.violet, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet)),
                  const SizedBox(width: 10),
                  Text('Searching documents & generating grounded response...', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    onSubmitted: (_) => _sendPrompt(),
                    decoration: InputDecoration(
                      hintText: 'Ask Centria Assistant anything about your workspace...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _isLoading ? null : _sendPrompt,
                  style: IconButton.styleFrom(backgroundColor: AppColors.teal),
                  icon: const Icon(Icons.arrow_upward, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
