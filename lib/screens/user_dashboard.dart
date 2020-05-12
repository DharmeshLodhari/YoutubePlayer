//TODO: ADD APP LOCALIZATION
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldSettingKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

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
          title: Text("User Dashboard"),
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
                  rowIconButtons(
                    iconButton(
                      Icons.person,
                      "Profile",
                      () {
                        _auth
                            .fetchCustomerProfile(userBloc.user.userName)
                            .then((user) {
                          Navigator.pushNamed(context, '/profile',
                              arguments: {"searchedUser": user});
                        });
                      },
                    ),
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
                  ),
                  rowIconButtons(
                    iconButton(Icons.settings, "Add Service", () {
                      Navigator.pushNamed(context, '/add-service');
                      Toast.show("Comming Soon !!", context,
                          backgroundColor: darkBlue(), textColor: Colors.white);
                    }),
                    iconButton(
                      Icons.event_note,
                      "Taxes",
                      () {
                        Toast.show("Comming Soon !!", context,
                            backgroundColor: darkBlue(),
                            textColor: Colors.white);
                      },
                    ),
                    Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
