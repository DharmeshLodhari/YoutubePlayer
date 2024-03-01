import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<List<ShippingAddress>> getAddressListing(
    List<String?> addressIdList) async {
  String? listNext = "";
  String? listPrevious = "";
  List<ShippingAddress> addressListing = [];
  int? listCount = 0;
  Map<String, dynamic> data = {
    "addresses": addressIdList,
  };

  if (listNext != null) {
    Map<String, dynamic>? result = await ShippingProcessAuthService()
        .getAddressListing(listNext, listPrevious, data);

    listCount = result!['count'];
    listNext = result['next'];
    listPrevious = result['previous'];
    var tempList = result['results'];
    addressListing.addAll(tempList);
  }
  return addressListing;
}

Future<List<SharedCartModel>> getCartList() async {
  int? listCount = 0;
  String? listNext = "";
  String? listPrevious = "";
  List<SharedCartModel> cartNameListing = [];
  if (listNext != null) {
    Map<String, dynamic>? result =
        await SharedCartAuthService().getSharedCartList(listNext, listPrevious);

    listCount = result!['count'];
    listNext = result['next'];
    listPrevious = result['previous'];
    var tempList = result['results'];
    cartNameListing.addAll(tempList);
  }
  return cartNameListing;
}

Future<bool?> buildNewCartAlertDialog(
    {required BuildContext context,
    required Map<String, dynamic> notification}) async {
  bool? result = await showDialogBoxWithInput(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: navyBlue,
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.viewCart,
      firstActionPrimary: false,
      content: Column(
        children: [
          Text(AppLocalization.of(context)!.newCartAlert,
              style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter",
                  fontSize: 16.0),
              textAlign: TextAlign.center),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'You have been added to ',
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontSize: 14.0,
                    ),
                  ),
                  TextSpan(
                    text: notification['data']['cart_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: blackFont,
                      fontFamily: "Inter",
                      fontSize: 14.0,
                    ),
                  ),
                  TextSpan(
                    text: ' shared cart',
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      leftButtonOnPressed: () async {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        Navigator.pop(context);

        SharedCartBloc sharedCartBloc =
            Provider.of<SharedCartBloc>(context, listen: false);
        int index = sharedCartBloc.cartList
            .indexWhere((item) => item.id == notification['data']['cart_id']);

        if (index == null || index < 0) {
          await sharedCartBloc.refreshAllCart(context);
        }

        int newIndex = sharedCartBloc.cartList
            .indexWhere((item) => item.id == notification['data']['cart_id']);

        sharedCartBloc.currentSelectedIndex = newIndex;
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed(Routes.SHARED_CARD_DETAILS);
      });
  return result;
}

Future<bool?> buildCartPaymentRequestDialog(
    {required BuildContext context,
    required Map<String, dynamic> notification}) async {
  bool? result = await showDialogBoxWithInput(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: navyBlue,
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.viewNow,
      firstActionPrimary: false,
      content: Column(
        children: [
          Text(AppLocalization.of(context)!.cartPaymentRequest,
              style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter",
                  fontSize: 16.0),
              textAlign: TextAlign.center),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text:
                          'A payment request of ${notification['data']['currency']}${notification['data']['amount']} from ',
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontSize: 14.0,
                      )),
                  TextSpan(
                      text: notification['data']['cart_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: blackFont,
                        fontFamily: "Inter",
                        fontSize: 14.0,
                      )),
                  TextSpan(
                    text: ' shared cart?',
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      leftButtonOnPressed: () async {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        Navigator.pop(context);

        // SharedCartBloc sharedCartBloc =
        //     Provider.of<SharedCartBloc>(context, listen: false);
        // int index = sharedCartBloc.cartList
        //     .indexWhere((item) => item.id == notification['data']['cart_id']);
        // sharedCartBloc.currentSelectedIndex = index;
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.pushNamed(context, Routes.ACCOUNTS);
      });
  return result;
}
