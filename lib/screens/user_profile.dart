import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/user_info.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class UserProfile extends StatefulWidget {
  var arguments;
  UserProfile({@required this.arguments});
  @override
  _UserProfileState createState() => _UserProfileState(arguments: arguments);
}

class _UserProfileState extends State<UserProfile> {
  var arguments;
  _UserProfileState({this.arguments});
  int currentIndex = 0;
  CustomerProfile searchedUser;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;
  double top;

  //popupmenu variables
  PopupMenu popUpMenuWidget;
  GlobalKey popupMenuBtnKeyForMenu = GlobalKey();
  var filterValue = "Info";

  //for refresh controller
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _serviceScaffoldKey =
      new GlobalKey<ScaffoldState>();

  final _auth = AuthService();

  // this variable responsible for product pagination
  int productCount = 0;
  String productNext = "";
  String productPrevious = "";
  List<Product> productList = [];
  ScrollController _productScrollController = new ScrollController();
  RefreshController _productsRefreshController =
      RefreshController(initialRefresh: false);
  bool isProductLoading = false;
  bool noProductInList = false;

  // this variable responsible for service pagination
  int serviceCount = 0;
  String serviceNext = "";
  String servicePrevious = "";
  List<Service> serviceList = [];
  ScrollController _serviceScrollController = new ScrollController();
  RefreshController _servicesRefreshController =
      RefreshController(initialRefresh: false);
  bool isServiceLoading = false;
  bool noServiceInList = false;

