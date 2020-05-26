import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';

class SearchModule extends StatefulWidget {
  @override
  _SearchModuleState createState() => _SearchModuleState();
}

class _SearchModuleState extends State<SearchModule> {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  static var filterValue = "Users";
  static String hint = "Find Users";
  static Icon icon = Icon(
    Icons.supervised_user_circle,
    color: Colors.white,
    size: 28,
  );

  final _auth = AuthService();
  SlidableController slidableController;
  SlidableController slidableController1;
  SlidableController slidableController2;

  List<Widget> results = [];

  GlobalKey textFormField = GlobalKey();
  TextEditingController searchItemTextController = TextEditingController();

  //popupmenu variables
  PopupMenu menu;
  GlobalKey popupMenuBtnKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();

  //pagination variables
  int count = 0;
  String next = "";
  String previous = "";
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    slidableController1 = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged1,
      onSlideIsOpenChanged: handleSlideIsOpenChanged1,
    );
    slidableController2 = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged2,
      onSlideIsOpenChanged: handleSlideIsOpenChanged2,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (next != null) {
          getList();
        }
      }
    });

    searchItemTextController.addListener(() {
      if (searchItemTextController.text.length >= 5) {
        autoCompleteSearchText = searchItemTextController.text;

        setState(() {
          count = 0;
          next = "";
          previous = "";
          results.clear();
          noItemInList = false;
          debugPrint("count = $count");
          debugPrint("next = $next");
          debugPrint("previous = $previous");
          debugPrint("results = $results");
          getList();
        });
      }
      if (results.isNotEmpty || searchItemTextController.text.length != 0) {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = true;
          });
        }
      }
    });

    super.initState();
  }

  void popUpMenu() {
    menu = PopupMenu(
      items: getMenuItems(),
      onClickMenu: onClickMenu,
      onDismiss: onDismiss,
      context: context,
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
          title: AppLocalization.of(context).users,
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
            title: AppLocalization.of(context).products,
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
            title: AppLocalization.of(context).services,
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
    if (mounted) {
      setState(() {
        searchItemTextController.text = "";
        count = 0;
        next = "";
        previous = "";
        results.clear();
        noItemInList = false;
        filterValue = item.menuTitle;
        hint = AppLocalization.of(context).find + " $filterValue";
        if (filterValue == "Users") {
          icon = Icon(
            Icons.supervised_user_circle,
            color: Colors.white,
            size: 28,
          );
        } else if (filterValue == "Products") {
          icon = Icon(
            Icons.computer,
            color: Colors.white,
            size: 28,
          );
        } else if (filterValue == "Services") {
          icon = Icon(
            Icons.burst_mode,
            color: Colors.white,
            size: 28,
          );
        }
      });
    }
  }

  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldSearchKey,
      backgroundColor: lightBlue(),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: darkBlue(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(child: autoComplete()),
          ],
        ),
        automaticallyImplyLeading: true,
        leading: icon,
        actions: <Widget>[
          IconButton(
            key: popupMenuBtnKey,
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {
              popUpMenu();
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
    );
  }

  Widget _buildResultList() {
    return isSearchIsEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context).pleaseTypeSomethingToGetResult,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context).noResultFound,
              )
            : ListView.builder(
                //+1 for progressbar
                itemCount: results.length + 1,
                // ignore: missing_return
                itemBuilder: (BuildContext context, int index) {
                  if (index == results.length) {
                    return _buildIndicator();
                  } else {
                    try {
                      return results[index];
                    } catch (error) {
                      debugPrint(error);
                    }
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
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
          ),
        ),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic> result = await _auth.searchEndpointPagination(
            getSearchUrl(searchItemTextController.text), next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
        debugPrint(
            "searchItemTextController.text = ${searchItemTextController.text}");
        debugPrint("count = $count");
        debugPrint("next = $next");
        debugPrint("previous = $previous");
        debugPrint("tempList = $tempList");
        if (mounted) {
          setState(() {
            isLoading = false;
            tempList.forEach((result) {
              results.add(getResultTile(result));
            });
          });
        }
      }
      if (results.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && results.length > 6) {
        _scaffoldSearchKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
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

    Widget avatarImage = Container(
        height: 50,
        width: 50,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : user.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          ),
        ));

    Widget tile = Card(
      semanticContainer: true,
      child: ListTile(
        dense: true,
        title: Text(
          user.fullName,
          maxLines: 1,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          user.userName,
          maxLines: 1,
        ),
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
    product.availableFrom =
        DateTime.parse(object['available_from']) ?? DateTime.now();
    product.isAvailable = object['is_available'];
    product.qrCode = object['qr_code'];
    product.seller = object['seller'];
    product.manufacturer = object['manufacturer'];
    product.serverImages = [];

    bool isOwner = false;
    if (object['seller'] == userBloc.user.userName) {
      isOwner = true;
    }

    return _getSlidableWithLists1(
        context, productCard(product, object), product);
  }

  Widget productCard(Product product, var object) {
    return Card(
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: getLeading(product, object),
                title: getTitle(product),
                trailing: product.price.toString().length > 6
                    ? null
                    : getTrailing(product),
                subtitle: getSubtitle(product),
                onTap: () {
                  Navigator.pushNamed(context, '/product',
                      arguments: {"product": product});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getLeading(Product product, var object) {
    var imageUrl = "";
    try {
      imageUrl = object["cover"] ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => imageUrl == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  Widget getTitle(Product product) {
    return Text(
      "${product.name}",
      maxLines: 1,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency] + ' ',
          style: TextStyle(
              fontFamily: "Roboto",
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        Text(
          product.price.toString(),
          style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }

  Widget getSubtitle(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${product.shortDescription}",
          maxLines: 1,
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          height: 2,
        ),
        product.price.toString().length > 6
            ? getTrailing(product)
            : Container(),
        getSellerName(product)
      ],
    );
  }

  Widget getSellerName(Product product) {
    return Row(
      children: <Widget>[
        Text(
          product.seller,
          maxLines: 1,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
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
    service.availableFrom = DateTime.now();

    bool isOwner = false;
    if (object['provider'] == userBloc.user.userName) {
      isOwner = true;
    }
    return _getSlidableWithLists2(
        context, getServiceCard(service, object), service);
  }

  Widget getServiceCard(Service service, var object) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        leading: getLeadingService(service, object),
        title: Text(
          object["name"],
          maxLines: 1,
          style: TextStyle(color: darkBlue(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          object["short_description"],
          maxLines: 1,
        ),
        trailing: service.price.toString().length > 6
            ? null
            : getTrailingService(service),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/service-detail', arguments: {"service": service});
        },
      ),
    );
  }

  Widget getLeadingService(Service service, var object) {
    var imageUrl = "";
    try {
      imageUrl = object["cover"] ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => imageUrl == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  Widget getTrailingService(Service service) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[service.currency] + ' ',
          style: TextStyle(
              fontFamily: "Roboto",
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        Text(
          service.price.toString(),
          style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }

  void loadUsers(List data) {
    switch (filterValue) {
      case "Users":
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getUserTile(item));
            });
          }
        });
        break;
      case "Products":
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getProductTile(item));
            });
          }
        });
        break;
      case "Services":
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getServiceTile(item));
            });
          }
        });
        break;
    }
  }

  Widget autoComplete() {
    return Column(
      children: <Widget>[
        TextFormField(
          key: textFormField,
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
          style: TextStyle(color: Colors.black, fontSize: 16),
          controller: searchItemTextController,
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                results.clear();
                noItemInList = false;
                getList();
              });
            }
          },
        ),
      ],
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
    String caption = AppLocalization.of(context).send;
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
        caption: AppLocalization.of(context).request,
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

  Widget _getSlidableWithLists1(
      BuildContext context, Widget searchCard, Product product) {
    return Slidable(
      controller: slidableController1,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem1(searchCard, product),
      actions: listActionSlideActions1(product),
      secondaryActions: listSecondaryActions1(product),
    );
  }

  List<Widget> listSecondaryActions1(Product product) {
    return [
      IconSlideAction(
        caption: "Message",
        color: Colors.green,
        icon: Icons.message,
        onTap: () async {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': product.seller,
            'subject': product.name,
          });
        },
      ),
    ];
  }

  List<Widget> listActionSlideActions1(Product product) {
    return [
      IconSlideAction(
          caption: AppLocalization.of(context).buy,
          color: Colors.green,
          icon: Icons.shopping_basket,
          onTap: () async {
            customerProfileBloc.customer =
                await _auth.fetchCustomerProfile(product.seller);
            Navigator.of(context).pushNamed('/send-payment', arguments: {
              'isFromProfile': false,
              'isRequest': false,
              'product': product
            });
          }),
    ];
  }

  Widget _getSlidableWithLists2(
      BuildContext context, Widget searchCard, Service service) {
    return Slidable(
      controller: slidableController2,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem2(searchCard, service),
      actions: listActionSlideActions2(service),
      secondaryActions: listSecondaryActions2(service),
    );
  }

  List<Widget> listSecondaryActions2(Service service) {
    return [
      IconSlideAction(
        caption: AppLocalization.of(context).message,
        color: Colors.green,
        icon: Icons.message,
        onTap: () async {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': service.provider,
            'subject': service.name,
          });
        },
      ),
    ];
  }

  List<Widget> listActionSlideActions2(Service service) {
    return [
      IconSlideAction(
          caption: AppLocalization.of(context).buy,
          color: Colors.green,
          icon: Icons.shopping_basket,
          onTap: () async {
            customerProfileBloc.customer =
                await _auth.fetchCustomerProfile(service.provider);
            Navigator.of(context).pushNamed('/send-payment', arguments: {
              'isFromProfile': false,
              'isRequest': false,
              'service': service
            });
          }),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void handleSlideAnimationChanged1(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged1(bool isOpen) {}

  void handleSlideAnimationChanged2(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged2(bool isOpen) {}
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
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUser": user});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem1 extends StatelessWidget {
  VerticalListItem1(this.child, this.product);
  final Widget child;
  Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product',
            arguments: {"product": product});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem2 extends StatelessWidget {
  VerticalListItem2(this.child, this.service);

  final Widget child;
  Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/service-detail',
            arguments: {"service": service});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
