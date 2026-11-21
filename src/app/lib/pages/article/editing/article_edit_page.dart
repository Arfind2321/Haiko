import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/article_edit_model.dart';
import 'package:haiko/models/article_model.dart';
import 'package:haiko/models/article_part_edit_model.dart';
import 'package:haiko/models/article_part_model.dart';
import 'package:haiko/pages/article/editing/article_part_edit_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class ArticleEditPage extends StatefulWidget  {
  const ArticleEditPage({super.key, required this.isNew, required this.articleId});

  final bool isNew;
  final String articleId;

  @override
  State<StatefulWidget> createState() => ArticleEditPageState();
}

class ArticleEditPageState extends State<ArticleEditPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });

    load();
  }

  List<ArticlePartEditModel> contents = [];

  Future<String?> updateArticle() async {
    for (ArticlePartEditWidget wg in parts) {
      contents.add(wg.pack());
    }

    ArticleEditModel editModel = ArticleEditModel(article == null ? "" : article!.id, titleController.text, tagsController.text.split(" "), contents);

    try {
      http.Response resp = await http.post(
        Uri.parse("${ServerApi.serverUrl}/api/central/articles/createOrEdit"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(editModel)
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          GoRouter.of(context).pushReplacement("/article/${respContent["id"]}");
        });
        return respContent["id"];
      }
      else {
        return null;
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return null;
    }
  }

  List<ArticlePartEditWidget> parts = [];
  ArticleModel? article;

  void load() async {
    if (!widget.isNew) {
      article = await ServerApi.getArticle(widget.articleId);

      if (article == null) {
        setState(() {
          GoRouter.of(context).pushReplacement("/error/Статья не найдена");
        });
        return;
      }

      titleController.text = article!.title;
      tagsController.text = article!.tags.join(" ");

      for (ArticlePartModel model in article!.contents) {
        addPartByModel(model);
      }

      setState(() {
      
      });
    } 
  }

  bool authorized = false;
  String atoken = "";

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      authorized = true;
      atoken = token;
    }

    if (!authorized) {
      goAuth();
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
    }
  }

  void removePart(ArticlePartEditWidget model) {
    parts.remove(model);
    setState(() {
      
    });
  }

  void addPart() {
    addPartByStrings("", "");
  }

  Future<bool> removeArticle() async {
    try {
      http.Response resp = await http.delete(
        Uri.parse("${ServerApi.serverUrl}/api/central/articles/remove?id=${article!.id}"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        }
      );

      if (resp.statusCode == 200) {
        setState(() {
          GoRouter.of(context).replace("/profile");
        });

        return true;
      }
      else {
        return false;
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  void addPartByStrings(String title, String content) {
    addPartByModel(ArticlePartModel("0", title, content, 0, 0, []));
  }

  void addPartByModel(ArticlePartModel part) {
    parts.add(ArticlePartEditWidget(removeCallback: removePart, model: part));
  }

  final titleController = TextEditingController();
  final tagsController = TextEditingController();

  bool isSubmiting = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                SelectableText(
                  widget.isNew ? "Создание статьи" : "Изменение статьи",
                  style: TextStyle(fontSize: 72),
                ),
                Row(
                  children: [
                    Text("Заголовок: "),
                    Expanded(child: TextField(controller: titleController,))
                  ],
                ),
                Row(
                  children: [
                    Text("Теги (через пробел): "),
                    Expanded(child: TextField(controller: tagsController,))
                  ],
                ),
                Column(
                  spacing: 10,
                  children: parts,
                ),
                TextButton(onPressed: () async {
                  addPart();
                  setState(() {
                    
                  });
                }, child: Text("+")),
                !isSubmiting ? TextButton(onPressed: () async {
                  if (isSubmiting) return;

                  setState(() {
                    isSubmiting = true;
                  });
                  String? id = await updateArticle();
                  setState(() {
                    isSubmiting = false;
                  });

                  if (id != null) {
                    
                  }
                }, child: Text(widget.isNew ? "Создать" : "Применить")) : CircularProgressIndicator(),
                if (!widget.isNew)
                TextButton(onPressed: () async {
                  bool ok = await removeArticle();
                  setState(() {
                    
                  });
                }, child: Text("Удалить")),
          ],
        ),
      );
  }
}