import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_inbox_item/ui_inbox_item.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Заглушка списка на время загрузки.
class InboxShimmer extends StatelessWidget {
  const InboxShimmer({super.key});

  static const int _rows = 4;

  @override
  Widget build(BuildContext context) {
    return const UiKitShimmer(
      child: Padding(
        padding: EdgeInsets.all(UiSpacing.x5),
        child: UiKitShimmerLoading(
          height: UiInboxItem.minHeight * _rows,
          borderRadius: UiRadius.lgAll,
        ),
      ),
    );
  }
}
