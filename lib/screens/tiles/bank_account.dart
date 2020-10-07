import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankAccountTile extends StatefulWidget {
  // Pass account object into this constructor
  final BankAccount account;

  BankAccountTile({this.account});

  @override
  _BankAccountTileState createState() => _BankAccountTileState();
}

class _BankAccountTileState extends State<BankAccountTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(
          widget.account.bankName,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
            '******' + widget.account.accountNumber.toString().substring(5, 9)),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.account.bankAvatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => widget.account.bankAvatar == ""
                ? Icon(
                    Icons.account_balance,
                    size: 45,
                    color: darkBlue(),
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/bank-account-list");
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class AccountBalanceTile extends StatefulWidget {
  // Pass account balance
  String balance;
  bool isLocked;
  GestureTapCallback onTap;

  AccountBalanceTile({this.balance, this.isLocked, this.onTap});

  @override
  _AccountBalanceTileState createState() => _AccountBalanceTileState();
}

class _AccountBalanceTileState extends State<AccountBalanceTile> {
  UserBloc userBloc;
  var currencyImage = Image.asset(
    'assets/images/money.png',
    scale: 0.8,
    width: 45,
    height: 45,
    fit: BoxFit.fill,
  );

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(
          AppLocalization.of(context).accountBalance,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: widget.isLocked
            ? Text("*******",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Text(worldCurrencies[userBloc.user.currency],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    )),
                Text(" " + widget.balance,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
        leading: currencyImage,
        trailing: IconButton(
          icon: Icon(widget.isLocked ? Icons.lock_outline : Icons.lock_open,
              color: Colors.grey[400]),
          onPressed: () {
            if (widget.isLocked) {
              PassCodePopup(
                  context: context,
                  isValidCallback: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      "/dashboard",
                      (Route<dynamic> route) => false,
                      arguments: {"dashboardIndex": 5, "isLocked": false},
                    );
                  },
                  cancelCallBack: () {
                    Navigator.pop(context);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalization.of(context).wrongPassword),
                    ));
                  });
              widget.onTap();
            } else {
              setState(() {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  "/dashboard",
                  (Route<dynamic> route) => false,
                  arguments: {"dashboardIndex": 5, "isLocked": true},
                );
                widget.isLocked = true;
              });
            }
          },
        ),
      ),
    );
  }
}
