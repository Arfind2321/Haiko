import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppBase extends StatefulWidget  {
  const AppBase({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => AppBaseState();
}

class AppBaseState extends State<AppBase> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
    asyncinitState();
  });
  }

  String? userName;
  String? id;

  Future<bool> tryAuth() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/auth/me"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        dynamic json = jsonDecode(resp.body);
        
        id = json["id"];
        userName = json["userName"];

        return true;
      }
      else {
        return false;
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      // возвращает то, что сохранено локально
      return false;
    }
  }

  bool authorized = false;
  String atoken = "";

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      atoken = token;
      if (await tryAuth()) {
        authorized = true;
      }
      else {
        await prefs.remove("token");
      }
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF10140f),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: 
          Scaffold(
            appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.5), // Радиус закругления снизу
                ),
              ),
              //actionsPadding: EdgeInsets.all(10),
              backgroundColor: Color(0xFF1e221c),
              leadingWidth: 250,
              leading: Container(
                padding: EdgeInsets.fromLTRB(50, 10, 10, 10),
                child: MouseRegion(
              cursor: SystemMouseCursors.click,
                child:  GestureDetector(
                  child: Image(image: AssetImage('assets/logo-white-text-only-sized.png')),
                  onTap: () => {
                    context.go("/")
                  },
                ),
              ),
              ),

              toolbarHeight: 80,

              actions: [
                Container(
                  margin: EdgeInsets.all(20),

                  child: Builder(builder: (builder) {
                    if (authorized) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            GoRouter.of(context).push("/profile");
                          },
                          child: Row(
                            children: [
                              CircleAvatar(radius: 40),
                              Text(userName!)
                            ],
                          ),
                        ),
                      );
                    }
                    else {
                      return TextButton(onPressed: () {
                          GoRouter.of(context).push("/auth");
                        },
                        child: Text("Вход")
                      );
                    }
                  })
                )
              ],
            ),
            body: Container(
              margin: const EdgeInsets.all(10),
              child: widget.child,
            )
          )
        )
    );
  }
}