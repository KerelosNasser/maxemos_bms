class Book {
  final String id;
  final String title;
  final String author;
  final String url;
  final int size;
  final DateTime dateCreated;
  final List<String> categories;
  final String summary;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.size,
    required this.dateCreated,
    this.categories = const [],
    this.summary = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['name'] as String,
      author:
          'Unknown', // Typically not provided by Drive API unless stored in description
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
      dateCreated:
          DateTime.tryParse(json['dateCreated'] ?? '') ?? DateTime.now(),
      categories: List<String>.from(json['categories'] ?? []),
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'url': url,
      'size': size,
      'dateCreated': dateCreated.toIso8601String(),
      'categories': categories,
      'summary': summary,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? url,
    int? size,
    DateTime? dateCreated,
    List<String>? categories,
    String? summary,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      url: url ?? this.url,
      size: size ?? this.size,
      dateCreated: dateCreated ?? this.dateCreated,
      categories: categories ?? this.categories,
      summary: summary ?? this.summary,
    );
  }
}
