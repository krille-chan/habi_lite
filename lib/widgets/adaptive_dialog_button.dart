import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final bool isDestructive;

  const AdaptiveDialogButton({
    required this.onPressed,
    required this.label,
    this.isDestructive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: isDestructive ? theme.colorScheme.error : null,
    );
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(
          onPressed: onPressed,
          child: Text(
            label,
            style: textStyle,
          ),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: textStyle,
          ),
        );
    }
  }
}
