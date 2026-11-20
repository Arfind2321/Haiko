import 'package:cached_network_image/cached_network_image.dart';
import 'package:haiko/api/server_api.dart';
import 'package:material_ui/material_ui.dart';


class HaikoCricleAvatar extends StatefulWidget  {
  const HaikoCricleAvatar({super.key, this.radius = 50, required this.id});

  final double radius;
  final String id;

  @override
  State<StatefulWidget> createState() => HaikoCricleAvatarState();
}

class HaikoCricleAvatarState extends State<HaikoCricleAvatar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CircleAvatar(radius: widget.radius, backgroundImage: Image(image: CachedNetworkImageProvider("${ServerApi.serverUrl}/static/${widget.id}")).image),
    );
  }
}