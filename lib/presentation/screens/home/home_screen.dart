import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../tasks/tasks_screen.dart';
import '../notes/notes_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    final List<Widget> screens = [
      const TasksScreen(),
      const NotesScreen(),
      const CalendarScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: screens[controller.currentIndex.value],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            selectedFontSize: Responsive.fontSize16,
            unselectedFontSize: Responsive.fontSize14,
            iconSize: Responsive.iconSize28,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.task_alt),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
            ],
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppTheme.secondaryColor,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: Responsive.spacing24),
                Icon(
                  Icons.note_alt,
                  size: Responsive.getWidth(20),
                  color: AppTheme.accentColor,
                ),
                SizedBox(height: Responsive.spacing12),
                Text(
                  'Notes App',
                  style: TextStyle(
                    fontSize: Responsive.fontSize24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.spacing32),
                Divider(color: AppTheme.dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: Text(
                    'Settings & Backup',
                    style: TextStyle(
                      fontSize: Responsive.fontSize16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    Get.to(() => const SettingsScreen());
                  },
                ),
                Divider(color: AppTheme.dividerColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
