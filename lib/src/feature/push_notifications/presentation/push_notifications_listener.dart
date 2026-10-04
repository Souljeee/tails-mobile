import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_notification.dart';
import 'package:tails_mobile/src/feature/push_notifications/domain/push_notifications_bloc.dart';

/// Вызывает [onOpened], когда пользователь нажимает на push-уведомление.
class PushNotificationsListener extends StatelessWidget {
  const PushNotificationsListener({
    required this.bloc,
    required this.onOpened,
    required this.child,
    super.key,
  });

  final PushNotificationsBloc bloc;
  final ValueChanged<PushNotification> onOpened;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<PushNotificationsBloc, PushNotificationsState>(
    bloc: bloc,
    listenWhen: (previous, current) => previous.openedCount != current.openedCount,
    listener: (context, state) {
      final notification = state.lastOpened;

      if (notification != null) {
        onOpened(notification);
      }
    },
    child: child,
  );
}
