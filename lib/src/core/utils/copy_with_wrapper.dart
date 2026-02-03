import 'package:equatable/equatable.dart';

class CopyWithWrapper<T> extends Equatable {
  final T value;
  const CopyWithWrapper.value(this.value);

  @override
  List<Object?> get props => [value];
}
