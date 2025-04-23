

import 'dart:io';

import 'package:non_translated_ui_finder/src/finder.dart';
import 'package:non_translated_ui_finder/src/finder_config.dart';
import 'package:test/test.dart';

void main() {
  group('Finder', () {
    late Directory tempDir;
    late FinderConfig config;
    late String outputFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ui_finder_test_');
      outputFile = '${tempDir.path}${Platform.pathSeparator}report.html';
      config = FinderConfig.fromArgs([
        '--target',
        tempDir.path,
        '--output',
        outputFile,
      ]);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds untranslated strings and generates report', () async {
      
      final uiDir =
          await Directory('${tempDir.path}${Platform.pathSeparator}ui')
              .create(recursive: true);
      final file = File('${uiDir.path}${Platform.pathSeparator}test.dart');
      await file.writeAsString('''
void main() {
  print("Hello World");
  print("ShouldIgnore".tr());
  print(package: "something");
  print("../path");
  print("file.dart");
  print("http://example.com");
  print("\\\$backend");
  print('X');
}
''');

      
      try {
        await Finder(config).run();
      } catch (_) {}

      
      final report = File(outputFile);
      expect(await report.exists(), isTrue);

      final content = await report.readAsString();
      expect(content, contains('Hello World'));
      expect(content, isNot(contains('ShouldIgnore')));
    });
  });
}
