import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/cart_members.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class SharedCartDetails extends StatefulWidget {
  @override
  State<SharedCartDetails> createState() => _SharedCartDetailsState();
}

class _SharedCartDetailsState extends State<SharedCartDetails> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
        title: Text("My Birthday Hangout", style: TextStyle(
              color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),),
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> CartMembers()));
            },
            child: buildMultipleFollowersWidget()),
          scanQRCodeBtn(),
          const SizedBox(
            width: 16,
          ),
        ],
        backgroundColor: white,
        elevation: 0.0,
      ),
      floatingActionButton:  checkoutWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

    Widget buildMultipleFollowersWidget(
      {double radiusSize: 32,
      double radiusShift: 10,
      double radiusHeight: 32,
      radiusWidth: 32}) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: StackedWidgets(
        size: radiusSize,
        xShift: radiusShift,
        items: [
          ...List.generate(3, (index) => CircleAvatar()),
        ],
      ),
    );
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

    Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shadowColor: boxShadowTwo,
      elevation: 4,
      child: Container(
        decoration: decorateBox(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.total + " : ",
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                // Text(
                //   worldCurrencies[userBloc.user.currency!]!,
                //   style: const TextStyle(
                //       fontFamily: "Inter",
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   moneyDisplayNormalizer(int.parse(getTotalPrice().toString())),
                //   style: const TextStyle(
                //       fontSize: 16, fontWeight: FontWeight.bold),
                // ),
              ],
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            MaterialButton(
              height: 40,
              color: navyBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const SizedBox(
                width: 66,
                child: Text(
                  "Checkout",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              onPressed: () {
                // if (appConfigurationModel?.enableCheckout == true) {
                //   NavigationUtil.push(
                //     context,
                //     screen: const CheckoutScreen(),
                //   );
                // } else {
                //   showToast(message: 'Checkout not available now');
                // }

                // // if (basketBloc.items.length != 0) {
                // //   addNoteDialog();
                // // } else {
                // //   showToast(
                // //       message: AppLocalization.of(context)!
                // //           .pleaseAddSomeItemsFirst);
                // // }
              },
            )
          ],
        ),
      ),
    );
  }
}
