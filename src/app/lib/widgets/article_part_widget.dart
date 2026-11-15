import 'package:haiko/models/article_part_model.dart';
import 'package:material_ui/material_ui.dart';

//ignore: must_be_immutable
class ArticlePartWidget extends StatefulWidget  {
  final dataKey = GlobalKey();
  ArticlePartWidget({super.key, required this.model, required this.completed, required this.available, required this.show, required this.callback});

  final ArticlePartModel model;
  bool show;
  bool available;
  bool completed;
  final Function(String, bool) callback;

  @override
  State<StatefulWidget> createState() => ArticlePartWidgetState();
}

class ArticlePartWidgetState extends State<ArticlePartWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
    asyncinitState();
  });
  }

  void asyncinitState() async {
    
  }

  void complete() async {
    
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
                    Container( 
                      width: 50,
                      height: 50,
                        decoration: BoxDecoration(
                          color: widget.completed ? Color.fromARGB(255, 90, 116, 90) : Color.fromARGB(255, 36, 39, 36),
                          shape: BoxShape.circle,
                        ),
                    ),
                    SelectableText(widget.model.title)
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
                SelectableText(widget.model.content, style: TextStyle(
                    fontSize: 20
                  )
                ),
                if (!widget.completed && widget.available)
                TextButton(onPressed: () async {
                  await widget.callback(widget.model.id, true);
                  setState(() {});
                }, child: Text("Завершить"))
              ],
            )
          )
        ],
      )
    );
  }
}