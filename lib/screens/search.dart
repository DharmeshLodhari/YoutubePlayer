import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/auto_complete.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';

final List<dynamic> services = [];

class SearchAll extends StatefulWidget {
  @override
  _SearchAllState createState() => _SearchAllState();
}

class _SearchAllState extends State<SearchAll> {
  bool isValidSearch = false;
  TextEditingController searchController;
  String searchedText = "";
  FocusNode searchFocus = FocusNode();
  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  static var filterValue = "Users";
  String hint = "Find Users";

  final _auth = AuthService();
  SlidableController slidableController;
  List<Widget> results = [];

  // this variables are for the autocomplete
  bool loading = true;
  List<SearchedUser> users = List<SearchedUser>();
  AutoCompleteTextField searchedAutoCompleteTextField;
  GlobalKey<AutoCompleteTextFieldState<SearchedUser>> autoTextFieldKey =
      GlobalKey();

  //popupmenu variables
  PopupMenu menu;
  GlobalKey popupMenuBtnKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldSearchKey;

  //pagination variables
  int count = 0;
  String next = "";
  String previous = "";
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    getAutoCompleteUser();
    searchController = TextEditingController();

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getList();
      }
    });

    super.initState();
  }

  void popupmenu() {
    menu = PopupMenu(
      items: getMenuItems(),
      onClickMenu: onClickMenu,
      onDismiss: onDismiss,
      maxColumn: 4,
    );
    menu.show(widgetKey: popupMenuBtnKey);
  }

  List<MenuItem> getMenuItems() {
    var menuItems = [
      MenuItem(
          textStyle: filterValue == 'Users'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: 'Users',
          image: Icon(
            Icons.supervised_user_circle,
            color: filterValue == 'Users' ? lightBlue() : Colors.white,
          )),
    ];

    if (userBloc.user.setting.enableProduct) {
      menuItems.add(
        MenuItem(
            textStyle: filterValue == 'Products'
                ? TextStyle(color: lightBlue(), fontSize: 10)
                : TextStyle(color: Colors.white, fontSize: 10),
            title: 'Products',
            image: Icon(
              Icons.computer,
              color: filterValue == 'Products' ? lightBlue() : Colors.white,
            )),
      );
    }
    if (userBloc.user.setting.enableService) {
      menuItems.add(
        MenuItem(
            textStyle: filterValue == 'Services'
                ? TextStyle(color: lightBlue(), fontSize: 10)
                : TextStyle(color: Colors.white, fontSize: 10),
            title: 'Services',
            image: Icon(
              Icons.burst_mode,
              color: filterValue == 'Services' ? lightBlue() : Colors.white,
            )),
      );
    }
    return menuItems;
  }

  void stateChanged(bool isShow) {
    debugPrint('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    setState(() {
      searchController.text = "";
      searchedText = "";
      count = 0;
      next = "";
      previous = "";
      results.clear();
      noItemInList = false;
      filterValue = item.menuTitle;
      hint = "Find $filterValue";
    });
  }

  void onDismiss() {
    debugPrint('Menu is dismiss');
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldSearchKey = GlobalKey<ScaffoldState>();
    PopupMenu.context = context;

    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldSearchKey,
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 4,
                ),
              ),
              Expanded(flex: 7, child: search()),
            ],
          ),
          actions: <Widget>[
            IconButton(
              key: popupMenuBtnKey,
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
                popupmenu();
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildResultList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultList() {
    return noItemInList
        ? NoItemInList(
            msg: "Sorry No $filterValue found",
          )
        : ListView.builder(
            //+1 for progressbar
            itemCount: results.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == results.length) {
                return _buildIndicator();
              } else {
                return results[index];
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        setState(() {
          isLoading = true;
        });
        Map<String, dynamic> result = await _auth.searchEndpointPagination(
            getSearchUrl(searchedText), next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
        setState(() {
          isLoading = false;
          tempList.forEach((result) {
            results.add(getResultTile(result));
          });
        });
      }
      if (results.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && results.length > 6) {
        _scaffoldSearchKey.currentState.showSnackBar(SnackBar(
          content: Text("Your have reached the end of the list"),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      setState(() {
        isLoading = false;
        getList();
      });
    }
  }

  // ignore: missing_return
  Widget getResultTile(var result) {
    switch (filterValue) {
      case "Users":
        return getUserTile(result);
        break;
      case "Products":
        return getProductTile(result);
        break;
      case "Services":
        return getServiceTile(result);
        break;
    }
  }

  Widget search() {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(fontSize: 15),
      textInputAction: TextInputAction.search,
      focusNode: searchFocus,
      controller: searchController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        hintText: hint,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darkBlue(),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      onFieldSubmitted: (val) async {
        count = 0;
        next = "";
        previous = "";
        results = [];
        getList();
      },
      onChanged: (value) {
        searchedText = value;
      },
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget searchCard, CustomerProfile user) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(searchCard, user),
      actions: listActionSlideActions(user),
      secondaryActions: listSecondaryActions(user),
    );
  }

  List<Widget> listSecondaryActions(CustomerProfile user) {
    String caption = 'Send';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.green,
          icon: Icons.send,
          onTap: () async {
            customerProfileBloc.customer =
                await _auth.fetchCustomerProfile(user.userName);
            Navigator.of(context).pushNamed('/send-payment',
                arguments: <String, bool>{
                  'isFromProfile': false,
                  'isRequest': false
                });
          }),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user) {
    return [
      IconSlideAction(
        caption: 'Request',
        color: Colors.green,
        icon: Icons.event_note,
        onTap: () async {
          customerProfileBloc.customer =
              await _auth.fetchCustomerProfile(user.userName);
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

  Widget getUserTile(var object) {
    var user = CustomerProfile(
        avatar: object["avatar"],
        fullName: object["full_name"],
        qrCode: object["qr_code"],
        userName: object["username"],
        type: object['type'] ?? 'user');

    var avatarImage = CachedNetworkImage(
      imageUrl: user.avatar,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.high,
    );

    Widget tile = Card(
      semanticContainer: true,
      child: ListTile(
        dense: true,
        title: Text(
          user.fullName,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(user.userName),
        leading: avatarImage,
      ),
    );

    return _getSlidableWithLists(context, tile, user);
  }

  Widget getProductTile(var object) {
    Product product = Product();
    product.name = object['name'];
    product.id = object['id'];
    product.shortDescription = object['short_description'];
    product.description = "";
    product.condition = object['condition'];
    product.currency = object['currency'];
    product.price = object['price'].toString();
    product.availableFrom = DateTime.parse(object['available_from']);
    product.isAvailable = object['is_available'];
    product.qrCode = object['qr_code'];
    product.seller = object['seller'];
    product.manufacturer = object['manufacturer'];
    product.serverImages = [];

    bool isOwner = false;
    if (object['seller'] == userBloc.user.userName) {
      isOwner = true;
    }
    return Container(
      height: 50,
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
                        imageUrl: object["cover"],
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/product',
                            arguments: {"product": product});
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
                                Navigator.of(context).pushNamed(
                                  '/edit-product',
                                  arguments: {
                                    "productId": product.id,
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
                      object['name'].length > 30
                          ? object['name'].substring(0, 30)
                          : object['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      object['short_description'].length > 30
                          ? object['short_description'].substring(0, 30)
                          : object['short_description'],
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: worldCurrencies[object["currency"]],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        TextSpan(text: " "),
                        TextSpan(
                            text: object['price'].toString(),
                            style: TextStyle(color: Colors.black))
                      ]),
                    )),
              ],
            ),
          )),
    );
  }

  Widget getServiceTile(var object) {
    Service service = Service();
    service.name = object['name'];
    service.id = object['id'];
    service.shortDescription = object['short_description'];
    service.currency = object['currency'];
    service.price = object['price'].toString();
    service.isAvailable = object['is_available'];
    service.qrCode = object['qr_code'];
    service.provider = object['provider'];
    service.serverImages = [];
    service.currency = "NGN";
    service.description = "";

    bool isOwner = false;
    if (object['provider'] == userBloc.user.userName) {
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
            imageUrl: object["cover"],
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
                      "serviceId": service.id,
                    },
                  );
                },
              )
            : null,
        onTap: () {
          Navigator.of(context)
              .pushNamed('/service-detail', arguments: {"service": service});
        },
      ),
    );
  }

  void getAutoCompleteUser() async {
    try {
      final response =
          await http.get("https://jsonplaceholder.typicode.com/users");
      if (response.statusCode == 200) {
        users = loadUsers(response.body);
        debugPrint("length of the user : " + users.length.toString());
        setState(() {
          loading = false;
        });
      } else {
        debugPrint("error in getting user.");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  static List<SearchedUser> loadUsers(String jsonString) {
    final parsed = json.decode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<SearchedUser>((json) => SearchedUser.fromJson(json))
        .toList();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child, this.user);
  final Widget child;
  CustomerProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (user.type != 'user') {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": user});
        }
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
