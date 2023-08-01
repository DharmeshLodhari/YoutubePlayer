import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/util.dart';
import '../../../widget/curved_btn.dart';
import '../service_hub/screens/my_job_details.dart';

class TransactionPaymentLink extends StatefulWidget {
  TransactionPaymentLink(
      {Key? key, this.date, this.amount, this.status, this.name})
      : super(key: key);
  String? date;
  String? amount;
  String? status;
  String? name;

  @override
  State<TransactionPaymentLink> createState() => _TransactionPaymentLinkState();
}

class _TransactionPaymentLinkState extends State<TransactionPaymentLink> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CustomText(
                                      title: 'Slydo',
                                      fontSize: 16,
                                      fontweight: FontWeight.w700,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      widget.date ?? '',
                                      style: const TextStyle(
                                        color: Color(0xff8d92a3),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                CustomText(
                                  title: '₦${widget.amount ?? ''}',
                                  fontSize: 16,
                                  fontweight: FontWeight.w700,
                                ),
                              ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(color: Color(0xff8d92a3)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: colorStats(widget.status!)
                                                  .withOpacity(0.1),
                                            ),
                                            child: Text(
                                              widget.status ?? '',
                                              style: TextStyle(
                                                color:
                                                    colorStats(widget.status!),
                                                fontSize: 10.80,
                                                fontFamily: "Open Sans",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const Spacer(),
                              Card(
                                elevation: 0.3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Image.asset(
                                  "assets/images/tran_bar_code.png",
                                  width: 60,
                                  height: 60,
                                ),
                              )
                            ],
                          ),
                        ),
                        transWidget(
                            image: 'trans_cat',
                            text: 'Category',
                            textDetails: 'General',
                            fontSize: 14,
                            color: black),
                        transWidget(
                            image: 'trans_ref',
                            text: 'Reference',
                            textDetails: widget.name,
                            fontSize: 14,
                            color: black),
                        transWidget(
                            image: 'tran_pass',
                            text: 'Passcode',
                            textDetails: '23456789',
                            fontSize: 14,
                            color: black),
                        transWidget(
                            image: 'link_trans',
                            text: 'Link',
                            textDetails:
                                'https:thisisyourgeneratedpaymentlink.com',
                            fontSize: 12,
                            color: navyBlue),
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
                widget.status?.toLowerCase() == 'successful'
                    ? const SizedBox.shrink()
                    : getSubmitButton()
              ],
            ),
          ),
        ));
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () {},
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: widget.status?.toLowerCase() == 'pending'
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
      padding: const EdgeInsets.only(left: 10),
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
          Column(
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
                textDetails ?? '',
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
        margin: EdgeInsets.symmetric(
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
