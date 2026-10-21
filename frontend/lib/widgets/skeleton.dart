import 'package:flutter/material.dart';

/// Apple-grade Shimmer Controller & Wrapper
class CentriaShimmer extends StatefulWidget {
  final Widget child;
  const CentriaShimmer({super.key, required this.child});

  @override
  State<CentriaShimmer> createState() => _CentriaShimmerState();
}

class _CentriaShimmerState extends State<CentriaShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + (_controller.value * 4.0), -0.3),
              end: Alignment(-1.0 + (_controller.value * 4.0), 0.3),
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// A precision rounded skeleton box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circular skeleton placeholder (for avatars, badges, etc.)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton screen for HomeScreen while user profile is loading
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CentriaShimmer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar skeleton
                const SkeletonCircle(size: 84),
                const SizedBox(height: 32),

                // Welcome title skeleton
                const SkeletonBox(width: 280, height: 32, borderRadius: 10),
                const SizedBox(height: 20),

                // User details card skeleton
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SkeletonBox(width: 170, height: 18, borderRadius: 6),
                      const SizedBox(height: 12),
                      const SkeletonBox(width: 220, height: 14, borderRadius: 6),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          SkeletonBox(width: 70, height: 14, borderRadius: 6),
                          SkeletonBox(width: 80, height: 14, borderRadius: 6),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Logout button skeleton
                const SkeletonBox(width: 160, height: 48, borderRadius: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton overlay for Form action / verification loading
class FormActionSkeleton extends StatelessWidget {
  const FormActionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CentriaShimmer(
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
