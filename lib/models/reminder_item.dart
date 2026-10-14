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
}
