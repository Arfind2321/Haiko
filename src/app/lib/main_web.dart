import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configureApp() {
  print("Runs on web");
  usePathUrlStrategy(); // Or your custom web plugin setup
}