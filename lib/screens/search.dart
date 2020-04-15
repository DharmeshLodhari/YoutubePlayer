import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

final List<dynamic> services = [];
CustomerProfile _payee;

class SearchAll extends StatefulWidget {
  @override
  _SearchAllState createState() => _SearchAllState();
}

class _SearchAllState extends State<SearchAll> {
  bool isValidSearch = false;
  TextEditingController searchController;
  String searchedText = "";
  FocusNode searchFocus;
  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  var filterValue = "Users";

  final _auth = AuthService();
  SlidableController slidableController;
  List<Widget> results = [];

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
    GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldSearchKey,
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
            ),
            _threeItemPopup(),
          ],
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListView(
              children: results,
            )),
      ),
    );
  }

  Widget search() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.sort,
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
                hintText: "Search here",
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
//    }
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
            searchController.text = "";
            searchedText = "";
            if (results.isNotEmpty) {
              results = [];
            }
            if (object != 1) {
              filterValue = object;
            }
          });
        },
      );

  void searchResult() async {
    if (searchController.text.length >= 3) {
      setState(() {
        if (results.isNotEmpty) {
          results = [];
        }
      });
      var url = getSearchUrl(searchedText);
      var searchedResults = await _auth.searchEndpoint(url);

      updateSearchResults(searchedResults);
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
  }

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

  String getSearchUrl(String searchedText) {
    switch (filterValue) {
      case "Users":
        return baseUrl + "/api/v1/search/users/?search=" + searchedText;
      case "Products":
        return baseUrl + "/api/v1/search/products/?search=" + searchedText;
      case "Services":
        return baseUrl + "/api/v1/search/services/?search=" + searchedText;
      default:
        return baseUrl + "/api/v1/search/users/?search=" + searchedText;
    }
  }

  void updateSearchResults(List searchedResults) {
    switch (filterValue) {
      case "Users":
        searchedResults.forEach((user) {
          setState(() {
            debugPrint("User : " + user.toString());
            results.add(getUserTile(user));
          });
        });
        break;
      case "Products":
        searchedResults.forEach((product) {
          setState(() {
            debugPrint("product : " + product.toString());
            results.add(getProductTile(product));
          });
        });
        break;
      case "Services":
        searchedResults.forEach((service) {
          setState(() {
            debugPrint("service : " + service.toString());
            results.add(getServiceTile(service));
          });
        });
        break;
    }
  }

  Widget getUserTile(var object) {
    _payee = CustomerProfile(
      avatar: object["avatar"],
      fullName: object["full_name"],
      qrCode: object["qr_code"],
      userName: object["username"],
    );

    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = CachedNetworkImage(
        imageUrl: object["avatar"],
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
      qrCodeImage = CachedNetworkImage(
        imageUrl: object["qr_code"],
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
    }

    Widget tile = Card(
      semanticContainer: true,
      child: ListTile(
        dense: true,
        title: Text(
          _payee.fullName,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(_payee.userName),
        leading: avatarImage,
        trailing: qrCodeImage,
      ),
    );

    return _getSlidableWithLists(context, tile);
  }

  Widget getProductTile(var object) {
    // Product product = _auth.createProduct(object);

    bool isOwner = false;
    if (object['seller'] == userBloc.user.userName) {
      isOwner = true;
    }
    return Container(
      height: 250,
      width: double.infinity,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    InkWell(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: object["seller_avatar"],
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/product',
                            arguments: {"product": ""});
                      },
                    ),
                    isOwner
                        ? Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: darkBlue(),
                              ),
                              onPressed: () {
                                //TODO: Navigate to the CurrentProduct
                                Navigator.of(context).pushNamed(
                                  '/edit-product',
                                  arguments: {
                                    "productId": "1",
                                  },
                                );
                              },
                            ),
                          )
                        : Container()
                  ]),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  title: Text(
                    object['name'].length > 11
                        ? object['name'].substring(0, 11)
                        : object['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    object['short_description'].length > 11
                        ? object['short_description'].substring(0, 11)
                        : object['short_description'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(worldCurrencies[object["currency"]] +
                      "${object['price']}" +
                      ""),
                ),
              ],
            ),
          )),
    );
  }

  Widget getServiceTile(var object) {
    bool isOwner = false;
    if (object['seller'] == userBloc.user.userName) {
      isOwner = true;
    }

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: object["provider_avatar"],
            height: 50,
            width: 50,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => object["provider_avatar"] == ""
                ? Icon(Icons.person)
                : CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
          ),
        ),
        title: Text(
          object["name"].length > 20
              ? object["name"].substring(0, 20)
              : object["name"],
          style: TextStyle(color: darkBlue(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          object["short_description"].length > 20
              ? object["short_description"].substring(0, 20)
              : object["short_description"],
        ),
        trailing: isOwner
            ? IconButton(
                icon: Icon(
                  Icons.edit,
                  color: darkBlue(),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/edit-service',
                    arguments: {
                      "serviceId": "1",
                    },
                  );
                },
              )
            : null,
        onTap: () {
          Navigator.of(context)
              .pushNamed('/service-detail', arguments: {"service": ""});
        },
      ),
    );
  }
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
