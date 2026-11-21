import 'package:haiko/models/article_part_edit_model.dart';

class ArticleEditModel 
{
    String id;
    String title;
    List<String> tags;
    List<ArticlePartEditModel> contents;

    ArticleEditModel(this.id, this.title, this.tags, this.contents);

    factory ArticleEditModel.fromJson(Map<String, Object?> json) {
      return ArticleEditModel(
        json['id'] as String,
        json['title'] as String,
        (json['tags'] as List<dynamic>).map((data) => data as String).toList(),
        (json['contents'] as List<dynamic>).map((data) => ArticlePartEditModel.fromJson(data)).toList(),
      );
    }

    Map<String, dynamic> toJson() => {'articleId': id, 'title': title, 'tags': tags, 'parts': contents};
}
