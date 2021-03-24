import 'dart:io';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/bank_account.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/device.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';

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
  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;
  MainSocketProvider socketProvider;
  BasketBloc basketBloc;

  bool isLoading = false;
  bool storeLocked = true;
  Language language;
  String accountBalance = "";

  DashboardBloc dashboardBloc;
  bool isBalanceHidden = true;

  @override
  void initState() {
    getAccountBalance();
    getLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    socketProvider = Provider.of<MainSocketProvider>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    dashboardBloc = Provider.of<DashboardBloc>(context);

    if (userBloc.user.type != "User") {
      storeLocked = false;
    }

    return Scaffold(
        key: _scaffoldSettingKey,
        body: Container(
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
        ));
  }

  Widget backgroundScreen() {
    if (userBloc.user.userAbout == null ||
        userBloc.user.userAbout.wallpaper == null ||
        userBloc.user.userAbout.wallpaper == "") {
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
      child: CachedNetworkImage(
        imageUrl: userBloc.user.userAbout.wallpaper,
        fit: BoxFit.cover,
        width: 100.0.w,
        height: 33.0.h,
        color: blackFont.withOpacity(0.4),
        colorBlendMode: BlendMode.darken,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: [
          Platform.isIOS ? Container() : flexibleSpace(),
          appBar(),
          flexibleSpace(flex: 4),
          accountBalanceCard(),
          flexibleSpace(flex: 2),
          firstRowOfUserDashboardItem(),
          flexibleSpace(flex: 1),
          secondRowOfUserDashboardItem(),
          flexibleSpace(flex: 1),
          thirdRowOfUserDashboardItem(),
          flexibleSpace(flex: 3),
          appVersionDataUI(),
          flexibleSpace(flex: 3),
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
      title: Text(
        "Account",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        // settingBtn(),
        // SizedBox(
        //   width: 6,
        // ),
        logoutBtn(),
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
          Navigator.of(context).pushNamed("/general-setting");
        },
      ),
    );
  }

  Widget logoutBtn() {
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
            SlydoAppIcon.leave,
            size: 16,
          ),
        ),
        onTap: () {
          showDialog(
              context: (context),
              builder: (context) => Center(child: CircularLoadingIndicator()),
              barrierDismissible: false);
          logoutUser();
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
          children: [
            isBalanceHidden
                ? Container()
                : Icon(
                    SlydoAppIcon.naira,
                    color: blackFont,
                    size: 16,
                  ),
            Text(
              isBalanceHidden ? "*********" : accountBalance,
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.bold, fontSize: 26),
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
          title: "Profile",
          onTap: () {
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
            Navigator.pushNamed(context, '/orders-list');
          },
          iconColor: HexColor("#FFAB00"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.store,
          title: "My store",
          isLocked: storeLocked,
          onTap: () {
            if (!storeLocked) {
              storeItemAndroidSheet();
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
          title: "Transaction",
          onTap: () {
            BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  Navigator.pushNamed(context, "/transactions");
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                });
          },
          iconColor: HexColor("#3F61DB"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.bank,
          title: "Bank",
          onTap: () {
            bankAndroidSheet();
          },
          iconColor: HexColor("#F35B46"),
        )),
        SizedBox(
          width: 12,
        ),
        // Expanded(
        //     child: UserDashboardItemTile(
        //   icon: Icons.business_center_rounded,
        //   title: "Business",
        //   isLocked: storeLocked,
        //   onTap: () {
        //     if (!storeLocked) {
        //       Navigator.of(context).pushNamed("/contracts");
        //     }
        //   },
        //   iconColor: HexColor("#5218E9"),
        // )),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.naira,
          title: "Topup",
          onTap: () {
            Navigator.of(context).pushNamed('/add-money-to-slydo-one');
          },
          iconColor: HexColor("#46CE7C"),
        )),
      ],
    );
  }

  Widget thirdRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.translation,
          title: "Language",
          onTap: () {
            // changeLanguage();
            changeLanguageBottomSheet();
          },
          iconColor: HexColor("#5218E9"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.more,
          title: "More",
          onTap: () {
            Navigator.pushNamed(context, "/more-apps");
          },
          iconColor: HexColor("#374677"),
        )),
        // Expanded(child: Container()),
        SizedBox(
          width: 12,
        ),
        Expanded(child: Container()),
      ],
    );
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
          Text("Made in Nigeria",
              style: TextStyle(
                  color: navyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                        color: boxShadow, blurRadius: 3, offset: Offset(1, 1)),
                    Shadow(
                        color: boxShadow, blurRadius: 3, offset: Offset(1, 1))
                  ])),
        ],
      ),
    );
  }

  void logoutUser() async {
    emptyBasketCart();
    SharedPreferences _sharedPreferences;

    MainSocketMessageHandler().dispose();

    // AssetsAudioPlayer.allPlayers().forEach((key, value) {
    //   debugPrint("Key:- $key");
    //   value.dispose();
    // });

    CacheManager().deleteCache(clearAll: true);
    await socketProvider?.close();

    await PushNotificationService().logout();
    await _auth.logOut();

    bankAccountBloc.bankAccount = BankAccount();
    dashboardBloc.index = 0;
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool('isLoggedOut', true);

    /// clearing all data when user is logout
    if (!_sharedPreferences.getBool("isChecked")) {
      await SecureStorage().clear();
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/index", (r) => false,
          arguments: {'isIntroDone': true});
    }
  }

  void emptyBasketCart() {
    basketBloc.items.clear();
    basketBloc.total = 0;
  }

  Widget displayAccountBalance(isLocked) {
    return AccountBalanceTile(
        balance: accountBalance, isLocked: isLocked, onTap: () {});
  }

  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value;
      var spendableBalance = data["spendable_balance"];
      accountBalance = spendableBalance.toString();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget iconButton(var icon, String title, GestureTapCallback tap) {
    return Card(
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        padding: EdgeInsets.all(6),
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Icon(icon, size: 45, color: darkBlue()),
              ),
              Center(
                child: Text(
                  textTrimmer(title),
                  style: TextStyle(fontSize: 12, color: darkBlue()),
                ),
              ),
            ],
          ),
          onTap: tap,
        ),
      ),
    );
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
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context).selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context).camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().getImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        String croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        try {
          isLoading = true;
          if (mounted) setState(() {});
          // Get user current login info so we can reuse it to login
          var dbUser = await _auth.getUser();
          var phoneNumber = dbUser.phoneNumber;
          var password = dbUser.password;

          // Upload Image new image
          await UserAuth().updateUserAvatar(File(croppedImage));

          // Get New updated user data and set new user data to userBloc
          await _auth.authenticate(phoneNumber, password).then((value) {
            userBloc.user = value;
            isLoading = false;
            if (mounted) setState(() {});
            dashboardBloc.index = 0;
          });
        } catch (err) {
          isLoading = false;
          if (mounted) setState(() {});
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Avatar : " + err.toString());
        }
      }
    }
  }

  void changeLanguage() async {
    await showDialog<Language>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalization.of(context).selectYourLanguage),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              content: SingleChildScrollView(
                child: Column(
                  children: languages.map((data) {
                    return RadioListTile(
                      selected: language.languageCode == data.languageCode,
                      title: Text(data.name),
                      activeColor: darkBlue(),
                      groupValue: language,
                      value: data,
                      onChanged: (lang) {
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
      String languageCode = sharedPreferences.getString("language");
      setState(() {
        language = getLanguageByLanguageCode(languageCode);
        debugPrint("Set language: => " + language.name);
      });
    } else {
      setState(() {
        language = getLanguageByLanguageCode("en");
        debugPrint("Set default language: => " + language.name);
      });
    }
  }

  void setLanguage(Language language) {
    setState(() {
      AppLocalization.load(Locale(language.languageCode, ""));
      Toast.show(
        AppLocalization.of(context).languageSwitchedTo + " ${language.name}",
        context,
        duration: Toast.LENGTH_LONG,
        textColor: Colors.white,
        backgroundColor: darkBlue(),
      );
    });
  }

  //to save language in shared preference when user change the language
  void saveIntoSharedPreference(Language language) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("language")) {
      bool result =
          await sharedPreferences.setString("language", language.languageCode);
      debugPrint(
          "${language.name} Language is updated in sharedPreference => $result");
    } else {
      bool result =
          await sharedPreferences.setString("language", language.languageCode);
      debugPrint(
          "${language.name} Language is set in sharedPreference => $result");
    }
  }

  void profileAndroidSheet() {
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
                      title: "My profile",
                      icon: SlydoAppIcon.user,
                      onTap: () {
                        UserAuth()
                            .fetchCustomerProfile(userBloc.user.userName)
                            .then((user) {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profile',
                              arguments: {"searchedUserName": user.userName});
                        });
                      },
                    ),
                    bottomSheetItem(
                      title: "Update my avatar",
                      icon: SlydoAppIcon.image,
                      onTap: () {
                        Navigator.pop(context);
                        pickImage();
                      },
                    ),
                    bottomSheetItem(
                      title: "My address",
                      icon: SlydoAppIcon.location,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/user-address',
                        );
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  void bankAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  bottomSheetItem(
                    title: "Bank accounts",
                    icon: SlydoAppIcon.bank,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/bank-account-list");
                    },
                  ),
                  bottomSheetItem(
                    title: "Payout list",
                    icon: SlydoAppIcon.payout_list,
                    onTap: () {
                      BottomSheetPassCode(
                          context: context,
                          isValidCallback: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/payout-list");
                          },
                          cancelCallBack: () {
                            Navigator.pop(context);
                          });
                    },
                  ),
                  bottomSheetItem(
                    title: "Payout",
                    icon: SlydoAppIcon.payout,
                    isLast: true,
                    onTap: () {
                      BottomSheetPassCode(
                          context: context,
                          isValidCallback: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/payout");
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
            child: Text(AppLocalization.of(context).myProfile),
            onPressed: () {
              Navigator.pop(context, 'My Profile');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).updateMyAvatar),
            onPressed: () {
              Navigator.pop(context, 'Update My Avatar');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).myAddress),
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
          child: Text(AppLocalization.of(context).cancel),
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
            child: Text(AppLocalization.of(context).bankAccounts),
            onPressed: () {
              Navigator.pop(context, 'Bank Accounts');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).payoutList),
            onPressed: () {
              Navigator.pop(context, 'Payout List');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).payout),
            onPressed: () {
              Navigator.pop(context, 'Payout');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalization.of(context).cancel),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        if (value == "My Profile") {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": userBloc.user.userName});
        } else if (value == "Update My Avatar") {
          pickImage();
        } else if (value == "My Address") {
          Navigator.pushNamed(
            context,
            '/user-address',
          );
        } else if (value == "My Connections") {
          Navigator.pushNamed(
            context,
            '/friends-dashboard',
          );
        } else if (value == "Bank Accounts") {
          Navigator.pushNamed(context, "/bank-account-list");
        } else if (value == "Payout List") {
          PassCodePopup(
              context: context,
              isValidCallback: () {
                Navigator.pushNamed(context, "/payout-list");
              },
              cancelCallBack: () {});
        } else if (value == "Payout") {
          PassCodePopup(
              context: context,
              isValidCallback: () {
                Navigator.pushNamed(context, "/payout");
              },
              cancelCallBack: () {});
        } else if (value == "Add Product") {
          Navigator.pushNamed(context, '/add-product');
        } else if (value == "Add Service") {
          Navigator.pushNamed(context, '/add-service');
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
                      icon: SlydoAppIcon.product,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-product');
                      },
                    ),
                    bottomSheetItem(
                      title: "Add service",
                      icon: SlydoAppIcon.note_2,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-service');
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
            child: Text(AppLocalization.of(context).addProduct),
            onPressed: () {
              Navigator.pop(context, 'Add Product');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).addService),
            onPressed: () {
              Navigator.pop(context, 'Add Service');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalization.of(context).cancel),
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
                        isChecked: language.languageCode == data.languageCode,
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
      {Function onTap,
      IconData icon,
      String title,
      bool isLast = false,
      bool isChecked}) {
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
      onTap: onTap,
    );
  }
}
