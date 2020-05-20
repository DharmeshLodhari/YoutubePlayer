
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/device.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/passcodePopup.dart';
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
  bool isLocked;
  Language language;
  String accountBalance = "";

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
            style: TextStyle(color: Colors.white),
          ),
          Text(
              AppLocalization.of(context).buildNumber +
                  ': ' +
                  _packageInfo.buildNumber,
              style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      isLocked = arguments['isLocked'];
    });
    if (!isLocked) {
      getAccountBalance();
    }

    _initPackageInfo();
    getLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);

    if (userBloc.user.isBusinessUser()) {
      storeLocked = false;
    }

    return Scaffold(
      key: _scaffoldSettingKey,
      backgroundColor: lightBlue(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue(),
        title: Row(
          children: <Widget>[
            displayUserAvatar(),
            Expanded(child: SizedBox(width: 10)),
            Text(AppLocalization.of(context).explore),
            Expanded(child: SizedBox(width: 10)),
          ],
        ),
        titleSpacing: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.white),
            onPressed: () {
              logoutUser(bankAccountBloc);
            },
            tooltip: AppLocalization.of(context).logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          color: lightBlue(),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                displayAccountBalance(isLocked),
                SizedBox(height: 15),

                //ROW 1
                rowIconButtons(
                  iconButton(
                    Icons.person,
                    AppLocalization.of(context).profile,
                    () {
                      Platform.isAndroid
                          ? profileAndroidSheet()
                          : profileIOSSheet();
                    },
                  ),
                  iconButton(
                    Icons.language,
                    AppLocalization.of(context).language,
                    () {
                      changeLanguage();
                    },
                  ),
                  iconButton(
                    Icons.shopping_cart,
                    AppLocalization.of(context).orders,
                    () {
                      Navigator.pushNamed(context, '/orders-list');
                    },
                  ),
                ),

                //ROW 2
                rowIconButtons(
                    iconButton(Icons.account_balance_wallet,
                        AppLocalization.of(context).transactions, () {
                      PassCodePopup(
                          context: context,
                          isValidCallback: () {
                            Navigator.pushNamed(context, "/transactions");
                          },
                          cancelCallBack: () {
                            Navigator.pop(context);
                          });
                    }),
                    iconButton(
                      Icons.account_balance,
                      AppLocalization.of(context).bank,
                      () {
                        Platform.isIOS ? bankIOSSheet() : bankAndroidSheet();
                      },
                    ),
                    myStore()),

                //ROW 3
                rowIconButtons(
                    Container(),
//TODO: FIND BATTER WAY TO ACCEPT CREDIT CARD  PAYMENT WITH OUT US WITH IN FOR THIS
//                    iconButton(
//                      Icons.credit_card,
//                      "Top Up",
//                      () {
//                        Navigator.pushNamed(context, "/card-payment-page");
//                      },
//                    ),
                    Container(),
                    Container()),
                SizedBox(
                  height: 16,
                ),
                _infoTile(),
              ],
            ),
          ),
        ),
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
            storeLocked
                ? null
                : Platform.isIOS
                    ? storeItemIOSSheet()
                    : storeItemAndroidSheet();
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
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
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
                      : CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: lightBlue(),
                        ),
                ),
              ),
            ),
          );
  }

  void logoutUser(BankAccountBloc bankAccountBloc) async {
    emptyBasketCart();
    SharedPreferences _sharedPreferences;
    await _auth.logOut();
    bankAccountBloc.bankAccount = BankAccount();
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
      setState(() {
        accountBalance = spendableBalance.toString();
      });
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
              title: Text(AppLocalization.of(context).selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context).camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context).gallary),
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

          debugPrint(file.toString());
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
              content: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width - 100,
                child: ListView(
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
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      title: Center(
                          child: Text(AppLocalization.of(context).myProfile)),
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
                    ListTile(
                      title: Center(
                          child:
                              Text(AppLocalization.of(context).updateAvatar)),
                      onTap: () {
                        Navigator.pop(context);
                        pickImage(userBloc);
                      },
                    ),
                    ListTile(
                      title: Center(
                          child: Text(AppLocalization.of(context).address)),
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
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: Center(
                        child: Text(AppLocalization.of(context).bankAccounts)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/bank-account-list");
                    },
                  ),
                  ListTile(
                    title: Center(
                        child: Text(AppLocalization.of(context).payoutList)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/payout-list");
                    },
                  ),
                  ListTile(
                    title:
                        Center(child: Text(AppLocalization.of(context).payout)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/payout");
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
            child: Text(AppLocalization.of(context).updateAvatar),
            onPressed: () {
              Navigator.pop(context, 'Update Avatar');
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalization.of(context).address),
            onPressed: () {
              Navigator.pop(context, 'Address');
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
      debugPrint(value);
      if (value != null) {
        if (value == "My Profile") {
          _auth.fetchCustomerProfile(userBloc.user.userName).then((user) {
            Navigator.pushNamed(context, '/profile',
                arguments: {"searchedUser": user});
          });
        } else if (value == "Update Avatar") {
          pickImage(userBloc);
        } else if (value == "Address") {
          Navigator.pushNamed(
            context,
            '/user-address',
          );
        } else if (value == "Bank Accounts") {
          Navigator.pushNamed(context, "/bank-account-list");
        } else if (value == "Payout List") {
          Navigator.pushNamed(context, "/payout-list");
        } else if (value == "Payout") {
          Navigator.pushNamed(context, "/payout");
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
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      title: Center(
                          child: Text(AppLocalization.of(context).addProduct)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-product');
                      },
                    ),
                    ListTile(
                      title: Center(
                          child: Text(AppLocalization.of(context).addService)),
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
}
