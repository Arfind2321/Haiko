import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/minimal_article_model.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

//ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  SearchPage({super.key, this.searchQuery});

  String? searchQuery;

  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });
  }

  List<MinimalArticleModel> result = [];
  bool isSearching = false;

  void search(String query) async {
    setState(() {
      isSearching = true;
      result.clear();
    });

    try {
      http.Response resp = await http.get(
        Uri.parse("${ServerApi.serverUrl}/api/searcher/search?search_request=$query&limit=10"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        }
      );

      if (resp.statusCode == 200) {
        dynamic json = jsonDecode(resp.body);
        
        for (String id in ((json['IDs'] as List<dynamic>).map((data) => data as String).toList())) {
          MinimalArticleModel? mam = await ServerApi.getMinimalArticle(id);

          if (mam != null) {
            result.add(mam);
          }
        }
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
    }

    setState(() {
      isSearching = false;
    });
  }

  void asyncinitState() async {
    if (widget.searchQuery != null) {
      searchController.text = widget.searchQuery!;
      search(widget.searchQuery!);
    }

    setState(() {
      
    });
  }

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Поиск: "),
              Expanded(child: TextField(controller: searchController, onSubmitted: (value) {
                search(value);
              }))
            ]
          ),
          Builder(builder: (builder) {
            if (isSearching) {
              return Center(child: CircularProgressIndicator());
            }
            else {
              return Column(
                children: [
                  Text("Результат поиска: ", style: TextStyle(fontSize: 36)),
                  ListView.builder(scrollDirection: Axis.vertical, shrinkWrap: true, itemCount: result.length, itemBuilder: (b, i) {
                    MinimalArticleModel mam = result[i];

                    return Container(
                      margin: EdgeInsets.all(5),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 41, 67, 45),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            //margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(30),
                            child: Text(mam.title, style: TextStyle(fontSize: 24))
                          ),
                          onTap: () {
                            GoRouter.of(context).push("/article/${mam.id}");
                          },
                        )
                      ),
                    );
                  })
                ],
              );
            }
          })
        ],
      )
    );
  }
}