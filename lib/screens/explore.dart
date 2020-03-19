import 'dart:async';
import 'dart:io';

import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';

final List<dynamic> services = [
  ["Book Taxi", Icons.local_taxi],
  ["Shopping", Icons.shopping_cart],
  ["Transportation", Icons.train],
  ["Hospitality", Icons.hotel],
  ["Charity", Icons.people],
  ["Public Service", Icons.public],
  ["Utilities", Icons.home],
  ["Mobile Top Up", Icons.phone_iphone],
  ["Investment", Icons.attach_money],
  ["Insurance", Icons.security],
  ["Restaurant", Icons.restaurant],
  ["Financial Service", Icons.account_balance],
  ["Property", Icons.account_balance],
  ["Entertainment", Icons.play_arrow],
  ["E-Books", Icons.book],
  ["News", Icons.info],
];

class ExploreList extends StatefulWidget {
  @override
  _ExploreListState createState() => _ExploreListState();
}

class _ExploreListState extends State<ExploreList> {
  bool isSearchBoxOpen = false;
  bool isValidSearch = false;
  TextEditingController searchController;
  String searchedText = "";
  FocusNode searchFocus;
  final _auth = AuthService();
  List<dynamic> searchedResult;

  @override
  void initState() {
    searchController = TextEditingController();
    searchFocus = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard',
            arguments: {'dashboardIndex': 4});
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: Platform.isAndroid ? false : true,
          backgroundColor: darkBlue(),
          title: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(
              child: child,
              scale: animation,
            ),
            child: search(),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: searchResult,
            )
          ],
        ),
        body: Center(child: listBuilder()),
      ),
    );
  }

  Widget listBuilder() {
    return isValidSearch
        ? FutureBuilder(
            future: fetchSearchResult(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => UserTile(
                          user: snapshot.data[index],
                        ));
              }
              return LoadingIndicator();
            })
        : ListView.builder(
            itemCount: services.length,
            itemBuilder: (BuildContext context, int index) =>
                getServiceList()[index]);
  }

  List<Widget> getServiceList() {
    List<Widget> lst = [];
    services.sort((a, b) => a[0].compareTo(b[0]));
    for (final service in services) {
      var card = Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            title: Text(service[0],
                style: TextStyle(
                    color: darkBlue(),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            leading: Icon(
              service[1],
              color: darkBlue(),
            ),
            onTap: () {
//              sendAndRetrieveMessage();
            },
          ),
        ),
      );
      lst.add(card);
    }
    return lst;
  }

//  final String serverToken =
//      'dlaPvW3Wsik:APA91bGXLQT9tgMIsXG0MCBVwrLoiBEiDpTqqHucGinXxnsJH9xKZl7Xzb9vQl7mwR_-CkBkeQ3ioAqOKlbrijpCMEoi38iEFn7mqiztmoC32_sgXZ675FN2eO-UIr8u1toASI0FlXq2';
//  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
//
//  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
//    await firebaseMessaging.requestNotificationPermissions(
//      const IosNotificationSettings(
//          sound: true, badge: true, alert: true, provisional: false),
//    );
//
//    await http
//        .post(
//      'https://fcm.googleapis.com/fcm/send',
//      headers: <String, String>{
//        'Content-Type': 'application/json',
//        'Authorization': 'key=$serverToken',
//      },
//      body: jsonEncode(
//        <String, dynamic>{
//          'notification': <String, dynamic>{
//            'body': 'this is a body',
//            'title': 'this is a title'
//          },
//          'priority': 'high',
//          'data': <String, dynamic>{
//            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//            'id': '1',
//            'status': 'done'
//          },
//          'to': await firebaseMessaging.getToken(),
//        },
//      ),
//    )
//        .then((result) {
//      print(result.body);
//    });
//
//    final Completer<Map<String, dynamic>> completer =
//        Completer<Map<String, dynamic>>();
//
//    firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        completer.complete(message);
//      },
//    );
//
//    return completer.future;
//  }

  Widget search() {
    if (!isSearchBoxOpen) {
      return Center(child: Text("Explore"));
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.keyboard,
              size: 30,
            ),
            onPressed: () {
              if (searchFocus.hasFocus) {
                FocusScope.of(context).unfocus();
              } else {
                FocusScope.of(context).requestFocus(searchFocus);
              }
            },
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Center(
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 15),
                textInputAction: TextInputAction.search,
                focusNode: searchFocus,
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Seach here",
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onFieldSubmitted: (val) {
                  searchResult();
                },
                onChanged: (value) {
                  searchedText = value;
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  void searchResult() {
    if (isSearchBoxOpen && searchController.text.length >= 3) {
      fetchSearchResult();
      FocusScope.of(context).unfocus();
      setState(() {
        isValidSearch = true;
      });
    }
    if (searchController.text.length < 3) {
      setState(() {
        isValidSearch = false;
      });
    }
    if (isSearchBoxOpen && searchController.text.length == 0) {
      setState(() {
        isSearchBoxOpen = false;
      });
    } else {
      setState(() {
        isSearchBoxOpen = true;
      });
    }
  }

  Future<List> fetchSearchResult() async {
    //call your searching API with passing searchedText variable and store your List in searchResult to be displayed
    // searchedResult = await _auth.listPaymentRequests("","");
    return searchedResult;
  }
}
