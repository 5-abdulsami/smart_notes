import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class QuillHelper {
  /// Parses a description string into a [Document].
  /// Handles both Quill Delta JSON format and legacy plain text strings.
  static Document parseDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return Document();
    }
    try {
      final decoded = jsonDecode(description);
      if (decoded is List && decoded.isNotEmpty) {
        return Document.fromJson(decoded);
      }
    } catch (_) {
      // Fallback for non-JSON or legacy plain text
    }
    final text = description.endsWith('\n') ? description : '$description\n';
    try {
      return Document.fromJson([
        {'insert': text}
      ]);
    } catch (_) {
      return Document();
    }
  }

  /// Converts a Quill [Document] to a JSON string for Hive database storage.
  static String documentToJson(Document document) {
    try {
      final deltaJson = document.toDelta().toJson();
      return jsonEncode(deltaJson);
    } catch (_) {
      return jsonEncode([
        {'insert': '${document.toPlainText().trim()}\n'}
      ]);
    }
  }

  /// Extracts plain text from a note description string.
  /// Useful for search index matching and list card previews.
  static String toPlainText(String? description) {
    if (description == null || description.trim().isEmpty) {
      return '';
    }
    try {
      final decoded = jsonDecode(description);
      if (decoded is List && decoded.isNotEmpty) {
        final doc = Document.fromJson(decoded);
        return doc.toPlainText().trim();
      }
    } catch (_) {
      // Return raw string if not JSON
    }
    return description.trim();
  }
}
