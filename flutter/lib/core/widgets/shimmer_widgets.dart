import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ─── Shimmer Effect Base ────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// ─── Shimmer KPI Card ───────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 36, height: 36, borderRadius: AppRadius.sm),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: 80, height: 28, borderRadius: 6),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 60, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// ─── Shimmer List Item ──────────────────────────────────────────
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 44, height: 44, borderRadius: AppRadius.md),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: AppSpacing.sm),
                ShimmerBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          const ShimmerBox(width: 60, height: 20, borderRadius: AppRadius.full),
        ],
      ),
    );
  }
}

/// ─── Shimmer List ───────────────────────────────────────────────
class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, index) => const ShimmerListItem(),
    );
  }
}

/// ─── Shimmer Dashboard ──────────────────────────────────────────
class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // KPI row 1
          const Row(
            children: [
              Expanded(child: ShimmerCard()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: ShimmerCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // KPI row 2
          const Row(
            children: [
              Expanded(child: ShimmerCard()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: ShimmerCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Chart placeholder
          ShimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: AppRadius.lg,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // List items
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: ShimmerListItem(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Shimmer Product Grid ───────────────────────────────────────
class ShimmerProductGrid extends StatelessWidget {
  const ShimmerProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 4,
      itemBuilder: (_, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 100, height: 14, borderRadius: 4),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 60, height: 16, borderRadius: 4),
                      ShimmerBox(width: 24, height: 24, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
