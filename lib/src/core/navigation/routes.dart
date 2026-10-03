import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/scaffold_with_navbar.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_screen.dart';
import 'package:tails_mobile/src/feature/auth/presentation/enter_code_screen.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/add_pet_modal.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/edit_pet/presentation/edit_pet_modal.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/pet_details_screen.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/presentation/pets_screen.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/presentation/select_breed_modal.dart';
import 'package:tails_mobile/src/feature/profile/about/presentation/about_screen.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/account_deleted_screen.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/delete_account_confirm_screen.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/delete_account_screen.dart';
import 'package:tails_mobile/src/feature/profile/edit_profile/presentation/edit_profile_screen.dart';
import 'package:tails_mobile/src/feature/profile/feedback/presentation/feedback_screen.dart';
import 'package:tails_mobile/src/feature/profile/notifications_settings/presentation/notifications_settings_screen.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/presentation/profile_screen.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/schedule_screen.dart';

part 'routes.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@TypedShellRoute<GlobalShellRoute>(
  routes: [
    TypedGoRoute<AuthRoute>(path: '/auth', name: 'auth'),
    TypedGoRoute<EnterCodeRoute>(path: '/enter-code', name: 'enter-code'),
    TypedGoRoute<SelectBreedRoute>(path: '/select-breed', name: 'select-breed'),
    TypedGoRoute<AddPetRoute>(path: '/add-pet', name: 'add-pet'),
    TypedGoRoute<EditPetRoute>(path: '/edit-pet', name: 'edit-pet'),
    TypedGoRoute<EditProfileRoute>(path: '/edit-profile', name: 'edit-profile'),
    TypedGoRoute<NotificationsSettingsRoute>(
      path: '/notifications-settings',
      name: 'notifications-settings',
    ),
    TypedGoRoute<AboutRoute>(path: '/about', name: 'about'),
    TypedGoRoute<FeedbackRoute>(path: '/feedback', name: 'feedback'),
    TypedGoRoute<DeleteAccountRoute>(path: '/delete-account', name: 'delete-account'),
    TypedGoRoute<DeleteAccountConfirmRoute>(
      path: '/delete-account/confirm',
      name: 'delete-account-confirm',
    ),
    TypedGoRoute<AccountDeletedRoute>(path: '/account-deleted', name: 'account-deleted'),
    TypedStatefulShellRoute<HomeShellRoute>(
      branches: [
        TypedStatefulShellBranch<PetsBranch>(
          routes: [
            TypedGoRoute<PetsRoute>(
              path: '/pets',
              name: 'pets',
              routes: [TypedGoRoute<PetDetailsRoute>(path: ':id', name: 'pet-details')],
            ),
          ],
        ),
        TypedStatefulShellBranch<ScheduleBranch>(
          routes: [TypedGoRoute<ScheduleRoute>(path: '/schedule', name: 'schedule')],
        ),
        TypedStatefulShellBranch<ProfileBranch>(
          routes: [TypedGoRoute<ProfileRoute>(path: '/profile', name: 'profile')],
        ),
      ],
    ),
  ],
)
class GlobalShellRoute extends ShellRouteData {
  const GlobalShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }
}

class HomeShellRoute extends StatefulShellRouteData {
  const HomeShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  }
}

/// Branches

class PetsBranch extends StatefulShellBranchData {
  const PetsBranch();
}

class ScheduleBranch extends StatefulShellBranchData {
  const ScheduleBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

/// Routes

class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthScreen();
}

class EnterCodeRoute extends GoRouteData with $EnterCodeRoute {
  final String phoneNumber;

  const EnterCodeRoute({required this.phoneNumber});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EnterCodeScreen(phoneNumber: phoneNumber);
}

class SelectBreedRoute extends GoRouteData with $SelectBreedRoute {
  final PetTypeEnum petType;
  final int? selectedBreedId;

  const SelectBreedRoute({required this.petType, this.selectedBreedId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SelectBreedModal(petType: petType, selectedBreedId: selectedBreedId);
}

class AddPetRoute extends GoRouteData with $AddPetRoute {
  const AddPetRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AddPetModal();
}

class EditPetRoute extends GoRouteData with $EditPetRoute {
  /// Редактируемый питомец; передаётся объектом, чтобы не перезагружать данные.
  final PetDetailsModel $extra;

  const EditPetRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) => EditPetModal(pet: $extra);
}

class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  /// Профиль передаётся объектом, чтобы форма открылась без повторной загрузки.
  final ProfileModel $extra;

  const EditProfileRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) => EditProfileScreen(profile: $extra);
}

class NotificationsSettingsRoute extends GoRouteData with $NotificationsSettingsRoute {
  const NotificationsSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsSettingsScreen();
}

class AboutRoute extends GoRouteData with $AboutRoute {
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AboutScreen();
}

class FeedbackRoute extends GoRouteData with $FeedbackRoute {
  /// Имя темы обращения (`FeedbackTopic.name`).
  final String topic;

  const FeedbackRoute({required this.topic});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FeedbackScreen(topic: FeedbackTopic.fromName(topic));
}

class DeleteAccountRoute extends GoRouteData with $DeleteAccountRoute {
  final String phoneNumber;

  const DeleteAccountRoute({required this.phoneNumber});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DeleteAccountScreen(phoneNumber: phoneNumber);
}

class DeleteAccountConfirmRoute extends GoRouteData with $DeleteAccountConfirmRoute {
  final String phoneNumber;

  const DeleteAccountConfirmRoute({required this.phoneNumber});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DeleteAccountConfirmScreen(phoneNumber: phoneNumber);
}

class AccountDeletedRoute extends GoRouteData with $AccountDeletedRoute {
  const AccountDeletedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccountDeletedScreen();
}

class PetDetailsRoute extends GoRouteData with $PetDetailsRoute {
  final int id;

  const PetDetailsRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) => PetDetailsScreen(id: id);
}

class PetsRoute extends GoRouteData with $PetsRoute {
  const PetsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PetsScreen();
}

class ScheduleRoute extends GoRouteData with $ScheduleRoute {
  const ScheduleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ScheduleScreen();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProfileScreen();
}
