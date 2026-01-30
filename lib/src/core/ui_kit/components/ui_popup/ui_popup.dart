import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

enum UiPopupContentType { info, action }

Future<T?> showUiPopup<T>({
  required BuildContext context,
  required Widget child,
  bool showCloseButton = true,
}) {
  return showModalBottomSheet<T>(
    backgroundColor: context.uiColors.white,
    isScrollControlled: true,
    context: context,
    builder:
        (context) => Wrap(
          children: [
            Stack(
              children: [
                if (showCloseButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 20),
                    child: Align(
                      alignment: Alignment.topRight,
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
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 52,
                    left: 20,
                    right: 20,
                    bottom: 32,
                  ),
                  child: child,
                ),
              ],
            ),
          ],
        ),
  );
}
