import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intercepted_client/intercepted_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_client/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/logging/integrations/logging_http_client.dart';
import 'package:tails_mobile/src/core/logging/sinks/file_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/sentry_error_reporter.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/refresh_service_impl.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/secure_token_storage.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/code_timer/code_timer_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/notifications_inbox_remote_data_source.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/pet_color_store.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/device_info_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/notification_permission_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/profile_remote_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/local_notifications_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/push_messaging_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/push_notifications_repository.dart';
import 'package:tails_mobile/src/feature/push_notifications/domain/push_notifications_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/settings/bloc/app_settings_bloc.dart';
import 'package:tails_mobile/src/feature/settings/data/app_settings_datasource.dart';
import 'package:tails_mobile/src/feature/settings/data/app_settings_repository.dart';

/// {@template composition_root}
/// A place where top-level dependencies are initialized.
/// {@endtemplate}
///
/// {@template composition_process}
/// Composition of dependencies is a process of creating and configuring
/// instances of classes that are required for the application to work.
/// {@endtemplate}
final class CompositionRoot {
  /// {@macro composition_root}
  const CompositionRoot({required this.config, required this.errorReporter, this.fileLogSink});

  /// Application configuration
  final ApplicationConfig config;

  /// Error tracking manager used to track errors in the application.
  final ErrorReporter errorReporter;

  /// Файловый журнал; очищается при выходе из аккаунта и удалении аккаунта.
  final FileLogSink? fileLogSink;

  /// Composes dependencies and returns result of composition.
  Future<CompositionResult> compose() async {
    final stopwatch = clock.stopwatch()..start();

    TailsLogger.info(
      'Инициализация зависимостей',
      category: TailsLogCategory.app,
      source: 'CompositionRoot',
    );
    // initialize dependencies
    final dependencies = await DependenciesFactory(
      config: config,
      errorReporter: errorReporter,
      fileLogSink: fileLogSink,
    ).create();
    stopwatch.stop();
    TailsLogger.info(
      'Зависимости инициализированы',
      category: TailsLogCategory.app,
      source: 'CompositionRoot',
      data: {'durationMs': stopwatch.elapsedMilliseconds},
    );
    final result = CompositionResult(
      dependencies: dependencies,
      millisecondsSpent: stopwatch.elapsedMilliseconds,
    );

    return result;
  }
}

/// {@template composition_result}
/// Result of composition
///
/// {@macro composition_process}
/// {@endtemplate}
final class CompositionResult {
  /// {@macro composition_result}
  const CompositionResult({required this.dependencies, required this.millisecondsSpent});

  /// The dependencies container
  final DependenciesContainer dependencies;

  /// The number of milliseconds spent
  final int millisecondsSpent;

  @override
  String toString() =>
      '$CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Value with time.
typedef ValueWithTime<T> = ({T value, Duration timeSpent});

/// {@template factory}
/// Factory that creates an instance of [T].
/// {@endtemplate}
abstract class Factory<T> {
  /// {@macro factory}
  const Factory();

  /// Creates an instance of [T].
  T create();
}

/// {@template async_factory}
/// Factory that creates an instance of [T] asynchronously.
/// {@endtemplate}
abstract class AsyncFactory<T> {
  /// {@macro async_factory}
  const AsyncFactory();

  /// Creates an instance of [T].
  Future<T> create();
}

/// {@template dependencies_factory}
/// Factory that creates an instance of [DependenciesContainer].
/// {@endtemplate}
class DependenciesFactory extends AsyncFactory<DependenciesContainer> {
  /// {@macro dependencies_factory}
  const DependenciesFactory({
    required this.config,
    required this.errorReporter,
    this.fileLogSink,
  });

  /// Application configuration
  final ApplicationConfig config;

  /// Error tracking manager used to track errors in the application.
  final ErrorReporter errorReporter;

  /// Файловый журнал; очищается при выходе из аккаунта и удалении аккаунта.
  final FileLogSink? fileLogSink;

