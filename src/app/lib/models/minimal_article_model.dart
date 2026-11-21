class MinimalArticleModel 
{
    String id;
    String title;
    String writerId;
    
    MinimalArticleModel(this.id, this.title, this.writerId);

    factory MinimalArticleModel.fromJson(Map<String, Object?> json) {
      return MinimalArticleModel(
        json['id'] as String,
        json['title'] as String,
        json['writerId'] as String
      );
    }
}
