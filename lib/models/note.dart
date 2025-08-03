import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id; // Format: surah_ayah_uniqueId
  final String content;
  final int surah;
  final int ayah;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted; // For soft delete
  final DateTime? deletedAt;

  const Note({
    required this.id,
    required this.content,
    required this.surah,
    required this.ayah,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      content: json['content'] as String,
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: (json['is_deleted'] as int? ?? 0) == 1,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'surah': surah,
      'ayah': ayah,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Create a note for a specific ayah
  factory Note.create({
    required int surah,
    required int ayah,
    required String content,
  }) {
    final now = DateTime.now();
    return Note(
      id: "${surah}_${ayah}_${DateTime.now().millisecondsSinceEpoch}",
      content: content,
      surah: surah,
      ayah: ayah,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a copy with updated content
  Note copyWith({
    String? id,
    String? content,
    int? surah,
    int? ayah,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Soft delete this note
  Note delete() {
    return copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Update note content
  Note updateContent(String newContent) {
    return copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        surah,
        ayah,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
      ];

  @override
  bool get stringify => true;
}