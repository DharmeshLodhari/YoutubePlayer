import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class SendCartPayment extends StatefulWidget {
  const SendCartPayment({Key? key}) : super(key: key);

  @override
  State<SendCartPayment> createState() => _SendCartPaymentState();
}

class _SendCartPaymentState extends State<SendCartPayment> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Send Payment',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: selectedListItemBackgroundBlue),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.zero,
                  shadowColor: boxShadowTwo,
                  color: white,
                  child: Container(
                    decoration: decorateBox(),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserProfile(),
                          const SizedBox(
                            height: 16,
                          ),
                          _buildRecipient(),
                          const SizedBox(
                            height: 16,
                          ),
                          _buildAmount(),
                          const SizedBox(
                            height: 16,
                          ),
                          _buildCategory(),
                          const SizedBox(
                            height: 16,
                          ),
                          _buildReference(),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildProfileImage(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Prineygladhair",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: black,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
      subtitle: Text(
        "Prineygladhair",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: black,
          fontFamily: "Inter",
        ),
      ),
      trailing: _buildQRImage(),
    );
  }

  Widget _buildProfileImage() {
    return Image.network(
      "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
      height: 48,
      width: 48,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      cacheHeight: 48,
      cacheWidth: 48,
      frameBuilder: imageFrameBuilder,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }

  Widget _buildQRImage() {
    return Image.asset(
      'assets/images/payment_qr_code.png',
      width: 48,
      height: 48,
    );
  }

  Widget _buildRecipient() {
    return CustomizedTextFormField(
      fontSize: 14,
      labelText: "Recipient",
      labelColor: darkGrey,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildAmount() {
    return CustomizedTextFormField(
      fontSize: 14,
      labelText: "Amount",
      labelColor: darkGrey,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildCategory() {
    return CustomizedDropDownField(
      title: "Category",
      fontSize: 14,
      fontWeight: FontWeight.w500,
      child: Container(
        child: ListTile(
          dense: true,
          title: Text(
            'Shopping',
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
            maxLines: 1,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildReference() {
    return CustomizedTextFormField(
      fontSize: 14,
      labelText: "Reference",
      labelColor: darkGrey,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildPaymentButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () {
                Navigator.of(context).pushNamed(Routes.SUCCESSFUL_ORDER);
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Send Payment',
      ),
    );
  }
}
