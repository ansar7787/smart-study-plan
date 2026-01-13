import 'package:equatable/equatable.dart';

class ExtractedTask extends Equatable {
  final String title;
  final String? description;

  const ExtractedTask({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}
