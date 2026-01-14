import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';
import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/settings/bloc/app_settings_bloc.dart';

/// {@template dependencies_container}
/// Container used to reuse dependencies across the application.
///
/// {@macro composition_process}
/// {@endtemplate}
class DependenciesContainer {
  /// {@macro dependencies_container}
  const DependenciesContainer({
    required this.logger,
    required this.config,
    required this.appSettingsBloc,
    required this.errorReporter,
    required this.packageInfo,
    required this.restClient, 
    required this.authRepository,
    required this.authorizationBloc,
    required this.sendCodeBloc,
  });

  /// [Logger] instance, used to log messages.
  final Logger logger;

  /// [ApplicationConfig] instance, contains configuration of the application.
  final ApplicationConfig config;

  /// [AppSettingsBloc] instance, used to manage theme and locale.
  final AppSettingsBloc appSettingsBloc;

  /// [ErrorReporter] instance, used to report errors.
  final ErrorReporter errorReporter;

  /// [PackageInfo] instance, contains information about the application.
  final PackageInfo packageInfo;

  /// [RestClient] instance, used to make HTTP requests.
  final RestClient restClient;

  /// [AuthRepository] instance, used to fetch auth data from the remote source.
  final AuthRepository authRepository;

  /// [AuthBloc] instance, used to manage authentication state.
  final AuthBloc authorizationBloc;

  /// [SendCodeBloc] instance, used to send verification code and manage timer.
  final SendCodeBloc sendCodeBloc;
}

/// {@template testing_dependencies_container}
/// A special version of [DependenciesContainer] that is used in tests.
///
/// In order to use [DependenciesContainer] in tests, it is needed to
/// extend this class and provide the dependencies that are needed for the test.
/// {@endtemplate}
base class TestDependenciesContainer implements DependenciesContainer {
  /// {@macro testing_dependencies_container}
  const TestDependenciesContainer();

  @override
  Object noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'The test tries to access ${invocation.memberName} dependency, but '
      'it was not provided. Please provide the dependency in the test. '
      'You can do it by extending this class and providing the dependency.',
    );
  }
}
