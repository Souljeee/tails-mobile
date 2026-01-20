import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.grayMain,
      appBar: UiAppBar.baseToolBar(
        title: 'Мои питомцы',
        actions: [
          _NotificationsButton(
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text('Мои питомцы'),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NotificationsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.uiColors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(12),
        child: Icon(
          Icons.notifications,
          color: context.uiColors.black100,
        ),
      ),
    );
  }
}
