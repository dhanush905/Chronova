import 'package:flutter/material.dart';

/// Represents a user-customizable category for calendar events.
/// Categories are not hardcoded and can be created or customized dynamically.
class EventCategory {
  final String id;
  final String name;
  final Color color;

  const EventCategory({
    required this.id,
    required this.name,
    required this.color,
  });

  EventCategory copyWith({String? id, String? name, Color? color}) {
    return EventCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color((json['color_value'] as num?)?.toInt() ?? 0xFF4F46E5),
    );
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isValidUuid(String val) => _uuidRegex.hasMatch(val);

  Map<String, dynamic> toJson({String? userId}) {
    final map = <String, dynamic>{
      'name': name,
      'color_value': color.toARGB32(),
    };
    if (isValidUuid(id)) {
      map['id'] = id;
    }
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }
}

/// Calendar event data model for Chronova.
class EventItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventCategory category;
  final String location;
  final bool isCompleted;

  const EventItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.category,
    this.location = '',
    this.isCompleted = false,
  });

  EventItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventCategory? category,
    String? location,
    bool? isCompleted,
  }) {
    return EventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      endTime: DateTime.parse(json['end_time'] as String).toLocal(),
      category: EventCategory(
        id: json['category_id'] as String? ?? 'cat-general',
        name: json['category_name'] as String? ?? 'General',
        color: Color((json['category_color'] as num?)?.toInt() ?? 0xFF4F46E5),
      ),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'category_name': category.name,
      'category_color': category.color.toARGB32(),
      'is_completed': isCompleted,
    };
    if (EventCategory.isValidUuid(id)) {
      map['id'] = id;
    }
    // Include category_id only if it's a valid UUID
    if (EventCategory.isValidUuid(category.id)) {
      map['category_id'] = category.id;
    }
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }
}
