import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/domain/delete_account_bloc.dart';
import 'package:tails_mobile/src/feature/profile/edit_profile/domain/edit_profile_bloc.dart';
import 'package:tails_mobile/src/feature/profile/feedback/domain/feedback_bloc.dart';

import '../../../helpers/profile_fakes.dart';
import '../../../helpers/recording_analytics_sink.dart';

void main() {
  late RecordingAnalyticsSink sink;
  late FakeProfileRepository repository;

  setUp(() {
    sink = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [sink]);
    repository = FakeProfileRepository();
  });

  tearDown(TailsAnalytics.reset);

  group('EditProfileBloc', () {
    late EditProfileBloc bloc;

    setUp(() => bloc = EditProfileBloc(profileRepository: repository));
    tearDown(() => bloc.close());

    test('смена имени: profile_updated без самого имени', () async {
      bloc.add(const EditProfileEvent.saveRequested(name: 'Мария'));
      await pumpEventQueue();

      expect(sink.names, ['profile_updated']);
      expect(sink.events.single.parameters, {'changed': 'name'});
      expect('${sink.events.single}', isNot(contains('Мария')));
    });

    test('новое фото: add, если фото не было, и change, если было', () async {
      bloc
        ..add(EditProfileEvent.saveRequested(avatar: File('a.jpg')))
        ..add(EditProfileEvent.saveRequested(avatar: File('a.jpg'), hadAvatar: true))
        ..add(const EditProfileEvent.saveRequested(removeAvatar: true, hadAvatar: true));
      await pumpEventQueue();

      expect(
        sink.events
            .where((e) => e.name == 'profile_photo_action')
            .map((e) => e.parameters['action']),
        ['add', 'change', 'remove'],
      );
    });

    test('ошибка сохранения не отправляет события', () async {
      repository.updateError = Exception('x');

      bloc.add(const EditProfileEvent.saveRequested(name: 'Мария'));
      await pumpEventQueue();

      expect(sink.events, isEmpty);
    });
  });

  group('FeedbackBloc', () {
    late FeedbackBloc bloc;

    setUp(() => bloc = FeedbackBloc(profileRepository: repository));
    tearDown(() => bloc.close());

    test('отправлено: тема без текста сообщения', () async {
      bloc.add(
        const FeedbackEvent.sendRequested(
          topic: FeedbackTopic.idea,
          message: 'Мой секретный текст',
        ),
      );
      await pumpEventQueue();

      expect(sink.events.single.name, 'feedback_sent');
      expect(sink.events.single.parameters, {'category': 'idea'});
      expect('${sink.events.single}', isNot(contains('секретный')));
    });

    test('лимит запросов и прочие ошибки', () async {
      repository.feedbackError = const FeedbackRateLimitException();
      bloc.add(const FeedbackEvent.sendRequested(topic: FeedbackTopic.problem, message: 'x'));
      await pumpEventQueue();
      repository.feedbackError = Exception('x');
      bloc.add(const FeedbackEvent.sendRequested(topic: FeedbackTopic.problem, message: 'x'));
      await pumpEventQueue();

      expect(sink.names, ['feedback_failed', 'feedback_failed']);
      expect(sink.events[0].parameters, {'reason': 'rate_limited'});
      expect(sink.events[1].parameters, {'reason': 'unknown'});
    });
  });

  group('DeleteAccountBloc', () {
    late FakePetRepository pets;
    late DeleteAccountBloc bloc;

    setUp(() {
      pets = FakePetRepository()
        ..pets = [fakePet(1, 'Бакс'), fakePet(2, 'Мурка')]
        ..knownPetsCount = 2;
      bloc = DeleteAccountBloc(profileRepository: repository, petRepository: pets);
    });

    tearDown(() => bloc.close());

    test('начало и успешное удаление: количество питомцев в корзине', () async {
      bloc
        ..add(const DeleteAccountEvent.started())
        ..add(const DeleteAccountEvent.deleteRequested(code: '1234'));
      await pumpEventQueue();

      expect(sink.names, ['account_delete_started', 'account_deleted']);
      expect(sink.events[1].parameters, {'pets_count': '2-3'});
      expect('${sink.events}', isNot(contains('Бакс')));
      expect('${sink.events}', isNot(contains('1234')));
    });

    test('неверный код и другая ошибка', () async {
      repository.deleteError = const InvalidDeletionCodeException(message: 'bad');
      bloc.add(const DeleteAccountEvent.deleteRequested(code: '0000'));
      await pumpEventQueue();
      repository.deleteError = Exception('x');
      bloc.add(const DeleteAccountEvent.deleteRequested(code: '0000'));
      await pumpEventQueue();

      expect(sink.names, ['account_delete_failed', 'account_delete_failed']);
      expect(sink.events[0].parameters, {'reason': 'invalid_code'});
      expect(sink.events[1].parameters, {'reason': 'unknown'});
    });
  });
}
