import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/colors.dart';
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 5),
      shadowColor: boxShadow,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Image.asset(
                widget.url,
                fit: BoxFit.fill,
                height: 48,
                width: 48,
              ),
            ),
            title: Text(
              widget.name,
              maxLines: 1,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${worldCurrencies[userBloc.user.currency]}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                      color: blackFont),
                ),
                Text(
                  widget.amount.toString(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blackFont),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
