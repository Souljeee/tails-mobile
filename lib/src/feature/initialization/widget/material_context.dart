import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/navigation/go_router_refresh_stream.dart';
import 'package:tails_mobile/src/core/navigation/router.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_loader_overlay/loader_overlay.dart';
import 'package:tails_mobile/src/feature/settings/model/app_theme.dart';
import 'package:tails_mobile/src/feature/settings/widget/settings_scope.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

/// {@template material_context}
/// [MaterialContext] is an entry point to the material context.
///
/// This widget sets locales, themes and routing.
/// {@endtemplate}
class MaterialContext extends StatefulWidget {
  /// {@macro material_context}
  const MaterialContext({super.key});

  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  State<MaterialContext> createState() => _MaterialContextState();
}

class _MaterialContextState extends State<MaterialContext> {
  GoRouterRefreshStream? _routerRefresh;
  RouterConfig<Object>? _routerConfig;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize router once, with a refresh trigger on auth changes.
    _routerRefresh ??= GoRouterRefreshStream(
      DependenciesScope.of(context).authorizationBloc.stream,
    );
    _routerConfig ??= AppRouter.create(refreshListenable: _routerRefresh!);
  }

  @override
  void dispose() {
    _routerRefresh?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.settingsOf(context);
    final mediaQueryData = MediaQuery.of(context);

    final theme = settings.appTheme ?? AppTheme.defaultTheme;

    final lightTheme = theme.buildThemeData(Brightness.light);
    final darkTheme = theme.buildThemeData(Brightness.dark);
    final themeMode = theme.themeMode;

    return MaterialApp.router(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: settings.locale,
      localizationsDelegates: Localization.localizationDelegates,
      supportedLocales: Localization.supportedLocales,
      routerConfig: _routerConfig,
      builder: (context, child) => MediaQuery(
        key: MaterialContext._globalKey,
        data: mediaQueryData.copyWith(
          textScaler: TextScaler.linear(
            mediaQueryData.textScaler.scale(settings.textScale ?? 1).clamp(0.5, 2),
          ),
        ),
        child: LoaderOverlay(child: child!),
      ),
    );
  }
}
