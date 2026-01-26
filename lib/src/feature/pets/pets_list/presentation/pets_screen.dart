import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/pets_list/domain/pets_list_bloc.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late final PetsListBloc _petsListBloc =
      PetsListBloc(petRepository: DependenciesScope.of(context).petRepository);

  @override
  void initState() {
    super.initState();

    _petsListBloc.add(const PetsListEvent.fetchRequested());
  }

  @override
  void dispose() {
    _petsListBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.grayMain,
      appBar: UiAppBar.baseToolBar(
        title: 'Мои питомцы',
        actions: [
          _NotificationsButton(
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: context.uiColors.orangePrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<PetsListBloc, PetsListState>(
          bloc: _petsListBloc,
          builder: (context, state) {
            return state.map(
              loading: (_) => const SizedBox.shrink(),
              success: (state) => _PetsList(pets: state.pets),
              error: (_) => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class _PetsList extends StatelessWidget {
  final List<PetModel> pets;

  const _PetsList({required this.pets});

  @override
  Widget build(BuildContext context) {
    return pets.isEmpty
        ? const _PetsEmptyList()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return _PetItem(pet: pets[index]);
            },
          );
  }
}

class _PetItem extends StatelessWidget {
  final PetModel pet;

  const _PetItem({required this.pet});

  String get petAge {
    final age = DateTime.now().difference(pet.birthday).inDays;

    final years = age ~/ 365;
    final months = (age % 365) ~/ 30;

    return years > 0 ? '$years лет $months месяцев' : '$months месяцев';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.uiColors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Image.network(pet.image),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: context.uiFonts.header24Semibold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward_ios),
                        iconSize: 16,
                        color: context.uiColors.black100.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pet.petType.name} · $petAge',
                    style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.brown),
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

class _PetsEmptyList extends StatelessWidget {
  const _PetsEmptyList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Список ваших питомцев пуст'),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NotificationsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.uiColors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsetsGeometry.all(12),
        child: Icon(
          Icons.notifications,
          color: context.uiColors.black100,
        ),
      ),
    );
  }
}