  @override
  Future<DependenciesContainer> create() async {
    final sharedPreferences = SharedPreferencesAsync();

    final packageInfo = await _timed('package info', PackageInfo.fromPlatform);

    final settingsBloc = await _timed(
      'app settings',
      AppSettingsBlocFactory(sharedPreferences).create,
    );

    const secureStorage = FlutterSecureStorage();

    final secureTokenStorage = SecureTokenStorage(secureStorage: secureStorage);

    final authorizationToken = await _timed('secure storage', secureTokenStorage.load);

    final resreshTokenClient = await _initRefreshTokenClient(config);

    final refreshService = RefreshServiceImpl(restClient: resreshTokenClient);

    final notAuthClient = await _initNotAuthClient(config);

    final restClient = await _timed(
      'rest client',
      () => _initRestClient(config, secureTokenStorage, refreshService),
    );

    final pushNotificationsRepository = PushNotificationsRepository(
      messagingDataSource: FirebasePushMessagingDataSource(),
      localNotificationsDataSource: FlutterLocalNotificationsDataSource(),
      devicesRemoteDataSource: DevicesRemoteDataSource(restClient: restClient),
    );

    final authRemoteDataSource = AuthRemoteDataSource(
      restClient: notAuthClient,
      authorizedRestClient: restClient,
    );

    final authRepository = AuthRepository(
      authRemoteDataSource: authRemoteDataSource,
      tokenStorage: secureTokenStorage,
      beforeLogout: pushNotificationsRepository.unregisterDevice,
      afterSessionCleared: fileLogSink?.clear,
    );

    final initialAuthorizationStatus = authorizationToken != null
        ? AuthorizationStatus.authorized
        : AuthorizationStatus.notAuthorized;

    final authorizationBloc = AuthBloc(
      AuthState.idle(status: initialAuthorizationStatus),
      authRepository: authRepository,
    );

    final pushNotificationsBloc = PushNotificationsBloc(
      repository: pushNotificationsRepository,
      initialAuthorizationStatus: initialAuthorizationStatus,
      authorizationStatus: authRepository.authorizationStatus,
    );

    final sendCodeBloc = SendCodeBloc(authRepository: authRepository);

    final codeTimerBloc = CodeTimerBloc();

    final petsRemoteDataSource = PetsRemoteDataSource(restClient: restClient);

    final petRepository = PetRepository(
      petsRemoteDataSource: petsRemoteDataSource,
      petColorStore: PetColorStore(preferences: sharedPreferences),
    );

    final scheduleRemoteDataSource = ScheduleRemoteDataSource(restClient: restClient);

    final scheduleRepository = ScheduleRepository(
      scheduleRemoteDataSource: scheduleRemoteDataSource,
    );

    final notificationsInboxRepository = NotificationsInboxRepository(
      remoteDataSource: NotificationsInboxRemoteDataSource(restClient: restClient),
      incomingPushes: pushNotificationsRepository.receivedNotifications,
      authorizationStatus: authRepository.authorizationStatus,
    );

    final profileRepository = ProfileRepository(
      remoteDataSource: ProfileRemoteDataSource(restClient: restClient),
      deviceInfoDataSource: const DeviceInfoDataSource(),
      notificationPermissionDataSource: const NotificationPermissionDataSource(),
      packageInfo: packageInfo,
    );

    return DependenciesContainer(
      config: config,
      errorReporter: errorReporter,
      packageInfo: packageInfo,
      appSettingsBloc: settingsBloc,
      restClient: restClient,
      authRepository: authRepository,
      authorizationBloc: authorizationBloc,
      sendCodeBloc: sendCodeBloc,
      codeTimerBloc: codeTimerBloc,
      petRepository: petRepository,
      scheduleRepository: scheduleRepository,
      profileRepository: profileRepository,
      pushNotificationsBloc: pushNotificationsBloc,
      notificationsInboxRepository: notificationsInboxRepository,
    );
  }
}

/// Выполняет шаг инициализации и пишет, сколько он длился.
///
/// Если шаг упал, в журнале остаётся его имя: само исключение пишет `AppRunner`, но из него
/// не всегда понятно, на каком шаге оно возникло. Ошибка пробрасывается дальше без изменений.
Future<T> _timed<T>(String step, Future<T> Function() action) async {
  final stopwatch = clock.stopwatch()..start();

  try {
    final result = await action();

    TailsLogger.debug(
      'init $step',
      category: TailsLogCategory.app,
      source: 'CompositionRoot',
      data: {'durationMs': stopwatch.elapsedMilliseconds},
    );

    return result;
  } on Object {
    TailsLogger.error(
      'init $step не выполнен',
      category: TailsLogCategory.app,
      source: 'CompositionRoot',
      data: {'durationMs': stopwatch.elapsedMilliseconds},
      // Само исключение отправит AppRunner.
      report: false,
    );

    rethrow;
  }
}

LoggingHttpClient _loggingClient(http.Client inner, String label) => LoggingHttpClient(
  inner,
  label: label,
  bodyMaxLength: TailsLogConfig.forBuildMode().networkBodyMaxLength,
);

Future<RestClient> _initNotAuthClient(ApplicationConfig config) async {
  final client = _loggingClient(http.Client(), 'public');

  final restClient = RestClientHttp(baseUrl: config.baseUrl, client: client);

  return restClient;
}

Future<RestClient> _initRestClient(
  ApplicationConfig config,
  SecureTokenStorage secureTokenStorage,
  RefreshService<OAuth2Token> refreshService,
) async {
  final authorizationToken = await secureTokenStorage.load();

  // Логирующая обёртка снаружи: в журнале видны и запросы, отклонённые перехватчиком.
  // Повтор запроса после обновления токена идёт через отдельный retryClient, поэтому
  // он тоже обёрнут.
  final client = _loggingClient(
    InterceptedClient(
      interceptors: [
        AuthInterceptor(
          tokenStorage: secureTokenStorage,
          refreshService: refreshService,
          retryClient: _loggingClient(http.Client(), 'api-retry'),
          token: authorizationToken,
        ),
      ],
    ),
    'api',
  );

  final restClient = RestClientHttp(baseUrl: config.baseUrl, client: client);

  return restClient;
}

Future<RestClient> _initRefreshTokenClient(ApplicationConfig config) async {
  return RestClientHttp(
    baseUrl: config.baseUrl,
    client: _loggingClient(http.Client(), 'auth-refresh'),
  );
}

/// {@template error_reporter_factory}
/// Factory that creates an instance of [ErrorReporter].
/// {@endtemplate}
class ErrorReporterFactory extends AsyncFactory<ErrorReporter> {
  /// {@macro error_reporter_factory}
  const ErrorReporterFactory(this.config);

