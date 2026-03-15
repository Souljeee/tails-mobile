import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

enum UiPopupContentType { info, action }

Future<T?> showUiPopup<T>({
  required BuildContext context,
  required Widget child,
  bool showCloseButton = true,
  bool isDismissible = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    backgroundColor: context.uiColors.white,
    isScrollControlled: true,
    context: context,
    isDismissible: isDismissible,
    useRootNavigator: useRootNavigator,
    builder:
        (context) => Wrap(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 52,
                    left: 20,
                    right: 20,
                    bottom: 32,
                  ),
                  child: child,
                ),
                if (showCloseButton)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 32,
                        color: context.uiColors.black30,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
  );
}
