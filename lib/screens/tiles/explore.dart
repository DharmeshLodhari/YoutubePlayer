import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ExploreTile extends StatefulWidget {
  @override
  _ExploreTileState createState() => _ExploreTileState();
}

class _ExploreTileState extends State<ExploreTile> {
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
        child: ListTile(
          title: Text(
            AppLocalization.of(context)!.explore,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          leading: Icon(
            Icons.explore,
            color: Colors.black,
            size: 45,
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/explore');
          },
        ),
      ),
    );
  }
}
