import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/device.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/user_dashboard_item_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class UserDashboard extends StatefulWidget {
  var arguments;

  UserDashboard({this.arguments});

  @override
  _UserDashboardState createState() =>
      _UserDashboardState(arguments: arguments);
}

class _UserDashboardState extends State<UserDashboard> {
  var arguments;

  _UserDashboardState({this.arguments});

  final GlobalKey<ScaffoldState> _scaffoldSettingKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  UserBloc userBloc;
  BankAccountBloc bankAccountBloc;
  BasketBloc basketBloc;

  bool isLoading = false;
  bool storeLocked = true;
  bool isLocked = true;
  Language language;
  String accountBalance = "";

  DashboardBloc dashboardBloc;
  bool isBalanceHidden = true;

  NotificationBloc notificationBloc;

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

  @override
  void initState() {
    setState(() {
      isLocked = arguments['isLocked'] ?? true;
    });
    if (!isLocked) {
      getAccountBalance();
    }
    getAccountBalance();
    _initPackageInfo();
    getLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    dashboardBloc = Provider.of<DashboardBloc>(context);
    notificationBloc = Provider.of<NotificationBloc>(context);

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
            ],
          ),
        ));
  }

  Widget backgroundScreen() {
    return Container(
      child: Image.asset(
        "assets/images/home_screen_background.png",
        frameBuilder: imageFrameBuilder,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: <Widget>[
                flexibleSpace(),
                appBar(),
                flexibleSpace(flex: 4),
                accountBalanceCard(),
                flexibleSpace(flex: 2),
                firstRowOfUserDashboardItem(),
                flexibleSpace(flex: 1),
                secondRowOfUserDashboardItem(),
                flexibleSpace(flex: 2),
                thirdRowOfUserDashboardItem(),
                flexibleSpace(flex: 1),
                appVersionDataUI()
              ],
            ),
          ),
          flexibleSpace()
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
        logoutBtn(),
      ],
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
          logoutUser(bankAccountBloc);
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
            padding: EdgeInsets.only(left: 24, right: 24, top: 18, bottom: 24),
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
      ],
    );
  }

  Widget thirdRowOfUserDashboardItem() {
    return Row(
      children: [
        Expanded(
            child: UserDashboardItemTile(
          icon: SlydoAppIcon.general_category,
          title: "More",
          onTap: () {
            Navigator.pushNamed(context, "/internal-apps");
          },
          iconColor: HexColor("#46CECE"),
        )),
        SizedBox(
          width: 12,
        ),
        Expanded(child: Container()),
        SizedBox(
          width: 12,
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget appVersionDataUI() {
    return _infoTile();
  }

  Widget _infoTile() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalization.of(context).appVersion +
                ': ' +
                _packageInfo.version,
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          Text(
              AppLocalization.of(context).buildNumber +
                  ': ' +
                  _packageInfo.buildNumber,
              style: TextStyle(color: darkGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget myStore() {
    return Stack(
      children: <Widget>[
        iconButton(
          Icons.store_mall_directory,
          AppLocalization.of(context).myStore,
          () {
            if (!storeLocked) {
              Platform.isIOS ? storeItemIOSSheet() : storeItemAndroidSheet();
            }
          },
        ),
        storeLocked
            ? Positioned(
                child: GestureDetector(
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onTap: () {},
                ),
                right: 8,
                top: 8,
              )
            : Container()
      ],
    );
  }

  Widget displayUserAvatar() {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userBloc.user.avatar,
                  height: 40,
                  width: 40,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => userBloc.user.avatar == ""
                      ? Icon(Icons.person)
                      : CircularLoadingIndicator(),
                ),
              ),
            ),
          );
  }

  void logoutUser(BankAccountBloc bankAccountBloc) async {
    emptyBasketCart();
    SharedPreferences _sharedPreferences;

    // await notificationBloc.pushNotificationService.logout();

    await _auth.logOut();

    bankAccountBloc.bankAccount = BankAccount();
    dashboardBloc.index = 0;
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool('isLoggedOut', true);

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
    await _auth.getAccountBalance().then((value) {
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

  void pickImage(userBloc) async {
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
                    AppLocalization.of(context).gallary,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker.pickImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        try {
          setState(() {
            isLoading = true;
          });
          // Get user current login info so we can reuse it to login
          var dbUser = await _auth.getUser();
          var phoneNumber = dbUser.phoneNumber;
          var password = dbUser.password;

          // Upload Image new image
          await _auth.updateCustomerAvatar(file);

          // Get New updated user data and set new user data to userBloc
          await _auth.authenticate(phoneNumber, password).then((value) {
            userBloc.user = value;
            setState(() {
              isLoading = false;
            });
          });
        } catch (err) {
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("update avatar : " + err.toString());
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
                        _auth
                            .fetchCustomerProfile(userBloc.user.userName)
                            .then((user) {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/profile',
                              arguments: {"searchedUser": user});
                        });
                      },
                    ),
                    bottomSheetItem(
                      title: "Update my avatar",
                      icon: SlydoAppIcon.image,
                      onTap: () {
                        Navigator.pop(context);
                        pickImage(userBloc);
                      },
                    ),
                    bottomSheetItem(
                      title: "My address",
                      icon: SlydoAppIcon.location,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/user-address',
                        );
                      },
                    ),
                    bottomSheetItem(
                      title: "My connection/ Request",
                      icon: SlydoAppIcon.connections,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/friends-dashboard',
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
          _auth.fetchCustomerProfile(userBloc.user.userName).then((user) {
            Navigator.pushNamed(context, '/profile',
                arguments: {"searchedUser": user});
          });
        } else if (value == "Update My Avatar") {
          pickImage(userBloc);
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

  Widget bottomSheetItem(
      {Function onTap, IconData icon, String title, bool isLast = false}) {
    return InkWell(
      child: Container(
        width: double.infinity,
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
              )
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
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
