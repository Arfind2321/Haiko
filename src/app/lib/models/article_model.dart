import 'package:haiko/models/article_part_model.dart';

class ArticleModel 
{
    String id;
    String writerID;
    String title;
    List<String> tags;
    DateTime creationTime;
    DateTime lastEditTime;
    List<ArticlePartModel> contents;
    bool isForked;
    ArticleModel? forkedFrom;

    ArticleModel(this.id, this.writerID, this.title, this.tags, this.creationTime, this.lastEditTime, this.contents, this.isForked, this.forkedFrom);

    factory ArticleModel.fromJson(Map<String, Object?> json) {
      return ArticleModel(
        json['id'] as String,
        json['writerID'] as String,
        json['title'] as String,
        (json['tags'] as List<dynamic>).map((data) => data as String).toList(),
        DateTime.parse(json['creationTime'] as String),
        DateTime.parse(json['lastEditTime'] as String),
        (json['contents'] as List<dynamic>).map((data) => ArticlePartModel.fromJson(data)).toList(),
        json['isForked'] as bool,
        json['forkedFrom'] != null ? ArticleModel.fromJson(json['forkedFrom'] as Map<String, Object?>) : null
      );
    }

    Map<String, dynamic> toJson() => {
      'id': id,
      'writerID': writerID,
      'title': title,
      'tags': tags,
      'creationTime': creationTime.toString(),
      'lastEditTime': lastEditTime.toString(),
      'contents': contents,
      'isForked': isForked,
      'forkedFrom': forkedFrom,
    };
}
