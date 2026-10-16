/// Состояние вхождения события в календаре.
enum ScheduleEventStatus {
  scheduled,
  done,
  cancelled;

  bool get isScheduled => this == scheduled;
  bool get isDone => this == done;
  bool get isCancelled => this == cancelled;
}