  void _onProductRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        productCount = 0;
        productNext = "";
        productPrevious = "";
        productList = [];
        debugPrint("Refresh called on products!!  ");
        getProductList();
        _productsRefreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _productsRefreshController.refreshCompleted();
      }
    });
  }

  void _onServiceRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        serviceCount = 0;
        serviceNext = "";
        servicePrevious = "";
        serviceList = [];
        debugPrint("Refresh called on Service!!  ");
        getServiceList();
        _servicesRefreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _servicesRefreshController.refreshCompleted();
      }
    });
  }

  @override
  void initState() {
    searchedUser = arguments['searchedUser'];
    debugPrint(searchedUser.fullName);
    debugPrint(searchedUser.userName);
    debugPrint(searchedUser.qrCode);
    debugPrint(searchedUser.avatar);

    this.getProductList();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent) {
        getProductList();
      }
    });

    this.getServiceList();
    _serviceScrollController.addListener(() {
      if (_serviceScrollController.position.pixels ==
          _serviceScrollController.position.maxScrollExtent) {
        getServiceList();
      }
    });

    super.initState();
  }

  void popUpMenu() {
    popUpMenuWidget = PopupMenu(
      items: getMenuItems(),
      onClickMenu: onClickMenu,
      onDismiss: onDismiss,
      maxColumn: 4,
    );
    popUpMenuWidget.show(widgetKey: popupMenuBtnKeyForMenu);
  }

  List<MenuItem> getMenuItems() {
    var menuItems = [
      MenuItem(
          textStyle: filterValue == 'Info'
              ? TextStyle(color: lightBlue(), fontSize: 10)
              : TextStyle(color: Colors.white, fontSize: 10),
          title: "Info",
          image: Icon(
            Icons.computer,
            color: filterValue == 'Info' ? lightBlue() : Colors.white,
          )),
    ];

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
        filterValue = item.menuTitle;
        if (filterValue == "Info") {
          currentIndex = 0;
        } else if (filterValue == "Products") {
          currentIndex = 1;
        } else if (filterValue == "Services") {
          currentIndex = 2;
        }
      });
    }
  }

  void onDismiss() {
    debugPrint('Menu is dismiss');
  }

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    userBloc = Provider.of<UserBloc>(context);

    if (userBloc.user.userName == searchedUser.userName) {
      isOwner = true;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, '/dashboard',
            arguments: {'dashboardIndex': 5});
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          titleSpacing: 0,
          title: Row(
            children: <Widget>[
              ClipOval(
                child: Container(
                  height: 40,
                  width: 40,
                  child: CachedNetworkImage(
                    imageUrl: searchedUser.avatar,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 10,
                ),
              ),
              Text(searchedUser.fullName),
              Expanded(
                child: SizedBox(
                  width: 10,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Toast.show(
                  "Coming Soon !!",
                  context,
                  gravity: Toast.BOTTOM,
                  duration: Toast.LENGTH_LONG,
                  backgroundColor: darkBlue(),
                  textColor: Colors.white,
                );
              },
            ),
            IconButton(
              key: popupMenuBtnKeyForMenu,
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
        body: tabViews(),
      ),
    );
  }

  List<Widget> actionButtons() {
    return [
      !isOwner
          ? IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          : Container(),
      !isOwner
          ? IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/compose_message', arguments: {
                  'recipient': searchedUser.userName,
                  'subject': "",
                });
              },
            )
          : Container()
    ];
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        UserInfo(user: searchedUser),
        productsList(),
        servicesList(),
      ],
    );
  }

  Widget productsList() {
    return Scaffold(
      key: _productScaffoldKey,
      body: Container(
        color: lightBlue(),
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: darkBlue(),
            ),
            controller: _productsRefreshController,
            onRefresh: _onProductRefresh,
            child: _buildProductList()),
      ),
    );
  }

  Widget _buildProductList() {
    return noProductInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noProducts,
          )
        : StaggeredGridView.countBuilder(
            controller: _productScrollController,
            crossAxisCount: 2,
            shrinkWrap: true,
            itemCount: productList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == productList.length) {
                return _buildProductIndicator();
              } else {
                return Card(
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
                                  imageUrl: getDisplayImage(index, productList),
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/product',
                                      arguments: {
                                        "product": productList[index]
                                      });
                                },
                              ),
                              isOwner
                                  ? Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                            '/edit-product',
                                            arguments: {
                                              "productId": productList[index]
                                                  .id
                                                  .toString(),
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  : Container()
                            ]),
                          ),
                          ListTile(
                              dense: true,
                              title: Text(
                                productList[index].name.length > 35
                                    ? productList[index].name.substring(0, 35)
                                    : productList[index].name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                productList[index].shortDescription.length > 35
                                    ? productList[index]
                                        .shortDescription
                                        .substring(0, 35)
                                    : productList[index].shortDescription,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: worldCurrencies[
                                          productList[index].currency],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  TextSpan(text: " "),
                                  TextSpan(
                                      text: productList[index].price.toString(),
                                      style: TextStyle(color: Colors.black))
                                ]),
                              )),
                        ],
                      ),
                    ));
              }
            },
            staggeredTileBuilder: (int index) =>
                new StaggeredTile.count(2, 1.5),
          );
  }

  Widget _buildProductIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isProductLoading ? 1.0 : 00,
            child: isProductLoading
                ? new CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : Container()),
      ),
    );
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        setState(() {
          isProductLoading = true;
        });
        Map<String, dynamic> result = await _auth.listProductsBySeller(
            productNext, productPrevious,
            userId: searchedUser.userName);
        productCount = result['count'];
        productNext = result['next'];
        productPrevious = result['previous'];
        var tempList = result['results'];
        setState(() {
          noProductInList = false;
          isProductLoading = false;
          productList.addAll(tempList);
        });
      }
      if (productList.isEmpty) {
        setState(() {
          noProductInList = true;
        });
      } else if (productNext == null && productList.length > 6) {
        _productScaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      setState(() {
        isProductLoading = false;
        getProductList();
      });
    }
  }

  Widget servicesList() {
    return Scaffold(
      key: _serviceScaffoldKey,
      body: Container(
        color: lightBlue(),
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: darkBlue(),
            ),
            controller: _servicesRefreshController,
            onRefresh: _onServiceRefresh,
            child: _buildServiceList()),
      ),
    );
  }

  Widget _buildServiceList() {
    return noServiceInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noServices,
          )
        : ListView.builder(
            controller: _serviceScrollController,
            itemCount: serviceList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == serviceList.length) {
                return _buildServiceIndicator();
              } else {
                return serviceTileExpanded(index);
              }
            });
  }

  Widget _buildServiceIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isServiceLoading ? 1.0 : 00,
            child: isServiceLoading
                ? new CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : Container()),
      ),
    );
  }

  void getServiceList() async {
    if (!isServiceLoading) {
      if (serviceNext != null && !isServiceLoading) {
        setState(() {
          isServiceLoading = true;
        });
        Map<String, dynamic> result = await _auth.listServicesByProvider(
            serviceNext, servicePrevious,
            userId: searchedUser.userName);
        serviceCount = result['count'];
        serviceNext = result['next'];
        servicePrevious = result['previous'];
        var tempList = result['results'];
        setState(() {
          noServiceInList = false;
          isServiceLoading = false;
          serviceList.addAll(tempList);
        });
      }
      if (serviceList.isEmpty) {
        setState(() {
          noServiceInList = true;
        });
      } else if (serviceNext == null && serviceList.length > 6) {
        _serviceScaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      setState(() {
        isServiceLoading = false;
        getServiceList();
      });
    }
  }

  Widget serviceTileExpanded(int index) {
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    InkWell(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: serviceList[index].serverImages[0],
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/service-detail',
                            arguments: {"service": serviceList[index]});
                      },
                    ),
                    isOwner
                        ? Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/edit-service',
                                  arguments: {
                                    "serviceId":
                                        serviceList[index].id.toString(),
                                  },
                                );
                              },
                            ),
                          )
                        : Container()
                  ]),
                ),
                ListTile(
                    dense: true,
                    title: Text(
                      serviceList[index].name.length > 35
                          ? serviceList[index].name.substring(0, 35)
                          : serviceList[index].name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      serviceList[index].shortDescription.length > 35
                          ? serviceList[index].shortDescription.substring(0, 35)
                          : serviceList[index].shortDescription,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: worldCurrencies[serviceList[index].currency],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        TextSpan(text: " "),
                        TextSpan(
                            text: serviceList[index].price.toString(),
                            style: TextStyle(color: Colors.black))
                      ]),
                    )),
              ],
            ),
          ),
        ));
  }

  String getDisplayImage(int index, List<Product> productList) {
    return productList[index].serverImages[0];
  }
}
