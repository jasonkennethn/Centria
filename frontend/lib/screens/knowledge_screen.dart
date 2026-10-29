import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  List<dynamic> _documents = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final docs = await ApiService.getDocuments();
    if (mounted) {
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await ApiService.searchKnowledge(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Knowledge Base', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                    const SizedBox(height: 4),
                    Text('Company specs, policies, and SOPs indexed for ground-truth AI search.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document upload dialog: Drag or select PDF/DOCX to index with pgvector.')),
                    );
                  },
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload Document'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Semantic Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search documents semantically (e.g. "What is our release checklist gate?")...',
                prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _handleSearch(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Results or Document List
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : (_searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _buildDocumentsGrid()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Semantic Citations (${_searchResults.length} matches found)', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.violet)),
            TextButton(
              onPressed: () => setState(() {
                _searchResults = [];
                _searchController.clear();
              }),
              child: const Text('Clear search'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, idx) {
              final r = _searchResults[idx];
              final score = ((r['similarity_score'] ?? 0.0) * 100).toInt();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8E2F3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r['document_title'] ?? 'Document', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.violet)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.violetPale, borderRadius: BorderRadius.circular(6)),
                          child: Text('$score% MATCH', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.violet)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r['excerpt'] as String? ?? '',
                      style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: const Color(0xFF53635A)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsGrid() {
    if (_isLoading) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisExtent: 155,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (ctx, i) => const SkeletonLoader(width: double.infinity, height: 155, borderRadius: 16),
      );
    }
    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: 16),
            Text('No documents uploaded yet.', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Upload company policies, specs, or release checklists to power Centria AI.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 155,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _documents.length,
      itemBuilder: (context, idx) {
        final d = _documents[idx];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.description, size: 18, color: AppColors.teal),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(6)),
                    child: Text('INDEXED (${d['chunk_count'] ?? 0})', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.teal2)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(d['title'] as String, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(d['description'] as String? ?? 'Indexed knowledge asset.', maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        );
      },
    );
  }
}
