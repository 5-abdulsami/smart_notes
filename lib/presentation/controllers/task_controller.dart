import 'package:get/get.dart';
import '../../data/models/task_model.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';

class TaskController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final NotificationService _notifications = Get.find<NotificationService>();

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool showCompleted = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void loadTasks() {
    final allTasks = _storage.tasks.values.toList();
    allTasks.sort((a, b) => a.order.compareTo(b.order));
    tasks.value = allTasks;
  }

  List<TaskModel> get filteredTasks {
    if (showCompleted.value) {
      return tasks;
    }
    return tasks.where((task) => !task.isCompleted).toList();
  }

  Future<void> addTask(String title, DateTime? reminderTime) async {
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
      order: tasks.length,
    );

    // Schedule notification if reminder time is set
    if (reminderTime != null) {
      task.notificationId = await _notifications.scheduleTaskReminder(task);
    }

    await _storage.addTask(task);
    loadTasks();
    Get.back();
    Get.snackbar('Success', 'Task added successfully');
  }

  Future<void> updateTask(TaskModel task) async {
    // Cancel existing notification
    await _notifications.cancelTaskReminder(task.notificationId);

    // Schedule new notification if reminder time is set
    if (task.reminderTime != null && !task.isCompleted) {
      task.notificationId = await _notifications.scheduleTaskReminder(task);
    } else {
      task.notificationId = null;
    }

    await _storage.updateTask(task);
    loadTasks();
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    task.isCompleted = !task.isCompleted;

    // Cancel notification when task is completed
    if (task.isCompleted) {
      await _notifications.cancelTaskReminder(task.notificationId);
      task.notificationId = null;
    } else if (task.reminderTime != null) {
      // Reschedule notification if task is uncompleted and has reminder
      task.notificationId = await _notifications.scheduleTaskReminder(task);
    }

    await _storage.updateTask(task);
    loadTasks();
  }

  Future<void> deleteTask(String id) async {
    // Cancel notification before deleting
    final task = _storage.tasks.get(id);
    if (task != null) {
      await _notifications.cancelTaskReminder(task.notificationId);
    }

    await _storage.deleteTask(id);
    loadTasks();
    Get.back();
    Get.snackbar('Success', 'Task deleted successfully');
  }

  void toggleCompletedFilter() {
    showCompleted.value = !showCompleted.value;
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    // Update order for all tasks
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].order = i;
      await _storage.updateTask(tasks[i]);
    }

    loadTasks();
  }
}
