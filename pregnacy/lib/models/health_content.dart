import 'content_reference.dart';

enum ContentStage {
  preconception,
  firstTrimester,
  secondTrimester,
  thirdTrimester,
  postpartum,
  loss,
  general,
}

class HealthContent {
  final String id;
  final String title;
  final String body;
  final String author;
  final bool medicallyReviewed;
  final String? reviewerName;
  final List<ContentStage> stages;
  final List<String> tags;
  final List<ContentReference> references;
  final DateTime publishedAt;
  final DateTime? updatedAt;

  HealthContent({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.medicallyReviewed,
    this.reviewerName,
    required this.stages,
    required this.tags,
    required this.references,
    required this.publishedAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'author': author,
        'medicallyReviewed': medicallyReviewed ? 1 : 0,
        'reviewerName': reviewerName,
        'stages': stages.map((s) => s.name).join(','),
        'tags': tags.join(','),
        'publishedAt': publishedAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory HealthContent.fromMap(Map<String, dynamic> map,
          {List<ContentReference> references = const []}) =>
      HealthContent(
        id: map['id'],
        title: map['title'],
        body: map['body'],
        author: map['author'],
        medicallyReviewed: map['medicallyReviewed'] == 1,
        reviewerName: map['reviewerName'],
        stages: (map['stages'] as String)
            .split(',')
            .map((s) => ContentStage.values.firstWhere(
                  (e) => e.name == s,
                  orElse: () => ContentStage.general,
                ))
            .toList(),
        tags: (map['tags'] as String).split(','),
        references: references,
        publishedAt: DateTime.parse(map['publishedAt']),
        updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      );
}
