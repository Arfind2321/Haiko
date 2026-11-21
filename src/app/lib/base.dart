import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/controllers/app_bar_auth_state_controller.dart';
import 'package:haiko/models/app_bar_state.dart';
import 'package:haiko/widgets/haiko_cricle_avatar.dart';
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
  final _appBarNotifier = ValueNotifier<AppBarState>(AppBarState(authState: false));


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });
  }

  @override
  void dispose() {
    _appBarNotifier.dispose();
    super.dispose();
  }

  String? userName;
  String? id;

  Future<bool> tryAuth() async {
    if (isLocal) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      id = sp.getString("id");
      userName = sp.getString("userName");

      return true;
    }
    try {
      http.Response resp = await http.get(
        Uri.parse("${ServerApi.serverUrl}/api/central/auth/me"),
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

        SharedPreferences sp = await SharedPreferences.getInstance();

        sp.setString("id", id!);
        sp.setString("userName", userName!);

        authorized = true;

        setState(() {
          //AppBarAuthController.of(context).updateAppBar(authState: true, userName: userName, id: id);
        });

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
  bool isLocal = false;

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isLocal = !(await ServerApi.checkConnection());

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
      AppBarAuthController.of(context).updateAppBar(authState: true, userName: userName, id: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarAuthController(
      appBarNotifier: _appBarNotifier,
      child: ValueListenableBuilder<AppBarState>(
        valueListenable: _appBarNotifier,
        builder: (c, s, _) {
          authorized = s.authState;

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
                          if (s.authState) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).pushReplacement("/profile");
                                },
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    HaikoCricleAvatar(radius: 20, id: id ?? "null-avatar"),
                                    Text(s.userName!)
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
      )
    );
  }
}