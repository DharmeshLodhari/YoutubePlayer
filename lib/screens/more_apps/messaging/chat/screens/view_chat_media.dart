import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewChatMedia extends StatefulWidget {
  final arguments;

  ViewChatMedia({this.arguments});

  @override
  _ViewChatMediaState createState() => _ViewChatMediaState();
}

class _ViewChatMediaState extends State<ViewChatMedia> {
  String type = "";
  String file = "";
  String message = "";

  @override
  void initState() {
    type = widget.arguments["type"];
    file = widget.arguments["file"];
    message = widget.arguments["message"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(true);
        },
        child: Scaffold(
          body: scaffoldBody(),
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              ClipRect(
                  child: PhotoView(
                imageProvider: NetworkImage(file),
              )),
              Positioned(
                top: 4,
                left: 4,
                child: InkWell(
                  child: ClipOval(
                    child: Container(
                      height: 36,
                      width: 36,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              (message != "")
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black38,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                                child: Center(
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.justify,
                              ),
                            )),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          )),
        ],
      ),
    );
  }
}
