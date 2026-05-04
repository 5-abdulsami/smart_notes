import 'package:get/get.dart';
import '../../data/models/note_model.dart';
import '../../data/services/storage_service.dart';

class NoteController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void loadNotes() {
    final allNotes = _storage.notes.values.toList();
    // Sort: Pinned first, then by order
    allNotes.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }
      return a.order.compareTo(b.order);
    });
    notes.value = allNotes;
  }

  List<NoteModel> get filteredNotes {
    var filtered = notes.toList();

    // Category Filter
    if (selectedCategoryId.value != 'all') {
      filtered = filtered
          .where((note) => note.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Search Filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            note.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> addNote(
    String title,
    String description, {
    double fontSize = 16.0,
    bool isBold = false,
    bool isUnderline = false,
    String? categoryId,
  }) async {
    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      order: 0,
      fontSize: fontSize,
      isBold: isBold,
      isUnderline: isUnderline,
      categoryId: categoryId,
    );

    // Shift all existing notes' orders
    for (var n in notes) {
      n.order++;
      await _storage.updateNote(n);
    }

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

  void setCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<void> togglePin(NoteModel note) async {
    note.isPinned = !note.isPinned;
    await _storage.updateNote(note);
    loadNotes();
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
