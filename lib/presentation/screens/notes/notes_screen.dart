import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/category_controller.dart';
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
  final CategoryController categoryController = Get.put(CategoryController());
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Add Category'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                categoryController.addCategory(nameController.text.trim());
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
            : Obx(() {
                final categoryId = controller.selectedCategoryId.value;
                if (categoryId == 'all') return const Text('Notes');
                final category = categoryController.categories.firstWhereOrNull(
                  (c) => c.id == categoryId,
                );
                return Text(category?.name ?? 'Notes');
              }),
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
                'Notes Categories',
                style: TextStyle(
                  fontSize: Responsive.fontSize20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.spacing24),
              const Divider(color: AppTheme.dividerColor),
              Expanded(
                child: Obx(() {
                  final categories = categoryController.categories;
                  final selectedId = controller.selectedCategoryId.value;

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.notes,
                          color: selectedId == 'all'
                              ? AppTheme.accentColor
                              : AppTheme.textSecondary,
                        ),
                        title: Text(
                          'All Notes',
                          style: TextStyle(
                            color: selectedId == 'all'
                                ? AppTheme.accentColor
                                : AppTheme.textPrimary,
                            fontWeight: selectedId == 'all'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          controller.setCategory('all');
                          Get.back();
                        },
                      ),
                      ...categories.map((category) {
                        final isSelected = selectedId == category.id;
                        return ListTile(
                          leading: Icon(
                            Icons.label,
                            color: isSelected
                                ? AppTheme.accentColor
                                : Color(category.colorValue),
                          ),
                          title: Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.accentColor
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () =>
                                categoryController.deleteCategory(category.id),
                          ),
                          onTap: () {
                            controller.setCategory(category.id);
                            Get.back();
                          },
                        );
                      }).toList(),
                      ListTile(
                        leading: const Icon(
                          Icons.add,
                          color: AppTheme.textSecondary,
                        ),
                        title: const Text(
                          'Add Category',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        onTap: _showAddCategoryDialog,
                      ),
                    ],
                  );
                }),
              ),
              const Divider(color: AppTheme.dividerColor),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: AppTheme.accentColor,
                ),
                title: const Text('Settings & Backup'),
                onTap: () {
                  Get.back();
                  Get.to(() => const SettingsScreen());
                },
              ),
              SizedBox(height: Responsive.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
