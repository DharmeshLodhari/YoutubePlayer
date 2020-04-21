import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/screens/tiles/explore.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class SettingsList extends StatefulWidget {
  var arguments;
  SettingsList({this.arguments});

  @override
  _SettingsListState createState() => _SettingsListState(arguments: arguments);
}

class _SettingsListState extends State<SettingsList> {
  final GlobalKey<ScaffoldState> _scaffoldSettingKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  bool _account = false;
  bool isLoading = false;
  String accountBalance = "";
  bool isLocked;
  var arguments;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  SlidableController slidableController;

  _SettingsListState({this.arguments});

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
            'App version: ' + _packageInfo.version,
            style: TextStyle(color: Colors.white),
          ),
          Text('Build number: ' + _packageInfo.buildNumber,
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

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    _initPackageInfo();
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
        key: _scaffoldSettingKey,
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.fromLTRB(0, 16, 0, 36),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  displayProfileTile(),
                  SizedBox(height: 10),
                  _getSlidableWithLists(
                      context, displayAccountBalance(isLocked)),
                  bankAccountBloc.bankAccount.bankName != null
                      ? SizedBox(height: 10)
                      : Container(),
                  bankAccountBloc.bankAccount.bankName != null
                      ? displayBankAccountTile(bankAccountBloc)
                      : Container(),
                  userBloc.user.setting.enableExplore
                      ? SizedBox(
                          height: 0,
                        )
                      : SizedBox(
                          height: 10,
                        ),
                  userBloc.user.setting.enableExplore
                      ? ExploreTile()
                      : Container(),
                  userBloc.user.setting.enableExplore
                      ? SizedBox(height: 10)
                      : Container(),
                  userBloc.user.type != 'user' ? serviceTile() : Container(),
                  userBloc.user.type != 'user'
                      ? SizedBox(height: 10)
                      : Container(),
                  userBloc.user.type != 'user' ? productTile() : Container(),
                  userBloc.user.type != 'user'
                      ? SizedBox(height: 10)
                      : Container(),
                  slydoBankAccountTile(),
                  SizedBox(height: 25),
                  _infoTile(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _account == true ? null : addAccountButton(),
      ),
    );
  }

  Widget displayProfileTile() {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 40),
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
        onTap: () {
          _auth.fetchCustomerProfile(userBloc.user.userName).then((user) {
            if (user.type != 'user') {
              {
                Navigator.pushNamed(context, '/profile',
                    arguments: {"searchedUser": user});
              }
            }
          });
        },
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
      return Container();
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

    Navigator.pushNamedAndRemoveUntil(context, "/index", (r) => false,
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

  Widget serviceTile() {
    return Card(
      margin: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
      child: ListTile(
        title: Text(
          "Add Servics",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        leading: Icon(
          Icons.settings,
          color: Colors.black,
          size: 45,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/add-service');
        },
      ),
    );
  }

  Widget productTile() {
    return Card(
      margin: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
      child: ListTile(
        title: Text(
          "Add Product",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        leading: Icon(
          Icons.shopping_basket,
          color: Colors.black,
          size: 45,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/add-product');
        },
      ),
    );
  }

  Widget slydoBankAccountTile() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 40),
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        dense: true,
        leading: ClipOval(
            child: Image.asset(
          "assets/images/slydo.png",
          height: 45,
          width: 45,
        )),
        title: Text(
          "Bank Name: GTB",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Account: 0123456789",
              style: TextStyle(fontSize: 11),
            ),
            Text(
              "Name : Slydo Private ltd",
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.account_balance),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget accountBalanceTile) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(accountBalanceTile),
      actions: listActionSlideActions(),
      secondaryActions: listSecondaryActions(),
    );
  }

  List<Widget> listSecondaryActions() {
    String caption = 'payout';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.green,
          icon: Icons.send,
          onTap: () async {
            Navigator.pushNamed(context, '/payout');
          }),
    ];
  }

  List<Widget> listActionSlideActions() {
    return [
      IconSlideAction(
        caption: 'payout list',
        color: Colors.green,
        icon: Icons.event_note,
        onTap: () {
          Navigator.pushNamed(context, '/payout-list');
        },
      ),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
