import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/category_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/quill_helper.dart';
import '../../../data/models/note_model.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final NoteController controller = Get.find<NoteController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  late TextEditingController titleController;
  late QuillController quillController;
  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');

    final doc = QuillHelper.parseDescription(widget.note?.description);
    quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (widget.note != null) {
      selectedCategoryId = widget.note!.categoryId;
    } else {
      if (controller.selectedCategoryId.value != 'all') {
        selectedCategoryId = controller.selectedCategoryId.value;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a note title');
      return;
    }

    final descriptionJson = QuillHelper.documentToJson(quillController.document);

    if (widget.note == null) {
      controller.addNote(
        titleController.text.trim(),
        descriptionJson,
        categoryId: selectedCategoryId,
      );
    } else {
      widget.note!.title = titleController.text.trim();
      widget.note!.description = descriptionJson;
      widget.note!.categoryId = selectedCategoryId;
      controller.updateNote(widget.note!);
    }
  }

  void _copyDescription() {
    final plainText = quillController.document.toPlainText().trim();
    if (plainText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: plainText));
      Get.snackbar(
        'Copied',
        'Description copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.secondaryColor,
        colorText: AppTheme.textPrimary,
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copyDescription,
            tooltip: 'Copy text',
          ),
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
              maxLines: 1,
            ),
          ),
          Obx(() {
            final categories = categoryController.categories;
            if (categories.isEmpty) return const SizedBox.shrink();

            return Container(
              height: Responsive.spacing40,
              margin: EdgeInsets.only(bottom: Responsive.spacing8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: Responsive.spacing16),
                children: [
                  ChoiceChip(
                    label: const Text('Uncategorized'),
                    selected: selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() => selectedCategoryId = null);
                    },
                  ),
                  SizedBox(width: Responsive.spacing8),
                  ...categories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: Responsive.spacing8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: selectedCategoryId == category.id,
                        onSelected: (selected) {
                          setState(() => selectedCategoryId =
                              selected ? category.id : null);
                        },
                        selectedColor: AppTheme.accentColor.withValues(alpha: 0.3),
                        checkmarkColor: AppTheme.accentColor,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.secondaryColor,
            ),
            margin: EdgeInsets.symmetric(horizontal: Responsive.spacing16),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing4,
              vertical: Responsive.spacing4,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: QuillSimpleToolbar(
                controller: quillController,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: true,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showInlineCode: false,
                  showColorButton: true,
                  showBackgroundColorButton: true,
                  showClearFormat: true,
                  showAlignmentButtons: true,
                  showHeaderStyle: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showListCheck: true,
                  showCodeBlock: false,
                  showQuote: true,
                  showIndent: true,
                  showLink: true,
                  showSubscript: false,
                  showSuperscript: false,
                  showSearchButton: false,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing8),
          Expanded(
            child: Container(
              color: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing16,
                vertical: Responsive.spacing8,
              ),
              child: QuillEditor(
                controller: quillController,
                scrollController: editorScrollController,
                focusNode: editorFocusNode,
                config: QuillEditorConfig(
                  placeholder: 'Start writing...',
                  scrollable: true,
                  autoFocus: false,
                  expands: true,
                  padding: EdgeInsets.zero,
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: Responsive.fontSize16,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
