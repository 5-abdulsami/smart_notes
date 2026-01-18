import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/note_model.dart';
import '../../core/utils/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../screens/notes/add_edit_note_screen.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final preview = note.description.length > 100
        ? '${note.description.substring(0, 100)}...'
        : note.description;

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.spacing12),
      child: InkWell(
        onTap: () => Get.to(() => AddEditNoteScreen(note: note)),
        borderRadius: BorderRadius.circular(Responsive.radius12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.spacing16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: Responsive.fontSize18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (preview.isNotEmpty) ...[
                      SizedBox(height: Responsive.spacing8),
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: Responsive.fontSize14,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: Responsive.spacing8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(note.createdAt),
                      style: TextStyle(
                        fontSize: Responsive.fontSize12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.drag_handle,
                color: AppTheme.textSecondary,
                size: Responsive.iconSize24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
