import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/delete_pet/domain/delete_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/edit_pet/domain/edit_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/domain/pet_details_bloc.dart';
import 'package:tails_mobile/src/feature/push_notifications/domain/push_notifications_bloc.dart';

/// События, которые описывают себя в журнале: только идентификаторы и флаги, без личных данных.
void main() {
  Map<String, Object?> dataOf(Object event) => (event as TailsLoggable).toLogData();

  test('удаление питомца', () {
    expect(dataOf(const DeletePetEvent.deleteRequested(id: 7)), {'petId': 7});
  });

  test('загрузка карточки питомца', () {
    expect(dataOf(const PetDetailsEvent.fetchRequested(id: 3, silent: true)), {
      'petId': 3,
      'silent': true,
    });
  });

  test('смена статуса авторизации', () {
    expect(
      dataOf(const AuthEvent.authorizationStatusUpdated(newStatus: AuthorizationStatus.authorized)),
      {'status': 'authorized'},
    );
  });

  test('изменение авторизации для push', () {
    expect(
      dataOf(
        const PushNotificationsEvent.authorizationChanged(
          status: AuthorizationStatus.notAuthorized,
        ),
      ),
      {'status': 'notAuthorized'},
    );
  });

  test('вход не описывает себя: в нём телефон и код', () {
    expect(
      const AuthEvent.login(phoneNumber: '+79001112233', code: '1234'),
      isNot(isA<TailsLoggable>()),
    );
  });

  test('редактирование питомца не раскрывает данные, только факт смены фото', () {
    final event = EditPetEvent.editingRequested(
      petId: 5,
      pet: const EditPetModel(name: 'Бакс'),
      image: File('/tmp/a.jpg'),
    );

    expect(dataOf(event), {'petId': 5, 'hasNewImage': true});
  });
}
