import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../service_hub/screens/my_job_details.dart';

class TransactionPaymentLink extends StatefulWidget {
  TransactionPaymentLink(
      {Key? key,
      this.date,
      this.id,
      this.amount,
      this.status,
      this.name,
      this.currency,
      this.category,
      this.link,
      this.passcode})
      : super(key: key);
  String? date;
  String? id;
  String? amount;
  String? currency;
  String? status;
  String? name;
  String? passcode;
  String? category;
  String? link;

  @override
  State<TransactionPaymentLink> createState() => _TransactionPaymentLinkState();
}

class _TransactionPaymentLinkState extends State<TransactionPaymentLink> {
  final now = DateTime.now();
  var yesterday;
  var datetime;
  bool isLoading = false;

  var response;

  bool isBalanceHidden = true;

  final _auth = PaymentAndBankingAuth();

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.transaction,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  enableActionLink(Map map) async {
    try {
      isLoading = true;
      await _auth.paymentLinksAction(map).then((value) {
        setState(() {
          if (value.statusCode == 200) {
            response = jsonDecode(value.body);
            isLoading = false;
          }
        });
      });

      setState(() {});
    } catch (e) {
      log(e.toString());
      isLoading = false;

      setState(() {});

      rethrow;
    }
  }

  @override
  void initState() {
    datetime = now.difference(DateTime.parse(widget.date!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Center(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  shadowColor: boxShadowTwo,
                  elevation: 0,
                  child: Container(
                    decoration: decorateBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 20),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getAmount(int.parse(widget.amount!),
                                      widget.currency!,
                                      fontSize: 20),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  getDateTime(context, widget.date!,
                                      fontSize: 14),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => showDataAlert(widget.link),
                                child: Card(
                                  elevation: 0.3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Image.asset(
                                    "assets/images/tran_bar_code.png",
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: darkGrey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  transIcon('trans_paylink'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 20,
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText(
                                    title: 'Status',
                                    fontSize: 16,
                                    fontweight: FontWeight.w700,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: colorStats(response != null
                                              ? response['status']
                                              : widget.status!)
                                          .withOpacity(0.1),
                                    ),
                                    child: Text(
                                      response != null
                                          ? response['status']
                                          : widget.status!,
                                      style: TextStyle(
                                        color: colorStats(response != null
                                            ? response['status']
                                            : widget.status!),
                                        fontSize: 10.80,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        transWidget(
                            image: 'trans_cat',
                            text: 'Category',
                            textDetails: widget.category ?? '',
                            fontSize: 14,
                            color: black),
                        transWidget(
                            image: 'trans_ref',
                            text: 'Reference',
                            textDetails: widget.name,
                            fontSize: 14,
                            color: black),
                        transWidgetPassword(
                            image: 'tran_pass',
                            text: 'Passcode',
                            textDetails: widget.passcode,
                            isHidden: true,
                            fontSize: 14,
                            color: black),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text:
                                    "Passcode: ${widget.passcode}\nLink: ${widget.link}"));
                            showToast(message: "Passcode and link copied !");
                          },
                          child: transWidget(
                              image: 'link_trans',
                              text: 'Link',
                              textDetails: widget.link ?? '',
                              fontSize: 12,
                              color: navyBlue),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                returnButton()
              ],
            ),
          ),
        ));
  }

  showDataAlert(link) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: Container(
              height: 520,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Payment Link",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Your payment link has been generated.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _displayBarcodeInfo(link),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                "Passcode: ${widget.passcode}\nLink: ${widget.link}"));
                        showToast(message: "Passcode and link copied !");
                      },
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: navyBlue,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                'Copy Link',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: white),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SvgPicture.asset(
                                'copy_icon_link'.toSVG(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget returnButton() {
    if (widget.status?.toLowerCase() == 'paid') {
      return const SizedBox.shrink();
    }
    if (widget.status?.toLowerCase() == 'cancelled') {
      return const SizedBox.shrink();
    }
    return isLoading == true
        ? const CircularProgressIndicator()
        : getSubmitButton();
  }

  Widget _displayBarcodeInfo(link) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFF3F3F3), width: 2)),
      margin: EdgeInsets.zero,
      elevation: 0.0,
      child: Container(
        decoration:
            decorateBox(borderRadius: 20, borderColor: HexColor("#F3F3F3")),
        child: Container(
          margin: const EdgeInsets.all(13),
          key: tutorialQrCodeKey,
          child: CustomPaint(
            painter: QrPainter(
                data: link,
                options: const QrOptions(
                    shapes: QrShapes(
                        darkPixel: QrPixelShapeCircle(radiusFraction: .8),
                        frame: QrFrameShapeRoundCorners(cornerFraction: .25),
                        ball: QrBallShapeRoundCorners(cornerFraction: .25)),
                    colors: QrColors(
                        light: QrColorSolid(Color.fromARGB(0, 0, 0, 0))))),
            size: Size(MediaQuery.of(context).size.width / 1.7,
                MediaQuery.of(context).size.width / 1.7),
          ),
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () => enableActionLink({
        'status':
            response != null && response['status'].toLowerCase() == 'active' ||
                    widget.status?.toLowerCase() == 'active'
                ? 'Inactive'
                : 'Active',
        'id': widget.id
      }),
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: response != null && response['status'].toLowerCase() == 'active' ||
              widget.status?.toLowerCase() == 'active'
          ? "Disable Link"
          : "Enable Link",
    );
  }

  Widget transWidget(
      {String? image,
      String? text,
      String? textDetails,
      Color? color,
      double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              transIcon(image),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 20,
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title: text!,
                  fontSize: 16,
                  fontweight: FontWeight.w700,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 300,
                  child: Text(
                    textDetails ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget transWidgetPassword(
      {String? image,
      String? text,
      String? textDetails,
      Color? color,
      bool isHidden = false,
      double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              transIcon(image),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 20,
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title: text!,
                  fontSize: 16,
                  fontweight: FontWeight.w700,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  isHidden == true && isBalanceHidden
                      ? '*******'
                      : textDetails ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          !isHidden
              ? const SizedBox.shrink()
              : isBalanceHidden
                  ? IconButton(
                      padding: const EdgeInsets.only(top: 4, right: 22),
                      alignment: Alignment.center,
                      icon: Icon(
                        SlydoAppIcon.eye,
                        color: black,
                        size: 12,
                      ),
                      onPressed: () {
                        BottomSheetPassCode(
                          context: context,
                          isValidCallback: () {
                            isBalanceHidden = false;
                            setState(() {});
                          },
                          cancelCallBack: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                  : IconButton(
                      alignment: Alignment.center,
                      icon: Icon(
                        SlydoAppIcon.eye_close,
                        color: black,
                        size: 12,
                      ),
                      onPressed: () {
                        isBalanceHidden = true;
                        setState(() {});
                      },
                    )
        ],
      ),
    );
  }

  Widget transIcon(String? icon) {
    return SizedBox(
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            icon!.toSVG(),
          ),
        ),
      ),
    );
  }
}
