import 'package:material_ui/material_ui.dart';

class ArticlesPage extends StatefulWidget  {
  const ArticlesPage({super.key});
  @override
  State<StatefulWidget> createState() => ArticlesPageState();
}

class ArticlesPageState extends State<ArticlesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
    asyncinitState();
  });
  }

  void asyncinitState() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: 
        Stack(
          children: [
            Column(
              children: [
                Text("hi"),
                
              ],
            )
          ],
        )
      );
  }
}