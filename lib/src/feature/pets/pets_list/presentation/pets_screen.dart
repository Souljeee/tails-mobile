import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/add_pet_modal.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetModal()),
          );
        },
        backgroundColor: context.uiColors.orangePrimary,
        child: Icon(
          Icons.add,
          color: context.uiColors.white,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PetsListBloc, PetsListState>(
          bloc: _petsListBloc,
          builder: (context, state) {
            return state.map(
              loading: (_) => const _PetsShimmer(),
              success: (state) => _PetsList(pets: state.pets),
              error: (_) => _FetchingError(
                onRetry: () {
                  _petsListBloc.add(const PetsListEvent.fetchRequested());
                },
              ),
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
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _PetItem(pet: pets[index]);
            },
          );
  }
}

class _PetItem extends StatelessWidget {
  final PetModel pet;

  const _PetItem({required this.pet});

  String _getPetAge(BuildContext context) {
    final age = DateTime.now().difference(pet.birthday).inDays;

    final years = age ~/ 365;
    final months = (age % 365) ~/ 30;

    if (years > 0) {
      return context.l10n.petAgeYearsAndMonths(years, months);
    } else {
      return context.l10n.petAgeMonths(months);
    }
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
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                pet.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
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
                    '${pet.petType.getLocalizedName(context.l10n)} · ${_getPetAge(context)}',
                    style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.brown),
                    overflow: TextOverflow.ellipsis,
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
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 120),
          SvgPicture.asset(
            context.uiIcons.emptyDogHouse.keyName,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'Список ваших питомцев пуст',
            style: context.uiFonts.header24Semibold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Расскажите нам о ваших любимцах',
            style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.brown),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PetsShimmer extends StatelessWidget {
  const _PetsShimmer();

  @override
  Widget build(BuildContext context) {
    return UiKitShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: UiKitShimmerLoading(
                height: 100,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FetchingError extends StatelessWidget {
  final VoidCallback onRetry;

  const _FetchingError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 120),
          SvgPicture.asset(
            context.uiIcons.sadDoc.keyName,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: context.uiFonts.header24Semibold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Повторите позднее',
            style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.brown),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          UiButton.main(
            label: 'Повторить',
            onPressed: onRetry,
          ),
        ],
      ),
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
