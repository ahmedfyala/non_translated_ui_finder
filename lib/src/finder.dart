// lib/src/finder.dart

import 'dart:io';

import 'package:path/path.dart' as p;

import 'finder_config.dart';
import 'html_report_generator.dart';

class Finder {
  final FinderConfig config;

  /// Regex for matching any string literal ('...' or "...")
  static final RegExp _stringLiteralRE = RegExp(r'''(['"])(.*?)\1''');

  /// Regex patterns to skip (imports, URLs, file paths, backend vars).
  static final List<RegExp> _skipPatterns = [
    RegExp(r'^package:'), // package:...
    RegExp(r'^dart:'), // dart:...
    RegExp(r'\.\./'), // ../
    RegExp(r'\.\.\\'), // ..\
    RegExp(r'\.dart$'), // ends with .dart
    RegExp(r'^http'), // http...
    RegExp(r'\$'), // contains $
  ];

  Finder(this.config);

  Future<void> run() async {
    final occurrences = <String, List<Map<String, dynamic>>>{};
    final dir = Directory(config.targetDir);
    if (!await dir.exists()) {
      throw Exception('Directory not found: ${config.targetDir}');
    }

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final path = entity.path;
        final lowerPath = path.toLowerCase();

        // only inside ui/ folders
        if (!lowerPath.contains(p.separator + 'ui' + p.separator)) continue;

        // skip configured ignore patterns
        if (config.ignorePatterns.any(path.contains)) continue;

        List<String> lines;
        try {
          lines = await File(path).readAsLines();
        } catch (e) {
          // handle read error (optional: log and continue)
          continue;
        }

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('.tr(')) continue;

          for (final match in _stringLiteralRE.allMatches(line)) {
            final text = match.group(2)!.trim();
            if (text.length < 2) continue;
            if (_shouldSkip(text)) continue;

            occurrences.putIfAbsent(path, () => []).add({
              'line': i + 1,
              'text': text,
            });
          }
        }
      }
    }

    final generator = HtmlReportGenerator(occurrences);
    await generator.generate(config.outputFile);
    print('✅ HTML report created at: ${config.outputFile}');
  }

  bool _shouldSkip(String text) {
    final lower = text.toLowerCase();
    return _skipPatterns.any((re) => re.hasMatch(lower));
  }
}
