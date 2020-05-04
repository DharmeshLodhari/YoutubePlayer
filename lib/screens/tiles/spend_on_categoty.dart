import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SpendOnCategoryTile extends StatefulWidget {
  String name;
  String amount;
  String url;
  SpendOnCategoryTile({this.name, this.amount, this.url});
  @override
  _SpendOnCategoryTileState createState() => _SpendOnCategoryTileState();
}

class _SpendOnCategoryTileState extends State<SpendOnCategoryTile> {
  @override
  Widget build(BuildContext context) {
    var userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ListTile(
          leading: ClipOval(
            child: Container(
              child: Image.asset(
                widget.url,
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(""),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text("")
            ],
          ),
          trailing: Text(
            '${worldCurrencies[userBloc.user.currency]} ${widget.amount} ',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
