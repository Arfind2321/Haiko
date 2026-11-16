import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<StatefulWidget> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });
  }

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      setState(() {
        GoRouter.of(context).replace("/");
      });
    }
  }

  void login() async {
    try {
      http.Response resp = await http.post(
        Uri.parse("http://localhost/api/central/auth/login"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "Username": loginController.text,
          "Password": passwordController.text
        }
      ));

      if (resp.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("token", resp.body.replaceAll(RegExp('"'), ""));

        setState(() {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          }
          else {
            GoRouter.of(context).replace("/");
          }
        });
      }
      else {
        setState(() {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text that the user has entered by
                // using the TextEditingController.
                content: Text("Ошибка входа: ${resp.body}"),
              );
            },
          );
        });
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      setState(() {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text that the user has entered by
                // using the TextEditingController.
                content: Text("Ошибка входа: ${ex.toString()}"),
              );
            },
          );
        });
    }
  }

  void register() async {
    try {
      http.Response resp = await http.post(
        Uri.parse("http://localhost/api/central/auth/register"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "Username": loginController.text,
          "Password": passwordController.text
        }
      ));

      if (resp.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("token", resp.body.replaceAll(RegExp('"'), ""));

        setState(() {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          }
          else {
            GoRouter.of(context).replace("/");
          }
        });
      }
      else {
        setState(() {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text that the user has entered by
                // using the TextEditingController.
                content: Text("Ошибка регистрации: ${resp.body}"),
              );
            },
          );
        });
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      setState(() {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                // Retrieve the text that the user has entered by
                // using the TextEditingController.
                content: Text("Ошибка регистрации: ${ex.toString()}"),
              );
            },
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image(image: AssetImage("assets/logo-white-cat-only-sized.png")),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 117, 114, 114),
              borderRadius: BorderRadius.circular(20) 
            ),
            child: Column(
              children: [
                Text("Вход в аккаунт", style: TextStyle(fontSize: 72)),
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Логин:"),
                    TextField(
                      controller: loginController,
                    ),
                    Text("Пароль:"),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: login, child: Text("Войти")
                        ),
                        TextButton(
                          onPressed: register, child: Text("Зарегистрироваться")
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),  
    );
  }
}