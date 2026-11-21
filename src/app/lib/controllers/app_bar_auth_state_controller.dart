import 'package:haiko/models/app_bar_state.dart';
import 'package:material_ui/material_ui.dart';

class AppBarAuthController extends InheritedWidget {
  final ValueNotifier<AppBarState> appBarNotifier;

  const AppBarAuthController({
    super.key,
    required this.appBarNotifier,
    required super.child,
  });

  static AppBarAuthController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppBarAuthController>();
    assert(result != null, 'No AppShellController found in context');
    return result!;
  }

  void updateAppBar({required bool authState, String? userName, String? id}) {
    appBarNotifier.value = AppBarState(authState: authState, userName: userName, id: id);
  }

  @override
  bool updateShouldNotify(AppBarAuthController oldWidget) => false;
}