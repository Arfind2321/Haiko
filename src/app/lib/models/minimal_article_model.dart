class MinimalArticleModel 
{
    String id;
    String title;
    
    MinimalArticleModel(this.id, this.title);

    factory MinimalArticleModel.fromJson(Map<String, Object?> json) {
      return MinimalArticleModel(
        json['id'] as String,
        json['title'] as String,
      );
    }
}
