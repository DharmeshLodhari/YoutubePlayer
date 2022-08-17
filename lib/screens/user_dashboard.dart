import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/device.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../locator.dart';
import '../routes/route_constants.dart';
import 'more_apps/ask/ask_start_screen.dart';
import 'more_apps/super_blog/super_blog.dart';
import 'more_apps/user_profile/user_auth.dart';

// ignore: must_be_immutable
class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldSettingKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  late UserBloc userBloc;
  late BankAccountBloc bankAccountBloc;

  bool isLoading = false;
  bool storeLocked = true;
  Language? language;
  String accountBalance = "";

  late DashboardBloc dashboardBloc;
  bool isBalanceHidden = true;
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    getAccountBalance();
    getLanguage();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    dashboardBloc = Provider.of<DashboardBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    if (userBloc.user.type != "User") {
      storeLocked = false;
    }

    return Scaffold(
      key: _scaffoldSettingKey,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              backgroundScreen(),
              foregroundScreen(),
              isLoading
                  ? Container(
                      color: Colors.black45,
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: CircularLoadingIndicator(),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("======> didChange dependency called !!");
    hideBalance();
  }

  void hideBalance() {
    if (isBalanceHidden == false) {
      isBalanceHidden = true;
      if (mounted) setState(() {});
    }
  }

  Widget backgroundScreen() {
    if (userBloc.user.userAbout == null ||
        userBloc.user.userAbout!.wallpaper == "") {
      return Container(
        child: Image.asset(
          "assets/images/home_screen_background.png",
          frameBuilder: imageFrameBuilder,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: new BorderRadius.vertical(
          bottom: new Radius.elliptical(100.0.w, 50.0)),
      child: Container(
        color: navyBlue,
        width: 100.0.w,
        height: 33.0.h,
        child: CachedNetworkImage(
          imageUrl: userBloc.user.userAbout!.wallpaper,
          fit: BoxFit.cover,
          color: blackFont.withOpacity(0.4),
          colorBlendMode: BlendMode.darken,
          filterQuality: FilterQuality.high,
          errorWidget: wallpaperErrorWidget,
        ),
      ),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Platform.isIOS ? Container() : flexibleSpace(),
          appBar(),
          flexibleSpace(flex: 5),
          accountBalanceCard(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: ListView(
              children: [
                firstRowOfUserDashboardItem(),
                SizedBox(height: 12),
                secondRowOfUserDashboardItem(),
                SizedBox(height: 12),
                thirdRowOfUserDashboardItem(),
                SizedBox(height: 12),
                Text(
                  'More apps',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12),
                firstRowOfMoreApps(),
                SizedBox(height: 12),
                appVersionDataUI(),
                SizedBox(height: 32),
              ],
            ),
          ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.width * 0.8,
          //   child: ListView(
          //     children: [
          //
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: GestureDetector(
        onTap: () async {
          await UserAuth()
              .fetchCustomerProfile(userBloc.user.userName)
              .then((user) {
            if (mounted) {
              Navigator.pushNamed(
                  myGlobals.navigationKey.currentContext!, Routes.USER_PROFILE,
                  arguments: {"searchedUserName": user.userName});
            }
          });
        },
        child: Text(
          "Account",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      actions: <Widget>[
        settingBtn(),
      ],
    );
  }

  Widget settingBtn() {
    return SizedBox(
      height: 34,
      width: 34,
      child: InkWell(
        child: Card(
          elevation: 0,
          color: lightGrey.withOpacity(0.1),
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            SlydoAppIcon.settings,
            size: 16,
          ),
        ),
        onTap: () {
          hideBalance();
          Navigator.of(context).pushNamed(Routes.GENERAL_SETTING);
        },
      ),
    );
  }

  Widget accountBalanceCard() {
    return CustomBoxShadow(
      child: Card(
        shadowColor: boxShadowTwo,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height > 600 ? 18 : 12,
                bottom: MediaQuery.of(context).size.height > 600 ? 24 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Balance",
                  style: TextStyle(fontSize: 14, color: darkGrey),
                ),
                SizedBox(
                  height: 16,
                ),
                accountBalanceUI()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget accountBalanceUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isBalanceHidden
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      worldCurrencies[userBloc.user.currency!]!,
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ),
            Text(
              isBalanceHidden
                  ? "*********"
                  : moneyDisplayNormalizer(int.parse(accountBalance)),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ],
        ),
        getAccountBalanceBtn()
      ],
    );
  }

  Widget getAccountBalanceBtn() {
    return isBalanceHidden
        ? IconButton(
            icon: Icon(
              SlydoAppIcon.eye,
              color: eyeGrey,
              size: 18,
            ),
            onPressed: () {
              BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  getAccountBalance();
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
            icon: Icon(
              SlydoAppIcon.eye_close,
              color: eyeGrey,
              size: 24,
            ),
            onPressed: () {
              isBalanceHidden = true;
              setState(() {});
            },
          );
  }

  Widget firstRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.user,
          title: AppLocalization.of(context)!.profile,
          onTap: () {
            hideBalance();
            profileAndroidSheet();
          },
          iconColor: HexColor("#9B51E0"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.cart,
          title: "Orders",
          onTap: () {
            hideBalance();
            Navigator.pushNamed(context, Routes.ORDERS_LIST);
          },
          iconColor: HexColor("#FFAB00"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.store,
          title: "Store Listing",
          isLocked: storeLocked,
          onTap: () {
            hideBalance();
            if (!storeLocked) {
              storeItemAndroidSheet();
            } else {
              showToast(
                  message:
                      'You need to upgrade to a business account to use this feature.');
            }
          },
          iconColor: HexColor("#46CE7C"),
        )),
      ],
    );
  }

  Widget secondRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
          child: UserDashboardItemTile(
            icon: SlydoAppIcon.transactions,
            title: AppLocalization.of(context)!.transaction,
            onTap: () {
              hideBalance();
              transactionAndroidSheet();
            },
            iconColor: HexColor("#3F61DB"),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UserDashboardItemTile(
            iconWidget: Center(
              child: Text(
                worldCurrencies[userBloc.user.currency!]!,
                style: TextStyle(
                  color: HexColor("#46CE7C"),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: "Roboto",
                ),
              ),
            ),
            title: "Cashout",
            onTap: () {
              hideBalance();
              bankAndroidSheet();
            },
            iconColor: HexColor("#46CE7C"),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UserDashboardItemTile(
            icon: Icons.account_balance_wallet_rounded,
            title: AppLocalization.of(context)!.wallet,
            onTap: () {
              Navigator.of(context).pushNamed(Routes.WALLET_OPTIONS_SELECTION);
            },
            iconColor: HexColor("#F35B46"),
          ),
        ),
        // Expanded(
        //     child: UserDashboardItemTile(
        //   icon: Icons.account_balance_wallet_rounded,
        //   title: "Fund Wallet",
        //   onTap: () {
        //     Navigator.of(context).pushNamed("/card-payment-page");
        //   },
        //   iconColor: HexColor("#F35B46"),
        // )),
      ],
    );
  }

  Widget thirdRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
          child: UserDashboardItemTile(
            icon: Icons.business_center_rounded,
            title: AppLocalization.of(context)!.business,
            isLocked: storeLocked,
            onTap: () {
              hideBalance();
              if (!storeLocked) {
                // Navigator.of(context).pushNamed(Routes.CONTRACTS);
                businessAndroidSheet();
              } else {
                showToast(
                    message:
                        'You need to upgrade to a business account to use this feature.');
              }
            },
            iconColor: HexColor("#5218E9"),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UserDashboardItemTile(
            icon: SlydoAppIcon.more,
            title: AppLocalization.of(context)!.more,
            onTap: () {
              Navigator.pushNamed(context, Routes.MORE_APPS);
            },
            iconColor: HexColor("#374677"),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget firstRowOfMoreApps() {
    return Row(
      children: [
        Expanded(
          child: UserDashboardItemTile(
            icon: SlydoAppIcon.utility,
            title: "Utility",
            onTap: () {
              if (appConfigurationModel?.enableUtility == true) {
                Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
              } else {
                showToast(message: 'Coming soon.');
              }
            },
            iconColor: HexColor("#FFAB00"),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UserDashboardItemTile(
            icon: SlydoAppIcon.news_moreapps,
            title: AppLocalization.of(context)!.blogs,
            onTap: () {
              NavigationUtil.push(
                context,
                screen: SuperBlog(),
              );
            },
            iconColor: HexColor("#374677"),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: UserDashboardItemTile(
            iconWidget: Icon(
              Icons.question_answer_rounded,
              size: 22,
            ),
            title: AppLocalization.of(context)!.ask,
            onTap: () {
              NavigationUtil.push(
                context,
                screen: AskStartScreen(),
              );
            },
            iconColor: HexColor("#374677"),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  void businessAndroidSheet() {
    androidBottomSheet(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            bottomSheetItem(
                title: 'Contract',
                iconData: Icons.description_rounded,
                onTap: () {
                  if (appConfigurationModel?.enableContract == true) {
                    hideBalance();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
            bottomSheetItem(
                title: "Invoice",
                iconData: Icons.receipt_outlined,
                onTap: () {
                  if (appConfigurationModel?.enableInvoice == true) {
                    hideBalance();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
          ],
        ));
  }

  Widget appVersionDataUI() {
    return madeInLagosTile();
  }

  Widget madeInLagosTile() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppLocalization.of(context)!.madeInNigeria,
              style: TextStyle(
                  color: navyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: boxShadow,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                    Shadow(
                      color: boxShadow,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    )
                  ])),
        ],
      ),
    );
  }

  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      accountBalance = spendableBalance.toString();
      if (mounted) {
        setState(() {});
      }
    });
  }

  String textTrimmer(String title) {
    if (title.length <= 12) {
      return title;
    } else {
      return title.substring(0, 10) + "..";
    }
  }

  Widget rowIconButtons(Widget item1, Widget item2, Widget item3) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: item1),
          Expanded(child: item2),
          Expanded(child: item3),
        ],
      ),
    );
  }

  void pickImage() async {
    String? croppedImage = await getCroppedImage(context);

    if (croppedImage != null) {
      try {
        isLoading = true;
        if (mounted) setState(() {});

        User? _user = await DatabaseHelper().getUser();

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String countryFromPref = sharedPreferences.getString('country') ?? "NG";

        Country country =
            CountryPickerUtils.getCountryByIsoCode(countryFromPref);

        SecureUser secureUser = await SecureStorage().getUser();
        String phoneNumber = secureUser.phoneNumber ?? "";
        String password = secureUser.password ?? "";

        if (phoneNumber != "") {
          phoneNumber = "+" + country.phoneCode! + phoneNumber;
        }

        if (phoneNumber == "" || password == "") {
          phoneNumber = _user?.phoneNumber ?? "";
          password = _user?.password ?? "";
        }

        if (phoneNumber == "" || password == "") {
          isLoading = false;
          if (mounted) setState(() {});
          return;
        }

        // Upload Image new image
        await UserAuth().updateUserAvatar(File(croppedImage));

        // Get new updated user data and set new user data to userBloc.
        await _auth.authenticate(phoneNumber, password).then((value) {
          userBloc.user = value;
          isLoading = false;
          if (mounted) setState(() {});
          dashboardBloc.index = 0;
        });
      } catch (err) {
        isLoading = false;
        if (mounted) setState(() {});
        // showToast(message: err.toString());
        debugPrint("Cannot Update Avatar : " + err.toString());
      }
    }
  }

  void changeLanguage() async {
    await showDialog<Language>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalization.of(context)!.selectYourLanguage),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              content: SingleChildScrollView(
                child: Column(
                  children: languages.map((data) {
                    return RadioListTile(
                      selected: language!.languageCode == data.languageCode,
                      title: Text(data.name),
                      activeColor: navyBlue,
                      groupValue: language,
                      value: data,
                      onChanged: (dynamic lang) {
                        setState(() {
                          language = lang;
                          setLanguage(lang);
                          Navigator.pop(context);
                          saveIntoSharedPreference(lang);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ));
  }

  void getLanguage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      String? languageCode = sharedPreferences.getString("language");
      setState(() {
        language = getLanguageByLanguageCode(languageCode);
        debugPrint("Set language: => " + language!.name);
      });
    } else {
      setState(() {
        language = getLanguageByLanguageCode("en");
        debugPrint("Set default language: => " + language!.name);
      });
    }
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

  void profileAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          bottomSheetItem(
            title: AppLocalization.of(context)!.myProfile,
            iconData: SlydoAppIcon.user,
            onTap: () async {
              await UserAuth()
                  .fetchCustomerProfile(userBloc.user.userName)
                  .then((user) {
                if (mounted) {
                  Navigator.pop(myGlobals.navigationKey.currentContext!);
                  Navigator.pushNamed(myGlobals.navigationKey.currentContext!,
                      Routes.USER_PROFILE,
                      arguments: {"searchedUserName": user.userName});
                }
              });
            },
          ),
          bottomSheetItem(
            title: AppLocalization.of(context)!.updateMyAvatar,
            iconData: SlydoAppIcon.image,
            onTap: () {
              Navigator.pop(context);
              pickImage();
            },
          ),
          bottomSheetItem(
            title: "Billing address",
            iconData: SlydoAppIcon.location,
            isLast: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.USER_ADDRESS,
              );
            },
          ),
        ],
      ),
    );
  }

  void transactionAndroidSheet() {
    androidBottomSheet(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            bottomSheetItem(
              title: AppLocalization.of(context)!.myTransaction,
              iconData: SlydoAppIcon.transactions,
              onTap: () {
                hideBalance();
                BottomSheetPassCode(
                    context: context,
                    isValidCallback: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.TRANSACTIONS);
                    },
                    cancelCallBack: () {
                      Navigator.pop(context);
                    });
              },
            ),
            bottomSheetItem(
              title: "My Payment Request",
              iconData: SlydoAppIcon.receive,
              onTap: () {
                hideBalance();
                Navigator.pop(context);

                Navigator.pushNamed(context, Routes.ACCOUNTS);
              },
            ),
          ],
        ));
  }

  void bankAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  bottomSheetItem(
                    title: AppLocalization.of(context)!.bankAccounts,
                    iconData: SlydoAppIcon.bank,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.BANK_ACCOUNT_LIST);
                    },
                  ),
                  bottomSheetItem(
                      title: AppLocalization.of(context)!.cashOut,
                      iconData: SlydoAppIcon.payout,
                      onTap: () {
                        if (appConfigurationModel?.enableCashout == false) {
                          BottomSheetPassCode(
                              context: context,
                              isValidCallback: () {
                                if (bankAccountBloc.bankAccount == null ||
                                    bankAccountBloc.bankAccount!.bankName ==
                                        null) {
                                  Navigator.pop(context);
                                  showToast(
                                      message:
                                          "Please add bank account first !!");
                                } else {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, Routes.PAYOUT);
                                }
                              },
                              cancelCallBack: () {
                                Navigator.pop(context);
                              });
                        } else {
                          showToast(message: 'Coming soon');
                        }
                      }),
                  bottomSheetItem(
                    title: "Cashout transactions",
                    iconData: SlydoAppIcon.payout_list,
                    isLast: true,
                    onTap: () {
                      BottomSheetPassCode(
                          context: context,
                          isValidCallback: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, Routes.PAYOUT_LIST);
                          },
                          cancelCallBack: () {
                            Navigator.pop(context);
                          });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void profileIOSSheet() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.myProfile),
            onPressed: () {
              Navigator.pop(context, 'My Profile');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.updateMyAvatar),
            onPressed: () {
              Navigator.pop(context, 'Update My Avatar');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.myAddress),
            onPressed: () {
              Navigator.pop(context, 'My Address');
            },
          ),
          CupertinoActionSheetAction(
            child: Text("My Connections/Request"),
            onPressed: () {
              Navigator.pop(context, "My Connections");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalization.of(context)!.cancel),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ),
    );
  }

  void bankIOSSheet() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.bankAccounts),
            onPressed: () {
              Navigator.pop(context, 'Bank Accounts');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.payoutList),
            onPressed: () {
              Navigator.pop(context, 'Payout List');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.payout),
            onPressed: () {
              Navigator.pop(context, 'Payout');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalization.of(context)!.cancel),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ),
    );
  }

  void showDemoActionSheet({required BuildContext context, Widget? child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child!,
    ).then((String? value) {
      if (value != null) {
        if (value == "My Profile") {
          Navigator.pushNamed(context, Routes.USER_PROFILE,
              arguments: {"searchedUserName": userBloc.user.userName});
        } else if (value == "Update My Avatar") {
          pickImage();
        } else if (value == "My Address") {
          Navigator.pushNamed(
            context,
            Routes.USER_ADDRESS,
          );
        } else if (value == "My Connections") {
          Navigator.pushNamed(
            context,
            Routes.FRIENDS_DASHBOARD,
          );
        } else if (value == "Bank Accounts") {
          Navigator.pushNamed(context, Routes.BANK_ACCOUNT_LIST);
        } else if (value == "Payout List") {
          PassCodePopup(
              context: context,
              isValidCallback: () {
                Navigator.pushNamed(context, Routes.PAYOUT_LIST);
              },
              cancelCallBack: () {});
        } else if (value == "Payout") {
          PassCodePopup(
              context: context,
              isValidCallback: () {
                Navigator.pushNamed(context, Routes.PAYOUT);
              },
              cancelCallBack: () {});
        } else if (value == "Add Product") {
          Navigator.pushNamed(context, Routes.ADD_PRODUCT);
        } else if (value == "Add Service") {
          Navigator.pushNamed(context, Routes.ADD_SERVICE);
        }
      }
    });
  }

  void storeItemAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Add product",
                      iconData: SlydoAppIcon.product,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_PRODUCT);
                      },
                    ),
                    bottomSheetItem(
                      title: "Add service",
                      iconData: SlydoAppIcon.note_2,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_SERVICE);
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  void storeItemIOSSheet() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.addProduct),
            onPressed: () {
              Navigator.pop(context, 'Add Product');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context)!.addService),
            onPressed: () {
              Navigator.pop(context, 'Add Service');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalization.of(context)!.cancel),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: languages.map((data) {
                    return bottomSheetItemWithCheck(
                        icon: SlydoAppIcon.translation,
                        title: data.name,
                        isChecked: language!.languageCode == data.languageCode,
                        onTap: () {
                          language = data;
                          setLanguage(data);
                          Navigator.pop(context);
                          saveIntoSharedPreference(data);
                        });
                  }).toList(),
                ),
              ));
        });
  }

  Widget bottomSheetItemWithCheck(
      {Function? onTap,
      IconData? icon,
      required String title,
      bool isLast = false,
      required bool isChecked}) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            RoundedBackgroundIcon(
              icon: Icon(
                icon,
                size: 14,
              ),
              backgroundColor: lightGrey,
              width: 32,
              height: 32,
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: blackFont),
            ),
            flexibleSpace(),
            isChecked
                ? Icon(
                    SlydoAppIcon.checked,
                    color: navyBlue,
                    size: 14,
                  )
                : Container()
          ],
        ),
      ),
      onTap: onTap as void Function()?,
    );
  }
}
