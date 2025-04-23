

import 'dart:io';

import 'package:non_translated_ui_finder/src/html_report_generator.dart';
import 'package:test/test.dart';

void main() {
  group('HtmlReportGenerator', () {
    late Directory tempDir;
    late String outputFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('html_gen_test_');
      outputFile = '${tempDir.path}${Platform.pathSeparator}out.html';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('generates HTML with summary and detail entries', () async {
      
      final occurrences = {
        'lib/feature/ui/sample.dart': [
          {'line': 5, 'text': 'Sample Text'}
        ],
      };

      final generator = HtmlReportGenerator(occurrences);
      
      try {
        await generator.generate(outputFile);
      } catch (_) {}

      final report = File(outputFile);
      expect(await report.exists(), isTrue);

      final html = await report.readAsString();
      expect(html, contains('<h1>Untranslated UI Texts Report</h1>'));
      expect(html, contains('Sample Text'));
      
      expect(html, contains('<table'));
      
      expect(html, contains('ui/sample.dart'));
    });
  });
}
