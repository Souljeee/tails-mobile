import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';

/// Обращение пользователя. Данные приложения и телефона добавляет репозиторий.
class FeedbackModel extends Equatable {
  const FeedbackModel({required this.topic, required this.message, this.screenshot});

  final FeedbackTopic topic;
  final String message;
  final File? screenshot;

  @override
  List<Object?> get props => [topic, message, screenshot?.path];
}
