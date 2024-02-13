import 'dart:io';

import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/tiles/members_payment_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/vertical_list_item.dart';

class SharedCartPayment extends StatefulWidget {
  const SharedCartPayment({Key? key}) : super(key: key);

  @override
  State<SharedCartPayment> createState() => _SharedCartPaymentState();
}

class _SharedCartPaymentState extends State<SharedCartPayment> {
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;
  SlidableController? _slideController;
  TextEditingController amountController = TextEditingController();
  bool isLoading = false;
  String? selectedCategory;
  List<String?> paymentCategories = [];

  @override
  void initState() {
    selectedCategory = "Shopping";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      amountController.text = moneyDisplayNormalizer(int.parse(sharedCartBloc
          .getSharedCartModel()
          .getSharedCartTotalPrice()
          .toString()));
    });
    fetchCategory();
    super.initState();
  }

  void fetchCategory() async {
    PaymentAndBankingAuth().getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          List categoriesList = result["results"]["data"];
          categoriesList.forEach((data) {
            paymentCategories.add(data["name"]);
          });
        });
      }
    });
  }

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
    userBloc = Provider.of<UserBloc>(context);
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
                              // _buildUserProfile(),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Divider(
                              //     thickness: 1,
                              //     color: dividerColor,
                              //   ),
                              // ),
                              // _buildRecipient(),
                              // const SizedBox(
                              //   height: 16,
                              // ),
                              _buildAmount(),
                              const SizedBox(
                                height: 16,
                              ),
                              getCategoryDropDown(),
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
                    if (sharedCartBloc.getSharedCartModel().splitBill == true)
                      _buildMemberList(),
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
      controller: amountController,
      labelText: "Amount",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      isReadOnly: true,
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

  Widget getCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.category,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedCategory != null ? selectedCategory! : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectCategory();
            },
          ),
        ),
      ],
    );
  }

  void selectCategory() async {
    final pressedCategory = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: paymentCategories.map<Widget>((category) {
                          if (selectedCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category!,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category!,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedCategory = pressedCategory;
      debugPrint("selected category $selectedCategory");
      setState(() {});
    }
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
              value: sharedCartBloc.getSharedCartModel().splitBill ?? false,
              onChanged: (value) {
                sharedCartBloc.getSharedCartModel().splitBill = value;
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
              return sharedCartBloc
                          .getSharedCartModel()
                          .membersDetails?[index]
                          .userName !=
                      userBloc.user.userName
                  ? _getSlidableWithLists(
                      context,
                      MembersPaymentTile(
                          members: sharedCartBloc
                              .getSharedCartModel()
                              .membersDetails?[index],
                          index: index),
                      sharedCartBloc
                          .getSharedCartModel()
                          .membersDetails?[index],
                    )
                  : MembersPaymentTile(
                      members: sharedCartBloc
                          .getSharedCartModel()
                          .membersDetails?[index],
                      index: index);
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
        sharedCartBloc.getSharedCartModel().splitBillEvenly =
            !(sharedCartBloc.getSharedCartModel().splitBillEvenly ?? false);
        setState(() {});
      },
      isChecked: sharedCartBloc.getSharedCartModel().splitBillEvenly,
      title: "Split bill evenly",
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total : ${sharedCartBloc.getSharedCartModel().getTotalOfPercentage()}%',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Text(
          '₦${moneyDisplayNormalizer(sharedCartBloc.getSharedCartModel().getSplitBillTotalPayment())}',
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
          if (sharedCartBloc.getSharedCartModel().splitBill == true) {
            if (sharedCartBloc.getSharedCartModel().getTotalOfPercentage() ==
                100) {
              requestForPayment();
            } else {
              showToast(message: "Total payment is not 100%");
            }
          } else {
            BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  Navigator.of(context).pushNamed(Routes.SUCCESSFUL_ORDER);
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                });
          }
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: sharedCartBloc.getSharedCartModel().splitBill == true
            ? 'Request Payment'
            : 'Send Payment',
      ),
    );
  }

  Future<void> requestForPayment() async {
    List<Map<String, dynamic>> dataList = [];
    for (UserFollowers member
        in sharedCartBloc.getSharedCartModel().membersDetails ?? []) {
      Map<String, dynamic> data = {
        "username": member.userName,
        "currency": "NGN",
        "amount": sharedCartBloc.getSharedCartModel().splitBillEvenly == true
            ? sharedCartBloc.getSharedCartModel().getSplitBillEvenlyPayment()
            : member.dividedPayment,
        "percentage":
            sharedCartBloc.getSharedCartModel().splitBillEvenly == true
                ? sharedCartBloc
                    .getSharedCartModel()
                    .getSplitBillEvenly()
                    .toStringAsFixed(2)
                : member.paymentPercentageValue.toString(),
      };
      dataList.add(data);
    }
    Map<String, dynamic> metaData = {
      "meta_data": {
        "user_data": dataList,
      }
    };
    await SharedCartAuthService()
        .requestPayment(sharedCartBloc.getSharedCartModel().id, metaData)
        .then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.requestPaymentSuccessfully);
      } else {
        showToast(message: AppLocalization.of(context)!.requestFailed);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }
}
