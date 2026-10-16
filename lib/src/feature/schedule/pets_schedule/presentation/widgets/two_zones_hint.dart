import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule_hint_store.dart';

/// Подсказка над списком событий: кружок отмечает выполнение, остальная карточка открывает детали.
/// Показывается один раз, закрывается кнопкой «Понятно».
class TwoZonesHint extends StatefulWidget {
  /// [store] подменяют в тестах.
  TwoZonesHint({ScheduleHintStore? store, super.key}) : store = store ?? ScheduleHintStore();

  final ScheduleHintStore store;

  @override
  State<TwoZonesHint> createState() => _TwoZonesHintState();
}

class _TwoZonesHintState extends State<TwoZonesHint> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    unawaited(_load());
  }

  Future<void> _load() async {
    final seen = await widget.store.isSeen();

    if (mounted && !seen) {
      setState(() => _visible = true);
    }
  }

  void _dismiss() {
    setState(() => _visible = false);
    unawaited(widget.store.markSeen());
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.x3),
      child: UiNoticeBanner(
        icon: Icons.touch_app_outlined,
        title: l10n.scheduleTwoZonesHintTitle,
        text: l10n.scheduleTwoZonesHintText,
        actionLabel: l10n.scheduleTwoZonesHintAction,
        onAction: _dismiss,
      ),
    );
  }
}
