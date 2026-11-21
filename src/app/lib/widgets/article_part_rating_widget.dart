import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/article_part_model.dart';
import 'package:haiko/models/user_comment_model.dart';
import 'package:haiko/models/user_vote_model.dart';
import 'package:haiko/models/user_vote_model_result.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//ignore: must_be_immutable
class ArticlePartRatingWidget extends StatefulWidget  {
  final dataKey = GlobalKey();
  ArticlePartRatingWidget({super.key, required this.model, required this.available, required this.show, required this.voteModel, required this.idNames, required this.pullName});

  final ArticlePartModel model;
  bool show;
  UserVoteModel? voteModel;
  bool available;
  Map<String, String> idNames;
  final Function(String) pullName;

  @override
  State<StatefulWidget> createState() => ArticlePartRatingWidgetState();
}

class ArticlePartRatingWidgetState extends State<ArticlePartRatingWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
    asyncinitState();
  });
  }

  bool authorized = false;
  String atoken = "";

  void asyncinitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    if (token != null) {
      authorized = true;
      atoken = token;
    }

    setState(() {
      
    });
  }

  Future<bool> vote(UserVoteType type) async {
    if (!authorized) {
      setState(() {
        GoRouter.of(context).push("/auth");
      });
      return false;
    }
    else {
      try {
        http.Response resp = await http.get(
          Uri.parse("${ServerApi.serverUrl}/api/central/voting/voteUnvote?id=${widget.model.id}&type=${type == UserVoteType.up ? 0 : 1}"),
          headers: {
            'Authorization': 'Bearer $atoken',
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        );

        if (resp.statusCode == 200) {
          UserVoteResultModel result = UserVoteResultModel.fromJson(jsonDecode(resp.body) as Map<String, Object?>);

          if (!result.isOk) return false;

          setState(() {
            if (result.isChecked) {
              if (type == UserVoteType.up) {
                widget.model.upVotes++;
                if (widget.voteModel != null) {
                  widget.model.downVotes--;
                }
              }
              else {
                widget.model.downVotes++;
                if (widget.voteModel != null) {
                  widget.model.upVotes--;
                }
              }
              widget.voteModel = UserVoteModel(0, widget.model.id, type);
            }
            else {
              if (type == UserVoteType.up) {
                widget.model.upVotes--;
              }
              else {
                widget.model.downVotes--;
              }
              widget.voteModel = null;
            }
          });

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

  }

  final commentController = TextEditingController();

  Future<bool> sendComment() async {
    try {
        http.Response resp = await http.get(
          Uri.parse("${ServerApi.serverUrl}/api/central/comments/create?pid=${widget.model.id}&content=${commentController.text}"),
          headers: {
            'Authorization': 'Bearer $atoken',
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        );

        if (resp.statusCode == 200) {
          if (resp.body == "true") {
            widget.model.comments.add(UserCommentModel(0, "you", commentController.text, DateTime.now(), 0, 0, []));
            setState(() {
              commentController.text = "";
            });
          }
            
          return false;
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

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
                SizedBox( 
                  width: 50,
                  height: 50,
                  child: Icon(Icons.add_comment),
                ),
                SelectableText("Оставьте отзыв о шаге"),
                Row(
                  spacing: 5,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              widget.voteModel == null ? Icons.thumb_up_outlined : widget.voteModel!.type == UserVoteType.up ? Icons.thumb_up : Icons.thumb_up_outlined
                            ),
                            SelectableText(widget.model.upVotes.toString())
                          ],
                        ),
                        onTap: () async {
                          await vote(UserVoteType.up);
                          setState(() {
                            
                          });
                        },
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              widget.voteModel == null ? Icons.thumb_down_outlined : widget.voteModel!.type == UserVoteType.down ? Icons.thumb_down : Icons.thumb_down_outlined
                            ),
                            SelectableText(widget.model.downVotes.toString())
                          ],
                        ),
                        onTap: () async {
                          await vote(UserVoteType.down);
                          setState(() {
                            
                          });
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 20, 22, 20),
                borderRadius: 
                widget.show ? BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)) 
                : BorderRadius.circular(20),
              ),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: commentController)),
                    TextButton(onPressed: sendComment, child: Text("Отправить"))
                  ],
                ),
                ListView.builder(scrollDirection: Axis.vertical, shrinkWrap: true, itemCount: widget.model.comments.length, itemBuilder: (context, index) {
                  UserCommentModel cmodel = widget.model.comments[index];

                  if (cmodel.userId != "you") {
                    widget.pullName(cmodel.userId);
                  }
                  
                  return Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 83, 81, 81),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    //margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    height: 50,
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox( 
                          width: 50,
                          height: 50,
                          child: Icon(Icons.comment),
                        ),
                        SelectableText("${widget.idNames[cmodel.userId] ?? "Неизвестный"}: ${cmodel.content}")
                      ],
                    ),
                  );
                })
              ],
            )
          )
        ],
      )
    );
  }
}