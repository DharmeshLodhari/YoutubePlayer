import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool> checkAccountBalance(int? amount, BuildContext context) async {
  final BankAccountBloc bankAccountBloc =
      Provider.of<BankAccountBloc>(context, listen: false);
  final BasketBloc basketBloc = Provider.of<BasketBloc>(context, listen: false);

  if (bankAccountBloc.bankAccount == null ||
      bankAccountBloc.bankAccount!.bankName == null) {
    Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
    showToast(message: "Please add bank account first !!");
    return false;
  } else {
    final double accountBalance = await getAccountBalance();
    // Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
    debugPrint("accountBalance:- $accountBalance");

    final double spendingAmount =
        amount != null ? amount / 100 : basketBloc.total / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    }
    return true;
  }
}
