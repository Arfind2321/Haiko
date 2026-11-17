import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/models/article_model.dart';
import 'package:haiko/widgets/article_part_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class ArticlePage extends StatefulWidget  {
  const ArticlePage({super.key, required this.articleId});

  final String articleId;

  @override
  State<StatefulWidget> createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  String writerName = "Неизвестный писатель";
  ArticleModel? model;
  late List<String> completedParts;

  Future<ArticleModel?> getArticle() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/articles/get?id=${widget.articleId}"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        return ArticleModel.fromJson(respContent);
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

  Future getWriter() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/users/get?id=${model!.writerID}"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        writerName = respContent["userName"] ?? "Неизвестный писатель";
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
    }
  }

  Future<bool> clearArticleCompletion() async {
    completedParts.clear();

    bool okls = await clearArticleCompletionFromLocalStorage();

    if (!okls) return false;

    if (authorized) {
      bool oka = await clearArticleCompletionFromAccount();

      if (!oka) return false;
    }

    setState(() {
      updateParts();
    });

    return true;
  }

  Future<bool> clearArticleCompletionFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.remove("completedParts-${widget.articleId}");
  }

  Future<bool> clearArticleCompletionFromAccount() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/completion/clear?id=${widget.articleId}"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        if (resp.body == "true") {
          return true;
        }
        return false;
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

  Future<List<String>> getArticleCompletion() async {
    if (authorized) {
      return getCompletionFromAccount();
    }
    else {
      return getCompletionFromLocalStorage();
    }
  }

  Future<bool> setArticleCompletion(String id, bool isCompleted) async {
    if (completedParts.contains(id)) return true;

    if (isCompleted) {
      completedParts.add(id);
    }
    else {
      completedParts.remove(id);
    }

    bool okls = await setCompletionToLocalStorage(completedParts);

    if (!okls) return false;

    if (authorized) {
      bool oka = await setCompletionToAccount(id, isCompleted);

      if (!oka) return false;
    }

    setState(() {
      updateParts();
    });

    return true;
  }

  bool authorized = false;
  String atoken = "";

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
      authorized = true;
      atoken = token;
    }

    ArticleModel? articleModel = await getArticle();

    if (articleModel == null) {
      setState(() {
        //Route route = MaterialPageRoute(builder: (context) => ErrorPage(error: "Статья не найдена"));
        GoRouter.of(context).pushReplacement("/error", extra: {"e": "Статья не найдена"});
      });
      return;
    }

    completedParts = await getArticleCompletion();

    model = articleModel;

    await getWriter();

    setState(() {
      
      generateParts();
    });
  }

  List<ArticlePartWidget> parts = [];

  void updateParts() {
    parts.clear();

    generateParts();
    setState(() {});
  }

  void generateParts() {
    List<ArticlePartWidget> partsTemp = [];

    bool stopShowing = false;
    for (var model in model!.contents) {
      if (completedParts.contains(model.id)) {
        partsTemp.add(ArticlePartWidget(model: model, completed: true, show: false, available: true, callback: (a,b) => setArticleCompletion(a, b)));
      }
      else {
        ArticlePartWidget apw = ArticlePartWidget(model: model, completed: false, available: stopShowing ? false : true, show: stopShowing ? false : true, callback: (a,b) => setArticleCompletion(a, b));
        partsTemp.add(apw);
        if (!stopShowing) {
          //Scrollable.ensureVisible(apw.dataKey.currentContext!);
        }
        if (!stopShowing) stopShowing = true;
      }

      developer.log("added part ${model.id} ${model.content}", name: 'haiko');
    }

    setState(() {
      parts = partsTemp;
    });
  }

  Future<List<String>> getCompletionFromAccount() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/completion/get?id=${widget.articleId}"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        List<String> respContent = (jsonDecode(resp.body) as List<dynamic>).map((data) => data as String).toList();
        await setCompletionToLocalStorage(respContent);
        return respContent;
      }
      else {
        // возвращает то, что сохранено локально
        return await getCompletionFromLocalStorage();
      }
    }
    catch (ex) {
      // возвращает то, что сохранено локально
      return await getCompletionFromLocalStorage();
    }
  }

  Future<List<String>> getCompletionFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList("completedParts-${widget.articleId}") ?? [];
  }

  Future<bool> setCompletionToLocalStorage(List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setStringList("completedParts-${widget.articleId}", values);
  }

  Future<bool> setCompletionToAccount(String id, bool completed) async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/completion/set?id=${widget.articleId}&pid=$id&ic=$completed"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        if (resp.body == "true") {
          return true;
        }
        return false;
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

  @override
  Widget build(BuildContext context) {
    if (model != null) {
      return SingleChildScrollView(
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                SelectableText(
                  model!.title,
                  style: TextStyle(fontSize: 72),
                ),
                Row(
                  children: [
                    Text("Последнее изменение: ${model!.lastEditTime.toString()}"),
                    Text(" - "),
                    Text("Написал: $writerName")
                  ],
                ),
                TextButton(onPressed: () async {
                    await clearArticleCompletion();
                }, child: Text("Сбросить")),
                Column(
                  spacing: 10,
                  children: parts,
                )
          ],
        ),
      );
    }
    else {
      return const Center(
              child: CircularProgressIndicator(),
            );
    }
  }
}