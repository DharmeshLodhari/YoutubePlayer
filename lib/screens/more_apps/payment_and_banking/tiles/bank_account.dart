import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BankAccountTile extends StatefulWidget {
  // Pass account object into this constructor
  final BankAccount? account;

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
          widget.account!.bankName!,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text('******' +
            widget.account!.accountNumber.toString().substring(5, 9)),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.account!.bankAvatar!,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => widget.account!.bankAvatar == ""
                ? Icon(
                    Icons.account_balance,
                    size: 45,
                    color: blackFont,
                  )
                : CircularLoadingIndicator(),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/bank-account-list");
        },
      ),
    );
  }
}
