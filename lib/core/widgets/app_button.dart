import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unorive/core/theme/colors.dart';
import 'package:unorive/core/theme/spacing.dart';

/// An animated button that scales down on tap and triggers haptics.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isPrimary = true,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height = 56.0,
  });

  /// Factory constructor for Primary Button style.
  factory AppButton.primary({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    double height = 56.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed ?? () {},
      isPrimary: true,
      isLoading: isLoading,
      isEnabled: isEnabled && onPressed != null,
      icon: icon,
      width: width,
      height: height,
      key: key,
    );
  }

  /// Factory constructor for Secondary Button style.
  factory AppButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    double? width,
    double height = 56.0,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed ?? () {},
      isPrimary: false,
      isLoading: isLoading,
      isEnabled: isEnabled && onPressed != null,
      icon: icon,
      width: width,
      height: height,
      key: key,
    );
  }

  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final double? width;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.isEnabled && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<UnoriveColors>();

    final primaryBg = theme.colorScheme.primary;
    final secondaryBg = customColors?.glassSurface ?? AppColors.darkSurfaceGlass;

    final primaryTextColor = theme.colorScheme.onPrimary;
    final secondaryTextColor = theme.colorScheme.onSurface;

    final isDisabled = !widget.isEnabled;

    Color buttonColor;
    Color textColor;
    BorderSide borderSide;

    if (widget.isPrimary) {
      buttonColor = isDisabled ? primaryBg.withValues(alpha: 0.4) : primaryBg;
      textColor = isDisabled ? primaryTextColor.withValues(alpha: 0.5) : primaryTextColor;
      borderSide = BorderSide.none;
    } else {
      buttonColor = isDisabled ? secondaryBg.withValues(alpha: 0.2) : secondaryBg;
      textColor = isDisabled ? secondaryTextColor.withValues(alpha: 0.4) : secondaryTextColor;
      borderSide = BorderSide(
        color: customColors?.border.withValues(alpha: isDisabled ? 0.3 : 1.0) ??
            AppColors.borderDark,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: borderSide != BorderSide.none
                ? Border.fromBorderSide(borderSide)
                : null,
            boxShadow: widget.isPrimary && !isDisabled && !widget.isLoading
                ? [
                    BoxShadow(
                      color: primaryBg.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(color: textColor, size: 20),
                          child: widget.icon!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
