import 'package:flutter/material.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outlined,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? callback =
        enabled && !isLoading ? onPressed : null;

    final Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (isLoading || icon != null) const SizedBox(width: 8),
        Text(label),
      ],
    );

    final Widget button;

    switch (variant) {
      case CustomButtonVariant.primary:
        button = ElevatedButton(
          onPressed: callback,
          child: content,
        );
      case CustomButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: callback,
          child: content,
        );
      case CustomButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: callback,
          child: content,
        );
    }

    if (expand) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}