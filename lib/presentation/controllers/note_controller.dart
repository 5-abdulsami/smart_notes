import 'package:get/get.dart';
import '../../data/models/note_model.dart';
import '../../data/services/storage_service.dart';

class NoteController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<NoteModel> notes = <NoteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void loadNotes() {
    final allNotes = _storage.notes.values.toList();
    allNotes.sort((a, b) => a.order.compareTo(b.order));
    notes.value = allNotes;
  }

  Future<void> addNote(String title, String description) async {
    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      order: notes.length,
    );

    await _storage.addNote(note);
    loadNotes();
    Get.back();
    Get.snackbar('Success', 'Note added successfully');
  }

  Future<void> updateNote(NoteModel note) async {
    note.updatedAt = DateTime.now();
    await _storage.updateNote(note);
    loadNotes();
    Get.back();
    Get.snackbar('Success', 'Note updated successfully');
  }

  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    loadNotes();
    Get.back();
    Get.snackbar('Success', 'Note deleted successfully');
  }

  Future<void> reorderNotes(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final note = notes.removeAt(oldIndex);
    notes.insert(newIndex, note);

    // Update order for all notes
    for (int i = 0; i < notes.length; i++) {
      notes[i].order = i;
      await _storage.updateNote(notes[i]);
    }

    loadNotes();
  }
}
