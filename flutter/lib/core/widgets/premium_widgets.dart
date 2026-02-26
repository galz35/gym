import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ─── Animated Counter ──────────────────────────────────────────
/// Animates a number from 0 to the target value
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        String formatted;
        if (decimals > 0) {
          formatted = animValue.toStringAsFixed(decimals);
        } else {
          formatted = animValue.toInt().toString();
        }
        return Text(
          '$prefix$formatted$suffix',
          style:
              style ??
              const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
        );
      },
    );
  }
}

/// ─── Formatted Currency Counter ─────────────────────────────────
class AnimatedCurrencyCounter extends StatelessWidget {
  final double value;
  final String symbol;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCurrencyCounter({
    super.key,
    required this.value,
    this.symbol = 'C\$',
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        final parts = animValue.toStringAsFixed(2).split('.');
        final intPart = parts[0];
        final decPart = parts[1];

        // Add thousands separator
        final buffer = StringBuffer();
        for (int i = 0; i < intPart.length; i++) {
          if (i > 0 && (intPart.length - i) % 3 == 0) {
            buffer.write(',');
          }
          buffer.write(intPart[i]);
        }

        return Text(
          '$symbol${buffer.toString()}.$decPart',
          style:
              style ??
              const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
        );
      },
    );
  }
}

/// ─── Glassmorphic Card ──────────────────────────────────────────
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tintColor;
  final double borderRadius;
  final double opacity;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
    this.tintColor,
    this.borderRadius = AppRadius.lg,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = tintColor ?? (isDark ? Colors.white : Colors.white);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ─── Animated FAB ──────────────────────────────────────────────
class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Duration delay;

  const AnimatedFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.label = '',
    this.delay = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    );
    _rotation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: RotationTransition(
        turns: _rotation,
        child: widget.label.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: widget.onPressed,
                icon: Icon(widget.icon, size: 20),
                label: Text(widget.label),
              )
            : FloatingActionButton(
                onPressed: widget.onPressed,
                child: Icon(widget.icon),
              ),
      ),
    );
  }
}

/// ─── Staggered Fade In ──────────────────────────────────────────
/// Wraps children with staggered fade-in + slide-up animation
class StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;

  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 80),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: 500 + (index * baseDelay.inMilliseconds).clamp(0, 400),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ─── Pulse Dot ──────────────────────────────────────────────────
/// Animated pulsing dot for notifications
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({super.key, this.color = AppColors.primary, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
        return Container(
          width: widget.size + (4 * _controller.value),
          height: widget.size + (4 * _controller.value),
          decoration: BoxDecoration(
            color: widget.color.withValues(
              alpha: 1.0 - (0.4 * _controller.value),
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─── Gradient Border Card ───────────────────────────────────────
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.gradientColors = const [AppColors.primary, AppColors.primaryLight],
    this.borderWidth = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(AppRadius.lg + borderWidth),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: child,
      ),
    );
  }
}

/// ─── Scale on Tap ──────────────────────────────────────────────
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: widget.scaleDown,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
