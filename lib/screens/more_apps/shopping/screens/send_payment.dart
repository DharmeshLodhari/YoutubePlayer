import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';

class SendPayment extends StatefulWidget {
  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  String productPrice = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: appBar() as PreferredSizeWidget?,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: CustomBoxShadow(
            child: Card(
              margin: EdgeInsets.all(16),
              shadowColor: boxShadowTwo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Diro Collection",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: blackFont),
                            ),
                            Text(
                              "Diro.Collection",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: darkGrey),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(
                          SlydoAppIcon.qr_code,
                          color: darkGrey,
                          size: 48,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        getAmountField(),
                        SizedBox(height: 20),
                        getAmountField(),
                        SizedBox(height: 20),
                        getAmountField(),
                        SizedBox(height: 20),
                        getAmountField(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                "Toggle to activate this tag",
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Switch(
                onChanged: (value) {
                  // flashTagAlertModel.isActive = !flashTagAlertModel.isActive;
                  // setState(() {});
                },
                value: true,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CurvedButton(
            text: 'Send payment',
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            productPrice = double.parse(val.replaceAll(',', '')).toString();
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget appBar() {
    return AppBar(
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
      title: Text(
        "Send Payment",
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: [
        // scanQRCodeBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
      backgroundColor: white,
      elevation: 0.0,
    );
  }
}
