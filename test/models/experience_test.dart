import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';

import '../helpers/fake_backend.dart';

void main() {
  group('Experience', () {
    test('fromJson membaca semua field serializer', () {
      final e = Experience.fromJson(experienceJson());

      expect(e.id, experienceId);
      expect(e.title, 'Backend Intern');
      expect(e.category, ExperienceCategory.partTime);
      expect(e.categoryDisplay, 'Part-Time');
      expect(e.thumbnail, '');
      expect(e.startedAt, DateTime.utc(2026, 1, 5));
      expect(e.endedAt, DateTime.utc(2026, 3, 20));
      expect(e.isOngoing, isFalse);
      expect(e.starCount, 2);
      expect(e.isStarred, isFalse);
      expect(e.starredByNames, 'ani, budi');
      expect(e.comments.single.username, 'ani');
      expect(e.comments.single.createdAt, DateTime.utc(2026, 2, 1, 10));
      expect(e.userComment, isNull);
    });

    test('fromJson memberi default untuk field opsional', () {
      final e = Experience.fromJson(const {
        'title': 'Minimal',
        'description': 'Hanya field wajib',
      });

      expect(e.id, isNull);
      expect(e.category, ExperienceCategory.freelance);
      expect(e.thumbnail, '');
      expect(e.comments, isEmpty);
      expect(e.starCount, 0);
    });

    test('kategori yang belum dikenal jatuh ke freelance', () {
      final e = Experience.fromJson({
        ...experienceJson(),
        'category': 'apprenticeship',
      });

      expect(e.category, ExperienceCategory.freelance);
    });

    test('fromJson membaca user_comment bila ada', () {
      final e = Experience.fromJson({
        ...experienceJson(),
        'user_comment': {'id': 'c1', 'text': 'Punyaku'},
      });

      expect(e.userComment?.text, 'Punyaku');
    });

    test('toJson hanya berisi field yang boleh ditulis', () {
      final json = Experience.fromJson(experienceJson()).toJson();

      expect(json.keys.toSet(), {
        'title',
        'description',
        'category',
        'thumbnail',
        'started_at',
        'ended_at',
      });
      expect(json['category'], 'part-time');
      expect(json['started_at'], '2026-01-05T00:00:00.000Z');
    });

    test('ended_at null tetap dikirim, started_at null dihilangkan', () {
      const ongoing = Experience(title: 'T', description: 'D');
      final json = ongoing.toJson();

      expect(json.containsKey('started_at'), isFalse);
      expect(json.containsKey('ended_at'), isTrue);
      expect(json['ended_at'], isNull);
    });

    test('setiap kategori dikirim dengan nilai choices Django', () {
      final values = [
        for (final category in ExperienceCategory.values)
          Experience(
            title: 'T',
            description: 'D',
            category: category,
          ).toJson()['category'],
      ];

      expect(values, [
        'internship',
        'volunteer',
        'part-time',
        'full-time',
        'freelance',
        'research',
      ]);
    });
  });

  test('Project.fromJson/toJson memetakan snake_case dan default kosong', () {
    final p = Project.fromJson(projectJson);

    expect(p.id, projectJson['id']);
    expect(p.techStack, ['Flutter', 'Django']);
    expect(p.url, '');
    expect(p.toJson().containsKey('id'), isFalse);
    expect(p.toJson()['tech_stack'], ['Flutter', 'Django']);
  });
}
