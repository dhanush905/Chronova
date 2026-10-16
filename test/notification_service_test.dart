import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronova/data/chronova_data_store.dart';
import 'package:chronova/data/repositories/in_memory_chronova_repository.dart';
import 'package:chronova/models/reminder_item.dart';
import 'package:chronova/services/notification_service.dart';

void main() {
  group('NotificationService - Unit Tests', () {
    test(
      'reminderIdToNotificationId produces stable, deterministic 31-bit integer IDs',
      () {
        const id1 = 'rem-1';
        const id2 = 'rem-2';
        const uuid1 = '7b9b1e96-a944-48f8-b327-0cf1b54a01a3';
        const uuid2 = '8c0c2fa7-b055-49f9-c438-1df2c65b12b4';

        final notifId1 = NotificationService.reminderIdToNotificationId(id1);
        final notifId2 = NotificationService.reminderIdToNotificationId(id2);
        final notifUuid1 = NotificationService.reminderIdToNotificationId(
          uuid1,
        );
        final notifUuid2 = NotificationService.reminderIdToNotificationId(
          uuid2,
        );

        // Verify positivity and 31-bit signed integer boundary (0 to 0x7FFFFFFF)
        expect(notifId1, greaterThanOrEqualTo(0));
        expect(notifId1, lessThanOrEqualTo(0x7FFFFFFF));
        expect(notifUuid1, greaterThanOrEqualTo(0));
        expect(notifUuid1, lessThanOrEqualTo(0x7FFFFFFF));

        // Verify stability across repeat calls
        expect(
          NotificationService.reminderIdToNotificationId(id1),
          equals(notifId1),
        );
        expect(
          NotificationService.reminderIdToNotificationId(uuid1),
          equals(notifUuid1),
        );

        // Verify uniqueness across distinct strings
        expect(notifId1, isNot(equals(notifId2)));
        expect(notifUuid1, isNot(equals(notifUuid2)));
      },
    );

    test(
      'calculateSnoozedReminder adds configured default snooze duration (10 min)',
      () {
        final service = NotificationService.instance;
        service.setDefaultSnoozeDuration(const Duration(minutes: 10));

        final baseTime = DateTime.now().add(const Duration(minutes: 5));
        final reminder = ReminderItem(
          id: 'rem-test-snooze',
          title: 'Team Standup',
          dueDateTime: baseTime,
          categoryName: 'Work',
          categoryColor: const Color(0xFF4F46E5),
          isDone: true,
          snoozeCount: 0,
        );

        final snoozed = service.calculateSnoozedReminder(reminder);

        expect(snoozed.id, equals(reminder.id));
        expect(snoozed.title, equals(reminder.title));
        expect(snoozed.snoozeCount, equals(1));
        expect(snoozed.isDone, isFalse);
        // New time should be approximately now + 10 minutes
        final diff = snoozed.dueDateTime.difference(DateTime.now()).inMinutes;
        expect(diff, closeTo(10, 1));
      },
    );

    test(
      'calculateSnoozedReminder supports custom snooze duration (5m & 15m)',
      () {
        final service = NotificationService.instance;

        final reminder = ReminderItem(
          id: 'rem-custom',
          title: 'Water Plants',
          dueDateTime: DateTime.now(),
          categoryName: 'Personal',
          categoryColor: const Color(0xFF10B981),
          snoozeCount: 2,
        );

        final snoozed5m = service.calculateSnoozedReminder(
          reminder,
          customDuration: const Duration(minutes: 5),
        );
        expect(snoozed5m.snoozeCount, equals(3));
        final diff5m = snoozed5m.dueDateTime
            .difference(DateTime.now())
            .inMinutes;
        expect(diff5m, closeTo(5, 1));

        final snoozed15m = service.calculateSnoozedReminder(
          reminder,
          customDuration: const Duration(minutes: 15),
        );
        expect(snoozed15m.snoozeCount, equals(3));
        final diff15m = snoozed15m.dueDateTime
            .difference(DateTime.now())
            .inMinutes;
        expect(diff15m, closeTo(15, 1));
      },
    );

    test(
      'scheduleReminder returns false when reminder is completed or alarm is disabled',
      () async {
        final service = NotificationService.instance;

        final doneReminder = ReminderItem(
          id: 'rem-done',
          title: 'Completed Task',
          dueDateTime: DateTime.now().add(const Duration(hours: 1)),
          categoryName: 'General',
          categoryColor: const Color(0xFF4F46E5),
          isDone: true,
          hasAlarm: true,
        );
        final resDone = await service.scheduleReminder(doneReminder);
        expect(resDone, isFalse);

        final noAlarmReminder = ReminderItem(
          id: 'rem-no-alarm',
          title: 'Silent Task',
          dueDateTime: DateTime.now().add(const Duration(hours: 1)),
          categoryName: 'General',
          categoryColor: const Color(0xFF4F46E5),
          isDone: false,
          hasAlarm: false,
        );
        final resNoAlarm = await service.scheduleReminder(noAlarmReminder);
        expect(resNoAlarm, isFalse);
      },
    );

    test(
      'scheduleReminder returns false when due time is in the past',
      () async {
        final service = NotificationService.instance;

        final pastReminder = ReminderItem(
          id: 'rem-past',
          title: 'Past Task',
          dueDateTime: DateTime.now().subtract(const Duration(hours: 2)),
          categoryName: 'General',
          categoryColor: const Color(0xFF4F46E5),
          isDone: false,
          hasAlarm: true,
        );
        final res = await service.scheduleReminder(pastReminder);
        expect(res, isFalse);
      },
    );

    test(
      'ReminderItem JSON serialization preserves alarm, snooze, and UUID fields',
      () {
        const validUuid = '12345678-1234-1234-1234-123456789abc';
        final reminder = ReminderItem(
          id: validUuid,
          title: 'Sync Architecture',
          dueDateTime: DateTime.utc(2026, 10, 20, 14, 30),
          categoryName: 'Work',
          categoryColor: const Color(0xFF4F46E5),
          isDone: true,
          hasAlarm: true,
          snoozeCount: 3,
        );

        final json = reminder.toJson(userId: 'user-xyz');
        expect(json['id'], equals(validUuid));
        expect(json['user_id'], equals('user-xyz'));
        expect(json['title'], equals('Sync Architecture'));
        expect(json['is_done'], isTrue);
        expect(json['has_alarm'], isTrue);
        expect(json['snooze_count'], equals(3));
        expect(json['category_name'], equals('Work'));

        final restored = ReminderItem.fromJson({
          'id': validUuid,
          'title': json['title'],
          'due_date_time': json['due_date_time'],
          'category_name': json['category_name'],
          'category_color': json['category_color'],
          'is_done': json['is_done'],
          'has_alarm': json['has_alarm'],
          'snooze_count': json['snooze_count'],
        });

        expect(restored.id, equals(reminder.id));
        expect(restored.title, equals(reminder.title));
        expect(restored.isDone, equals(reminder.isDone));
        expect(restored.hasAlarm, equals(reminder.hasAlarm));
        expect(restored.snoozeCount, equals(3));
      },
    );
  });

  group('ChronovaDataStore - Reminder Operations & Lifecycle', () {
    late ChronovaDataStore store;
    late InMemoryChronovaRepository mockRepo;

    setUp(() {
      store = ChronovaDataStore.instance;
      mockRepo = InMemoryChronovaRepository();
      store.setRepository(mockRepo);
      store.resetToSampleData();
    });

    test('addReminder inserts reminder and notifies listeners', () async {
      var notified = false;
      store.addListener(() => notified = true);

      final newReminder = ReminderItem(
        id: 'rem-add-test',
        title: 'Deploy Production Release',
        dueDateTime: DateTime.now().add(const Duration(days: 1)),
        categoryName: 'Architecture',
        categoryColor: const Color(0xFF06B6D4),
      );

      await store.addReminder(newReminder);

      expect(notified, isTrue);
      expect(store.reminders.any((r) => r.id == 'rem-add-test'), isTrue);
      expect(store.reminders.first.title, equals('Deploy Production Release'));
    });

    test(
      'updateReminder modifies reminder in-place without duplicating',
      () async {
        final initial = ReminderItem(
          id: 'rem-update-test',
          title: 'Initial Title',
          dueDateTime: DateTime.now().add(const Duration(hours: 3)),
          categoryName: 'Work',
          categoryColor: const Color(0xFF4F46E5),
        );
        await store.addReminder(initial);
        final countBefore = store.reminders.length;

        final updated = initial.copyWith(title: 'Updated Title');
        final success = await store.updateReminder(updated);

        expect(success, isTrue);
        expect(store.reminders.length, equals(countBefore));
        final found = store.reminders.firstWhere(
          (r) => r.id == 'rem-update-test',
        );
        expect(found.title, equals('Updated Title'));
      },
    );

    test('deleteReminder removes item cleanly', () async {
      final item = ReminderItem(
        id: 'rem-del-test',
        title: 'To Be Deleted',
        dueDateTime: DateTime.now().add(const Duration(hours: 1)),
        categoryName: 'Personal',
        categoryColor: const Color(0xFF10B981),
      );
      await store.addReminder(item);
      expect(store.reminders.any((r) => r.id == 'rem-del-test'), isTrue);

      final deleted = await store.deleteReminder('rem-del-test');
      expect(deleted, isTrue);
      expect(store.reminders.any((r) => r.id == 'rem-del-test'), isFalse);
    });

    test('toggleReminder flips isDone state', () async {
      final item = ReminderItem(
        id: 'rem-toggle-test',
        title: 'Toggle Task',
        dueDateTime: DateTime.now().add(const Duration(hours: 2)),
        categoryName: 'Ideas',
        categoryColor: const Color(0xFFF59E0B),
        isDone: false,
      );
      await store.addReminder(item);

      await store.toggleReminder('rem-toggle-test');
      var current = store.reminders.firstWhere(
        (r) => r.id == 'rem-toggle-test',
      );
      expect(current.isDone, isTrue);

      await store.toggleReminder('rem-toggle-test');
      current = store.reminders.firstWhere((r) => r.id == 'rem-toggle-test');
      expect(current.isDone, isFalse);
    });

    test(
      'snoozeReminder updates dueDateTime and increments snoozeCount',
      () async {
        final item = ReminderItem(
          id: 'rem-snooze-test',
          title: 'Call Supplier',
          dueDateTime: DateTime.now().add(const Duration(minutes: 2)),
          categoryName: 'Work',
          categoryColor: const Color(0xFF4F46E5),
          snoozeCount: 0,
        );
        await store.addReminder(item);

        await store.snoozeReminder(
          'rem-snooze-test',
          duration: const Duration(minutes: 15),
        );
        final snoozed = store.reminders.firstWhere(
          (r) => r.id == 'rem-snooze-test',
        );

        expect(snoozed.snoozeCount, equals(1));
        expect(snoozed.isDone, isFalse);
        final diff = snoozed.dueDateTime.difference(DateTime.now()).inMinutes;
        expect(diff, closeTo(15, 1));
      },
    );

    test('Notification callbacks wire successfully to store actions', () {
      final service = NotificationService.instance;
      expect(service.onReminderDone, isNotNull);
      expect(service.onReminderSnoozed, isNotNull);
    });
  });
}
