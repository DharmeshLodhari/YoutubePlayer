import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MembersPaymentTile extends StatefulWidget {
  MembersPaymentTile({this.members, this.index, super.key});

  final int? index;
  final UserFollowers? members;

  @override
  State<MembersPaymentTile> createState() => _MembersPaymentTileState();
}

class _MembersPaymentTileState extends State<MembersPaymentTile> {
  double percentageValue = 0.0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: GestureDetector(
          onTap: () {
            _buildPaymentPercentageDialog(context);
          },
          child: ListTile(
            leading: ClipOval(
              child: CachedNetworkImage(
                height: 45,
                width: 45,
                imageUrl: widget.members?.avatar == ""
                    ? defaultImage
                    : widget.members?.avatar ?? "",
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fill,
                errorWidget: imageErrorWidget,
                filterQuality: FilterQuality.high,
              ),
            ),
            title: Text(
              '@${widget.members?.userName}',
              style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: "Inter"),
            ),
            subtitle: SliderTheme(
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
                value: 50.0,
                onChanged: (newValue) {
                  // setState(() {
                  //   final to = Duration(milliseconds: newValue.floor());
                  //   _visibleValue = to;
                  // });
                },
              ),
            ),
            trailing: Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '₦0.00',
                      style: TextStyle(
                          color: navyBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: "Inter"),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '10%',
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Inter"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _buildPaymentPercentageDialog(BuildContext context) {
    showDialogBoxWithTitle(
        context: context,
        actionTextColor: white,
        actionBgColor: navyBlue,
        actionText: 'Save',
        firstActionPrimary: false,
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
                      Text('Name : @${widget.members?.userName}',
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
                            return null;
                          }
                          return AppLocalization.of(context)!
                              .pleaseEnterCartName;
                        },
                        onChanged: (val) {
                          setState(() {
                            // _controller.text = val;
                            percentageValue = double.parse(val);
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
                          value: percentageValue,
                          onChanged: (newValue) {
                            setState(() {
                              _controller.text = newValue.floor().toString();
                              percentageValue = newValue;
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
          Navigator.pop(context, true);
        });
  }
}
