import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberPaymentTile extends StatefulWidget {
  MemberPaymentTile(
      {this.member, this.index, this.isUserPaymentDone, super.key});

  final int? index;
  final SharedCartMemberModel? member;
  final bool? isUserPaymentDone;

  @override
  State<MemberPaymentTile> createState() => _MemberPaymentTileState();
}

class _MemberPaymentTileState extends State<MemberPaymentTile> {
  double percentageValue = 0.0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: GestureDetector(
          onTap: () {
            sharedCartBloc.getSharedCartModel().splitBillEvenly == false &&
                    sharedCartBloc.isUserCartOwner(context) == true
                ? _buildPaymentPercentageDialog(context)
                : null;
            setState(() {});
          },
          child: ListTile(
            leading: getLeading(),
            title: getTitle(),
            subtitle: getSubTitle(),
            trailing: getTrailing(),
          ),
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        height: 45,
        width: 45,
        imageUrl: widget.member?.avatar == ""
            ? defaultImage
            : widget.member?.avatar ?? "",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        errorWidget: imageErrorWidget,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget getTitle() {
    return Text(
      '@${widget.member?.userName}',
      style: TextStyle(
          color: blackFont,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: "Inter"),
    );
  }

  Widget getSubTitle() {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
          overlayShape: SliderComponentShape.noOverlay,
          trackHeight: 4,
          thumbShape: RoundSliderThumbShape(
              disabledThumbRadius: 0,
              enabledThumbRadius: 0,
              elevation: 0,
              pressedElevation: 0)),
      child: Slider(
        min: 0,
        max: 100,
        inactiveColor: greyBorderColor,
        activeColor: richPink,
        value: getSliderValue(),
        onChanged: (newValue) {
          // setState(() {
          //   final to = Duration(milliseconds: newValue.floor());
          //   _visibleValue = to;
          // });
        },
      ),
    );
  }

  double getSliderValue() {
    double sliderValue = 0;
    sliderValue = widget.member?.percentageValue?.toDouble() ?? 0;
    return sliderValue;
  }

  Widget getTrailing() {
    return Container(
      width: 110,
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              getAmount(),
              style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: "Inter"),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                getPercentage(),
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: "Inter"),
              ),
              SizedBox(width: 3),
              if (widget.isUserPaymentDone == true)
                Image.asset(
                  height: 15,
                  width: 15,
                  "assets/images/check_mark.jpeg",
                  fit: BoxFit.fitWidth,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String getPercentage() {
    String percentage = "0";
    percentage = "${widget.member?.percentageValue.toString() ?? 0}%";
    return percentage;
  }

  String getAmount() {
    String amount = "0";
    amount =
        '${worldCurrencies[userBloc.user.currency]}${moneyDisplayNormalizer(widget.member?.paymentValue)}';
    return amount;
  }

  void _buildPaymentPercentageDialog(BuildContext context) {
    showDialogBoxWithTitle(
        context: context,
        actionTextColor: white,
        actionBgColor: navyBlue,
        actionText: 'Save',
        firstActionPrimary: false,
        isOverlayTapDismiss: false,
        content: StatefulBuilder(builder: (context, setState) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    percentageValue = 0.0;
                    _controller.clear();
                  },
                  icon: Icon(Icons.highlight_off_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Change Percentage',
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Inter",
                                fontSize: 16.0),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(height: 30),
                      Text('Name : @${widget.member?.userName}',
                          style: TextStyle(
                              color: darkGrey,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Inter",
                              fontSize: 16.0),
                          textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      CustomizedTextFormField(
                        controller: _controller,
                        labelText: "Percentage",
                        labelColor: darkGrey,
                        validator: (val) {
                          if (val.isNotEmpty) {
                            // if (int.parse(val) > 100) {
                            //   return "Set percentage blow 100";
                            // }
                            return null;
                          }
                          return AppLocalization.of(context)!
                              .pleaseEnterCartName;
                        },
                        onChanged: (val) {
                          setState(() {
                            // _controller.text = val;

                            // if (int.parse(val) <= 100) {
                            percentageValue = double.parse(val);
                            // }
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      SliderTheme(
                        data: Theme.of(context).sliderTheme.copyWith(
                            overlayShape: SliderComponentShape.noOverlay,
                            trackHeight: 3,
                            thumbShape: RoundSliderThumbShape(
                                disabledThumbRadius: 10,
                                enabledThumbRadius: 10,
                                elevation: 1,
                                pressedElevation: 10)),
                        child: Slider(
                          min: 0,
                          max: 100,
                          inactiveColor: greyBorderColor,
                          activeColor: richPink,
                          value: percentageValue <= 100 ? percentageValue : 0,
                          onChanged: (newValue) {
                            setState(() {
                              // if (newValue > 100) {
                              // showToast(message: "Set percentage blow 100");
                              // } else {
                              _controller.text = newValue.floor().toString();
                              percentageValue = newValue;
                              // }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        ButtonOnPressed: () async {
          if (_formKey.currentState!.validate()) {
            sharedCartBloc.updatePercentageAndPrice(
                cart: sharedCartBloc.getSharedCartModel(),
                val: double.parse(_controller.text.trim()),
                index: widget.index ?? 0,
                context: context);
            percentageValue = 0.0;
            _controller.clear();
            setState(() {});
          }
        });
  }
}
