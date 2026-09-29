import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Заглушка вкладки «Профиль»: дизайн экрана появится позже.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: context.uiPalette.canvas);
  }
}
