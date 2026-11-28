import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API
/// (`ProjectSerializer`: id, name, description, type, url, image, tech_stack).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.name,
    required this.description,
    required this.techStack,
    this.type = 'personal',
    this.url = '',
    this.image = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Server-generated UUID; never sent in request bodies.
  @JsonKey(includeToJson: false)
  final String? id;
  final String name;
  final String description;
  @JsonKey(defaultValue: 'personal')
  final String type;
  @JsonKey(defaultValue: '')
  final String url;
  @JsonKey(defaultValue: '')
  final String image;
  @JsonKey(defaultValue: <String>[])
  final List<String> techStack;

  static const List<String> types = ['personal', 'competition', 'team'];

  static String typeLabel(String type) =>
      type.isEmpty ? type : '${type[0].toUpperCase()}${type.substring(1)}';

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