  /// Application configuration
  final ApplicationConfig config;

  @override
  Future<ErrorReporter> create() async {
    final errorReporter = SentryErrorReporter(
      sentryDsn: config.sentryDsn,
      environment: config.environment.value,
    );

    if (config.sentryDsn.isNotEmpty) {
      await errorReporter.initialize();
    }

    return errorReporter;
  }
}

/// {@template app_settings_bloc_factory}
/// Factory that creates an instance of [AppSettingsBloc].
///
/// The [AppSettingsBloc] should be initialized during the application startup
/// in order to load the app settings from the local storage, so user can see
/// their selected theme,locale, etc.
/// {@endtemplate}
class AppSettingsBlocFactory extends AsyncFactory<AppSettingsBloc> {
  /// {@macro app_settings_bloc_factory}
  const AppSettingsBlocFactory(this.sharedPreferences);

  /// Shared preferences instance
  final SharedPreferencesAsync sharedPreferences;

  @override
  Future<AppSettingsBloc> create() async {
    final appSettingsRepository = AppSettingsRepositoryImpl(
      datasource: AppSettingsDatasourceImpl(sharedPreferences: sharedPreferences),
    );

    final appSettings = await appSettingsRepository.getAppSettings();
    final initialState = AppSettingsState.idle(appSettings: appSettings);

    return AppSettingsBloc(
      appSettingsRepository: appSettingsRepository,
      initialState: initialState,
    );
  }
}
