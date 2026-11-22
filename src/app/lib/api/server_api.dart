import 'dart:convert';

import 'package:haiko/models/article_model.dart';
import 'package:haiko/models/minimal_article_model.dart';
import 'package:haiko/models/pdf_request_model.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class ServerApi {
  static const serverUrl = "http://localhost";

  static bool isWeb() {
    return kIsWeb;
  }

  static void downloadArticle(ArticleModel model) async {
    PdfRequestModel requestModel = PdfRequestModel.fromArticleModel(model);

    final Uri url = Uri.parse('$serverUrl/api/pdf/gen?query=${jsonEncode(requestModel)}');

    await launchUrl(url);
  }

  static Future<ArticleModel?> getArticle(String articleId) async {
    try {
      http.Response resp = await http.get(
        Uri.parse("$serverUrl/api/central/articles/get?id=$articleId"),
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

  static Future<List<MinimalArticleModel>> getMinimalArticlesByQuery(String query) async {
    try {
      List<MinimalArticleModel> list = [];

      for (String id in await getArticlesIdsByQuery(query)) {
        MinimalArticleModel? mam = await getMinimalArticle(id);

        if (mam != null) {
          list.add(mam);
        }
      }

      return list;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return [];
    }
  }

  static Future<List<String>> getArticlesIdsByQuery(String query) async {
    try {
      http.Response resp = await http.get(
        Uri.parse("$serverUrl/api/searcher/search?search_request=$query"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        return respContent["IDs"];
      }
      else {
        return [];
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
      return [];
    }
  }

  static Future<MinimalArticleModel?> getMinimalArticle(String articleId) async {
    try {
      http.Response resp = await http.get(
        Uri.parse("$serverUrl/api/central/articles/getMinimal?id=$articleId"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        return MinimalArticleModel.fromJson(respContent);
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

  static Future<bool> checkConnection() async {
    if (isWeb()) return true;
    
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
    connectivityResult.contains(ConnectivityResult.wifi) ||
    connectivityResult.contains(ConnectivityResult.ethernet)
    ) 
    {
        return await checkServer();
    }

    return false;
  }

  static Future<bool> checkServer() async {
    try {
      await http.get(
        Uri.parse("$serverUrl/")
      );

      return true;
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      return false;
    }
  }

  static Future<String> getUserName(String id) async {
    try {
      http.Response resp = await http.get(
        Uri.parse("$serverUrl/api/central/users/get?id=$id"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> respContent = jsonDecode(resp.body) as Map<String, dynamic>;
        return respContent["userName"] ?? "Неизвестный";
      }

      return "Неизвестный";
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      return "Неизвестный";
    }
  }
}