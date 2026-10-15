import 'package:flutter/material.dart';

/// Represents a reminder/alarm item with snooze and priority capability.
class ReminderItem {
  final String id;
  final String title;
  final DateTime dueDateTime;
  final String categoryName;
  final Color categoryColor;
  final bool isDone;
  final bool hasAlarm;
  final int snoozeCount;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.dueDateTime,
    required this.categoryName,
    required this.categoryColor,
    this.isDone = false,
    this.hasAlarm = true,
    this.snoozeCount = 0,
  });

  ReminderItem copyWith({
    String? id,
    String? title,
    DateTime? dueDateTime,
    String? categoryName,
    Color? categoryColor,
    bool? isDone,
    bool? hasAlarm,
    int? snoozeCount,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      isDone: isDone ?? this.isDone,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDateTime: DateTime.parse(json['due_date_time'] as String).toLocal(),
      categoryName: json['category_name'] as String? ?? 'General',
      categoryColor: Color(
        (json['category_color'] as num?)?.toInt() ?? 0xFF4F46E5,
      ),
      isDone: json['is_done'] as bool? ?? false,
      hasAlarm: json['has_alarm'] as bool? ?? true,
      snoozeCount: (json['snooze_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'due_date_time': dueDateTime.toUtc().toIso8601String(),
      'category_name': categoryName,
      'category_color': categoryColor.toARGB32(),
      'is_done': isDone,
      'has_alarm': hasAlarm,
      'snooze_count': snoozeCount,
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }
}
