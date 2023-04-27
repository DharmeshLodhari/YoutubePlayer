import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/state_notifier.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/util.dart';
import '../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

Future<bool> checkAccountBalance(int? amount, BuildContext context) async {
  BankAccountBloc bankAccountBloc =
      Provider.of<BankAccountBloc>(context, listen: false);
  BasketBloc basketBloc = Provider.of<BasketBloc>(context, listen: false);

  if (bankAccountBloc.bankAccount == null ||
      bankAccountBloc.bankAccount!.bankName == null) {
    Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
    showToast(message: "Please add bank account first !!");
    return false;
  } else {
    double accountBalance = await getAccountBalance();
    // Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
    debugPrint("accountBalance:- $accountBalance");

    double spendingAmount =
        amount != null ? amount / 100 : basketBloc.total / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    }
    return true;
  }
}

Widget getUserProfilePic(String image, String fullName) {
  if (image == "" ||
      image ==
          "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
    return CircleAvatar(
      backgroundColor: navyBlue,
      radius: 15,
      child: Text(
        getInitials(fullName).toUpperCase(),
        style: TextStyle(color: white, fontWeight: FontWeight.w600),
      ),
    );
  } else {
    return SizedBox(
      width: 35,
      child: getCircularUserAvatar(image),
    );
  }
}
