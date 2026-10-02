import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/edit_pet_dto.dart';

void main() {
  test('EditPetDto отправляет стерилизацию, в том числе снятую', () {
    expect(const EditPetDto(hasCastration: true).toJson(), {'has_castration': true});
    expect(const EditPetDto(hasCastration: false).toJson(), {'has_castration': false});
  });

  test('EditPetDto не отправляет стерилизацию, если она не задана', () {
    expect(const EditPetDto(name: 'Чарли').toJson().containsKey('has_castration'), isFalse);
  });
}
