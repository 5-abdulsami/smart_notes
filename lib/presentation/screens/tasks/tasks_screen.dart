import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/task_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../settings/settings_screen.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.put(TaskController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: Responsive.iconSize24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.showCompleted.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                size: Responsive.iconSize24,
              ),
              onPressed: controller.toggleCompletedFilter,
              tooltip: controller.showCompleted.value
                  ? 'Hide completed'
                  : 'Show completed',
            ),
          ),
        ],
      ),
      body: Obx(() {
        final tasks = controller.filteredTasks;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: Responsive.getWidth(20),
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: Responsive.spacing16),
                Text(
                  'No tasks yet',
                  style: TextStyle(
                    fontSize: Responsive.fontSize18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.spacing8),
                Text(
                  'Tap + to create your first task',
                  style: TextStyle(
                    fontSize: Responsive.fontSize14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: EdgeInsets.all(Responsive.spacing16),
          itemCount: tasks.length,
          onReorder: controller.reorderTasks,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(key: ValueKey(task.id), task: task);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditTaskScreen()),
        child: Icon(Icons.add, size: Responsive.iconSize28),
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
    );
  }
}
