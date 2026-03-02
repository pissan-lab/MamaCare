class ContentReference {
  final String id;
  final String contentId;
  final String title;
  final String? authors;
  final String? journal;
  final int? year;
  final String? url;
  final String? doi;

  ContentReference({
    required this.id,
    required this.contentId,
    required this.title,
    this.authors,
    this.journal,
    this.year,
    this.url,
    this.doi,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'contentId': contentId,
        'title': title,
        'authors': authors,
        'journal': journal,
        'year': year,
        'url': url,
        'doi': doi,
      };

  factory ContentReference.fromMap(Map<String, dynamic> map) => ContentReference(
        id: map['id'],
        contentId: map['contentId'],
        title: map['title'],
        authors: map['authors'],
        journal: map['journal'],
        year: map['year'],
        url: map['url'],
        doi: map['doi'],
      );
}
