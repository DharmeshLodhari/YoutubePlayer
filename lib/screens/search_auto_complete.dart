import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';

class SearchAutoComplete extends StatefulWidget {
  @override
  _SearchAutoCompleteState createState() => _SearchAutoCompleteState();
}

class _SearchAutoCompleteState extends State<SearchAutoComplete> {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  static var filterValue = "Users";
  String hint = "Search hear";
  Icon icon = Icon(
    Icons.supervised_user_circle,
    color: Colors.white,
    size: 28,
  );

  final _auth = AuthService();
  SlidableController slidableController;
  SlidableController slidableController1;

  List<Widget> results = [];

  // this variables are for the autocomplete
  bool loading = true;
  List<dynamic> users = List<dynamic>();
  GlobalKey<AutoCompleteTextFieldState<dynamic>> autoTextFieldKey = GlobalKey();
  TextEditingController autoCompleteTextController = TextEditingController();

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
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged1,
      onSlideIsOpenChanged: handleSlideIsOpenChanged1,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (next != null) {
          getList();
        }
      }
    });

    autoCompleteTextController.addListener(() {
      if (autoCompleteTextController.text.length >= 5) {
        autoCompleteSearchText = autoCompleteTextController.text;
        getAutoCompleteUser();
      }
      if (results.isNotEmpty || autoCompleteTextController.text.length != 0) {
        setState(() {
          isSearchIsEmpty = false;
        });
      }
    });

    super.initState();
  }

  void popUpMenu() {
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
    setState(() {
      autoCompleteTextController.text = "";
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

  void onDismiss() {}

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;

    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
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
            getSearchUrl(autoCompleteTextController.text), next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
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
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          getList();
        });
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
          caption: "BUY",
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

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void handleSlideAnimationChanged1(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged1(bool isOpen) {}

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
      children: <Widget>[
        Text(
          worldCurrencies[product.currency] + ' ' + product.price.toString(),
          style: TextStyle(
              fontFamily: "Roboto",
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        Text(
          ' ' + product.price.toString(),
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
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
          ),
        ),
        title: Text(
          object["name"],
          maxLines: 1,
          style: TextStyle(color: darkBlue(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          object["short_description"],
          maxLines: 1,
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
    debugPrint("getAutoComplete called!!");
    try {
      setState(() {
        results = [];
      });

      String url = getSearchUrl(autoCompleteSearchText);
      var result = await _auth.searchEndpoint(url);

      next = result['next'];
      count = result['count'];
      previous = result['previous'];
      var data = result['results'];

      loadUsers(data);
      debugPrint("length of the items : " + data.length.toString());
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void loadUsers(List data) {
    switch (filterValue) {
      case "Users":
        data.forEach((item) {
          setState(() {
            if (data.isNotEmpty) {
              noItemInList = false;
            }
            results.add(getUserTile(item));
          });
        });
        break;
      case "Products":
        data.forEach((item) {
          setState(() {
            if (data.isNotEmpty) {
              noItemInList = false;
            }
            results.add(getProductTile(item));
          });
        });
        break;
      case "Services":
        data.forEach((item) {
          setState(() {
            if (data.isNotEmpty) {
              noItemInList = false;
            }
            results.add(getServiceTile(item));
          });
        });
        break;
    }
  }

  Widget autoComplete() {
    return AutoCompleteTextField<dynamic>(
      controller: autoCompleteTextController,
      textSubmitted: (val) {
        if (next != null) {
          setState(() {
            count = 0;
            next = "";
            previous = "";
            results = [];
          });
          getList();
        }
      },
      key: autoTextFieldKey,
      suggestions: users,
      clearOnSubmit: true,
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

      // ignore: missing_return
      itemFilter: (item, query) {
        switch (filterValue) {
          case "Users":
            return item.userName.toLowerCase().startsWith(query.toLowerCase());
            break;
          case "Products":
            return item.name.toLowerCase().startsWith(query.toLowerCase());
            break;
          case "Services":
            return item.name.toLowerCase().startsWith(query.toLowerCase());
            break;
        }
      },
      // ignore: missing_return
      itemSorter: (a, b) {
        switch (filterValue) {
          case "Users":
            return a.userName.compareTo(b.userName);
            break;
          case "Products":
            return a.name.compareTo(b.name);
            break;
          case "Services":
            return a.name.compareTo(b.name);
            break;
        }
      },
      // ignore: missing_return
      itemBuilder: (context, item) {
        switch (filterValue) {
          case "Users":
            return getUserTile(item);
            break;
          case "Products":
            return getProductTile(item);
            break;
          case "Services":
            return getServiceTile(item);
            break;
        }
      },
      itemSubmitted: (item) {},
    );
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
