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
}
