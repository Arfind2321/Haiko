import 'dart:convert';

import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/article_model.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class LocalArticleStorageApi {
  static Future<bool> updateArticle(String articleId) async {
    try {
      ArticleModel? articleModel = await ServerApi.getArticle(articleId);

      if (articleModel == null) {
        unsaveArticle(articleId);

        return false;
      }

      return await saveArticle(articleModel);
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  static Future<ArticleModel?> getArticle(String articleId) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      if (await isSaved(articleId)) {
        String string = sp.getString("saved=$articleId")!;

        return ArticleModel.fromJson(jsonDecode(string));
      }

      return null;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return null;
    }
  }

  static Future<List<ArticleModel>> getSavedArticles() async {
    try {
      List<ArticleModel> sa = [];

      for (String id in await getSaveArticlesIds()) {
        ArticleModel? am = await getArticle(id);

        if (am != null) {
          sa.add(am);
        }
      }

      return sa;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return [];
    }
  }

  static Future<bool> updateArticles() async {
    try {
      for (String id in await getSaveArticlesIds()) {
        await updateArticle(id);
      }

      return true;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  static Future<bool> unsaveArticle(String articleid) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      List<String> savedArticles = await getSaveArticlesIds();

      if (savedArticles.contains(articleid)) {
        savedArticles.remove(articleid);
        setSaveArticlesIds(savedArticles);

        sp.remove("saved=$articleid");
      }
      
      return true;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  static Future<bool> saveArticle(ArticleModel article) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      List<String> savedArticles = await getSaveArticlesIds();

      if (!savedArticles.contains(article.id)) {
        savedArticles.add(article.id);
        setSaveArticlesIds(savedArticles);
      }
      
      sp.setString("saved=${article.id}", jsonEncode(article));

      return true;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  static Future<bool> isSaved(String id) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      return (sp.getStringList("savedArticles"))!.contains(id);
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }

  static Future<List<String>> getSaveArticlesIds() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      return await sp.getStringList("savedArticles") ?? [];
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return [];
    }
  }

  static Future<bool> setSaveArticlesIds(List<String> values) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      return await sp.setStringList("savedArticles", values);
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return false;
    }
  }
}