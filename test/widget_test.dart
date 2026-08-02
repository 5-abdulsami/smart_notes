import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/core/utils/quill_helper.dart';

void main() {
  test('App smoke test', () {
    final doc = QuillHelper.parseDescription('Test Note');
    expect(doc.toPlainText().trim(), equals('Test Note'));
  });
}
