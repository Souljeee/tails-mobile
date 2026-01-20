import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/utils/extensions/context_extension.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';

abstract interface class AuthController {
  AuthorizationStatus get status;

  void login(String phoneNumber, String code);

  void logout();
}

class AuthScope extends StatefulWidget {
  final Widget child;
  final AuthBloc authBloc;

  const AuthScope({
    required this.child,
    required this.authBloc,
    super.key,
  });

  static AuthController of(BuildContext context, {bool listen = true}) =>
      context.inhOf<_InheritedAuth>(listen: listen).controller;

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> implements AuthController {
  @override
  void login(String phoneNumber, String code) {
    widget.authBloc.add(
      AuthEvent.login(
        phoneNumber: phoneNumber,
        code: code,
      ),
    );
  }

  @override
  void logout() {
    widget.authBloc.add(const AuthEvent.logout());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      builder: (context, state) {
        return _InheritedAuth(
          controller: this,
          state: state,
          child: widget.child,
        );
      },
    );
  }

  @override
  AuthorizationStatus get status => widget.authBloc.state.status;
}

class _InheritedAuth extends InheritedWidget {
  final AuthController controller;
  final AuthState state;

  const _InheritedAuth({
    required super.child,
    required this.controller,
    required this.state,
  });

  @override
  bool updateShouldNotify(covariant _InheritedAuth oldWidget) => state != oldWidget.state;
}
