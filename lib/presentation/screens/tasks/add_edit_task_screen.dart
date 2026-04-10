import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/presentation/widgets/primary_button.dart';
import '../../controllers/task_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TaskController controller = Get.find<TaskController>();
  late TextEditingController titleController;
  DateTime? reminderTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    reminderTime = widget.task?.reminderTime;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentColor,
              surface: AppTheme.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(reminderTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.accentColor,
                surface: AppTheme.secondaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a task title');
      return;
    }

    if (widget.task == null) {
      controller.addTask(titleController.text.trim(), reminderTime);
    } else {
      widget.task!.title = titleController.text.trim();
      widget.task!.reminderTime = reminderTime;
      controller.updateTask(widget.task!);
      Get.back();
      Get.snackbar('Success', 'Task updated successfully');
    }
  }

  void _deleteTask() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTask(widget.task!.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
          actions: widget.task != null
              ? [
                  IconButton(
                    icon: Icon(Icons.delete, size: Responsive.iconSize24),
                    onPressed: _deleteTask,
                  ),
                ]
              : null,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
                style: TextStyle(fontSize: Responsive.fontSize16),
                maxLines: 10,
                minLines: 1,
              ),
              SizedBox(height: Responsive.spacing24),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: AppTheme.accentColor,
                    size: Responsive.iconSize24,
                  ),
                  title: Text(
                    'Reminder',
                    style: TextStyle(fontSize: Responsive.fontSize16),
                  ),
                  subtitle: Text(
                    reminderTime != null
                        ? DateFormat(
                            'MMM dd, yyyy hh:mm a',
                          ).format(reminderTime!)
                        : 'No reminder set',
                    style: TextStyle(
                      fontSize: Responsive.fontSize14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: reminderTime != null
                      ? IconButton(
                          icon: Icon(Icons.clear, size: Responsive.iconSize20),
                          onPressed: () => setState(() => reminderTime = null),
                        )
                      : null,
                  onTap: _selectReminderTime,
                ),
              ),
              SizedBox(height: Responsive.spacing32),
              PrimaryButton(text: 'Save', onTap: _saveTask),
            ],
          ),
        ),
      ),
    );
  }
}
