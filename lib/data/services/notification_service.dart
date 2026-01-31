import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task_model.dart';
import '../models/calendar_event_model.dart';
import 'storage_service.dart';

/// Service for managing local notifications and alarms.
///
/// Handles scheduling, cancellation, and re-registration of notifications
/// for tasks and calendar events. Works completely offline using Android
/// AlarmManager for reliable scheduling.
class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification Channel IDs
  static const String _taskChannelId = 'task_reminders';
  static const String _eventChannelId = 'calendar_reminders';
  static const String _alarmChannelId = 'calendar_alarms';

  // Channel Names
  static const String _taskChannelName = 'Task Reminders';
  static const String _eventChannelName = 'Calendar Reminders';
  static const String _alarmChannelName = 'Calendar Alarms';

  /// Initialize the notification service.
  /// Must be called before using any other methods.
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _requestPermissions();
    }
  }

  /// Request notification permissions (Android 13+)
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Request notification permission
      await androidPlugin.requestNotificationsPermission();
      // Request exact alarm permission
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Can be extended to navigate to specific screens based on payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ==================== Task Notifications ====================

  /// Schedule a notification reminder for a task.
  /// Returns the notification ID, or null if scheduling failed.
  Future<int?> scheduleTaskReminder(TaskModel task) async {
    if (task.reminderTime == null) return null;

    final DateTime scheduledTime = task.reminderTime!;

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('Task reminder time is in the past, skipping: ${task.title}');
      return null;
    }

    final int notificationId = _generateNotificationId(task.id);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: 'Reminders for your tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Task Reminder',
        task.title,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task:${task.id}',
      );

      debugPrint('Scheduled task reminder: ${task.title} at $scheduledTime');
      return notificationId;
    } catch (e) {
      debugPrint('Failed to schedule task reminder: $e');
      return null;
    }
  }

  /// Cancel a task notification.
  Future<void> cancelTaskReminder(int? notificationId) async {
    if (notificationId == null) return;

    try {
      await _notifications.cancel(notificationId);
      debugPrint('Cancelled task notification: $notificationId');
    } catch (e) {
      debugPrint('Failed to cancel task notification: $e');
    }
  }

  // ==================== Calendar Event Notifications ====================

  /// Schedule a notification reminder for a calendar event.
  /// Returns the notification ID, or null if scheduling failed.
  Future<int?> scheduleEventReminder(CalendarEventModel event) async {
    DateTime? scheduledTime = _calculateEventReminderTime(event);
    if (scheduledTime == null) return null;

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint(
        'Event reminder time is in the past, skipping: ${event.title}',
      );
      return null;
    }

    final int notificationId = _generateNotificationId(event.id);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _eventChannelId,
          _eventChannelName,
          channelDescription: 'Reminders for your calendar events',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.event,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Event Reminder',
        _buildEventNotificationBody(event),
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'event:${event.id}',
      );

      debugPrint('Scheduled event reminder: ${event.title} at $scheduledTime');
      return notificationId;
    } catch (e) {
      debugPrint('Failed to schedule event reminder: $e');
      return null;
    }
  }

  /// Schedule an alarm-style notification for a calendar event.
  /// Shows heads-up notification with alarm sound.
  /// Returns the notification ID, or null if scheduling failed.
  Future<int?> scheduleEventAlarm(CalendarEventModel event) async {
    if (!event.alarmEnabled) return null;

    DateTime? scheduledTime = _calculateEventReminderTime(event);
    if (scheduledTime == null) return null;

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('Event alarm time is in the past, skipping: ${event.title}');
      return null;
    }

    // Use a different ID for alarms (offset by a large number)
    final int notificationId = _generateNotificationId(event.id) + 100000;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: 'Alarm alerts for calendar events',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        '⏰ Event Alarm',
        _buildEventNotificationBody(event),
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'alarm:${event.id}',
      );

      debugPrint('Scheduled event alarm: ${event.title} at $scheduledTime');
      return notificationId;
    } catch (e) {
      debugPrint('Failed to schedule event alarm: $e');
      return null;
    }
  }

  /// Cancel all notifications for a calendar event (reminder + alarm).
  Future<void> cancelEventNotifications({
    int? notificationId,
    int? alarmNotificationId,
  }) async {
    if (notificationId != null) {
      try {
        await _notifications.cancel(notificationId);
        debugPrint('Cancelled event notification: $notificationId');
      } catch (e) {
        debugPrint('Failed to cancel event notification: $e');
      }
    }

    if (alarmNotificationId != null) {
      try {
        await _notifications.cancel(alarmNotificationId);
        debugPrint('Cancelled event alarm: $alarmNotificationId');
      } catch (e) {
        debugPrint('Failed to cancel event alarm: $e');
      }
    }
  }

  // ==================== Reboot Handler ====================

  /// Re-schedule all notifications after device reboot.
  /// Should be called on app startup.
  Future<void> rescheduleAllNotifications() async {
    try {
      final StorageService storage = Get.find<StorageService>();

      // Reschedule task notifications
      for (final task in storage.tasks.values) {
        if (task.reminderTime != null && !task.isCompleted) {
          final newId = await scheduleTaskReminder(task);
          if (newId != null && newId != task.notificationId) {
            task.notificationId = newId;
            await storage.updateTask(task);
          }
        }
      }

      // Reschedule event notifications
      for (final event in storage.events.values) {
        // Reschedule reminder
        final newReminderId = await scheduleEventReminder(event);
        bool needsUpdate = false;

        if (newReminderId != null && newReminderId != event.notificationId) {
          event.notificationId = newReminderId;
          needsUpdate = true;
        }

        // Reschedule alarm
        if (event.alarmEnabled) {
          final newAlarmId = await scheduleEventAlarm(event);
          if (newAlarmId != null && newAlarmId != event.alarmNotificationId) {
            event.alarmNotificationId = newAlarmId;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          await storage.updateEvent(event);
        }
      }

      debugPrint('Rescheduled all notifications after reboot/startup');
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  // ==================== Helper Methods ====================

  /// Generate a consistent notification ID from a string ID.
  int _generateNotificationId(String id) {
    return id.hashCode.abs() % 2147483647; // Keep within int32 range
  }

  /// Calculate the reminder time for an event based on settings.
  DateTime? _calculateEventReminderTime(CalendarEventModel event) {
    // First, try to use the explicit reminderTime if set
    if (event.reminderTime != null) {
      return event.reminderTime;
    }

    // Otherwise, calculate based on event date/time and reminderMinutesBefore
    DateTime eventDateTime = event.date;

    // If time is specified, parse it
    if (event.time != null && event.time!.isNotEmpty) {
      final timeParts = event.time!.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        eventDateTime = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
          hour,
          minute,
        );
      }
    }

    // Subtract reminder minutes
    return eventDateTime.subtract(
      Duration(minutes: event.reminderMinutesBefore),
    );
  }

  /// Build a notification body for an event.
  String _buildEventNotificationBody(CalendarEventModel event) {
    final buffer = StringBuffer(event.title);

    if (event.time != null && event.time!.isNotEmpty) {
      buffer.write(' at ${event.time}');
    }

    if (event.location != null && event.location!.isNotEmpty) {
      buffer.write(' - ${event.location}');
    }

    return buffer.toString();
  }

  /// Cancel all pending notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }
}
