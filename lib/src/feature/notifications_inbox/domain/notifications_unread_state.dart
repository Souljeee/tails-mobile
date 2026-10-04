part of 'notifications_unread_bloc.dart';

final class NotificationsUnreadState extends Equatable {
  const NotificationsUnreadState({this.count = 0});

  final int count;

  @override
  List<Object?> get props => [count];
}
