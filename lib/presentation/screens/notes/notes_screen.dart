import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../widgets/note_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../settings/settings_screen.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteController controller = Get.put(NoteController());
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: controller.updateSearchQuery,
              )
            : const Text('Notes'),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchController.clear();
                    controller.updateSearchQuery('');
                  });
                },
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, size: Responsive.iconSize24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              size: Responsive.iconSize24,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  controller.updateSearchQuery('');
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        final notes = controller.filteredNotes;

        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note,
                  size: Responsive.getWidth(20),
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: Responsive.spacing16),
                Text(
                  'No notes yet',
                  style: TextStyle(
                    fontSize: Responsive.fontSize18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.spacing8),
                Text(
                  'Tap + to create your first note',
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
          itemCount: notes.length,
          onReorder: controller.reorderNotes,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(key: ValueKey(note.id), note: note);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditNoteScreen()),
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
