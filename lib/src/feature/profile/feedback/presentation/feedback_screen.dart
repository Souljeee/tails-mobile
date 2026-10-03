import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_compact_button/ui_compact_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_discard_guard/ui_discard_guard.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/photo_picking.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/feedback/domain/feedback_bloc.dart';

/// Максимальная длина сообщения совпадает с ограничением на сервере.
const int _maxMessageLength = 2000;

/// Обращение в поддержку: проблема, идея или вопрос.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({required this.topic, super.key});

  final FeedbackTopic topic;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final FeedbackBloc _bloc = FeedbackBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
  );

  final UiTextFieldController _messageController = UiTextFieldController();

  late FeedbackTopic _topic = widget.topic;

  File? _screenshot;

  bool get _hasMessage => _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bloc.close();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _attachScreenshot() async {
    try {
      final file = await pickPhoto(ImageSource.gallery);

      if (file != null && mounted) {
        setState(() => _screenshot = file);
      }
    } catch (_) {
      if (mounted) {
        showUiSnackBar(context, message: context.l10n.photoPickError);
      }
    }
  }

  void _send() {
    FocusScope.of(context).unfocus();

    _bloc.add(
      FeedbackEvent.sendRequested(
        topic: _topic,
        message: _messageController.text.trim(),
        screenshot: _screenshot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return UiDiscardGuard(
      hasChanges: _hasMessage || _screenshot != null,
      child: Scaffold(
        backgroundColor: context.uiPalette.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                child: UiSheetHeader(title: l10n.feedbackTitle, cancelLabel: l10n.cancel),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(UiSpacing.x5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.feedbackTopicLabel,
                        style: context.uiFonts.callout.copyWith(color: context.uiPalette.ink2),
                      ),
                      const SizedBox(height: UiSpacing.x2),
                      Wrap(
                        spacing: UiSpacing.x2,
                        runSpacing: UiSpacing.x2,
                        children: [
                          for (final topic in FeedbackTopic.values)
                            UiChip(
                              label: _topicLabel(l10n, topic),
                              selected: topic == _topic,
                              onTap: () => setState(() => _topic = topic),
                            ),
                        ],
                      ),
                      const SizedBox(height: UiSpacing.x4),
                      UiTextField(
                        controller: _messageController,
                        labelText: l10n.feedbackMessageLabel,
                        placeholderText: _placeholder(l10n),
                        minLines: 6,
                        maxLines: 10,
                        maxLength: _maxMessageLength,
                        keyboardType: TextInputType.multiline,
                        capitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: UiSpacing.x4),
                      _ScreenshotAttachment(
                        screenshot: _screenshot,
                        onAttach: _attachScreenshot,
                        onRemove: () => setState(() => _screenshot = null),
                      ),
                      const SizedBox(height: UiSpacing.x4),
                      const _DeviceNote(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UiSpacing.x5,
                  UiSpacing.x2,
                  UiSpacing.x5,
                  UiSpacing.x4,
                ),
                child: BlocConsumer<FeedbackBloc, FeedbackState>(
                  bloc: _bloc,
                  listener: (context, state) {
                    state.mapOrNull(
                      sent: (_) {
                        showUiSnackBar(
                          context,
                          message: l10n.feedbackSent,
                          kind: UiSnackBarKind.success,
                        );
                        Navigator.of(context).pop();
                      },
                      failure: (state) => showUiSnackBar(
                        context,
                        message: state.isRateLimited ? l10n.feedbackRateLimit : l10n.tryLater,
                      ),
                    );
                  },
                  builder: (context, state) {
                    final isSending = state.mapOrNull(sending: (_) => true) ?? false;

                    return UiButton.main(
                      label: l10n.feedbackSend,
                      isLoading: isSending,
                      onPressed: _hasMessage && !isSending ? _send : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _topicLabel(AppLocalizations l10n, FeedbackTopic topic) => switch (topic) {
    FeedbackTopic.problem => l10n.feedbackTopicProblem,
    FeedbackTopic.idea => l10n.feedbackTopicIdea,
    FeedbackTopic.question => l10n.feedbackTopicQuestion,
  };

  String _placeholder(AppLocalizations l10n) => switch (_topic) {
    FeedbackTopic.problem => l10n.feedbackPlaceholderProblem,
    FeedbackTopic.idea => l10n.feedbackPlaceholderIdea,
    FeedbackTopic.question => l10n.feedbackPlaceholderQuestion,
  };
}

class _ScreenshotAttachment extends StatelessWidget {
  const _ScreenshotAttachment({
    required this.screenshot,
    required this.onAttach,
    required this.onRemove,
  });

  final File? screenshot;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final file = screenshot;

    if (file == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: UiCompactButton(
          label: l10n.feedbackScreenshotAdd,
          icon: Icons.add,
          onPressed: onAttach,
        ),
      );
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: UiRadius.mdAll,
          child: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
        ),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: Icon(Icons.close, size: 18, color: palette.danger),
              label: Text(
                l10n.feedbackScreenshotRemove,
                style: context.uiFonts.callout.copyWith(color: palette.danger),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Пояснение, какие данные уйдут вместе с сообщением.
class _DeviceNote extends StatelessWidget {
  const _DeviceNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final repository = DependenciesScope.of(context).profileRepository;
    final noteStyle = fonts.footnote.copyWith(color: palette.ink2);

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.sunken, borderRadius: UiRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 20, color: palette.ink3),
            const SizedBox(width: UiSpacing.x2),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: noteStyle,
                  children: [
                    TextSpan(text: l10n.feedbackDeviceNotePrefix),
                    TextSpan(
                      text: '${repository.appVersion} (${repository.appBuildNumber})',
                      style: fonts.monoMeta.copyWith(color: palette.ink),
                    ),
                    TextSpan(text: l10n.feedbackDeviceNoteSuffix),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
