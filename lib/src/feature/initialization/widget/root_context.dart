import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tails_mobile/src/core/utils/layout/window_size.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';
import 'package:tails_mobile/src/feature/initialization/logic/composition_root.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/initialization/widget/material_context.dart';
import 'package:tails_mobile/src/feature/settings/widget/settings_scope.dart';

/// {@template app}
/// [RootContext] is an entry point to the application.
///
/// If a scope doesn't depend on any inherited widget returned by
/// [MaterialApp] or [WidgetsApp], like [Directionality] or [Theme],
/// and it should be available in the whole application, it can be
/// placed here.
/// {@endtemplate}
class RootContext extends StatelessWidget {
  /// {@macro app}
  const RootContext({required this.compositionResult, super.key});

  /// The result from the [CompositionRoot], required to launch the application.
  final CompositionResult compositionResult;

  @override
  Widget build(BuildContext context) => DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: DependenciesScope(
          dependencies: compositionResult.dependencies,
          child: SettingsScope(
            child: WindowSizeScope(
              child: AuthScope(
                authBloc: compositionResult.dependencies.authorizationBloc,
                child: GestureDetector(
                  onTap: () => _unFocus(context: context),
                  child: const MaterialContext(),
                ),
              ),
            ),
          ),
        ),
      );

  void _unFocus({required BuildContext context}) {
    final currentScope = FocusScope.of(context);

    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
