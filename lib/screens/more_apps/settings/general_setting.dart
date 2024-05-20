import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_message_settings.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/user_kyc.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/device.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_setting_screen.dart';
import 'package:Slydo/services/logout_helper.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item_with_check.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GeneralSettingScreen extends StatefulWidget {
  @override
  _GeneralSettingScreenState createState() => _GeneralSettingScreenState();
}

class _GeneralSettingScreenState extends State<GeneralSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldGeneralSettingKey =
      new GlobalKey<ScaffoldState>();

  bool isLoading = false;
  late BasketBloc basketBloc;
  late UserBloc userBloc;
  late DashboardBloc dashboardBloc;
  late BankAccountBloc bankAccountBloc;

  Language? language;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @protected
  void initState() {
    _initPackageInfo();
    getLanguage();
    super.initState();
  }

  void getLanguage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      String? languageCode = sharedPreferences.getString("language");
      setState(() {
        language = getLanguageByLanguageCode(languageCode);
        debugPrint("Set language: => ${language?.name}");
      });
    } else {
      setState(() {
        language = getLanguageByLanguageCode("en");
        debugPrint("Set default language: => ${language?.name}");
      });
    }
  }

  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    dashboardBloc = Provider.of<DashboardBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    return Scaffold(
      key: _scaffoldGeneralSettingKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getReferralCodeTile(),
                getIncomingSoundTile(),
                getOutGoingSoundTile(),
                getAccountBalanceVisibilityTile(),
                getCurrencyTile(),
                getLanguageTile(),
                getSettingsTile(
                    title: "Yarn Settings",
                    onTap: () {
                      NavigationUtil.push(
                        context,
                        screen: YarnSettingsScreen(),
                      );
                    }),
                getSettingsTile(
                  title: "Upgrade Account Tier/KYC",
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            Center(child: LoadingIndicator()));
                    PaymentAndBankingAuth()
                        .checkIfKycIsVerified(userName: userBloc.user.userName!)
                        .then(
                      (kycModel) {
                        Navigator.pop(context);

                        if (kycModel != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserKyc(kycModel: kycModel),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, '/upgrade-account');
                        }
                      },
                    ).catchError(
                      (e) {
                        Navigator.pop(context);
                        showToast(message: e.toString());
                      },
                    );
                  },
                ),
                getSettingsTile(
                    title: "Change Password",
                    onTap: () async {
                      Navigator.of(context).pushNamed(Routes.CHANGE_PASSWORD);
                    }),
                getSettingsTile(
                    title: "Deactivate Account",
                    onTap: () async {
                      deactivateAccountDialogue();
                    }),
                getSettingsTile(
                    title: "Terms of Service",
                    onTap: () async {
                      try {
                        if (!await launch(AppConfig.termsAndCondition!))
                          throw 'Could not launch ${AppConfig.termsAndCondition!}';
                      } catch (error) {
                        debugPrint("Error:- $error");
                      }
                    }),
                getSettingsTile(
                    title: "Privacy Policy",
                    onTap: () async {
                      try {
                        if (!await launch(AppConfig.privacyPolicy!))
                          throw 'Could not launch ${AppConfig.privacyPolicy!}';
                      } catch (error) {
                        debugPrint("Error:- $error");
                      }
                    }),
                Center(child: _infoTile()),
                const SizedBox(
                  height: 120,
                ),
                // getLogoutTile(),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void deactivateAccountDialogue() async {
    bool? result = await showDialogBox(
      context: context,
      actionOneTextColor: white,
      actionOneBgColor: mateRed,
      actionTwoTextColor: blackFont,
      actionTwoBgColor: greyBorderColor,
      title: 'Deactivate Account',
      actionTwoText: "Cancel",
      actionOneText: "Yes",
      description: 'are sure they want to deactivate your account?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: const Icon(SlydoAppIcon.delete),
      ),
    );
    if (result != null && result) {
      bool? result1 = await showDialogBox(
        context: myGlobals.navigationKey.currentContext!,
        actionOneTextColor: white,
        actionOneBgColor: mateRed,
        actionTwoTextColor: blackFont,
        actionTwoBgColor: greyBorderColor,
        title: 'Deactivate Account',
        actionTwoText: "Cancel",
        actionOneText: "Deactivate",
        description:
            'all your transaction will still be Available But your account will be deactivated?',
        roundedBackgroundIcon: RoundedBackgroundIcon(
          enableMargin: false,
          width: 90,
          height: 90,
          image: const Icon(SlydoAppIcon.delete),
        ),
      );

      if (result1 != null && result1) {
        debugPrint("USER HAS REQUESTED ACCOUNT DEACTIVATION $result1");
        await deactivateAccount();
      }
    }
  }

  Future<void> deactivateAccount() async {
    bool result = await UserAuth().deactivateUserAccount();
    if (result) {
      showDialog(
          context: (context),
          builder: (context) => Center(child: CircularLoadingIndicator()),
          barrierDismissible: false);
      await LogoutHelper().logoutUser();
    }
  }

  Widget _infoTile() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalization.of(context)!.appVersion +
                ': ' +
                _packageInfo.version +
                " (${_packageInfo.buildNumber})",
            style: TextStyle(
              color: darkGrey,
              fontSize: 12,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 20,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      // leading: IconButton(
      //   icon: Icon(
      //     Icons.keyboard_arrow_left,
      //     color: navyBlue,
      //     size: 24,
      //   ),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      centerTitle: false,
      title: Text(
        "Settings",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget getSettingsTile({String title = "", Function()? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
        ),
      ),
    );
  }

  Widget getIncomingSoundTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Incoming Message Sound",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: userBloc.chatMessageSettings.playIncomingMessageSound!,
              onChanged: (value) {
                ChatMessageSettings chatMessageSettings = ChatMessageSettings();
                chatMessageSettings.playOutgoingMessageSound =
                    userBloc.chatMessageSettings.playOutgoingMessageSound;
                chatMessageSettings.playIncomingMessageSound = value;
                userBloc.chatMessageSettings = chatMessageSettings;
                DatabaseHelper()
                    .updateGeneralSettings(chatMessageSettings.toDBJson());
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getCurrencyTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Currency",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Text(
            worldCurrencies[userBloc.user.currency!]!,
            maxLines: 1,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getReferralCodeTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "My Referral Code",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Text(
            userBloc.user.userName ?? "",
            maxLines: 1,
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getLanguageTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Language",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Text(
            language?.name ?? "",
            maxLines: 1,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onTap: () {
            changeLanguageBottomSheet();
          },
        ),
      ),
    );
  }

  void changeLanguageBottomSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: languages.map((data) {
                    return BottomSheetItemWithCheck(
                        icon: SlydoAppIcon.translation,
                        title: data.name,
                        isChecked:
                            (language?.languageCode ?? "") == data.languageCode,
                        onTap: () {
                          language = data;
                          setLanguage(data);
                          Navigator.pop(context);
                          saveIntoSharedPreference(data);
                        });

                    // return bottomSheetItemWithCheck(
                    //     icon: SlydoAppIcon.translation,
                    //     title: data.name,
                    //     isChecked: language!.languageCode == data.languageCode,
                    //     onTap: () {
                    //       language = data;
                    //       setLanguage(data);
                    //       Navigator.pop(context);
                    //       saveIntoSharedPreference(data);
                    //     });
                  }).toList(),
                ),
              ));
        });
  }

  Widget getOutGoingSoundTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Outgoing Message Sound",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: userBloc.chatMessageSettings.playOutgoingMessageSound!,
              onChanged: (value) {
                ChatMessageSettings chatMessageSettings = ChatMessageSettings();
                chatMessageSettings.playIncomingMessageSound =
                    userBloc.chatMessageSettings.playIncomingMessageSound;
                chatMessageSettings.playOutgoingMessageSound = value;
                userBloc.chatMessageSettings = chatMessageSettings;
                DatabaseHelper()
                    .updateGeneralSettings(chatMessageSettings.toDBJson());
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getAccountBalanceVisibilityTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Account Balance Visibility",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: userBloc.chatMessageSettings.accountBalanceVisibility!,
              onChanged: (value) {
                BottomSheetPassCode(
                  context: context,
                  isValidCallback: () {
                    ChatMessageSettings chatMessageSettings =
                        ChatMessageSettings();
                    chatMessageSettings.accountBalanceVisibility =
                        userBloc.chatMessageSettings.accountBalanceVisibility;
                    chatMessageSettings.accountBalanceVisibility = value;
                    userBloc.chatMessageSettings = chatMessageSettings;
                    DatabaseHelper()
                        .updateGeneralSettings(chatMessageSettings.toDBJson());
                  },
                  cancelCallBack: () {
                    Navigator.pop(context);
                  },
                );
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getLogoutTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Logout",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Inter",
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 50,
            child: Icon(
              SlydoAppIcon.leave,
              size: 23,
              color: blackFont,
            ),
          ),
          onTap: () async {
            showDialog(
                context: (context),
                builder: (context) => Center(child: CircularLoadingIndicator()),
                barrierDismissible: false);
            await LogoutHelper().logoutUser();
          },
        ),
      ),
    );
  }

  void setLanguage(Language? language) {
    setState(() {
      AppLocalization.load(Locale(language!.languageCode, ""));
      showToast(
          message: AppLocalization.of(context)!.languageSwitchedTo +
              " ${language.name}");
    });
  }

  //to save language in shared preference when user change the language
  void saveIntoSharedPreference(Language? language) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      bool result =
          await sharedPreferences.setString("language", language!.languageCode);
      debugPrint(
          "${language.name} Language is updated in sharedPreference => $result");
    } else {
      bool result =
          await sharedPreferences.setString("language", language!.languageCode);
      debugPrint(
          "${language.name} Language is set in sharedPreference => $result");
    }
  }
}
