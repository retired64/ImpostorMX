import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('All languages in lib/lang contain the same translation keys as Spanish (es.dart)', () {
    final langDir = Directory('lib/lang');
    expect(langDir.existsSync(), isTrue, reason: 'lib/lang directory must exist');

    final dartFiles = langDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    // Helper to extract keys from a translation file content
    Set<String> extractKeys(String content) {
      // Matches pattern like 'key_name': 'value'
      final regExp = RegExp(r"^\s*'([^']+)'\s*:", multiLine: true);
      return regExp.allMatches(content).map((m) => m.group(1)!).toSet();
    }

    File? esFile;
    final otherFiles = <File>[];

    for (var file in dartFiles) {
      if (file.path.endsWith('/es.dart') || file.path.endsWith('${Platform.pathSeparator}es.dart')) {
        esFile = file;
      } else {
        // Skip non-map files if any (like punishment lists if defined separately, though lists start with List<String>)
        final content = file.readAsStringSync();
        if (content.contains('const Map<String, String>')) {
          otherFiles.add(file);
        }
      }
    }

    expect(esFile, isNotNull, reason: 'es.dart base language file must exist');

    final baseContent = esFile!.readAsStringSync();
    final baseKeys = extractKeys(baseContent);

    expect(baseKeys, isNotEmpty, reason: 'Base language keys should not be empty');

    for (var file in otherFiles) {
      final fileName = file.uri.pathSegments.last;
      final content = file.readAsStringSync();
      final langKeys = extractKeys(content);

      final missingInLang = baseKeys.difference(langKeys);
      final extraInLang = langKeys.difference(baseKeys);

      expect(
        missingInLang,
        isEmpty,
        reason: '$fileName is missing keys: $missingInLang',
      );

      expect(
        extraInLang,
        isEmpty,
        reason: '$fileName has extra/unknown keys: $extraInLang',
      );
    }
  });
}
