import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:haiko/base.dart';
import 'package:haiko/pages/article/article_page.dart';
import 'package:haiko/pages/article/articles_page.dart';
import 'package:haiko/pages/auth_page.dart';
import 'package:haiko/pages/error_page.dart';
import 'package:haiko/pages/home_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MainApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppBase(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => AuthPage(),
        ),
        GoRoute(
          path: '/error/:e',
          builder: (context, state) => ErrorPage(error: state.pathParameters['id'] ?? "Неизвестная ошибка",),
        ),
        GoRoute(
          path: '/articles',
          builder: (context, state) => ArticlesPage(),
        ),
        GoRoute(
          path: '/article/:id',
          builder: (context, state) {
            String? id = state.pathParameters['id'];

            if (id != null) {
              return ArticlePage(articleId: id);
            }
            else {
              return ArticlesPage();
            }
          },
        ),
      ]
    )
  ],
  
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF222920),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}
