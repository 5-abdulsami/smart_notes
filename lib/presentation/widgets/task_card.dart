import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../screens/tasks/add_edit_task_screen.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find<TaskController>();

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.spacing12),
      child: InkWell(
        onTap: () => Get.to(() => AddEditTaskScreen(task: task)),
        borderRadius: BorderRadius.circular(Responsive.radius12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing12),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) => controller.toggleTaskCompletion(task),
              ),
              SizedBox(width: Responsive.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: Responsive.fontSize16,
                        color: AppTheme.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.textSecondary,
                      ),
                    ),
                    if (task.reminderTime != null) ...[
                      SizedBox(height: Responsive.spacing4),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: Responsive.iconSize20,
                            color: AppTheme.accentColor,
                          ),
                          SizedBox(width: Responsive.spacing4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy hh:mm a',
                            ).format(task.reminderTime!),
                            style: TextStyle(
                              fontSize: Responsive.fontSize12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.drag_handle,
                color: AppTheme.textSecondary,
                size: Responsive.iconSize24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
