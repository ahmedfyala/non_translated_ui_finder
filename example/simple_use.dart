

import 'package:non_translated_ui_finder/src/non_translated_ui_finder_base.dart';



Future<void> main() async {
  await runFinder([
    '--target',
    'lib/ui',
    '--output',
    'report.html',
    '--ignore',
    '.g.dart',
    '--ignore',
    'locale_keys.g.dart',
  ]);

  print('✅ Report generated at report.html');
}
