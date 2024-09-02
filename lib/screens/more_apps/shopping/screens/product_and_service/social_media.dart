import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class SocialMedia extends StatefulWidget {
  const SocialMedia({super.key, this.arguments});

  final dynamic arguments;

  @override
  State<SocialMedia> createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  String? momentUrl;
  String? yarnUrl;

  @override
  void initState() {
    String modelName = widget.arguments["modelName"];
    modelName = modelName.toLowerCase();
    final String id = widget.arguments["id"];

    yarnUrl = "/api/v1/social/ask/$modelName/$id/";
    momentUrl = "/api/v1/social/moments/$modelName/$id/";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: _buildBody(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        '${widget.arguments["modelName"]} Showcase',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Text(
        "Coming Soon",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
