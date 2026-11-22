import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/local_article_storage_api.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/article_model.dart';
import 'package:haiko/widgets/article_part_widget.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:pasteboard/pasteboard.dart';
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
  bool isLocal = false;
  bool isSaved = false;
  late List<String> completedParts;
  
  Map<String, String> idNames = {
    "you": "Вы"
  };

  void pullName(String id) async {
    if (idNames.containsKey(id)) return;

    String name = await ServerApi.getUserName(id);
    idNames[id] = name;

    setState(() {
      
    });
  }

  Future<bool> clearArticleCompletion() async {
    completedParts.clear();

    bool okls = await clearArticleCompletionFromLocalStorage();

    if (!okls) return false;

    if (authorized && !isLocal) {
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
        Uri.parse("${ServerApi.serverUrl}/api/central/completion/clear?id=${widget.articleId}"),
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
    if (authorized && !isLocal) {
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

    if (authorized && !isLocal) {
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
    
    ArticleModel? articleModel;
    
    if (await ServerApi.checkConnection()) {
      articleModel = await ServerApi.getArticle(widget.articleId);
      isLocal = false;
    }
    else {
      articleModel = await LocalArticleStorageApi.getArticle(widget.articleId);
      if (articleModel != null) {
        isLocal = true;
      }
    }
    

    if (articleModel == null) {
      setState(() {
        //Route route = MaterialPageRoute(builder: (context) => ErrorPage(error: "Статья не найдена"));
        GoRouter.of(context).pushReplacement("/error/Статья не найдена");
      });
      return;
    }

    completedParts = await getArticleCompletion();

    model = articleModel;

    isSaved = await LocalArticleStorageApi.isSaved(widget.articleId);

    pullName(articleModel.writerID);

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
        partsTemp.add(ArticlePartWidget(model: model, isLocal: isLocal, completed: true, show: false, available: true, pullName: (p0) => pullName(p0), idNames: idNames, callback: (a,b) => setArticleCompletion(a, b)));
      }
      else {
        ArticlePartWidget apw = ArticlePartWidget(model: model, isLocal: isLocal, completed: false, available: stopShowing ? false : true, pullName: (p0) => pullName(p0), idNames: idNames, show: stopShowing ? false : true, callback: (a,b) => setArticleCompletion(a, b));
        partsTemp.add(apw);
        if (!stopShowing) stopShowing = true;
      }
    }

    setState(() {
      parts = partsTemp;
    });
  }

  Future<List<String>> getCompletionFromAccount() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("${ServerApi.serverUrl}/api/central/completion/get?id=${widget.articleId}"),
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
        Uri.parse("${ServerApi.serverUrl}/api/central/completion/set?id=${widget.articleId}&pid=$id&ic=$completed"),
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

  Future<bool> fork() async {
    try {
      http.Response resp = await http.post(
        Uri.parse("${ServerApi.serverUrl}/api/central/articles/fork?id=${widget.articleId}"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;

        if ((respContent["isOk"] as bool)) {
          setState(() {
            GoRouter.of(context).pushReplacement("/edit/${respContent["id"]}");
          });

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

  bool isForking = false;
  bool copiedSuccessfuly = false;

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
                  style: TextStyle(fontSize: 48),
                ),
                Row(
                  children: [
                    Text("Последнее изменение: ${() {
                        final DateTime now = model!.creationTime.toLocal();
                        final DateFormat formatter = DateFormat('yyyy-MM-dd');
                        return formatter.format(now);
                      }.call()
                    }"),
                    Text(" - "),
                    Text("Написал: ${idNames[model!.writerID]}")
                  ],
                ),
                Row(
                  children: [
                    Text("Теги: "),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(scrollDirection: Axis.horizontal, shrinkWrap: true, itemCount: model!.tags.length, itemBuilder: (b,i) {
                          String tag = model!.tags[i];

                          return Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 79, 94, 108),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(child: SelectableText(tag)),
                          );
                        }
                      ),
                    )
                  ],
                ),
                if (!isLocal) Builder(builder: (b) {
                  if (model!.isForked) {
                    return Row(
                      children: [
                        Text("Изменённая версия."),
                        TextButton(child: Text("Перейти к оригиналу"), onPressed: () {
                          GoRouter.of(context).pushReplacement("/article/${model!.forkedFrom!.id}");
                        }),
                      ],
                    );
                  }

                  return Text("Оригинальная статья");
                }),
                Row(
                  children: [
                    TextButton(onPressed: () async {
                      await clearArticleCompletion();

                    }, child: Text("Сбросить прохождение")),
                    if (!ServerApi.isWeb()) TextButton(onPressed: () async {
                        if (isSaved) {
                          await LocalArticleStorageApi.unsaveArticle(widget.articleId);
                          isSaved = false;
                        }
                        else {
                          await LocalArticleStorageApi.saveArticle(model!);
                          isSaved = true;
                        }

                        setState(() {
                          
                        });
                    }, child: Text(isSaved ? "Удалить" : "Сохранить")),

                    if (!isLocal) TextButton(onPressed: () async {
                      if (isForking) return;
                      setState(() {
                        isForking = true;
                      });
                      await fork();
                      setState(() {
                        isForking = false;
                      });
                    }, child: !isForking ? Text("Форк") : CircularProgressIndicator()),

                    TextButton(onPressed: () {
                      try {
                        Pasteboard.writeText("${ServerApi.serverUrl}/article/${widget.articleId}");
                        setState(() {
                          copiedSuccessfuly = true;
                        });
                      }
                      catch (ex) {
                        developer.log(ex.toString());
                      }
                    }, child: Text(!copiedSuccessfuly ? "Скопировать ссылку на статью" : "Ссылка успешно скопирована")),
                  ],
                ),
                if (isLocal) Text("Прогресс будет сброшен при подключении к сети"),
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