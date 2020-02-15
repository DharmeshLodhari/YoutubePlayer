import 'package:Slydo/models/transactions.dart';
import 'package:flutter/material.dart';

Future showScaleAlertBox({
  @required BuildContext context,
  @required Widget yourWidget,
  Widget icon,
  Widget title,
  @required Widget firstButton,
  Widget secondButton,
}) {
  assert(context != null, "context is null!!");
  assert(yourWidget != null, "yourWidget is null!!");
  assert(firstButton != null, "button is null!!");
  return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              title: title,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[icon, Container(height: 10), yourWidget],
              ),
              actions: <Widget>[
                firstButton,
                secondButton,
              ],
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {});
}

class PaymentRequestTile extends StatelessWidget {
  final PaymentRequest paymentRequest;
  PaymentRequestTile({this.paymentRequest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            leading: getLeading(),
            title: getTitle(),
            trailing: getTrailing(),
            subtitle: getSubtitle()),
      ),
    );
  }

  Widget getLeading() {
    return Image.network(
      paymentRequest.avatar,
      height: 45,
      width: 45,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.high,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 45,
          width: 45,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes
                : null,
          ),
        );
      },
    );
  }

  Widget getTitle() {
    return Text(
      paymentRequest.payee,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Text(
      paymentRequest.currency + ' ' + paymentRequest.amount.toString(),
      style: TextStyle(
          color: paymentRequest.isCredit ? Colors.green[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }

  Widget getSubtitle() {
    return Text(
      paymentRequest.description,
      style: TextStyle(
          color: paymentRequest.isCredit ? Colors.green[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 15),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  TransactionTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            title: Text(
              transaction.payee,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            subtitle: Text(transaction.description),
            leading: Image.network(
              transaction.avatar,
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 45,
                  width: 45,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
            trailing: Text(
              transaction.currency + ' ' + transaction.amount.toString(),
              style: TextStyle(
                  color: transaction.isCredit
                      ? Colors.green[400]
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
      ),
    );
  }
}
