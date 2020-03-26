import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/screens/tiles/explore.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SettingsList extends StatefulWidget {
  var arguments;
  SettingsList({this.arguments});

  @override
  _SettingsListState createState() => _SettingsListState(arguments: arguments);
}

class _SettingsListState extends State<SettingsList> {
  final _auth = AuthService();
  bool _account = false;
  bool isLoading = false;
  String accountBalance = "";
  bool isLocked;
  var arguments;
  _SettingsListState({this.arguments});

  @override
  void initState() {
    setState(() {
      isLocked = arguments['isLocked'];
    });
    if (!isLocked) {
      getAccountBalance();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text('Settings'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.power_settings_new, color: Colors.white),
              onPressed: () {
                logoutUser(bankAccountBloc);
              },
              tooltip: "Logout",
            ),
          ],
        ),
        body: Center(
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  displayProfileTile(userBloc),
                  displayAccountBalance(isLocked),
                  displayBankAccountTile(bankAccountBloc),
                  userBloc.user.userName == "abiola.rashhed.2"
                      ? ExploreTile()
                      : Container(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _account == true ? null : addAccountButton(),
      ),
    );
  }

  Widget displayProfileTile(userBloc) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            userBloc.user.fullName,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          isThreeLine: true,
          subtitle:
              Text(userBloc.user.userName + "\n" + userBloc.user.phoneNumber),
          leading: isLoading
              ? Container(
                  height: 45,
                  width: 45,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
              : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userBloc.user.avatar,
                    height: 45,
                    width: 45,
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
          trailing: IconButton(
            icon: Icon(
              Icons.mode_edit,
              color: darkBlue(),
            ),
            tooltip: "Edit Profile",
            onPressed: () {
              Connectivity().checkConnectivity().then((value) {
                var connectionResult = value;
                if (connectionResult == ConnectivityResult.wifi ||
                    connectionResult == ConnectivityResult.mobile) {
                  pickImage(userBloc);
                } else {
                  Toast.show("Internet Connection is not available", context,
                      gravity: Toast.BOTTOM, backgroundColor: darkBlue());
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget displayBankAccountTile(BankAccountBloc bankAccountBloc) {
    if (bankAccountBloc.bankAccount.bankName != null) {
      setState(() {
        _account = true;
      });
      return BankAccountTile(account: bankAccountBloc.bankAccount);
    } else {
      return Text(" ");
    }
  }

  Widget addAccountButton() {
    return FloatingActionButton(
      heroTag: "add-account",
      backgroundColor: darkBlue(),
      onPressed: () {
        Navigator.of(context).pushNamed('/add-account');
      },
      tooltip: 'Add Account',
      child: Icon(Icons.add),
    );
  }

  void pickImage(userBloc) async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Camera"),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery"),
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

  void logoutUser(BankAccountBloc bankAccountBloc) async {
    SharedPreferences _sharedPreferences;
    await _auth.logOut();
    bankAccountBloc.bankAccount = BankAccount();
    setState(() {
      _account = false;
    });
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool('isLoggedOut', true);

    Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false,
        arguments: {'isIntroDone': true});
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
}
