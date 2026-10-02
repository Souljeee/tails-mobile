import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_alphabet_index/ui_alphabet_index.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/domain/breed_sections.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/domain/breeds_bloc.dart';

/// Страница выбора породы. Закрывается, возвращая выбранную [BreedModel].
///
/// Открывать через `SelectBreedRoute(...).push<BreedModel>(context)`.
class SelectBreedModal extends StatefulWidget {
  final PetTypeEnum petType;

  /// Выбранная ранее порода: отмечается галочкой.
  final int? selectedBreedId;

  const SelectBreedModal({required this.petType, this.selectedBreedId, super.key});

  @override
  State<SelectBreedModal> createState() => _SelectBreedModalState();
}

class _SelectBreedModalState extends State<SelectBreedModal> {
  final UiTextFieldController _searchController = UiTextFieldController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  late final BreedsBloc _breedsBloc = BreedsBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );

  @override
  void initState() {
    super.initState();

    _breedsBloc.add(BreedsEvent.fetchRequested(petType: widget.petType));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _breedsBloc.close();

    super.dispose();
  }

  void _select(BreedModel breed) => Navigator.of(context).pop(breed);

  void _scrollTo(String letter) {
    final target = _sectionKeys[letter]?.currentContext;

    if (target != null) {
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.petType == PetTypeEnum.cat
        ? l10n.breedPageTitleCat
        : l10n.breedPageTitleDog;

    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: Column(
        children: [
          UiTopBar(
            title: title,
            backLabel: l10n.enterCodeBack,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: BlocBuilder<BreedsBloc, BreedsState>(
              bloc: _breedsBloc,
              builder: (context, state) {
                return state.map(
                  loading: (_) => const _BreedsShimmer(),
                  error: (_) => UiFetchingError(
                    onRetry: () =>
                        _breedsBloc.add(BreedsEvent.fetchRequested(petType: widget.petType)),
                  ),
                  success: (state) => _buildContent(context, state.breeds),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<BreedModel> breeds) {
    final l10n = context.l10n;
    final listing = buildBreedsListing(breeds, query: _searchController.text);
    final bottom = MediaQuery.paddingOf(context).bottom;

    _sectionKeys
      ..removeWhere((letter, _) => !listing.letters.contains(letter))
      ..addEntries([
        for (final letter in listing.letters) MapEntry(letter, _sectionKeys[letter] ?? GlobalKey()),
      ]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiSpacing.x5,
            UiSpacing.x2,
            UiSpacing.x5,
            UiSpacing.x3,
          ),
          child: UiTextField(
            controller: _searchController,
            placeholderText: l10n.breedSearchPlaceholder,
            trailingIcon: Icon(Icons.search, size: 24, color: context.uiPalette.ink3),
          ),
        ),
        Expanded(
          child: listing.isEmpty
              ? UiEmptyState(title: l10n.breedNothingFound)
              : Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        UiSpacing.x5,
                        0,
                        UiSpacing.x5 + 24,
                        bottom + UiSpacing.x4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (listing.mixed != null) ...[
                            UiGroupedList(
                              children: [
                                UiSelectableRow(
                                  label: l10n.breedMixedLabel,
                                  selected: listing.mixed!.id == widget.selectedBreedId,
                                  onTap: () => _select(listing.mixed!),
                                ),
                              ],
                            ),
                            const SizedBox(height: UiSpacing.x4),
                          ],
                          for (final section in listing.sections) ...[
                            _SectionTitle(
                              key: _sectionKeys[section.letter],
                              letter: section.letter,
                            ),
                            UiGroupedList(
                              children: [
                                for (final breed in section.breeds)
                                  UiSelectableRow(
                                    label: breed.name,
                                    selected: breed.id == widget.selectedBreedId,
                                    onTap: () => _select(breed),
                                  ),
                              ],
                            ),
                            const SizedBox(height: UiSpacing.x4),
                          ],
                        ],
                      ),
                    ),
                    if (_searchController.text.trim().isEmpty)
                      Positioned(
                        right: UiSpacing.x1,
                        top: 0,
                        bottom: bottom,
                        child: Center(
                          child: UiAlphabetIndex(
                            letters: listing.letters,
                            onLetterSelected: _scrollTo,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.letter, super.key});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.x2),
      child: Semantics(
        header: true,
        child: Text(
          letter,
          style: context.uiFonts.monoEyebrow.copyWith(color: context.uiPalette.ink2),
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
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5, vertical: UiSpacing.x2),
        child: Column(
          children: List.generate(
            5,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: UiSpacing.x3),
              child: UiKitShimmerLoading(height: 56, borderRadius: UiRadius.mdAll),
            ),
          ),
        ),
      ),
    );
  }
}
