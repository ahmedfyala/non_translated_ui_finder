

import 'finder.dart';
import 'finder_config.dart';



Future<void> runFinder(List<String> args) async {
  
  final config = FinderConfig.fromArgs(args);

  
  await Finder(config).run();
}
