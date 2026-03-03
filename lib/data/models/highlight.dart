import 'package:uuid/uuid.dart';

class Highlight {
  final String id;
  final int pageNumber;
  final String text;
  final int colorValue;
  final DateTime createdAt;
  final String? note;
  final String? folderId;

  Highlight({
    String? id,
    required this.pageNumber,
    required this.text,
    this.colorValue = 0xFFB8860B, // vintageGold default
    DateTime? createdAt,
    this.note,
    this.folderId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      text: json['text'] as String,
      colorValue: json['colorValue'] as int? ?? 0xFFB8860B,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
      folderId: json['folderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageNumber': pageNumber,
      'text': text,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'folderId': folderId,
    };
  }

  Highlight copyWith({
    String? id,
    int? pageNumber,
    String? text,
    int? colorValue,
    DateTime? createdAt,
    String? note,
    String? folderId,
  }) {
    return Highlight(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      text: text ?? this.text,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Highlight && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
