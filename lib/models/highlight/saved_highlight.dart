import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavedHighlight {
  final String id;
  final int page;
  final String location;
  final int colorValue; // Store color as int for database compatibility
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPartial;
  final double? startPercentage;
  final double? endPercentage;
  final String? note; // Optional note for the highlight

  SavedHighlight({
    String? id,
    required this.page,
    required this.location,
    required this.colorValue,
    DateTime? createdAt,
    this.updatedAt,
    this.isPartial = false,
    this.startPercentage,
    this.endPercentage,
    this.note,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  // Convert color to Color object
  Color get color => Color(colorValue);

  // Create from Color object
  static SavedHighlight fromColor({
    String? id,
    required int page,
    required String location,
    required Color color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isPartial = false,
    double? startPercentage,
    double? endPercentage,
    String? note,
  }) {
    return SavedHighlight(
      id: id,
      page: page,
      location: location,
      colorValue: color.value,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPartial: isPartial,
      startPercentage: startPercentage,
      endPercentage: endPercentage,
      note: note,
    );
  }

  // Create from database map
  factory SavedHighlight.fromJson(Map<String, dynamic> json) {
    return SavedHighlight(
      id: json['id'] as String,
      page: json['page'] as int,
      location: json['location'] as String,
      colorValue: json['color_value'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: json['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : null,
      isPartial: (json['is_partial'] as int) == 1,
      startPercentage: json['start_percentage'] as double?,
      endPercentage: json['end_percentage'] as double?,
      note: json['note'] as String?,
    );
  }

  // Convert to database map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'location': location,
      'color_value': colorValue,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'is_partial': isPartial ? 1 : 0,
      'start_percentage': startPercentage,
      'end_percentage': endPercentage,
      'note': note,
    };
  }

  // Create a copy with updated fields
  SavedHighlight copyWith({
    String? id,
    int? page,
    String? location,
    int? colorValue,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPartial,
    double? startPercentage,
    double? endPercentage,
    String? note,
  }) {
    return SavedHighlight(
      id: id ?? this.id,
      page: page ?? this.page,
      location: location ?? this.location,
      colorValue: color?.value ?? colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPartial: isPartial ?? this.isPartial,
      startPercentage: startPercentage ?? this.startPercentage,
      endPercentage: endPercentage ?? this.endPercentage,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedHighlight && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SavedHighlight(id: $id, page: $page, location: $location, color: ${color.toString()})';
  }
}