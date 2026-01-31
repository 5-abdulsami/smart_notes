import 'package:hive/hive.dart';

part 'calendar_event_model.g.dart';

@HiveType(typeId: 2)
class CalendarEventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? time;

  @HiveField(4)
  String? location;

  @HiveField(5)
  DateTime? reminderTime;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  int? notificationId;

  @HiveField(8)
  int? alarmNotificationId;

  @HiveField(9)
  bool alarmEnabled;

  @HiveField(10)
  int reminderMinutesBefore;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.location,
    this.reminderTime,
    required this.createdAt,
    this.notificationId,
    this.alarmNotificationId,
    this.alarmEnabled = false,
    this.reminderMinutesBefore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'reminderTime': reminderTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
      'alarmNotificationId': alarmNotificationId,
      'alarmEnabled': alarmEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      notificationId: json['notificationId'],
      alarmNotificationId: json['alarmNotificationId'],
      alarmEnabled: json['alarmEnabled'] ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 0,
    );
  }
}
