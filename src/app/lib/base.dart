import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class AppBase extends StatefulWidget  {
  const AppBase({super.key, required this.child});

  final Widget child;

  @override
  State<StatefulWidget> createState() => AppBaseState();
}

class AppBaseState extends State<AppBase> {
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
    return Container(
      color: Color(0xFF10140f),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: 
          Scaffold(
            appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.5), // Радиус закругления снизу
                ),
              ),
              //actionsPadding: EdgeInsets.all(10),
              backgroundColor: Color(0xFF1e221c),
              leadingWidth: 250,
              leading: Container(
                padding: EdgeInsets.fromLTRB(50, 10, 10, 10),
                child: MouseRegion(
              cursor: SystemMouseCursors.click,
                child:  GestureDetector(
                  child: Image(image: AssetImage('assets/logo-white-text-only-sized.png')),
                  onTap: () => {
                    context.go("/")
                  },
                ),
              ),
              ),

              toolbarHeight: 80,

              actions: [
                Text("login")
              ],
            ),
            body: Container(
              margin: const EdgeInsets.all(10),
              child: widget.child,
            )
          )
        )
    );
  }
}