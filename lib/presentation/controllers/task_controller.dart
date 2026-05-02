import 'package:get/get.dart';
import '../../data/models/task_model.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';

class TaskController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final NotificationService _notifications = Get.find<NotificationService>();

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxBool showCompleted = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void loadTasks() {
    final allTasks = _storage.tasks.values.toList();
    // Sort: Pinned first, then by order
    allTasks.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }
      return a.order.compareTo(b.order);
    });
    tasks.value = allTasks;
  }

  List<TaskModel> get filteredTasks {
    List<TaskModel> result = tasks;

    // Filter by completion
    if (!showCompleted.value) {
      result = result.where((task) => !task.isCompleted).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      result = result.where((task) {
        return task.title.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    return result;
  }

  Future<void> addTask(String title, DateTime? reminderTime) async {
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
      order: 0, // Set to 0 to be at top
    );

    // Schedule notification if reminder time is set
    if (reminderTime != null) {
      task.notificationId = await _notifications.scheduleTaskReminder(task);
    }

    // Shift all existing tasks' orders
    for (var t in tasks) {
      t.order++;
      await _storage.updateTask(t);
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

  Future<void> togglePin(TaskModel task) async {
    task.isPinned = !task.isPinned;
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
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
