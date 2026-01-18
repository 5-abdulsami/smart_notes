import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/calendar_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageService storage = Get.find<StorageService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(Responsive.spacing16),
        children: [
          Text(
            'Data Management',
            style: TextStyle(
              fontSize: Responsive.fontSize20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.spacing16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.backup,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: Text(
                    'Backup Data',
                    style: TextStyle(fontSize: Responsive.fontSize16),
                  ),
                  subtitle: Text(
                    'Export all data to JSON file',
                    style: TextStyle(
                      fontSize: Responsive.fontSize14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: Responsive.iconSize20,
                    color: AppTheme.textSecondary,
                  ),
                  onTap: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    final path = await storage.backupData();
                    Get.back();

                    if (path != null) {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: AppTheme.secondaryColor,
                          title: const Text('Backup Created'),
                          content: Text(
                            'Backup saved successfully!\n\nLocation:\n$path',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                Divider(height: 1, color: AppTheme.dividerColor),
                ListTile(
                  leading: Icon(
                    Icons.restore,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: Text(
                    'Restore Data',
                    style: TextStyle(fontSize: Responsive.fontSize16),
                  ),
                  subtitle: Text(
                    'Import data from JSON backup file',
                    style: TextStyle(
                      fontSize: Responsive.fontSize14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: Responsive.iconSize20,
                    color: AppTheme.textSecondary,
                  ),
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        backgroundColor: AppTheme.secondaryColor,
                        title: const Text('Restore Data'),
                        content: const Text(
                          'This will replace all current data with the backup file. Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Get.back();

                              Get.dialog(
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                barrierDismissible: false,
                              );

                              final success = await storage.restoreData();
                              Get.back();

                              if (success) {
                                if (Get.isRegistered<TaskController>()) {
                                  Get.find<TaskController>().loadTasks();
                                }
                                if (Get.isRegistered<NoteController>()) {
                                  Get.find<NoteController>().loadNotes();
                                }
                                if (Get.isRegistered<CalendarController>()) {
                                  Get.find<CalendarController>().loadEvents();
                                }
                              }
                            },
                            child: const Text('Restore'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing32),
          Text(
            'About',
            style: TextStyle(
              fontSize: Responsive.fontSize20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.spacing16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes App',
                    style: TextStyle(
                      fontSize: Responsive.fontSize18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: Responsive.fontSize14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing12),
                  Text(
                    'A complete notes app with tasks, notes, and calendar features.',
                    style: TextStyle(
                      fontSize: Responsive.fontSize14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
