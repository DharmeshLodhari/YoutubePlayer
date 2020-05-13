//TODO: ADD APP LOCALIZATION
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/device.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isLocked;
  Language language;
  String accountBalance = "";

  PersistentBottomSheetController bankAccountController;
  PersistentBottomSheetController profileSheetController;

  @override
  void initState() {
    setState(() {
      isLocked = arguments['isLocked'];
    });
    if (!isLocked) {
      getAccountBalance();
    }

    getLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard',
            arguments: {'dashboardIndex': 5});
        return false;
      },
      child: Scaffold(
        key: _scaffoldSettingKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Row(
            children: <Widget>[
              displayUserAvatar(),
              Expanded(child: SizedBox(width: 10)),
              Text("User Dashboard"),
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
                  SizedBox(height: 20),

                  //ROW 1
                  rowIconButtons(
                    iconButton(
                      Icons.person,
                      "Profile",
                      () {
                        showProfileSheet();
                      },
                    ),
                    iconButton(
                      Icons.language,
                      "Language",
                      () {
                        changeLanguage();
                      },
                    ),
                    iconButton(
                      Icons.event_note,
                      "Taxes",
                      () {
                        Toast.show("Comming Soon !!", context,
                            backgroundColor: darkBlue(),
                            textColor: Colors.white);
                      },
                    ),
                  ),

                  //ROW 2
                  rowIconButtons(
                    iconButton(
                      Icons.shopping_cart,
                      "Orders",
                      () {
                        Navigator.pushNamed(context, '/orders-list');
                      },
                    ),
                    iconButton(
                      Icons.shopping_basket,
                      "Add Products",
                      () {
                        Navigator.pushNamed(context, '/add-product');
                      },
                    ),
                    iconButton(Icons.settings, "Add Service", () {
                      Navigator.pushNamed(context, '/add-service');
                      Toast.show("Comming Soon !!", context,
                          backgroundColor: darkBlue(), textColor: Colors.white);
                    }),
                  ),

                  //ROW 3
                  rowIconButtons(
                    iconButton(
                      Icons.credit_card,
                      "Top Up",
                      () {
                        Toast.show("Comming Soon !!", context,
                            backgroundColor: darkBlue(),
                            textColor: Colors.white);
                      },
                    ),
                    iconButton(Icons.account_balance_wallet, "Transactions",
                        () {
                      Navigator.pushNamed(context, "/transactions");
                    }),
                    iconButton(
                      Icons.account_balance,
                      "Bank",
                      () {
                        showBankAccoutSheet();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayUserAvatar() {
    return Padding(
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
                    backgroundColor: Colors.white,
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

    Navigator.pushNamedAndRemoveUntil(context, "/index", (r) => false,
        arguments: {'isIntroDone': true});
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
      margin: EdgeInsets.symmetric(horizontal: 20),
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

  showBankAccoutSheet() {
    bankAccountController =
        _scaffoldSettingKey.currentState.showBottomSheet((context) => Card(
              elevation: 15,
              margin: EdgeInsets.all(0),
              color: Colors.white,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Bank Account Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkBlue(),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text("Bank Accounts"),
                        onTap: () {
                          Navigator.pushNamed(context, "/bank-account-list");
                        },
                      ),
                      ListTile(
                        title: Text("Payout List"),
                        onTap: () {
                          Navigator.pushNamed(context, "/payout-list");
                        },
                      ),
                      ListTile(
                        title: Text("Payout"),
                        onTap: () {
                          Navigator.pushNamed(context, "/payout");
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  showProfileSheet() {
    profileSheetController =
        _scaffoldSettingKey.currentState.showBottomSheet((context) => Card(
              elevation: 15,
              margin: EdgeInsets.all(0),
              color: Colors.white,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkBlue(),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text("My Profile"),
                        onTap: () {
                          _auth
                              .fetchCustomerProfile(userBloc.user.userName)
                              .then((user) {
                            Navigator.pushNamed(context, '/profile',
                                arguments: {"searchedUser": user});
                          });
                        },
                      ),
                      ListTile(
                        title: Text("Update Avatar"),
                        onTap: () {
                          pickImage(userBloc);
                        },
                      ),
                      ListTile(
                        title: Text("Address"),
                        onTap: () {
//                          pickImage(userBloc);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
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
      final file = await ImagePicker.pickImage(source: imageSource);
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
        } catch (err) {}
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
        debugPrint("Setted language: => " + language.name);
      });
    } else {
      setState(() {
        language = getLanguageByLanguageCode("en");
        debugPrint("Setted default language: => " + language.name);
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
}
