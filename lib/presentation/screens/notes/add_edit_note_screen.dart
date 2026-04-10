import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/note_model.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final NoteController controller = Get.find<NoteController>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  bool isBold = false;
  bool isUnderline = false;
  double fontSize = 16;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.note?.description ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a note title');
      return;
    }

    if (widget.note == null) {
      controller.addNote(
        titleController.text.trim(),
        descriptionController.text.trim(),
      );
    } else {
      widget.note!.title = titleController.text.trim();
      widget.note!.description = descriptionController.text.trim();
      controller.updateNote(widget.note!);
    }
  }

  void _deleteNote() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteNote(widget.note!.id);
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
          title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
          actions: [
            if (widget.note != null)
              IconButton(
                icon: Icon(Icons.delete, size: Responsive.iconSize24),
                onPressed: _deleteNote,
              ),
            IconButton(
              icon: Icon(Icons.check, size: Responsive.iconSize24),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.spacing16),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                ),
                style: TextStyle(
                  fontSize: Responsive.fontSize18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 10,
                minLines: 1,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.secondaryColor,
              ),

              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing8,
                vertical: Responsive.spacing8,
              ),
              margin: EdgeInsets.symmetric(horizontal: Responsive.spacing16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.format_bold,
                      color: isBold
                          ? AppTheme.accentColor
                          : AppTheme.textSecondary,
                    ),
                    iconSize: Responsive.iconSize20,
                    onPressed: () => setState(() => isBold = !isBold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.format_underline,
                      color: isUnderline
                          ? AppTheme.accentColor
                          : AppTheme.textSecondary,
                    ),
                    iconSize: Responsive.iconSize20,
                    onPressed: () => setState(() => isUnderline = !isUnderline),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted),
                    iconSize: Responsive.iconSize20,
                    color: AppTheme.textSecondary,
                    onPressed: () {
                      final text = descriptionController.text;
                      final selection = descriptionController.selection;
                      final newText = '${text.substring(0, selection.start)}• ';
                      descriptionController.value = TextEditingValue(
                        text: newText + text.substring(selection.start),
                        selection: TextSelection.collapsed(
                          offset: newText.length,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    iconSize: Responsive.iconSize20,
                    color: AppTheme.textSecondary,
                    onPressed: () {
                      final text = descriptionController.text;
                      final selection = descriptionController.selection;
                      final newText = '${text.substring(0, selection.start)}☐ ';
                      descriptionController.value = TextEditingValue(
                        text: newText + text.substring(selection.start),
                        selection: TextSelection.collapsed(
                          offset: newText.length,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  DropdownButton<double>(
                    value: fontSize,
                    dropdownColor: AppTheme.secondaryColor,
                    items: [12.0, 14.0, 16.0, 18.0, 20.0, 24.0].map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(
                          '${size.toInt()}',
                          style: TextStyle(fontSize: Responsive.fontSize14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => fontSize = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppTheme.primaryColor,
                padding: EdgeInsets.all(Responsive.spacing16),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start writing...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.textPrimary,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    decoration: isUnderline ? TextDecoration.underline : null,
                    height: 1.5,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
