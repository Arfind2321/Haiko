import 'package:material_ui/material_ui.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      
      children: [
        Text("Оооой...."),
        Text("Возникла ошибка при обработке вашего запроса Ж("),
        Text(error),
        TextButton(
          child: Text("Назад"), 
          onPressed: () => {
            Navigator.pop(context)
          }
        )
      ],
      
    );
  }
}