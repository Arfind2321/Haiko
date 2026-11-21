class UserCommentModel {
  int id;
  String userId;
  String content;
  DateTime dateTime;
  int likes;
  int dislikes;
  List<UserCommentModel> answers = [];

  UserCommentModel(this.id, this.userId, this.content, this.dateTime, this.likes, this.dislikes, this.answers);

  factory UserCommentModel.fromJson(Map<String, Object?> json) {
    return UserCommentModel(
      json['id'] as int,
      json['userId'] as String,
      json['content'] as String,
      DateTime.parse(json['dateTime'] as String),
      json['likes'] as int,
      json['dislikes'] as int,
      (json['answers'] as List<dynamic>).map((data) => UserCommentModel.fromJson(data)).toList()
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'dateTime': dateTime,
    'likes': likes,
    'dislikes': dislikes,
    'answers': answers,
  };
}