import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SpendOnCategoryTile extends StatefulWidget {
  String? name;
  int? amount;
  IconData? icon;
  Color? color;

  SpendOnCategoryTile(
      {super.key, this.name, this.amount, this.icon, this.color});

  @override
  State<SpendOnCategoryTile> createState() => _SpendOnCategoryTileState();
}

class _SpendOnCategoryTileState extends State<SpendOnCategoryTile> {
  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconBtnGrey, width: 1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: RoundedBackgroundIcon(
              icon: Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
              backgroundColor: widget.color!.withOpacity(0.08),
              borderRadius: 20,
              height: 50,
              width: 50,
              onTap: () {},
            ),
            title: Text(
              widget.name!,
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
                  '${worldCurrencies[userBloc.user.currency!]}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Inter",
                      color: blackFont),
                ),
                Text(
                  moneyDisplayNormalizer(widget.amount),
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
