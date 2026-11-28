import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Sama dengan `Experience.EXPERIENCE_CHOICES` di Django.
@JsonEnum(fieldRename: FieldRename.kebab)
enum ExperienceCategory {
  internship('Internship'),

  volunteer('Volunteer'),

  partTime('Part-Time'),

  fullTime('Full-Time'),

  freelance('Freelance'),

  research('Research');

  ExperienceCategory(this.label);

  final String label;
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.category = ExperienceCategory.freelance,
    this.thumbnail = '',
    this.startedAt,
    this.endedAt,
    this.id,
    this.categoryDisplay = '',
    this.isOngoing = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
    this.comments = const [],
    this.userComment,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;

  final String title;

  final String description;

  @JsonKey(
    defaultValue: ExperienceCategory.freelance,
    unknownEnumValue: ExperienceCategory.freelance,
  )
  final ExperienceCategory category;

  @JsonKey(defaultValue: '')
  final String thumbnail;

  /// Tanggal mulai. Dihilangkan dari body bila `null` karena serializer
  /// menolak `started_at: null` (server memakai waktu sekarang).
  @JsonKey(includeIfNull: false)
  final DateTime? startedAt;

  /// Tanggal selesai. Tetap dikirim saat `null` agar PATCH bisa mengubah
  /// entri menjadi "masih berlangsung".
  final DateTime? endedAt;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isOngoing;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  /// Status bintang pemohon; selalu `false` untuk permintaan anonim.
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  @JsonKey(includeToJson: false, defaultValue: <ExperienceComment>[])
  final List<ExperienceComment> comments;

  @JsonKey(includeToJson: false)
  final UserComment? userComment;

  static const int maxTitleLength = 255;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ExperienceComment {
  const ExperienceComment({
    required this.id,
    required this.text,
    this.username = '',
    this.createdAt,
  });

  factory ExperienceComment.fromJson(Map<String, dynamic> json) =>
      _$ExperienceCommentFromJson(json);

  final String id;

  final String text;

  @JsonKey(defaultValue: '')
  final String username;

  final DateTime? createdAt;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class UserComment {
  const UserComment({required this.id, required this.text});

  factory UserComment.fromJson(Map<String, dynamic> json) =>
      _$UserCommentFromJson(json);

  final String id;

  final String text;
}
