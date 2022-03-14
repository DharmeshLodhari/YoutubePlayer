import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_model.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../data/state_notifier.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../services/auth.dart';
import '../../../../../widget/LoadingIndicator.dart';
import '../../../../../widget/curved_btn.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../../../../widget/dialog.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../user_auth.dart';

class ChooseSubscription extends StatefulWidget {
  const ChooseSubscription({Key? key}) : super(key: key);

  @override
  State<ChooseSubscription> createState() => _ChooseSubscriptionState();
}

class _ChooseSubscriptionState extends State<ChooseSubscription> {
  int _id =
      0; // To help determine what subscriptions card to show and what card to highlight when clicked.
  late UserBloc userBloc;
  String? selectedAccountType;
  final _auth = AuthService();
  late SubscriptionsModel subscriptionsModelCopy;
  Future<List<SubscriptionsModel>>? getSubscriptionsFuture;
  TextEditingController _businessNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      appBar: customAppBar(context: context, title: 'Subscription')
          as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset('assets/images/subscription_img.svg'),
            SizedBox(height: 20),
            Text(
              'Choose your plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff030F36),
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: getAccountTypeField(),
            ),
            getSubscriptionsFuture != null
                ? FutureBuilder<List<SubscriptionsModel>>(
                    future: getSubscriptionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.hasData) {
                          return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                SubscriptionsModel subscriptionsModel =
                                    snapshot.data![index];
                                return SubscriptionTile(
                                  id: _id,
                                  isVisible: _id == 0
                                      ? true
                                      : _id == subscriptionsModel.id,
                                  currency: subscriptionsModel.currency,
                                  subscriptionId: subscriptionsModel.id,
                                  amount: subscriptionsModel.price.toString(),
                                  subscriptionType:
                                      subscriptionsModel.subscriptionType,
                                  onTap: () {
                                    if (_id == 0) {
                                      _selectSubscriptionsPlan(
                                          subscriptionsModel);
                                    } else {
                                      setState(() {
                                        _id = 0;
                                      });
                                    }
                                  },
                                );
                              });
                        } else {
                          return Center(
                              child:
                                  Text('No subscriptions data at the moment'));
                        }
                      } else {
                        return Center(child: CircularLoadingIndicator());
                      }
                    })
                : SizedBox.shrink(),
            Visibility(
              visible: _id != 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CustomizedTextFormField(
                      controller: _businessNameCtrl,
                      hintText: 'Full business name',
                      validator: (value) {
                        return value.isEmpty
                            ? 'Enter your business name'
                            : null;
                      },
                    ),
                    SizedBox(height: 12),
                    CurvedButton(
                      text: 'Submit',
                      onPressed: () {
                        if (_businessNameCtrl.text.isNotEmpty) {
                          _showChoosePlanDialog(subscriptionsModelCopy);
                        } else {
                          showToast(message: 'Enter your business name');
                        }
                      },
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAccountTypeField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.chooseAccountType,
      child: ListTile(
        dense: true,
        title: Text(
          selectedAccountType != null ? selectedAccountType! : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectAccountTypeCategory();
        },
      ),
    );
  }

  void selectAccountTypeCategory() async {
    final pressedAccountType = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['Business', 'Developer']
                            .map<Widget>((accountType) {
                          return ListTile(
                            title: Text(
                              accountType,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, accountType);
                            },
                          );
                        }).toList()),
                  ),
                ),
              ),
            ));
    if (pressedAccountType != null) {
      selectedAccountType = pressedAccountType;
      getSubscriptionsFuture = SubscriptionsAuth()
          .getSubscriptionList(accountType: selectedAccountType!);
      _id = 0;
      setState(() {});
    }
  }

  _selectSubscriptionsPlan(SubscriptionsModel subscriptionsModel) {
    setState(() {
      _id = subscriptionsModel.id;
      subscriptionsModelCopy = subscriptionsModel;
    });
  }

  void _showChoosePlanDialog(SubscriptionsModel subscriptionsModel) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: navyBlue,
      title: _getDialogTitle(subscriptionsModel),
      actionTwoText: 'Yes',
      actionOneText: 'No',
      description: 'Are you sure you want to pick this plan?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/accept_dialog_icon.png'),
      ),
      rightButtonOnPressed: () {
        showDialog(
            context: context,
            builder: (dialogLoadingContext) => LoadingIndicator());
        _choosePlan(subscriptionsModel);
      },
    );
  }

  _getDialogTitle(SubscriptionsModel subscriptionsModel) {
    switch (subscriptionsModel.subscriptionType) {
      case 'Annually':
        return 'Annual plan';
      case 'Monthly':
        return 'Monthly plan';
      case 'Weekly':
        return 'Weekly plan';
    }
  }

  _choosePlan(SubscriptionsModel subscriptionsModel) async {
    SubscriptionsAuth()
        .upgradeUserAccount(
      accountType: selectedAccountType!,
      subscriptionsId: subscriptionsModel.id,
      businessName: _businessNameCtrl.text,
    )
        .then((value) async {
      await _auth
          .authenticate(userBloc.user.phoneNumber, userBloc.user.password)
          .then((newUser) async {
        userBloc.user = newUser;
        if (mounted) setState(() {});

        await UserAuth()
            .fetchCustomerProfile(userBloc.user.userName)
            .then((user) {
          showToast(message: "Your profile upgrade was successful.");

          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": user.userName, "index": 0});
        });
      });
    }).catchError((e) {
      Navigator.pop(context);
      showToast(message: '${e.toString()}');
    });
  }
}

class SubscriptionTile extends StatelessWidget {
  final int id;
  final bool isVisible;
  final int subscriptionId;
  final String amount;
  final String? tagName;
  final Function() onTap;
  final String currency;
  final String subscriptionType;
  const SubscriptionTile(
      {Key? key,
      required this.isVisible,
      required this.currency,
      required this.id,
      required this.subscriptionId,
      this.tagName,
      required this.onTap,
      required this.amount,
      required this.subscriptionType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
              side: id == subscriptionId
                  ? BorderSide(color: navyBlue)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subscriptionType,
                      style: TextStyle(
                        color: Color(0Xff75818F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    id == subscriptionId
                        ? CircleAvatar(
                            radius: 14,
                            backgroundColor: navyBlue,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.check,
                                  size: 20, color: Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.radio_button_unchecked_outlined,
                          ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    getCurrencySymbol(currency),
                    Text(
                      '$amount ($subscriptionType) plan',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff030F36),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                tagName != null
                    ? Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: navyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          tagName!,
                          style: TextStyle(
                              color: navyBlue, fontWeight: FontWeight.w400),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 10),
                Text(
                  'then ${getPlan(subscriptionType)}. Cancel anytime',
                  style: TextStyle(
                    color: Color(0xff030F36),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String getPlan(String subscriptionType) {
  switch (subscriptionType) {
    case 'Annually':
      return 'per year';
    case 'Monthly':
      return 'per month';
    case 'Weekly':
      return 'per week';
    default:
      return '';
  }
}

Widget getCurrencySymbol(String currency) {
  switch (currency) {
    case 'NGN':
      return Icon(SlydoAppIcon.naira, size: 16);
    default:
      return Container();
  }
}
