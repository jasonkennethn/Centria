import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class DocumentsPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const DocumentsPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  bool _isUploading = false;
  List<dynamic> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final res = await _api.getDocuments();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.isSuccess && res.data is List) {
          _documents = res.data;
        }
      });
    }
  }

  Future<void> _handleUploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploading = true);

    final res = await _api.uploadDocument(
      title: file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
      category: 'CONTRACT',
      companyId: '00000000-0000-0000-0000-000000000000', // Root fallback or active workspace
      filename: file.name,
      bytes: file.bytes!,
      runAiAnalysis: true,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.success,
            content: Text('Document uploaded to Neon S3 Object Cloud & analyzed by Gemini!'),
          ),
        );
        _loadDocuments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text(res.errorMessage ?? 'Upload failed.'),
          ),
        );
      }
    }
  }

  Future<void> _triggerAiAnalysis(String docId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Triggering Gemini Multimodal OCR...')),
    );
    final res = await _api.triggerDocAnalysis(docId);
    if (res.isSuccess) {
      _loadDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Document Vault (Neon S3)', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Neon Object Cloud & Gemini Multimodal OCR',
                    description: 'Store enterprise media, agreements, and receipts securely in S3 with automated Gemini contract summarization.',
                    aiButtonLabel: 'Analyze Vault Files',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VAULT REPOSITORY',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _handleUploadDocument,
                        icon: _isUploading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined, size: 16),
                        label: Text(_isUploading ? 'Uploading to S3...' : 'Upload File to S3'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else if (_documents.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.darkBorder)),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.folder_open, size: 48, color: AppTheme.textMuted),
                            SizedBox(height: 12),
                            Text('No documents in Neon S3 Vault yet.', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            Text('Upload a contract, NDA, receipt or policy to extract AI summaries.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documents.length,
                      itemBuilder: (ctx, idx) {
                        final doc = _documents[idx];
                        final id = doc['id'].toString();
                        final analysis = doc['latest_analysis'];
                        final s3Url = doc['s3_file_url'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withAlpha(30),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.description, color: AppTheme.accent, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(doc['title'] ?? 'Document', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 2),
                                          Text('${doc['category']} • S3 Key: ${doc['s3_key'] ?? 'media/doc'}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    if (s3Url.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.open_in_new, size: 18, color: AppTheme.accent),
                                        tooltip: 'Open in Neon S3',
                                        onPressed: () async {
                                          final uri = Uri.parse(s3Url);
                                          if (await canLaunchUrl(uri)) launchUrl(uri);
                                        },
                                      ),
                                    ElevatedButton.icon(
                                      onPressed: () => _triggerAiAnalysis(id),
                                      icon: const Icon(Icons.auto_awesome, size: 14),
                                      label: const Text('Gemini OCR', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.darkBorder,
                                        foregroundColor: AppTheme.accent,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                                if (analysis != null && analysis['summary'] != null) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkSubtle,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.primary.withAlpha(40)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.psychology, size: 14, color: AppTheme.accent),
                                            SizedBox(width: 6),
                                            Text('Gemini Multimodal Intelligence Summary:', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          analysis['summary'] ?? '',
                                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
