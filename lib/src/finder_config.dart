// lib/src/finder_config.dart

import 'package:args/args.dart';

class FinderConfig {
  /// Default patterns to ignore when scanning.
  static const List<String> _defaultIgnorePatterns = [
    '.g.dart',
    'locale_keys.g.dart',
  ];

  final String targetDir;
  final String outputFile;
  final List<String> ignorePatterns;

  FinderConfig._(
    this.targetDir,
    this.outputFile,
    this.ignorePatterns,
  );

  factory FinderConfig.fromArgs(List<String> args) {
    final parser = ArgParser()
      ..addOption('target', abbr: 't', help: 'Directory to scan')
      ..addOption('output',
          abbr: 'o',
          help: 'HTML output path',
          defaultsTo: 'untranslated_report.html')
      ..addMultiOption('ignore',
          abbr: 'i',
          defaultsTo: _defaultIgnorePatterns,
          help: 'Patterns to ignore');

    final result = parser.parse(args);

    // If a positional argument is present, use it as targetDir
    final targetDir = result.rest.isNotEmpty
        ? result.rest.first
        : (result['target'] as String);

    return FinderConfig._(
      targetDir,
      result['output'] as String,
      result['ignore'] as List<String>,
    );
  }
}
