import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/calendar_event_model.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';

class CalendarController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final NotificationService _notifications = Get.find<NotificationService>();

  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  void loadEvents() {
    events.value = _storage.events.values.toList();
  }

  List<CalendarEventModel> getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }

  Future<void> addEvent({
    required DateTime date,
    required String title,
    String? time,
    String? location,
    DateTime? reminderTime,
    bool alarmEnabled = false,
    int reminderMinutesBefore = 0,
  }) async {
    final event = CalendarEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      time: time,
      location: location,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
      alarmEnabled: alarmEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
    );

    // Schedule notification reminder
    event.notificationId = await _notifications.scheduleEventReminder(event);

    // Schedule alarm if enabled
    if (alarmEnabled) {
      event.alarmNotificationId = await _notifications.scheduleEventAlarm(
        event,
      );
    }

    await _storage.addEvent(event);
    loadEvents();
    Get.back();
    Get.snackbar('Success', 'Event added successfully');
  }

  Future<void> updateEvent(CalendarEventModel event) async {
    // Cancel existing notifications
    await _notifications.cancelEventNotifications(
      notificationId: event.notificationId,
      alarmNotificationId: event.alarmNotificationId,
    );

    // Schedule new reminder notification
    event.notificationId = await _notifications.scheduleEventReminder(event);

    // Schedule new alarm if enabled
    if (event.alarmEnabled) {
      event.alarmNotificationId = await _notifications.scheduleEventAlarm(
        event,
      );
    } else {
      event.alarmNotificationId = null;
    }

    await _storage.updateEvent(event);
    loadEvents();
    Get.back();
    Get.snackbar('Success', 'Event updated successfully');
  }

  Future<void> deleteEvent(String id) async {
    // Cancel notifications before deleting
    final event = _storage.events.get(id);
    if (event != null) {
      await _notifications.cancelEventNotifications(
        notificationId: event.notificationId,
        alarmNotificationId: event.alarmNotificationId,
      );
    }

    await _storage.deleteEvent(id);
    loadEvents();
    Get.back();
    Get.snackbar('Success', 'Event deleted successfully');
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  void previousMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month - 1,
    );
  }

  void nextMonth() {
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month + 1,
    );
  }
}
