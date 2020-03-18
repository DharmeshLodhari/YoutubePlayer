import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/widget/local_notification.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BankAccountTile extends StatefulWidget {
  // Pass account object into this constructor
  final BankAccount account;
  BankAccountTile({this.account});

  @override
  _BankAccountTileState createState() => _BankAccountTileState();
}

class _BankAccountTileState extends State<BankAccountTile> {
  final localNotifications = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();

    final settingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    localNotifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async =>
      await Navigator.of(context)
          .pushNamed('/dashboard', arguments: {'dashboardIndex': 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            widget.account.bankName,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text('******' +
              widget.account.accountNumber.toString().substring(5, 9)),
          leading: CachedNetworkImage(
            imageUrl: widget.account.bankAvatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[400]),
            onPressed: () {
              showOngoingNotification(localNotifications,
                  title: "title", body: "body");
            },
          ),
        ),
      ),
    );
  }
}

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
  var currencyImage = Image.asset(
    'assets/images/naira.png',
    scale: 1.0,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            'Account Balance',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(widget.isLocked ? "*******" : widget.balance),
          leading: currencyImage,
          trailing: IconButton(
            icon: Icon(widget.isLocked ? Icons.lock_outline : Icons.lock_open,
                color: Colors.grey[400]),
            onPressed: () {
              if (widget.isLocked) {
                PasscodePopup(
                    context: context,
                    isValidCallback: () {
                      Navigator.of(context).pushNamed('/dashboard',
                          arguments: {'dashboardIndex': 4, 'isLocked': false});
                    },
                    cancelCallBack: () {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Wrong Password !!"),
                      ));
                    });
                widget.onTap();
              } else {
                setState(() {
                  Navigator.of(context).pushNamed('/dashboard',
                      arguments: {'dashboardIndex': 4, 'isLocked': true});
                  widget.isLocked = true;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
