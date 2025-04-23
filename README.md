# non_translated_ui_finder

A CLI and library for locating hardcoded, untranslated UI strings in Dart projects and generating a comprehensive, interactive HTML report.

## Features

- **Scan only UI folders**: Recursively searches `.dart` files whose paths include `ui/` or `\ui\`.
- **Skip translated calls**: Ignores lines containing `.tr(` to avoid already translated texts.
- **Smart filtering**: Skips imports, file paths, URLs, backend variables, and short or empty strings.
- **Interactive HTML report**:
  - Search and sort summary table of files and untranslated counts.
  - Clickable file entries that scroll to detailed occurrences with highlights.
  - Copy-to-clipboard buttons for each text literal.
  - Export options: PDF, CSV, JSON, Excel, XML.
- **Configurable**: Custom target directory, output path, and ignore patterns.
- **API & CLI**: Use via `runFinder()` in code or through the command-line tool.

## Getting Started

### Installation

Add to your project’s dev dependencies in `pubspec.yaml`:

```yaml
dev_dependencies:
  non_translated_ui_finder: ^1.0.0
```

Then fetch with:

```bash
dart pub get
```

Or install globally via:

```bash
dart pub global activate non_translated_ui_finder
```

Ensure `~/.pub-cache/bin` is in your `PATH` to run the CLI.

### CLI Usage

```bash
non_translated_ui_finder --target <directory> --output <file.html> --ignore <pattern> [--ignore <pattern>...]
```

- `--target`, `-t`: Directory to scan (defaults to `lib/feature`).
- `--output`, `-o`: Path for the generated HTML report (defaults to `untranslated_report.html`).
- `--ignore`, `-i`: One or more filename patterns to skip (defaults to `.g.dart`, `locale_keys.g.dart`).

**Example**:

```bash
non_translated_ui_finder -t lib/ui -o untranslated_report.html -i .g.dart -i locale_keys.g.dart
```

### API Usage

Import and invoke in Dart code:

```dart
import 'package:non_translated_ui_finder/src/non_translated_ui_finder_base.dart';

Future<void> main() async {
  await runFinder([
    '--target', 'lib/ui',
    '--output', 'report.html',
    '--ignore', '.g.dart',
    '--ignore', 'locale_keys.g.dart',
  ]);
}
```

## Example Project

Inspect the `example/simple_use.dart` for a minimal integration:

```dart
import 'package:non_translated_ui_finder/src/non_translated_ui_finder_base.dart';

void main() async {
  await runFinder([
    '--target', 'lib/ui',
    '--output', 'out.html',
  ]);
}
```

## Configuration Reference

| Option             | CLI Flag            | Default                       | Description                                       |
|--------------------|---------------------|-------------------------------|---------------------------------------------------|
| Target directory   | `--target`, `-t`    | `lib/feature`                 | Directory to scan for Dart UI files.             |
| Output file        | `--output`, `-o`    | `untranslated_report.html`    | Path where the HTML report will be written.       |
| Ignore patterns    | `--ignore`, `-i`    | `.g.dart`, `locale_keys.g.dart` | Filename patterns to exclude from scanning.       |




