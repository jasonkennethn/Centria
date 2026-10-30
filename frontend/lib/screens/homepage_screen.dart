import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/auth_state.dart';
import 'package:centria/services/api_service.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  final ScrollController _scrollController = ScrollController();

  // Section GlobalKeys for exact dynamic scrolling
  final GlobalKey _productKey = GlobalKey();
  final GlobalKey _solutionsKey = GlobalKey();
  final GlobalKey _integrationsKey = GlobalKey();
  final GlobalKey _plansKey = GlobalKey();
  final GlobalKey _resourcesKey = GlobalKey();

  // Interactive States
  int _previewTab = 0; // 0: Overview, 1: Issues, 2: Knowledge, 3: Approvals
  int _workflowStep = 0; // 0..3
  bool _isYearlyBilling = false;
  int? _expandedFaq;

  // Modals
  void _openAuthModal({bool isSignUp = false}) {
    showDialog(
      context: context,
      barrierColor: AppColors.ink.withValues(alpha: 0.55),
      builder: (context) => _AuthModalDialog(initialSignUp: isSignUp),
    );
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && _scrollController.hasClients) {
        final position = box.localToGlobal(Offset.zero);
        final currentScroll = _scrollController.offset;
        final target = (currentScroll + position.dy - 84).clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 860;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          // 1. Locked Navigation Bar (Sticky at top)
          _buildHeader(isMobile),

          // 2. Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHero(isMobile, width),
                  _buildTrustStrip(isMobile),
                  _buildFeatures(isMobile),
                  _buildWorkflowSection(isMobile),
                  _buildAudienceSection(isMobile),
                  _buildAiSection(isMobile),
                  _buildIntegrationsSection(isMobile),
                  _buildSecuritySection(isMobile),
                  _buildPricingSection(isMobile),
                  _buildFaqSection(isMobile),
                  _buildCtaBanner(isMobile),
                  _buildFooter(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Locked Header ---
  Widget _buildHeader(bool isMobile) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.98),
        border: Border(bottom: BorderSide(color: AppColors.line.withValues(alpha: 0.85))),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo + Text
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: AppColors.teal.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 20, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Centria',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -1.2, color: AppColors.ink),
                  ),
                ],
              ),

              // Navigation Links (Desktop)
              if (!isMobile)
                Row(
                  children: [
                    _navLink('Product', () => _scrollToSection(_productKey)),
                    _navLink('Solutions', () => _scrollToSection(_solutionsKey)),
                    _navLink('Integrations', () => _scrollToSection(_integrationsKey)),
                    _navLink('Plans', () => _scrollToSection(_plansKey)),
                    _navLink('Resources', () => _scrollToSection(_resourcesKey)),
                  ],
                ),

              // Single Action Button
              ElevatedButton(
                onPressed: () => _openAuthModal(isSignUp: true),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Get Started'),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF52665E)),
          ),
        ),
      ),
    );
  }

  // --- 3. Hero Section ---
  Widget _buildHero(bool isMobile, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCopy(isMobile),
                    const SizedBox(height: 48),
                    _buildProductPreview(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 48, child: _buildHeroCopy(isMobile)),
                    const SizedBox(width: 48),
                    Expanded(flex: 52, child: _buildProductPreview(isMobile)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroCopy(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: const Color(0xFFE5EFE4), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.circle_outlined, size: 14, color: AppColors.teal2),
            ),
            const SizedBox(width: 8),
            Text(
              'COMPANY WORK, CONNECTED',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.teal2),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Headline
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: isMobile ? 44 : 64,
              fontWeight: FontWeight.w600,
              letterSpacing: -2.2,
              height: 1.02,
              color: AppColors.ink,
            ),
            children: const [
              TextSpan(text: "Your company's work.\n"),
              TextSpan(text: "One clearer way forward.", style: TextStyle(color: AppColors.teal)),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Copy
        Text(
          "Bring projects, issues, company knowledge and approvals into one workspace—so teams can spend less time chasing context and more time moving work forward.",
          style: GoogleFonts.inter(fontSize: 16, height: 1.7, color: const Color(0xFF60716B)),
        ),
        const SizedBox(height: 28),

        // Actions
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => _openAuthModal(isSignUp: true),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Join Now'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _scrollToSection(_productKey),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Explore the product'),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Proof points
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _proofPoint('Work with clear ownership'),
            _proofPoint('Sources beside AI answers'),
            _proofPoint('People stay in control'),
          ],
        ),
        const SizedBox(height: 20),

        // Note
        Text(
          'Built for: founders, product teams and growing service businesses.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _proofPoint(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 15, color: AppColors.teal),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF5D6E66))),
      ],
    );
  }

  // --- Interactive Product Preview ---
  Widget _buildProductPreview(bool isMobile) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(color: const Color(0xFF1D3E31).withValues(alpha: 0.12), blurRadius: 60, offset: const Offset(0, 24)),
              BoxShadow(color: const Color(0xFF1D3E31).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Window Bar
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCFDFB),
                  border: Border(bottom: BorderSide(color: Color(0xFFE8EDE7))),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    // Dots
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFD8E0D8), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFD8E0D8), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFD8E0D8), shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Text('Centria', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 16, color: const Color(0xFFE2E7E1)),
                    const SizedBox(width: 8),
                    Text('Northstar workspace', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF78877E))),
                    const Spacer(),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4A9B73), shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('Product preview', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5F7C6E))),
                  ],
                ),
              ),

              // Window Body (Side + Content) - Fixed layout to prevent CanvasKit collapse
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: isMobile ? 320 : 380),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar
                    Container(
                      width: isMobile ? 105 : 140,
                      constraints: BoxConstraints(minHeight: isMobile ? 320 : 380),
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFCF9),
                        border: Border(right: BorderSide(color: Color(0xFFE8EEE7))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(color: const Color(0xFFDFEAD5), borderRadius: BorderRadius.circular(6)),
                                child: const Center(child: Text('N', style: TextStyle(color: Color(0xFF45643D), fontWeight: FontWeight.bold, fontSize: 10))),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Northstar', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('WORKSPACE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.8)),
                          const SizedBox(height: 6),
                          _miniSideItem('My Day', Icons.calendar_today_outlined, _previewTab == 0),
                          _miniSideItem('Projects', Icons.folder_outlined, _previewTab == 1, badge: '08'),
                          _miniSideItem('Knowledge', Icons.book_outlined, _previewTab == 2),
                          _miniSideItem('Approvals', Icons.check_circle_outline, _previewTab == 3, badge: '03'),
                        ],
                      ),
                    ),

                    // Main Mock Panel Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildPreviewTabContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs to switch views
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _previewTabButton(0, 'Overview'),
            _previewTabButton(1, 'Projects & Tasks'),
            _previewTabButton(2, 'Knowledge Base'),
            _previewTabButton(3, 'Approvals'),
          ],
        ),
      ],
    );
  }

  Widget _miniSideItem(String label, IconData icon, bool active, {String? badge}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F1E8) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: active ? AppColors.teal : const Color(0xFF708078)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 9, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? AppColors.teal2 : const Color(0xFF708078)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null)
            Text(badge, style: GoogleFonts.inter(fontSize: 8, color: const Color(0xFF839086))),
        ],
      ),
    );
  }

  Widget _previewTabButton(int index, String label) {
    final active = _previewTab == index;
    return InkWell(
      onTap: () => setState(() => _previewTab = index),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? const Color(0xFFDCE5DA) : Colors.transparent),
          boxShadow: active ? [BoxShadow(color: AppColors.ink.withValues(alpha: 0.04), blurRadius: 6)] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: active ? AppColors.teal : const Color(0xFF708078)),
        ),
      ),
    );
  }

  Widget _buildPreviewTabContent() {
    switch (_previewTab) {
      case 1:
        // Projects & Issues view
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Projects (08)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
                  child: Text('+ New Task', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _taskRow('[POR-1] Review customer feedback', 'Done', isDone: true),
            _taskRow('[REL-1] Confirm release checklist', 'In Review', isReview: true),
            _taskRow('[POR-2] Approve updated scope', 'To Do'),
          ],
        );
      case 2:
        // Knowledge view
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company Knowledge Base', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.violetPale, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8E2F3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: AppColors.violet),
                      const SizedBox(width: 6),
                      Text('Semantic Search with Citations', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.violet)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('"Release Checklist v1.4 Gate is indexed with 3072-dim embeddings for ground-truth answers."', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5F5875))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _docItem('Release Checklist · Version 3.pdf', 'Indexed · 12 chunks'),
            _docItem('Client Service Level Agreement.docx', 'Indexed · 8 chunks'),
          ],
        );
      case 3:
        // Approvals view
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Approvals (03)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFCFDFB), border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Release 1.4 Checklist Sign-off', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.amberPale, borderRadius: BorderRadius.circular(4)),
                        child: Text('RELEASE GATE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.amber)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Requester: Priya Sharma · Waiting for sign-off', style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
                        child: Text('Approve', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(6)),
                        child: Text('Review Details', style: GoogleFonts.inter(fontSize: 9, color: AppColors.ink, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        // Overview (My Day) view
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning, Priya', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    Text("Here's what needs your attention today.", style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF65746A))),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _openAuthModal(isSignUp: true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 10),
                      const SizedBox(width: 4),
                      Text('Create', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3 metrics
            Row(
              children: [
                Expanded(child: _metricBox('Active projects', '08', 'Across workspace')),
                const SizedBox(width: 6),
                Expanded(child: _metricBox('Open issues', '24', '5 need attention', isWarn: true)),
                const SizedBox(width: 6),
                Expanded(child: _metricBox('Pending review', '03', 'Next: release gate')),
              ],
            ),
            const SizedBox(height: 12),

            // Lower split
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 55,
                  child: Column(
                    children: [
                      _taskRow('Review feedback', 'Done', isDone: true),
                      _taskRow('Confirm release checklist', 'Review', isReview: true),
                      _taskRow('Approve updated scope', '2 pm'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 45,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.violetPale,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E2F3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 11, color: AppColors.violet),
                            const SizedBox(width: 4),
                            Text('Centria AI', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.violet)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'The release is waiting on one approval. The checklist and change request are linked.',
                          style: GoogleFonts.inter(fontSize: 8, height: 1.45, color: const Color(0xFF5F5875)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), border: Border.all(color: const Color(0xFFE4DFF0))),
                          child: Text('Evidence: Release checklist v3', style: GoogleFonts.inter(fontSize: 7, color: const Color(0xFF70668F))),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _metricBox(String label, String value, String sub, {bool isWarn = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 7, color: isWarn ? AppColors.amber : AppColors.greenDone)),
        ],
      ),
    );
  }

  Widget _taskRow(String title, String tag, {bool isDone = false, bool isReview = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEDF1EC)))),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFE1F1E4) : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: isDone ? const Color(0xFF9FC9AA) : const Color(0xFFB6C6B8)),
            ),
            child: isDone ? const Center(child: Text('✓', style: TextStyle(fontSize: 7, color: Color(0xFF377750)))) : null,
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDone ? AppColors.greenPale : (isReview ? AppColors.amberPale : AppColors.soft),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag, style: GoogleFonts.inter(fontSize: 6, fontWeight: FontWeight.w700, color: isDone ? AppColors.greenDone : (isReview ? AppColors.amber : AppColors.ink))),
          ),
        ],
      ),
    );
  }

  Widget _docItem(String name, String meta) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 16, color: AppColors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700)),
                Text(meta, style: GoogleFonts.inter(fontSize: 7, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Trust Strip ---
  Widget _buildTrustStrip(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFDFB),
        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFE0E7DF))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: [
              Text(
                'BUILT FOR TEAMS GROWING WHAT\'S NEXT',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: AppColors.muted),
              ),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _trustItem('Fast by default'),
                  _trustItem('Clean data isolation'),
                  _trustItem('Clear accountability'),
                  _trustItem('Evidence beside answers'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shield_outlined, size: 14, color: AppColors.teal),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF53675C))),
      ],
    );
  }

  // --- 5. Features Section ---
  Widget _buildFeatures(bool isMobile) {
    final features = [
      {'title': 'Projects', 'desc': 'Structured workspaces for releases, customer deliverables, and team milestones.', 'icon': Icons.folder_open_outlined, 'color': AppColors.teal},
      {'title': 'Tasks & Issues', 'desc': 'Keep daily execution connected to broader goals with custom kanban states.', 'icon': Icons.checklist_outlined, 'color': AppColors.teal},
      {'title': 'Knowledge Base', 'desc': 'Store SOPs, specs, and policies right where your team works.', 'icon': Icons.menu_book_outlined, 'color': AppColors.teal},
      {'title': 'Approval Gates', 'desc': 'Clear approval workflows for releases, scope changes, and budget gates.', 'icon': Icons.verified_user_outlined, 'color': AppColors.amber},
      {'title': 'Ground-Truth AI', 'desc': 'Get instant answers with verifiable source citations from your documents.', 'icon': Icons.auto_awesome, 'color': AppColors.violet},
      {'title': 'GitHub Connected', 'desc': 'Link branches, pull requests, and commit milestones to tasks seamlessly.', 'icon': Icons.code_outlined, 'color': AppColors.teal},
    ];

    return Container(
      key: _productKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EVERYTHING CONNECTED', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('One platform for your entire operational flow', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 16),
              Text('Stop duct-taping five disconnected tools. Centria brings clarity without the clutter.', style: GoogleFonts.inter(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 48),

              // Dynamic Responsive Features Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 240,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final f = features[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFDFA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5EAE3)),
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
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (f['color'] as Color).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(f['icon'] as IconData, size: 20, color: f['color'] as Color),
                                ),
                                const Spacer(),
                                Text(f['title'] as String, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                                const SizedBox(height: 6),
                                Text(f['desc'] as String, style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: const Color(0xFF5D6E63))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. Interactive Workflow Section ---
  Widget _buildWorkflowSection(bool isMobile) {
    final steps = [
      {'title': '1. Plan & align', 'sub': 'Define projects, deliverables, and team responsibilities in one view.'},
      {'title': '2. Track & ship', 'sub': 'Move work forward on kanban boards with linked GitHub pull requests.'},
      {'title': '3. Capture knowledge', 'sub': 'Upload specs and SOPs; let pgvector AI index them for instant citation retrieval.'},
      {'title': '4. Close the loop', 'sub': 'Clear approval gates and keep an immutable audit trail for complete compliance.'},
    ];

    return Container(
      key: _solutionsKey,
      color: const Color(0xFFF0F3EE),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HOW TEAMS OPERATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('From early idea to audited completion', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 40),

              isMobile
                  ? Column(
                      children: [
                        _buildWorkflowStepList(steps),
                        const SizedBox(height: 24),
                        _buildWorkflowDisplayCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 42, child: _buildWorkflowStepList(steps)),
                        const SizedBox(width: 48),
                        Expanded(flex: 58, child: _buildWorkflowDisplayCard()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowStepList(List<Map<String, String>> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        final active = _workflowStep == index;
        return InkWell(
          onTap: () => setState(() => _workflowStep = index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active ? const Color(0xFFDCE5DA) : Colors.transparent),
              boxShadow: active ? [BoxShadow(color: AppColors.ink.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))] : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : const Color(0xFFE4EBE1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('${index + 1}', style: TextStyle(color: active ? Colors.white : const Color(0xFF486D56), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[index]['title']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      Text(steps[index]['sub']!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: active ? AppColors.teal : Colors.transparent),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWorkflowDisplayCard() {
    final cardTitles = [
      'Define clear project deliverables',
      'Manage tasks across unified boards',
      'Instant answers with cited sources',
      'Approve releases with audit trails',
    ];
    final cardDescriptions = [
      'Every project has a clear owner, timeline, and status. Break deliverables into actionable items with full team transparency.',
      'Connect commits and pull requests directly to task cards. No more asking "is this PR merged yet?" in Slack.',
      'Centria AI searches your uploaded specs with vector embeddings and cites exact document pages right next to the answer.',
      'Sign-off on release gates, budget authorizations, and client deliverables with verifiable audit logs and zero guesswork.',
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5DA)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF223E2F).withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STAGE 0${_workflowStep + 1}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF0F3EE), borderRadius: BorderRadius.circular(6)),
                child: Text('Operational Gate', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(cardTitles[_workflowStep], style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.6)),
          const SizedBox(height: 12),
          Text(cardDescriptions[_workflowStep], style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: const Color(0xFF697A70))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tagPill('Role Scoped Access'),
              _tagPill('Immutable Audit'),
              _tagPill('Live NeonDB Sync'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: AppColors.greenDone),
              const SizedBox(width: 8),
              Text('Verified & active in Northstar workspace', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF50705B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFBFCFA), border: Border.all(color: const Color(0xFFE2E8DF)), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF65776C))),
    );
  }

  // --- 7. Audience Section ---
  Widget _buildAudienceSection(bool isMobile) {
    final audiences = [
      {
        'tag': 'FOUNDERS & LEADERS',
        'title': 'Solo Founders & Startups',
        'desc': 'Run your whole company without drowning in administrative bloat.',
        'points': ['One central operational view', 'Zero configuration overhead', 'Automated meeting and task summaries'],
      },
      {
        'tag': 'PRODUCT & ENGINEERING',
        'title': 'Software & IT Teams',
        'desc': 'Bridge engineering tasks with business context and client deliverables.',
        'points': ['GitHub PR linking', 'Kanban states with issue numbers', 'Release gating and sign-offs'],
      },
      {
        'tag': 'OPERATIONS MANAGERS',
        'title': 'Project Managers & Leads',
        'desc': 'Keep customers happy and approvals moving with clear ownership.',
        'points': ['Documented compliance audits', 'Customer CRM workspaces', 'Verifiable AI answers'],
      },
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WHO USES CENTRIA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Tailored for high-velocity teams', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 48),

              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 380,
                    ),
                    itemCount: audiences.length,
                    itemBuilder: (context, index) {
                      final a = audiences[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFDFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE4EAE2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF3EB), borderRadius: BorderRadius.circular(6)),
                                  child: Text(a['tag'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF4D7357))),
                                ),
                                const SizedBox(height: 14),
                                Text(a['title'] as String, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                                const SizedBox(height: 6),
                                Text(a['desc'] as String, style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: const Color(0xFF6B7B72))),
                                const Spacer(),
                                ...((a['points'] as List<String>).map((p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check, size: 14, color: AppColors.teal),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(p, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF53685D)))),
                                        ],
                                      ),
                                    ))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 8. Centria AI Section ---
  Widget _buildAiSection(bool isMobile) {
    return Container(
      color: const Color(0xFFF4F2F9),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EVIDENCE-FIRST AI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.violet, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Answers with sources you can verify', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 16),
              Text('No hallucinated business metrics. Centria AI retrieves from your exact documents with pgvector embeddings.', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF6B6980))),
              const SizedBox(height: 48),

              // Evidence Demo Card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4DEF0)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF33264B).withValues(alpha: 0.08), blurRadius: 40, offset: const Offset(0, 16)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(color: const Color(0xFFF0ECFA), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.auto_awesome, color: AppColors.violet, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Centria Grounded Assistant', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('Powered by Gemini 2.5 Flash + pgvector', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6E6682))),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF8F6FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE3DCEF))),
                          child: Text('LIVE PREVIEW', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF76689A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sample Question
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFF7F5FB), borderRadius: BorderRadius.circular(12)),
                      child: Text('"What needs sign-off before Release 1.4 can go to production?"', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF433958))),
                    ),
                    const SizedBox(height: 16),

                    // Sample Answer
                    Text(
                      "Release 1.4 is pending approval from the assigned release manager. The final checklist requires all P0 bugs to be closed and the database migration script verified. All unit tests have passed.",
                      style: GoogleFonts.inter(fontSize: 13, height: 1.7, color: const Color(0xFF53635A)),
                    ),
                    const SizedBox(height: 16),

                    // Source Chip
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF9FD),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9E5F1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 16, color: AppColors.violet),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Release Checklist v1.4 Gate.pdf', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF51456F))),
                                Text('Section 4: Production Deployment Gates', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF6E6682))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.violetPale, borderRadius: BorderRadius.circular(4)),
                            child: Text('98% MATCH', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.violet)),
                          ),
                        ],
                      ),
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

  // --- 9. Integrations Section ---
  Widget _buildIntegrationsSection(bool isMobile) {
    final integrations = [
      {'name': 'GitHub', 'status': 'ACTIVE', 'desc': 'Sync pull requests, branches, and issues with Personal Access Tokens.'},
      {'name': 'NeonDB (PostgreSQL)', 'status': 'ACTIVE', 'desc': 'Scalable serverless database with native pgvector indexing.'},
      {'name': 'Neon Object Cloud (S3)', 'status': 'ACTIVE', 'desc': 'Optimized AVIF media storage and document archiving.'},
      {'name': 'Brevo Email', 'status': 'ACTIVE', 'desc': 'Transactional emails and OTP verification from verified sender.'},
    ];

    return Container(
      key: _integrationsKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INTEGRATIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Connected to the tools you already rely on', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 48),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E8DF)),
                  color: const Color(0xFFFCFDFA),
                ),
                child: Column(
                  children: List.generate(integrations.length, (index) {
                    final it = integrations[index];
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: index == integrations.length - 1 ? null : const Border(bottom: BorderSide(color: Color(0xFFE8EDE6))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
                            child: Center(child: Text(it['name']!.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it['name']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(it['desc']!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(6)),
                            child: Text(it['status']!, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.teal2)),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 10. Security & Privacy Section ---
  Widget _buildSecuritySection(bool isMobile) {
    final securityCards = [
      {'title': 'Company Isolation', 'desc': 'Multi-tenant architecture ensures strict row-level isolation between organizations.'},
      {'title': 'Immutable Audit Logs', 'desc': 'Every creation, approval, and data modification is stamped with user and IP.'},
      {'title': 'Role-Based Access', 'desc': 'Granular permissions per role (Owner, Admin, Project Manager, Member, Viewer).'},
      {'title': 'Secure Token Auth', 'desc': 'Encrypted JWT tokens with automatic rotation and 6-digit Brevo OTP resets.'},
    ];

    return Container(
      color: const Color(0xFFF2F5F0),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SECURITY & PRIVACY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Built for sensitive corporate operations', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 40),

              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 340,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 240,
                    ),
                    itemCount: securityCards.length,
                    itemBuilder: (context, index) {
                      final s = securityCards[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(color: const Color(0xFFFBFCF9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE0E7DD))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock_outline, size: 20, color: AppColors.teal),
                                const Spacer(),
                                Text(s['title']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                                const SizedBox(height: 6),
                                Text(s['desc']!, style: GoogleFonts.inter(fontSize: 11, height: 1.45, color: const Color(0xFF6D7B72))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 11. Pricing Section ---
  Widget _buildPricingSection(bool isMobile) {
    final plans = [
      {
        'name': 'Starter',
        'price': '₹0',
        'sub': 'Free forever',
        'desc': 'Ideal for solo founders getting started.',
        'btn': 'Start for free',
        'featured': false,
      },
      {
        'name': 'Team / Growth',
        'price': _isYearlyBilling ? '₹1,599' : '₹1,999',
        'sub': 'per month',
        'desc': 'For teams up to 25 managing active products.',
        'btn': 'Join Now',
        'featured': true,
      },
      {
        'name': 'Scale',
        'price': _isYearlyBilling ? '₹3,999' : '₹4,999',
        'sub': 'per month',
        'desc': 'Advanced RAG queries, priority queues & integrations.',
        'btn': 'Get Scale',
        'featured': false,
      },
      {
        'name': 'Enterprise',
        'price': '₹14,999',
        'sub': 'per month',
        'desc': 'Custom SLAs, dedicated AI quotas & enterprise support.',
        'btn': 'Contact sales',
        'featured': false,
      },
    ];

    return Container(
      key: _plansKey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSPARENT PLANS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Text('Predictable pricing that scales', style: GoogleFonts.inter(fontSize: isMobile ? 28 : 42, fontWeight: FontWeight.w600, letterSpacing: -1.2)),
                    ],
                  ),
                  // Billing Toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Monthly', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: !_isYearlyBilling ? AppColors.ink : AppColors.muted)),
                      Switch(
                        value: _isYearlyBilling,
                        activeTrackColor: AppColors.teal,
                        onChanged: (val) => setState(() => _isYearlyBilling = val),
                      ),
                      Text('Yearly', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _isYearlyBilling ? AppColors.ink : AppColors.muted)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFE9F2E3), borderRadius: BorderRadius.circular(6)),
                        child: Text('SAVE 20%', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF356744))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Plans Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 340,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 340,
                    ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final p = plans[index];
                      final isFeatured = p['featured'] == true;
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: isFeatured ? const Color(0xFFF6FAF4) : const Color(0xFFFCFDFA),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: isFeatured ? const Color(0xFF6FA28C) : const Color(0xFFE1E7DF), width: isFeatured ? 1.8 : 1.0),
                              boxShadow: isFeatured ? [BoxShadow(color: const Color(0xFF25573E).withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))] : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFeatured)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(999)),
                                    child: Text('MOST POPULAR', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                                  ),
                                Text(p['name'] as String, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(p['desc'] as String, style: GoogleFonts.inter(fontSize: 11, height: 1.4, color: AppColors.muted)),
                                const SizedBox(height: 18),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(p['price'] as String, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -1.0)),
                                    Text(p['sub'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: isFeatured
                                      ? ElevatedButton(
                                          onPressed: () => _openAuthModal(isSignUp: true),
                                          child: Text(p['btn'] as String),
                                        )
                                      : OutlinedButton(
                                          onPressed: () => _openAuthModal(isSignUp: true),
                                          child: Text(p['btn'] as String),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 12. FAQ Section ---
  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      {'q': 'What makes Centria different from traditional ERPs?', 'a': 'Centria is built specifically for modern software and IT services teams of 5-50 people. It avoids monolithic complexity by focusing on real work: projects, issues, knowledge, and approvals with AI grounding.'},
      {'q': 'How does Centria AI ground its answers in company documents?', 'a': 'Centria embeds your uploaded PDFs, Word docs, and markdown specs using 3072-dimensional Gemini embeddings stored in NeonDB pgvector. When asked a question, it retrieves the exact source passages and displays them side-by-side.'},
      {'q': 'Is our company data isolated and secure?', 'a': 'Yes. Every entity in Centria implements strict row-level company isolation. Your documents and vectors are never shared across tenants or used to train public foundation models.'},
      {'q': 'Can we connect our GitHub repositories?', 'a': 'Yes. Centria supports manual Personal Access Token linking without requiring complex OAuth setups. PRs and branches are automatically linked to corresponding task cards.'},
      {'q': 'How does the approval workflow operate?', 'a': 'Team members can submit release gates, scope changes, or document approvals. Designated approvers receive notifications and can approve or reject with decision notes.'},
    ];

    return Container(
      key: _resourcesKey,
      color: AppColors.paper,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 96, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FREQUENTLY ASKED QUESTIONS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              Text('Got questions? We have answers.', style: GoogleFonts.inter(fontSize: isMobile ? 32 : 46, fontWeight: FontWeight.w600, letterSpacing: -1.5)),
              const SizedBox(height: 40),

              Column(
                children: List.generate(faqs.length, (index) {
                  final isOpen = _expandedFaq == index;
                  return Container(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _expandedFaq = isOpen ? null : index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(faqs[index]['q']!, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                ),
                                Icon(isOpen ? Icons.remove : Icons.add, color: AppColors.teal, size: 20),
                              ],
                            ),
                          ),
                        ),
                        if (isOpen)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(faqs[index]['a']!, style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: const Color(0xFF68786E))),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 13. CTA Banner ---
  Widget _buildCtaBanner(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 32 : 56),
            decoration: BoxDecoration(
              color: const Color(0xFF163B32),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('READY TO SIMPLIFY WORK?', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.lime, letterSpacing: 1.0)),
                      const SizedBox(height: 12),
                      Text("Bring your team's work into one clear workspace.", style: GoogleFonts.inter(fontSize: isMobile ? 28 : 42, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -1.2)),
                      const SizedBox(height: 16),
                      Text("Join growing software teams who manage projects, documents, and approvals with Centria.", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC5D5CC))),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () => _openAuthModal(isSignUp: true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: const Color(0xFF183B30)),
                        child: const Text('Join Now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 14. Footer ---
  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(8)),
                            child: const Center(child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 18, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Centria', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  Text('Company work, connected.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Text('© 2026 Centria Platform. All rights reserved.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text('Privacy Policy', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                      Text('Terms of Service', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Interactive Auth Modal Dialog ---
class _AuthModalDialog extends StatefulWidget {
  final bool initialSignUp;
  const _AuthModalDialog({this.initialSignUp = false});

  @override
  State<_AuthModalDialog> createState() => _AuthModalDialogState();
}

class _AuthModalDialogState extends State<_AuthModalDialog> {
  late bool _isSignUp;
  bool _isForgotPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _companyNameController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_isForgotPassword) {
        if (!_otpSent) {
          if (_emailController.text.trim().isEmpty) {
            setState(() => _errorMessage = 'Please enter your work email.');
            return;
          }
          final res = await ApiService.forgotPassword(_emailController.text.trim());
          if (res['success']) {
            setState(() {
              _otpSent = true;
              _successMessage = 'Verification code sent to your email!';
            });
          } else {
            setState(() => _errorMessage = res['error'] ?? 'Failed to send OTP.');
          }
        } else {
          if (_otpController.text.trim().isEmpty) {
            setState(() => _errorMessage = 'Please enter the 6-digit verification code.');
            return;
          }
          if (_newPasswordController.text.length < 8) {
            setState(() => _errorMessage = 'New password must be at least 8 characters.');
            return;
          }
          if (_newPasswordController.text != _confirmPasswordController.text) {
            setState(() => _errorMessage = 'New password and re-typed password do not match.');
            return;
          }
          final res = await ApiService.resetPassword(
            email: _emailController.text.trim(),
            otpCode: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          );
          if (res['success']) {
            setState(() {
              _isForgotPassword = false;
              _isSignUp = false;
              _otpSent = false;
              _otpController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
              _successMessage = 'Password reset! You can now sign in.';
            });
          } else {
            setState(() => _errorMessage = res['error'] ?? 'Invalid code or password.');
          }
        }
      } else if (_isSignUp) {
        final compName = _companyNameController.text.trim();
        final fullName = _fullNameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (compName.isEmpty) {
          setState(() => _errorMessage = 'Please enter your company or workspace name.');
          return;
        }
        if (fullName.isEmpty) {
          setState(() => _errorMessage = 'Please enter your full name.');
          return;
        }
        if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
          setState(() => _errorMessage = 'Please enter a valid work email address.');
          return;
        }
        if (password.length < 8) {
          setState(() => _errorMessage = 'Password must be at least 8 characters long.');
          return;
        }

        final res = await AuthState().register(
          companyName: compName,
          fullName: fullName,
          email: email,
          password: password,
        );
        if (res['success']) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          setState(() => _errorMessage = res['error'] ?? 'Sign up failed.');
        }
      } else {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (email.isEmpty) {
          setState(() => _errorMessage = 'Please enter your email address.');
          return;
        }
        if (password.isEmpty) {
          setState(() => _errorMessage = 'Please enter your password.');
          return;
        }

        final res = await AuthState().login(email, password);
        if (res['success']) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          setState(() => _errorMessage = res['error'] ?? 'Invalid email or password.');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(8)),
                            child: const Center(child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 16, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Centria', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                _isForgotPassword
                    ? (_otpSent ? 'Create New Password' : 'Reset Password')
                    : (_isSignUp ? 'Create Workspace' : 'Sign In to Centria'),
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              Text(
                _isForgotPassword
                    ? (_otpSent
                        ? 'Enter the 6-digit code sent to your email and choose a new password.'
                        : 'Enter your account email to receive a 6-digit verification code.')
                    : (_isSignUp ? 'Get your team workspace up and running in 30 seconds.' : 'Enter your email and password to access your workspace.'),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.errorPale, borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                ),

              if (_successMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.greenPale, borderRadius: BorderRadius.circular(8)),
                  child: Text(_successMessage!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.greenDone, fontWeight: FontWeight.w600)),
                ),

              // Form fields
              if (_isSignUp) ...[
                TextField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(labelText: 'Company / Workspace Name', hintText: 'Acme Studio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Your Full Name', hintText: 'Jane Doe'),
                ),
                const SizedBox(height: 12),
              ],

              if (!_isForgotPassword || !_otpSent) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Work Email', hintText: 'you@company.com'),
                ),
                const SizedBox(height: 12),
              ],

              if (!_isForgotPassword) ...[
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', hintText: '••••••••'),
                ),
                // Forgot password button ONLY at sign in, never at create workspace
                if (!_isSignUp) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _isForgotPassword = true;
                        _otpSent = false;
                        _errorMessage = null;
                        _successMessage = null;
                      }),
                      child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 11, color: AppColors.teal)),
                    ),
                  ),
                ],
              ],

              // After asking OTP, then only ask new password and re-type password
              if (_isForgotPassword && _otpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '6-digit OTP Code', hintText: '123456'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password', hintText: 'At least 8 characters'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Re-type New Password', hintText: 'Confirm your new password'),
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isForgotPassword ? (_otpSent ? 'Update Password' : 'Send Verification Code') : (_isSignUp ? 'Create Workspace' : 'Sign In')),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    if (_isForgotPassword) {
                      _isForgotPassword = false;
                      _otpSent = false;
                    } else {
                      _isSignUp = !_isSignUp;
                    }
                    _errorMessage = null;
                    _successMessage = null;
                  }),
                  child: Text(
                    _isForgotPassword
                        ? '← Back to Sign In'
                        : (_isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Create one"),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
