import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/local_article_storage_api.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/controllers/app_bar_auth_state_controller.dart';
import 'package:haiko/models/article_model.dart';
import 'package:haiko/models/minimal_article_model.dart';
import 'package:haiko/widgets/haiko_cricle_avatar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  bool authorized = false;
  String atoken = "";

  String? userName;
  String? id;

  void showError(String error) {
    setState(() {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Retrieve the text that the user has entered by
            // using the TextEditingController.
            content: Text(error),
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });
  }

  Future<bool> tryAuth() async {
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

  List<MinimalArticleModel> articles = [];

  Future<bool> getArticles() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("${ServerApi.serverUrl}/api/central/auth/getArticles"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        dynamic json = jsonDecode(resp.body);
        
        articles = (json["articles"] as List<dynamic>).map((data) => MinimalArticleModel.fromJson(data)).toList();

        await LocalArticleStorageApi.updateArticles();

        setState(() {
          
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

  bool isLocal = false;
  List<ArticleModel> localArticles = [];

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      authorized = true;
      atoken = token;
    }

    isLocal = !(await ServerApi.checkConnection());

    localArticles = await LocalArticleStorageApi.getSavedArticles();

    if (isLocal) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      id = sp.getString("id");
      userName = sp.getString("userName");

      authorized = true;
    }
    else {
      if (!authorized) {
        goAuth();
      }
      else {
        tryAuth();

        getArticles();
      }
    }

    setState(() {
      
    });
  }

  void pickAvatar() async {
    PlatformFile? file = await FilePicker.pickFile(dialogTitle: "Выберите аватар", type: FileType.image);

    if (file == null) return;

    if ((await file.length())! > 10485760) {
        
      return;
    }

    try {
      var request = http.MultipartRequest("POST", Uri.parse("${ServerApi.serverUrl}/api/central/auth/uploadAvatar"));
      request.headers["Authorization"] = "Bearer $atoken";
      request.files.add(await http.MultipartFile.fromBytes(
          'uploadedFile',
          await file.readAsBytes(),
          filename: "image.png"
      ));
      http.StreamedResponse resp = await request.send();

      if (resp.statusCode == 200) {
        setState(() {
          GoRouter.of(context).refresh();
        });

        return;
      }
      else {
        showError("Ошибка: ${resp.stream.toString()}");
        return;
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      return;
    }
  }

  void goAuth() async {
    String? token = await GoRouter.of(context).push<String>("/auth");

    if (token == null) {
      goAuth();
    }
    else {
      atoken = token;
      authorized = true;
      tryAuth();
        setState(() {
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    if (!authorized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 83, 81, 81),
              borderRadius: BorderRadius.circular(20)
            ),
            //margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(30),
            child: Row(
              spacing: 20,
              children: [
                if (!isLocal) MouseRegion(
                  cursor: !isLocal ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: GestureDetector(
                    onTap: () {
                      if (isLocal) return;

                      pickAvatar();
                    },
                    child: HaikoCricleAvatar(radius: 80, id: id ?? "null-avatar"),
                  ),
                ),
                SelectableText(userName ?? "кто то", style: TextStyle(fontSize: 30))
              ],
            ),
          ),
          Row(
            children: [
              if (!isLocal) TextButton(onPressed: () {
                GoRouter.of(context).pushReplacement("/create");
              }, child: Text("Создать")),
              TextButton(onPressed: () async {
                SharedPreferences sp = await SharedPreferences.getInstance();

                sp.clear();

                setState(() {
                  GoRouter.of(context).pushReplacement("/auth");
                  AppBarAuthController.of(context).updateAppBar(authState: false, userName: userName, id: id);
                });
              }, child: Text("Выйти и удалить данные"))
            ],
          ),
          if (!isLocal) Text("Статьи: ", style: TextStyle(fontSize: 36)),
          if (!isLocal) ListView.builder(scrollDirection: Axis.vertical, shrinkWrap: true, itemCount: articles.length, itemBuilder: (b, i) {
            MinimalArticleModel mam = articles[i];

            return Container(
              margin: EdgeInsets.all(5),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 41, 67, 45),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    //margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(30),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(flex: 3, child: Text(mam.title, style: TextStyle(fontSize: 20))),
                        Expanded(flex: 1, child: TextButton(onPressed: () {
                          GoRouter.of(context).push("/edit/${mam.id}");
                        }, child: Text("Изменить")))
                      ],
                    ),
                  ),
                  onTap: () {
                    GoRouter.of(context).push("/article/${mam.id}");
                  },
                )
              ),
            );
          }),

          if (!ServerApi.isWeb()) Text("Локальные статьи: ", style: TextStyle(fontSize: 36)),
          if (!ServerApi.isWeb()) ListView.builder(scrollDirection: Axis.vertical, shrinkWrap: true, itemCount: localArticles.length, itemBuilder: (b, i) {
            ArticleModel mam = localArticles[i];

            return Container(
              margin: EdgeInsets.all(5),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 41, 67, 45),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    //margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(30),
                    child: Row(
                      spacing: 20,
                      children: [
                        Expanded(flex: 3, child: Text(mam.title, style: TextStyle(fontSize: 24))),
                        if (!isLocal) Expanded(flex: 1, child: TextButton(onPressed: () {
                          GoRouter.of(context).push("/edit/${mam.id}");
                        }, child: Text("Изменить")))
                      ],
                    ),
                  ),
                  onTap: () {
                    GoRouter.of(context).push("/article/${mam.id}");
                  },
                )
              ),
            );
          })
        ],
      )
    );
  }
}