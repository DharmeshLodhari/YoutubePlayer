import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

final List<dynamic> services = [];
CustomerProfile _payee;

class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  bool isSearchBoxOpen = false;
  bool isValidSearch = false;
  TextEditingController searchController;
  String searchedText = "";
  FocusNode searchFocus;
  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  var filterValue = "Users";

  final _auth = AuthService();
  SlidableController slidableController;

  @override
  void initState() {
    searchController = TextEditingController();
    searchFocus = FocusNode();

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: key,
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
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: _getSlidableWithLists(context, getDisplayCard())),
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

  Widget search() {
    if (!isSearchBoxOpen) {
      return Center(child: Text("Find users"));
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
                onFieldSubmitted: (val) async {
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

  void searchResult() async {
    if (isSearchBoxOpen && searchController.text.length >= 3) {
//      fetchSearchResult();

      var customerProfile = await _auth.fetchCustomerProfile(searchedText);
      setState(() {
        _payee = customerProfile;
      });

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
    //TODO:call your searching API with passing searchedText variable and store your List in searchResult to be displayed
    // searchedResult = await _auth.listPaymentRequests("","");
    return searchedResult;
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: EdgeInsets.all(0),
        captureInheritedThemes: true,
        itemBuilder: (context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Filter"),
                  Icon(
                    Icons.sort,
                    color: Colors.black,
                  )
                ],
              ),
              value: 1,
            ),
          );
          list.add(
            PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Users",
                style: TextStyle(color: Colors.black),
              ),
              value: "Users",
              checked: filterValue == "Users" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Products",
                style: TextStyle(color: Colors.black),
              ),
              value: "Products",
              checked: filterValue == "Products" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Services",
                style: TextStyle(color: Colors.black),
              ),
              value: "Services",
              checked: filterValue == "Services" ? true : false,
            ),
          );

          return list;
        },
        onSelected: (Object object) {
          setState(() {
            if (object != 1) {
              filterValue = object;
            }
          });
        },
      );

  Widget getDisplayCard() {
    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = CachedNetworkImage(
        imageUrl: _payee.avatar,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
      qrCodeImage = CachedNetworkImage(
        imageUrl: _payee.qrCode,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
    }

    return _payee == null
        ? Container()
        : Card(
            semanticContainer: true,
            child: ListTile(
              dense: true,
              title: Text(
                _payee.fullName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              subtitle: Text(_payee.userName),
              leading: avatarImage,
              trailing: qrCodeImage,
            ),
          );
  }

  Widget _getSlidableWithLists(BuildContext context, Widget searchCard) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(searchCard),
      actions: listActionSlideActions(),
      secondaryActions: listSecondaryActions(),
    );
  }

  List<Widget> listSecondaryActions() {
    String caption = 'Send';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.green,
          icon: Icons.send,
          onTap: () async {
            customerProfileBloc.customer =
                await _auth.fetchCustomerProfile(_payee.userName);
            Navigator.of(context).pushNamed('/send-payment',
                arguments: <String, bool>{
                  'isFromProfile': false,
                  'isRequest': false
                });
          }),
    ];
  }

  List<Widget> listActionSlideActions() {
    return [
      IconSlideAction(
        caption: 'Request',
        color: Colors.green,
        icon: Icons.event_note,
        onTap: () async {
          customerProfileBloc.customer =
              await _auth.fetchCustomerProfile(_payee.userName);
          Navigator.of(context).pushNamed('/request-payment',
              arguments: <String, bool>{
                'isFromProfile': false,
                'isRequest': true
              });
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
      onTap: () {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUser": _payee});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
