import 'dart:async';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../locator.dart';
import '../../../../../services/app_config_bloc.dart';
import '../../../../../services/auth.dart';
import '../../../../../widget/curved_btn.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../../../../widget/dialog.dart';
import '../../../../../widget/loading_indicator.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../user_auth.dart';

class ChooseSubscription extends StatefulWidget {
  const ChooseSubscription({super.key});

  @override
  State<ChooseSubscription> createState() => _ChooseSubscriptionState();
}

class _ChooseSubscriptionState extends State<ChooseSubscription> {
  int _id =
      0; // To help determine what subscriptions card to show and what card to highlight when clicked.
  Timer? typingTimer;
  late UserBloc userBloc;
  String? selectedAccountType;
  final _auth = AuthService();
  late AppLocalization appLocalization;
  bool?
      businessNameVerified; // Variable to show the submit button and check mark in textfield when business name is verified.
  bool verifyingBusinessName =
      false; // Variable to show the loading bar when we are verifying business name.
  late SubscriptionsModel subscriptionsModelCopy;
  Future<List<SubscriptionsModel>>? getSubscriptionsFuture;
  final TextEditingController _businessNameCtrl = TextEditingController();
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    super.initState();
  }

  void _onChanged(String value) {
    const duration = Duration(milliseconds: 1000);
    if (typingTimer != null) {
      setState(() => typingTimer!.cancel()); // clear timer
    }
    typingTimer = Timer(
      duration,
      () => _checkBusinessName(value),
    );
  }

  void _checkBusinessName(String value) {
    if (value.isNotEmpty && value.length > 1) {
      if (checkSlydoName(value) != null &&
          checkSlydoName(value)!.contains(slydoNameMsg)) {
        setState(() => businessNameVerified = false);
        showToast(message: 'Name cannot contain slydo');
      } else {
        _verifyBusinessName();
      }
    } else {
      setState(() => businessNameVerified = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;

    return Scaffold(
      appBar: customAppBar(context: context, title: 'Subscription')
          as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset('assets/images/subscription_img.svg'),
            const SizedBox(height: 20),
            const Text(
              'Choose your plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff030F36),
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: getAccountTypeField(),
            ),
            Visibility(
              visible: _id != 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CustomizedTextFormField(
                      onChanged: _onChanged,
                      controller: _businessNameCtrl,
                      hintText: 'Full business name',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _getBusinessNameSuffixIcon(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (getSubscriptionsFuture != null)
              FutureBuilder<List<SubscriptionsModel>>(
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                appConfigurationModel?.freeSubscription == true
                                    ? 1
                                    : snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final SubscriptionsModel subscriptionsModel =
                                  snapshot.data![index];
                              return SubscriptionTile(
                                id: _id,
                                isVisible: true,
                                freeSubscription:
                                    appConfigurationModel?.freeSubscription ??
                                        false,
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
                                      _businessNameCtrl.clear();
                                      businessNameVerified = null;
                                    });
                                  }
                                },
                              );
                            });
                      } else {
                        return const Center(
                            child: Text('No subscriptions data at the moment'));
                      }
                    } else {
                      return Center(child: CircularLoadingIndicator());
                    }
                  })
            else
              const SizedBox.shrink(),
            const SizedBox(height: 10),
            Visibility(
              visible: businessNameVerified ?? false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CurvedButton(
                      text: 'Submit',
                      onPressed: () {
                        if (_businessNameCtrl.text.isNotEmpty) {
                          _showConfirmationSubscriptionDialog(
                              subscriptionsModelCopy);
                        } else {
                          showToast(message: 'Enter your business name');
                        }
                      },
                    ),
                  ),
                ],
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
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
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
      businessNameVerified = false;
      setState(() {});
    }
  }

  void _selectSubscriptionsPlan(SubscriptionsModel subscriptionsModel) {
    setState(() {
      _id = subscriptionsModel.id;
      subscriptionsModelCopy = subscriptionsModel;
    });
  }

  void _showConfirmationSubscriptionDialog(
      SubscriptionsModel subscriptionsModel) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: naturalGreen,
      title: _getDialogTitle(subscriptionsModel),
      actionTwoText: 'Yes',
      actionOneText: 'No',
      description: 'Are you sure you want to choose this plan?',
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
        _upgradeAccount(subscriptionsModel);
      },
    );
  }

  String _getDialogTitle(SubscriptionsModel subscriptionsModel) {
    switch (subscriptionsModel.subscriptionType) {
      case 'Annually':
        return 'Annual ${subscriptionsModel.accountType} Plan';
      case 'Monthly':
        return 'Monthly ${subscriptionsModel.accountType} Plan';
      case 'Weekly':
        return 'Weekly ${subscriptionsModel.accountType} Plan';
      default:
        return "";
    }
  }

  Widget _getBusinessNameSuffixIcon() {
    if (verifyingBusinessName) {
      return SizedBox(width: 20, height: 20, child: CircularLoadingIndicator());
    } else {
      if (businessNameVerified != null) {
        if (businessNameVerified!) {
          return CircleAvatar(
            radius: 14,
            backgroundColor: navyBlue,
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.check, size: 20, color: Colors.white),
            ),
          );
        } else {
          return const Icon(
            Icons.cancel,
            color: Colors.red,
          );
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  void _verifyBusinessName() async {
    setState(() => verifyingBusinessName = true);

    SubscriptionsAuth()
        .verifyBusinessName(businessName: _businessNameCtrl.text.trim())
        .then((businessNameAvailable) {
      if (businessNameAvailable) {
        setState(() {
          businessNameVerified = true;
          verifyingBusinessName = false;
        });
      } else {
        setState(() {
          businessNameVerified = false;
          verifyingBusinessName = false;
        });
        showToast(message: appLocalization.businessNameNotAvailable);
      }
    }).catchError((e) {
      Navigator.pop(context);
      showToast(message: e.toString());
    });
  }

  void _upgradeAccount(SubscriptionsModel subscriptionsModel) {
    SubscriptionsAuth()
        .upgradeUserAccount(
            accountType: selectedAccountType!,
            businessName: _businessNameCtrl.text,
            subscriptionsId: subscriptionsModel.id)
        .then((value) => _refreshUser())
        .catchError((e) {
      Navigator.pop(context);
      showToast(message: e.toString());
    });
  }

  void _refreshUser() async {
    await _auth
        .authenticate(userBloc.user.phoneNumber, userBloc.user.password)
        .then((newUser) async {
      userBloc.user = newUser;
      if (mounted) setState(() {});

      await UserAuth()
          .fetchCustomerProfile(userBloc.user.userName)
          .then((user) {
        showToast(message: appLocalization.profileUpgradeSuccessful);

        Navigator.pop(context);
        Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": user.userName, "index": 0});
      });
    });
  }
}

class SubscriptionTile extends StatelessWidget {
  final int id;
  final bool isVisible;
  final int subscriptionId;
  final String amount;
  final Function() onTap;
  final String currency;
  final bool freeSubscription;
  final String subscriptionType;
  const SubscriptionTile({
    super.key,
    this.freeSubscription = false,
    required this.isVisible,
    required this.currency,
    required this.id,
    required this.subscriptionId,
    required this.onTap,
    required this.amount,
    required this.subscriptionType,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      style: const TextStyle(
                        color: Color(0Xff75818F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (id == subscriptionId)
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: navyBlue,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child:
                              Icon(Icons.check, size: 20, color: Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.radio_button_unchecked_outlined),
                  ],
                ),
                if (freeSubscription)
                  Text(
                    'Free (one year) Plan',
                    style: TextStyle(
                        fontSize: 20,
                        color: naturalGreen.withOpacity(0.8),
                        fontWeight: FontWeight.w700),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 12),
                if (freeSubscription)
                  const SizedBox.shrink()
                else
                  Row(
                    children: [
                      Text(
                        worldCurrencies[currency]!,
                        style: const TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '${moneyDisplayNormalizer(int.parse(amount))} ($subscriptionType) plan',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xff030F36),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                if (freeSubscription)
                  const SizedBox.shrink()
                else
                  const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: 'then ',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      WidgetSpan(
                          child: Text(
                            worldCurrencies[currency]!,
                            style: const TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          baseline: TextBaseline.alphabetic,
                          alignment: PlaceholderAlignment.baseline),
                      TextSpan(
                          text:
                              '${moneyDisplayNormalizer(int.parse(amount))}  ${getPlan(subscriptionType)}. Cancel anytime'),
                    ],
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
