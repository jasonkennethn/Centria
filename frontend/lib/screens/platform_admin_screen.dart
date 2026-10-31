import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

class PlatformAdminScreen extends StatefulWidget {
  const PlatformAdminScreen({super.key});

  @override
  State<PlatformAdminScreen> createState() => _PlatformAdminScreenState();
}

class _PlatformAdminScreenState extends State<PlatformAdminScreen> {
  Map<String, dynamic>? _adminData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getPlatformAdminOverview();
    if (mounted) {
      setState(() {
        _adminData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentCompanies = (_adminData?['recent_companies'] as List?) ?? [];

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
              runSpacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Platform Administration', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                    const SizedBox(height: 4),
                    Text('Global tenancy overview and system statistics (jasonkennethn@gmail.com).', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
                  child: Text('SUPERADMIN ACCESS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            if (_isLoading)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 95,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: 3,
                itemBuilder: (ctx, i) => const SkeletonLoader(width: double.infinity, height: 95, borderRadius: 16),
              )
            else
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 95,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                children: [
                  _statCard('Total Companies', '${_adminData?['total_companies'] ?? 0}', Icons.domain),
                  _statCard('Active Tenants', '${_adminData?['active_companies'] ?? 0}', Icons.verified),
                  _statCard('Total Users', '${_adminData?['total_users'] ?? 0}', Icons.people),
                ],
              ),
            const SizedBox(height: 32),

            Text('Recently Created Workspaces', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
            const SizedBox(height: 16),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: AppleGlass.decoration(radius: 24),
                    child: ListView.builder(
                      itemCount: recentCompanies.length,
                      itemBuilder: (context, idx) {
                        final c = recentCompanies[idx];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.04))),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(10)),
                                child: Center(child: Text(c['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                                    Text('Slug: ${c['slug']} · Plan: ${c['plan']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(6)),
                                child: Text((c['plan'] as String).toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.teal2)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: AppleGlass.decoration(radius: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -1.0)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: AppColors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
