import 'package:equatable/equatable.dart';

class SlideUio extends Equatable {
  final String imagePath;
  final String title;
  final String subtitle;

  const SlideUio({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [
        imagePath,
        title,
        subtitle,
      ];
}
