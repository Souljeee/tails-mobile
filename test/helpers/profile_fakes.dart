import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/feedback_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';

/// Подмены репозиториев профиля и питомцев для тестов блоков и экранов.
class FakeProfileRepository extends Fake implements ProfileRepository {
  FakeProfileRepository();

  // ignore: close_sinks
  final events = StreamController<ProfileRepositoryEvent>.broadcast();
  final calls = <String>[];

  @override
  bool canAttachLogs = false;

  ProfileModel profile = ProfileModel(
    id: 'u1',
    phoneNumber: '79990001122',
    name: 'Анна',
    notificationSettings: NotificationSettingsModel.allEnabled(),
  );
  NotificationSettingsModel settings = NotificationSettingsModel.allEnabled();
  bool blocked = false;

  Exception? profileError;
  Exception? setNotificationError;
  Exception? sendCodeError;
  Exception? deleteError;
  Exception? feedbackError;
  Exception? updateError;

  /// Если задан, ответ на переключение ждёт этого completer.
  Completer<void>? setNotificationGate;
  Completer<void>? feedbackGate;
  Completer<void>? deleteGate;

  @override
  Stream<ProfileRepositoryEvent> get eventStream => events.stream;

  @override
  String get appVersion => '1.2.3';

  @override
  String get appBuildNumber => '45';

  @override
  Future<ProfileModel> getProfile() async {
    calls.add('getProfile');

    if (profileError != null) {
      throw profileError!;
    }

    return profile;
  }

  @override
  Future<ProfileModel> updateProfile({String? name, File? avatar}) async {
    calls.add('updateProfile(name: $name, avatar: ${avatar?.path})');

    if (updateError != null) {
      throw updateError!;
    }

    return profile;
  }

  @override
  Future<void> deleteAvatar() async => calls.add('deleteAvatar');

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async => settings;

  @override
  Future<NotificationSettingsModel> setNotificationEnabled({
    required NotificationCategory category,
    required bool enabled,
  }) async {
    calls.add('set(${category.name}, $enabled)');

    await setNotificationGate?.future;

    if (setNotificationError != null) {
      throw setNotificationError!;
    }

    return settings = settings.copyWith(category: category, value: enabled);
  }

  @override
  Future<bool> isNotificationBlockedBySystem() async => blocked;

  @override
  Future<int> sendDeletionCode() async {
    calls.add('sendDeletionCode');

    if (sendCodeError != null) {
      throw sendCodeError!;
    }

    return 60;
  }

  @override
  Future<void> deleteAccount({required String code}) async {
    calls.add('deleteAccount($code)');

    await deleteGate?.future;

    if (deleteError != null) {
      throw deleteError!;
    }
  }

  @override
  Future<void> sendFeedback(FeedbackModel feedback) async {
    calls.add(
      'sendFeedback(${feedback.topic.name}, ${feedback.message}'
      '${feedback.attachLogs ? ', logs' : ''})',
    );

    await feedbackGate?.future;

    if (feedbackError != null) {
      throw feedbackError!;
    }
  }
}

class FakePetRepository extends Fake implements PetRepository {
  // ignore: close_sinks
  final events = StreamController<PetsRepositoryEventsEvent>.broadcast();

  List<PetModel> pets = [];
  Exception? error;

  @override
  int? knownPetsCount;

  @override
  Stream<PetsRepositoryEventsEvent> get eventStream => events.stream;

  @override
  Future<List<PetModel>> getPets() async {
    if (error != null) {
      throw error!;
    }

    return pets;
  }
}

PetModel fakePet(int id, String name) => PetModel(
  id: id,
  petType: PetTypeEnum.dog,
  name: name,
  breed: const BreedModel(id: 1, name: 'Метис или не знаю'),
  gender: 'male',
  birthday: DateTime(2020),
  color: 'рыжий',
  image: '',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class ThrowingSettingsRepository extends FakeProfileRepository {
  @override
  Future<NotificationSettingsModel> getNotificationSettings() async => throw Exception('offline');
}
