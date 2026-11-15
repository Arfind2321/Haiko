import 'package:haiko/models/user_comment_model.dart';

class ArticlePartModel 
{
    String id;
    String title;
    String content;
    int upVotes;
    int downVotes;
    List<UserCommentModel> comments = [];


    ArticlePartModel(this.id, this.title, this.content, this.upVotes, this.downVotes, this.comments);

    factory ArticlePartModel.fromJson(Map<String, Object?> json) {
    return ArticlePartModel(
      json['id'] as String,
      json['title'] as String,
      json['content'] as String,
      json['upVotes'] as int,
      json['downVotes'] as int,
      (json['comments'] as List<dynamic>).map((data) => UserCommentModel.fromJson(data)).toList()
    );
  }
}
