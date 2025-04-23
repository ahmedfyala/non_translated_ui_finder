import 'package:non_translated_ui_finder/src/finder.dart';
import 'package:non_translated_ui_finder/src/finder_config.dart';

Future<void> main(List<String> args) async {
  final config = FinderConfig.fromArgs(args);
  await Finder(config).run();
}
