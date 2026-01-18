import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../models/note_model.dart';
import '../models/calendar_event_model.dart';

class StorageService extends GetxService {
  static const String tasksBox = 'tasks';
  static const String notesBox = 'notes';
  static const String eventsBox = 'events';

  Box<TaskModel>? _tasksBox;
  Box<NoteModel>? _notesBox;
  Box<CalendarEventModel>? _eventsBox;

  Box<TaskModel> get tasks => _tasksBox!;
  Box<NoteModel> get notes => _notesBox!;
  Box<CalendarEventModel> get events => _eventsBox!;

  Future<void> init() async {
    _tasksBox = await Hive.openBox<TaskModel>(tasksBox);
    _notesBox = await Hive.openBox<NoteModel>(notesBox);
    _eventsBox = await Hive.openBox<CalendarEventModel>(eventsBox);
  }

  // Backup all data to JSON with Custom Location
  Future<String?> backupData() async {
    try {
      final Map<String, dynamic> backup = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'tasks': tasks.values.map((task) => task.toJson()).toList(),
        'notes': notes.values.map((note) => note.toJson()).toList(),
        'events': events.values.map((event) => event.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final fileName =
          'notes_app_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      // Let user choose where to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select where to save your backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonString),
      );

      if (outputFile == null) return null; // User canceled

      // For some platforms, saveFile handles writing if bytes are provided,
      // but for reliability across all, we write manually if needed:
      final file = File(outputFile);
      await file.writeAsString(jsonString);

      Get.snackbar(
        'Success',
        'Backup saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return outputFile;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create backup: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Restore data from JSON file
  Future<bool> restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(jsonString);

      // Clear existing data
      await tasks.clear();
      await notes.clear();
      await events.clear();

      // Restore tasks
      if (backup['tasks'] != null) {
        for (var taskJson in backup['tasks']) {
          final task = TaskModel.fromJson(taskJson);
          await tasks.put(task.id, task);
        }
      }

      // Restore notes
      if (backup['notes'] != null) {
        for (var noteJson in backup['notes']) {
          final note = NoteModel.fromJson(noteJson);
          await notes.put(note.id, note);
        }
      }

      // Restore events
      if (backup['events'] != null) {
        for (var eventJson in backup['events']) {
          final event = CalendarEventModel.fromJson(eventJson);
          await events.put(event.id, event);
        }
      }

      Get.snackbar(
        'Success',
        'Data restored successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to restore data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Task operations
  Future<void> addTask(TaskModel task) async => await tasks.put(task.id, task);
  Future<void> updateTask(TaskModel task) async =>
      await tasks.put(task.id, task);
  Future<void> deleteTask(String id) async => await tasks.delete(id);

  // Note operations
  Future<void> addNote(NoteModel note) async => await notes.put(note.id, note);
  Future<void> updateNote(NoteModel note) async =>
      await notes.put(note.id, note);
  Future<void> deleteNote(String id) async => await notes.delete(id);

  // Event operations
  Future<void> addEvent(CalendarEventModel event) async =>
      await events.put(event.id, event);
  Future<void> updateEvent(CalendarEventModel event) async =>
      await events.put(event.id, event);
  Future<void> deleteEvent(String id) async => await events.delete(id);
}
