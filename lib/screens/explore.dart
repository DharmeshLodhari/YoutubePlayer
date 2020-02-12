import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/widget/exit_alert_dialog.dart';
import 'package:flutter/material.dart';

class ExploreList extends StatefulWidget {
  @override
  _ExploreListState createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => ExitAlertDialog(),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Center(child: Text("Explore")),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
