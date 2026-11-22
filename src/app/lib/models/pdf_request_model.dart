import 'package:haiko/models/article_model.dart';

class PdfRequestModel 
{
    String title;
    List<PdfRequestPageModel> steps;
    
    PdfRequestModel(this.title, this.steps);

    factory PdfRequestModel.fromJson(Map<String, Object?> json) {
      return PdfRequestModel(
        json['title'] as String,
        (json['steps'] as List<dynamic>).map((data) => PdfRequestPageModel.fromJson(data)).toList(),
      );
    }

    factory PdfRequestModel.fromArticleModel(ArticleModel model) {
      return PdfRequestModel(
        model.title,
        model.contents.map((data) => PdfRequestPageModel(data.title, data.content)).toList(),
      );
    }

    Map<String, dynamic> toJson() => {
      'title': title,
      'steps': steps
    };
}

class PdfRequestPageModel 
{
    String title;
    String body;
    
    PdfRequestPageModel(this.title, this.body);

    factory PdfRequestPageModel.fromJson(Map<String, Object?> json) {
      return PdfRequestPageModel(
        json['title'] as String,
        json['body'] as String
      );
    }

    Map<String, dynamic> toJson() => {
      'title': title,
      'body': body
    };
}
