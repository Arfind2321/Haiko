class ArticlePartEditModel 
{
    String? id;
    String title;
    String content;

    ArticlePartEditModel(this.id, this.title, this.content);

    factory ArticlePartEditModel.fromJson(Map<String, Object?> json) {
      return ArticlePartEditModel(
        json['id'] as String?,
        json['title'] as String,
        json['content'] as String
      );
    }

    Map<String, dynamic> toJson() => {'id': id, 'title': title, 'content': content};
}
