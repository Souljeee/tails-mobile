import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/pets_chip_list.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/schedule_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  static final _mockedPetList = [
    PetModel(
      id: 1,
      petType: PetTypeEnum.dog,
      name: 'Барсик',
      breed: const BreedModel(id: 1, name: 'Лабрадор'),
      gender: 'male',
      birthday: DateTime(2020, 5, 12),
      color: 'Палевый',
      image:
          'https://img.freepik.com/free-photo/portrait-beautiful-purebred-pussycat-with-shorthair-orange-collar-neck-sitting-floor-reacting-camera-flash-scared-looking-light-indoor_8353-12551.jpg?semt=ais_rp_progressive&w=740&q=80',
      createdAt: DateTime(2020, 6, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    PetModel(
      id: 2,
      petType: PetTypeEnum.cat,
      name: 'Мурка',
      breed: const BreedModel(id: 2, name: 'Британская'),
      gender: 'female',
      birthday: DateTime(2021, 3, 8),
      color: 'Серый',
      image:
          'https://img.freepik.com/free-photo/portrait-beautiful-purebred-pussycat-with-shorthair-orange-collar-neck-sitting-floor-reacting-camera-flash-scared-looking-light-indoor_8353-12551.jpg?semt=ais_rp_progressive&w=740&q=80',
      createdAt: DateTime(2021, 4, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    PetModel(
      id: 3,
      petType: PetTypeEnum.dog,
      name: 'Рекс',
      breed: const BreedModel(id: 3, name: 'Немецкая овчарка'),
      gender: 'male',
      birthday: DateTime(2019, 11, 20),
      color: 'Чёрно-рыжий',
      image:
          'https://img.freepik.com/free-photo/portrait-beautiful-purebred-pussycat-with-shorthair-orange-collar-neck-sitting-floor-reacting-camera-flash-scared-looking-light-indoor_8353-12551.jpg?semt=ais_rp_progressive&w=740&q=80',
      createdAt: DateTime(2019, 12, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    PetModel(
      id: 4,
      petType: PetTypeEnum.cat,
      name: 'Васька',
      breed: const BreedModel(id: 4, name: 'Мейн-кун'),
      gender: 'male',
      birthday: DateTime(2022, 7, 15),
      color: 'Рыжий',
      image:
          'https://img.freepik.com/free-photo/portrait-beautiful-purebred-pussycat-with-shorthair-orange-collar-neck-sitting-floor-reacting-camera-flash-scared-looking-light-indoor_8353-12551.jpg?semt=ais_rp_progressive&w=740&q=80',
      createdAt: DateTime(2022, 8, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    PetModel(
      id: 5,
      petType: PetTypeEnum.dog,
      name: 'Лайка',
      breed: const BreedModel(id: 5, name: 'Хаски'),
      gender: 'female',
      birthday: DateTime(2023, 1, 10),
      color: 'Серо-белый',
      image:
          'https://img.freepik.com/free-photo/portrait-beautiful-purebred-pussycat-with-shorthair-orange-collar-neck-sitting-floor-reacting-camera-flash-scared-looking-light-indoor_8353-12551.jpg?semt=ais_rp_progressive&w=740&q=80',
      createdAt: DateTime(2023, 2, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();

  String get formattedSelectedDate => DateFormat.MMMMd().format(selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.grayMain,
      appBar: const UiAppBar.baseToolBar(title: 'Календарь'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add event
        },
        backgroundColor: context.uiColors.orangePrimary,
        child: Icon(Icons.add, color: context.uiColors.white),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetsChipList(
                    pets: ScheduleScreen._mockedPetList,
                    onSelectedPetsChanged: (selectedPetIds) {},
                  ),
                  const SizedBox(height: 24),
                  ScheduleCalendar(
                    selectedDate: selectedDate,
                    onDateTap: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(formattedSelectedDate, style: context.uiFonts.header24Semibold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
