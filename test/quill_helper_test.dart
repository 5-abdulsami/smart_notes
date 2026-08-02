import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/core/utils/quill_helper.dart';

void main() {
  group('QuillHelper Tests', () {
    test('parseDescription should handle plain text correctly', () {
      const plainText = 'Meeting notes point 1\nPoint 2';
      final doc = QuillHelper.parseDescription(plainText);
      expect(doc.toPlainText().trim(), equals('Meeting notes point 1\nPoint 2'));
    });

    test('documentToJson and parseDescription roundtrip should preserve content', () {
      const initialText = 'Formatted text test';
      final doc = QuillHelper.parseDescription(initialText);
      final jsonStr = QuillHelper.documentToJson(doc);
      
      final restoredDoc = QuillHelper.parseDescription(jsonStr);
      expect(restoredDoc.toPlainText().trim(), equals(initialText));
    });

    test('toPlainText should extract clean text from both raw text and JSON Delta', () {
      const rawText = 'Raw note text';
      expect(QuillHelper.toPlainText(rawText), equals('Raw note text'));

      final doc = QuillHelper.parseDescription('Rich note content');
      final jsonStr = QuillHelper.documentToJson(doc);
      expect(QuillHelper.toPlainText(jsonStr), equals('Rich note content'));
    });
  });
}
