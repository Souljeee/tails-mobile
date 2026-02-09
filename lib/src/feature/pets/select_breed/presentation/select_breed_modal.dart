import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/domain/breeds_bloc.dart';

class SelectBreedModal extends StatefulWidget {
  final PetTypeEnum petType;

  const SelectBreedModal({
    required this.petType,
    super.key,
  });

  @override
  State<SelectBreedModal> createState() => _SelectBreedModalState();
}

class _SelectBreedModalState extends State<SelectBreedModal> {
  final UiTextFieldController _searchController = UiTextFieldController();
  late final BreedsBloc _breedsBloc =
      BreedsBloc(petRepository: DependenciesScope.of(context).petRepository);
  List<BreedModel> _showedBreeds = [];

  @override
  void initState() {
    _breedsBloc.add(BreedsEvent.fetchRequested(petType: widget.petType));

    _searchController.addListener(_searchListener);

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _breedsBloc.close();

    super.dispose();
  }

  void _searchListener() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return;
    }

    setState(() {
      _showedBreeds = _breedsBloc.state.maybeMap(
        success: (state) =>
            state.breeds.where((breed) => breed.name.toLowerCase().contains(query)).toList(),
        orElse: () => [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.white,
      appBar: AppBar(
        title: Text(
          'Выберите породу',
          style: context.uiFonts.header24Semibold,
        ),
        backgroundColor: context.uiColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: BlocConsumer<BreedsBloc, BreedsState>(
          bloc: _breedsBloc,
          listener: (context, state) {
            state.mapOrNull(
              success: (state) {
                setState(() {
                  _showedBreeds = state.breeds;
                });
              },
            );
          },
          builder: (context, state) {
            return state.maybeMap(
              error: (_) => _FetchingError(
                onRetry: () {
                  _breedsBloc.add(BreedsEvent.fetchRequested(petType: widget.petType));
                },
              ),
              loading: (_) => const _BreedsShimmer(),
              orElse: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: UiTextField(
                      controller: _searchController,
                      placeholderText: 'Найти породу...',
                      placeholderStyle: context.uiFonts.text16Regular.copyWith(
                        color: context.uiColors.brown,
                      ),
                      trailingIcon: Icon(
                        Icons.search,
                        size: 28,
                        color: context.uiColors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _showedBreeds.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _BreedItem(breed: _showedBreeds[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BreedItem extends StatelessWidget {
  final BreedModel breed;

  const _BreedItem({required this.breed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(breed);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Row(
            children: [
              BreedAvatar(name: breed.name),
              const SizedBox(width: 16),
              Text(
                breed.name,
                style: context.uiFonts.text16Medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreedAvatar extends StatelessWidget {
  final String name;

  const BreedAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.uiColors.black5, shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(8.16),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: context.uiFonts.text16Medium.copyWith(
                color: context.uiColors.black50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreedsShimmer extends StatelessWidget {
  const _BreedsShimmer();

  @override
  Widget build(BuildContext context) {
    return UiKitShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: UiKitShimmerLoading(
                height: 60,
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
