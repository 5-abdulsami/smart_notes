import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/presentation/screens/splash/splash_screen.dart';
import 'data/models/task_model.dart';
import 'data/models/note_model.dart';
import 'data/models/calendar_event_model.dart';
import 'data/services/storage_service.dart';
import 'data/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(CalendarEventModelAdapter());

  // Initialize Storage Service
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService);

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  Get.put(notificationService);

  // Reschedule notifications (handles reboot persistence)
  await notificationService.rescheduleAllNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
