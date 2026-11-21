import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:haiko/api/server_api.dart';
import 'package:haiko/models/minimal_article_model.dart';
import 'package:material_ui/material_ui.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncinitState();
    });
  }

  Map<String, String> idNames = {
    "you": "Вы"
  };

  void pullName(String id) async {
    if (idNames.containsKey(id)) return;

    String name = await ServerApi.getUserName(id);
    idNames[id] = name;

    setState(() {
      
    });
  }

  List<MinimalArticleModel> latest = [];
  int page = 1;

  void getLatest() async {
    try {
      http.Response resp = await http.get(
        Uri.parse("${ServerApi.serverUrl}/api/central/articles/getLatest?max=10&page=$page"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        }
      );

      if (resp.statusCode == 200) {
        dynamic json = jsonDecode(resp.body);
        
        latest = (json as List<dynamic>).map((data) => MinimalArticleModel.fromJson(data)).toList();

        setState(() {
          
        });
      }
    }
    catch (ex) {
      developer.log(ex.toString(), name: 'haiko');
    }
  }

  void asyncinitState() async {
    getLatest();

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
                GoRouter.of(context).push("/search/$value");
              }))
            ]
          ),
          Text("Все статьи: ", style: TextStyle(fontSize: 36)),
          ListView.builder(scrollDirection: Axis.vertical, shrinkWrap: true, itemCount: latest.length, itemBuilder: (b, i) {
            MinimalArticleModel mam = latest[i];

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
          }),
          TextButton(onPressed: () {
            page++;
            getLatest();
          }, child: Text("Загрузить ещё"))
        ],
      )
    );
  }
}