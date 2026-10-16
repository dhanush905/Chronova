import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_item.dart';

/// Top-level background action handler for notification actions (Android).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    '[NotificationService] Background notification action: '
    'actionId=${notificationResponse.actionId}, payload=${notificationResponse.payload}',
  );
}

/// Status of notification permissions on the host platform.
class NotificationPermissionInfo {
  final bool notificationsEnabled;
  final bool exactAlarmsAllowed;
  final String description;

  const NotificationPermissionInfo({
    required this.notificationsEnabled,
    required this.exactAlarmsAllowed,
    required this.description,
  });
}

/// Core service managing native scheduled alarms and notifications for Chronova.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  Duration _defaultSnoozeDuration = const Duration(minutes: 10);

  // Callback hooks for UI or store integration
  void Function(String reminderId)? onReminderDone;
  void Function(String reminderId, Duration snoozeDuration)? onReminderSnoozed;

  NotificationService._internal({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Visible for testing to inject a custom plugin or test harness.
  @visibleForTesting
  factory NotificationService.withPlugin(
    FlutterLocalNotificationsPlugin plugin,
  ) {
    return NotificationService._internal(plugin: plugin);
  }

  bool get isInitialized => _isInitialized;
  Duration get defaultSnoozeDuration => _defaultSnoozeDuration;

  /// Whether platform channels are ready or if running in headless test/web environment.
  static bool get isPlatformChannelAvailable {
    if (kIsWeb) return false;
    try {
      FlutterLocalNotificationsPlatform.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sets the user-configured default snooze duration (5, 10, or 15 minutes).
  void setDefaultSnoozeDuration(Duration duration) {
    _defaultSnoozeDuration = duration;
  }

  /// Converts a reminder string ID into a deterministic, stable 31-bit integer notification ID.
  /// This prevents duplicate notifications when editing or rescheduling reminders.
  static int reminderIdToNotificationId(String reminderId) {
    var hash = 0;
    for (var i = 0; i < reminderId.length; i++) {
      hash = (31 * hash + reminderId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Initializes timezone data and native notification channels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    try {
      tz.initializeTimeZones();
      final timeZoneName = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        // Fallback to UTC if device timezone abbreviation is not in database
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('[NotificationService] Timezone initialization error: $e');
    }

    if (kIsWeb || !isPlatformChannelAvailable) {
      _isInitialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization failed: $e');
      _isInitialized = false;
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final reminderId = response.payload;
    if (reminderId == null || reminderId.isEmpty) return;

    if (actionId == 'action_done') {
      onReminderDone?.call(reminderId);
    } else if (actionId == 'action_snooze') {
      onReminderSnoozed?.call(reminderId, _defaultSnoozeDuration);
    }
  }

  /// Requests notification and exact alarm permissions where applicable.
  Future<NotificationPermissionInfo> requestPermissions() async {
    if (!isPlatformChannelAvailable) {
      return NotificationPermissionInfo(
        notificationsEnabled: true,
        exactAlarmsAllowed: true,
        description: kIsWeb
            ? 'Web platform • In-app alerts active'
            : 'Simulated environment active',
      );
    }

    var notifsEnabled = false;
    var exactAllowed = false;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        if (androidPlugin != null) {
          try {
            notifsEnabled =
                await androidPlugin.requestNotificationsPermission() ?? false;
          } catch (e) {
            debugPrint(
              '[NotificationService] requestNotificationsPermission failed: $e',
            );
          }

          try {
            exactAllowed =
                await androidPlugin.requestExactAlarmsPermission() ?? false;
          } catch (e) {
            debugPrint(
              '[NotificationService] requestExactAlarmsPermission failed: $e',
            );
          }
        }
      } else {
        notifsEnabled = true;
        exactAllowed = true;
      }
    } catch (e) {
      debugPrint('[NotificationService] requestPermissions fallback: $e');
      notifsEnabled = true;
      exactAllowed = true;
    }

    return NotificationPermissionInfo(
      notificationsEnabled: notifsEnabled,
      exactAlarmsAllowed: exactAllowed,
      description: notifsEnabled
          ? (exactAllowed
                ? 'Exact alarms & notifications enabled'
                : 'Notifications allowed; exact alarm permission optional')
          : 'Notification permissions denied',
    );
  }

  /// Inspects current permission status without prompting user.
  Future<NotificationPermissionInfo> checkPermissionStatus() async {
    if (!isPlatformChannelAvailable) {
      return NotificationPermissionInfo(
        notificationsEnabled: true,
        exactAlarmsAllowed: true,
        description: kIsWeb
            ? 'Web platform • In-app alerts active'
            : 'Simulated environment active',
      );
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          final notifs = await androidPlugin.areNotificationsEnabled() ?? false;
          final exact =
              await androidPlugin.canScheduleExactNotifications() ?? false;
          return NotificationPermissionInfo(
            notificationsEnabled: notifs,
            exactAlarmsAllowed: exact,
            description: notifs
                ? (exact
                      ? 'Alarms & notifications active'
                      : 'Exact alarms restricted')
                : 'Notifications disabled in system settings',
          );
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] checkPermissionStatus fallback: $e');
      return const NotificationPermissionInfo(
        notificationsEnabled: true,
        exactAlarmsAllowed: true,
        description: 'Environment active',
      );
    }

    return const NotificationPermissionInfo(
      notificationsEnabled: true,
      exactAlarmsAllowed: true,
      description: 'Platform active',
    );
  }

  /// Schedules or updates a notification for a reminder.
  /// If the reminder is marked done, has alarm disabled, or is in the past, existing alarms are cancelled.
  Future<bool> scheduleReminder(ReminderItem reminder) async {
    final notificationId = reminderIdToNotificationId(reminder.id);

    // If reminder is done or has alarm disabled, cancel any scheduled notification
    if (reminder.isDone || !reminder.hasAlarm) {
      await cancelReminder(reminder.id);
      return false;
    }

    final now = DateTime.now();
    if (reminder.dueDateTime.isBefore(now)) {
      // Due time has already elapsed. Cancel any stale notification.
      await cancelReminder(reminder.id);
      return false;
    }

    if (!isPlatformChannelAvailable) {
      return true;
    }

    if (!_isInitialized) {
      await initialize();
    }

    final tzDateTime = tz.TZDateTime.from(
      reminder.dueDateTime.toUtc(),
      tz.getLocation('UTC'),
    );

    const androidDetails = AndroidNotificationDetails(
      'chronova_reminders',
      'Chronova Reminders',
      channelDescription: 'Scheduled reminders, alerts, and priority tasks',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_snooze',
          'Snooze',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'action_done',
          'Mark as Done',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      // Attempt exact alarm first
      await _plugin.zonedSchedule(
        id: notificationId,
        title: reminder.title,
        body:
            'Due at ${reminder.dueDateTime.hour}:${reminder.dueDateTime.minute.toString().padLeft(2, '0')} • ${reminder.categoryName}',
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id,
      );
      return true;
    } catch (e) {
      debugPrint(
        '[NotificationService] Exact alarm failed, trying inexact: $e',
      );
      try {
        // Fallback to inexact alarm if exact alarm permission is missing
        await _plugin.zonedSchedule(
          id: notificationId,
          title: reminder.title,
          body: 'Due: ${reminder.categoryName}',
          scheduledDate: tzDateTime,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.id,
        );
        return true;
      } catch (e2) {
        debugPrint(
          '[NotificationService] Failed to schedule notification: $e2',
        );
        return false;
      }
    }
  }

  /// Cancels any scheduled notification for the given reminder ID.
  Future<void> cancelReminder(String reminderId) async {
    final notificationId = reminderIdToNotificationId(reminderId);
    if (!isPlatformChannelAvailable) return;

    try {
      await _plugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('[NotificationService] Cancel notification failed: $e');
    }
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    if (!isPlatformChannelAvailable) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[NotificationService] Cancel all failed: $e');
    }
  }

  /// Restores scheduled notifications for all active future reminders.
  /// Called upon app launch or session initialization to ensure Android alarms survive restarts.
  Future<void> syncReminders(List<ReminderItem> reminders) async {
    final now = DateTime.now();
    for (final reminder in reminders) {
      if (!reminder.isDone &&
          reminder.hasAlarm &&
          reminder.dueDateTime.isAfter(now)) {
        await scheduleReminder(reminder);
      } else {
        await cancelReminder(reminder.id);
      }
    }
  }

  /// Computes a snoozed ReminderItem by adding snooze duration and incrementing snoozeCount.
  ReminderItem calculateSnoozedReminder(
    ReminderItem reminder, {
    Duration? customDuration,
  }) {
    final duration = customDuration ?? _defaultSnoozeDuration;
    return reminder.copyWith(
      dueDateTime: DateTime.now().add(duration),
      snoozeCount: reminder.snoozeCount + 1,
      isDone: false,
    );
  }
}
