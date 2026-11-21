import 'package:haiko/models/article_part_edit_model.dart';
import 'package:haiko/models/article_part_model.dart';
import 'package:material_ui/material_ui.dart';

//ignore: must_be_immutable
class ArticlePartEditWidget extends StatefulWidget  {

  ArticlePartEditWidget({super.key, this.model, required this.removeCallback});

  TextEditingController title = TextEditingController(text: "");
  TextEditingController content  = TextEditingController(text: "");

  final Function(ArticlePartEditWidget) removeCallback;

  ArticlePartModel? model;

  bool show = true;

  ArticlePartEditModel pack() {
    return ArticlePartEditModel(model == null ? null : model!.id, title.text, content.text);
  }

  @override
  State<StatefulWidget> createState() => ArticlePartEditWidgetState();
}

class ArticlePartEditWidgetState extends State<ArticlePartEditWidget> {
  @override
  void initState() {
    if (widget.model != null) {
      widget.title.text = widget.model!.title;
      widget.content.text = widget.model!.content;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 83, 81, 81),
                  borderRadius: 
                  widget.show ? BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)) 
                  : BorderRadius.circular(20),
                ),
                //margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                height: 50,
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(child: Icon(Icons.padding)),
                    Expanded(flex: 5, child: TextField(controller: widget.title)),
                    Expanded(flex: 1, child: TextButton(onPressed: () {
                      widget.removeCallback(widget);
                    }, child: Text("X")))
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  widget.show = !widget.show;
                });
              },
            )
          ),
          if (widget.show)
          Container(     
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 117, 114, 114),
                borderRadius: 
                widget.show ? BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)) 
                : BorderRadius.circular(20),
              ),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: TextField(controller: widget.content, keyboardType: TextInputType.multiline, maxLines: null),
                )
              ],
            )
          )
        ],
      )
    );
  }
}