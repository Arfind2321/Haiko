import 'dart:convert';

import 'package:haiko/models/article_part_model.dart';
import 'package:haiko/models/user_vote_model.dart';
import 'package:haiko/widgets/article_part_rating_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  UserVoteModel? voteModel;

  Future<bool> getUserVote() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("http://localhost/api/central/voting/get?id=${widget.model.id}"),
        headers: {
          'Authorization': 'Bearer $atoken',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        if (resp.body != '"non"') {
          voteModel = UserVoteModel.fromJson(jsonDecode(resp.body) as Map<String, Object?>);
        }

        return true;
      }
      else {
        return false;
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');

      return false;
    }
  }

  bool authorized = false;
  String atoken = "";

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      authorized = true;
      atoken = token;

      await getUserVote();

      setState(() {
        
      });
    }
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
                TextButton(
                  onPressed: () async {
                    await widget.callback(widget.model.id, true);
                    setState(() {});
                  }, 
                  child: Text("Завершить")
                ),
                ArticlePartRatingWidget(model: widget.model, available: widget.available, show: true, voteModel: voteModel)
              ],
            )
          )
        ],
      )
    );
  }
}