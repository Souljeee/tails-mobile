import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/widgets/pet_details_content.dart';

PetDetailsModel _pet({bool castrated = true}) => PetDetailsModel(
  id: 1,
  petType: PetTypeEnum.dog,
  name: 'рекс',
  breed: const BreedModel(id: 2, name: 'Корги'),
  gender: PetSexEnum.male,
  birthday: DateTime(2020, 1, 15),
  color: 'рыжий',
  image: '',
  weight: 14.5,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  hasCastration: castrated,
);

Widget _app(Widget child) => MaterialApp(
  theme: UiThemeData.lightTheme,
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('PetDetailsContent shows real pet data and empty events hint', (tester) async {
    await tester.pumpWidget(_app(PetDetailsContent(pet: _pet(), upcomingEvents: const [])));

    expect(find.text('Рекс'), findsOneWidget);
    expect(find.text('Собака · Корги'), findsOneWidget);
    expect(find.text('14,5 кг'), findsOneWidget);
    expect(find.text('рыжий'), findsOneWidget);
    expect(find.text('Кастрирован'), findsOneWidget);
    expect(find.text('В ближайшие две недели событий нет'), findsOneWidget);
  });

  testWidgets('PetDetailsContent hides castration row when not castrated', (tester) async {
    await tester.pumpWidget(
      _app(PetDetailsContent(pet: _pet(castrated: false), upcomingEvents: const [])),
    );

    expect(find.text('Кастрирован'), findsNothing);
  });
}
