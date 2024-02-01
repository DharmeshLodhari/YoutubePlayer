import 'dart:io';

import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/tiles/members_payment_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../widget/vertical_list_item.dart';

class SendCartPayment extends StatefulWidget {
  const SendCartPayment({Key? key}) : super(key: key);

  @override
  State<SendCartPayment> createState() => _SendCartPaymentState();
}

class _SendCartPaymentState extends State<SendCartPayment> {
  bool _switchValue = false;
  late SharedCartBloc sharedCartBloc;
  SlidableController? _slideController;
  bool isLoading = false;
  bool isChecked = false;

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
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: selectedListItemBackgroundBlue),
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Divider(
                                  thickness: 1,
                                  color: dividerColor,
                                ),
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
                    const SizedBox(
                      height: 10,
                    ),
                    _buildSplitBill(),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_switchValue == true) _buildMemberList(),
                  ],
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
      labelText: "Amount",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            // productPrice = double.parse(val.replaceAll(',', '')).toString();
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
    ;
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

  Widget _buildSplitBill() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Split Bill',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Transform.scale(
          scale: .8,
          child: CupertinoSwitch(
              value: _switchValue,
              onChanged: (value) {
                _switchValue = value;
                setState(() {});
              },
              activeColor: const Color(0xff3F61DB) // Color when switch is ON
              ),
        ),
      ],
    );
  }

  Widget _buildMemberList() {
    return Column(
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: sharedCartBloc.getSharedCartModel().membersDetails?.length,
          itemBuilder: (BuildContext context, int index) {
            if (index ==
                sharedCartBloc.getSharedCartModel().membersDetails?.length) {
              return buildLoadingIndicator(isLoading: isLoading);
            } else {
              return _getSlidableWithLists(
                context,
                MembersPaymentTile(
                    members: sharedCartBloc
                        .getSharedCartModel()
                        .membersDetails?[index],
                    index: index),
                sharedCartBloc.getSharedCartModel().membersDetails?[index],
              );
            }
          },
        ),
        const SizedBox(height: 10),
        _buildSplitEvenly(),
        const SizedBox(height: 10),
        _buildTotalAmount(),
      ],
    );
  }

  Widget _buildSplitEvenly() {
    return CustomizedCheckBoxField(
      onTap: () {
        isChecked = !isChecked;
        setState(() {});
      },
      isChecked: isChecked,
      title: "Split bill evenly",
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total : 100%',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Text(
          '₦0.00',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget cartMemberTile, UserFollowers? member) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(cartMemberTile),
      secondaryActions: listActionSlideActions(member: member),
    );
  }

  List<Widget> listActionSlideActions({UserFollowers? member}) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.true_icon,
          onTap: () {},
          title: AppLocalization.of(context)!.accept,
          slideController: _slideController),
    ];
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
