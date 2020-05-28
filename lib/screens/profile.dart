import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  var arguments;
  Profile({@required this.arguments});
  @override
  _ProfileState createState() => _ProfileState(arguments: arguments);
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  var arguments;
  _ProfileState({this.arguments});
  TabController _tabController;
  int currentIndex = 0;
  CustomerProfile user;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;
  double top;

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
        getProductList();
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
    user = arguments['searchedUser'];
    debugPrint(user.fullName);
    debugPrint(user.userName);
    debugPrint(user.qrCode);
    debugPrint(user.avatar);

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

    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    if (userBloc.user.userName == user.userName) {
      isOwner = true;
    }

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, i) {
            return [
              SliverAppBar(
                  backgroundColor: darkBlue(),
                  pinned: true,
                  expandedHeight: 220.0,
                  actions: actionButtons(),
                  title: Text(user.userName),
                  titleSpacing: 0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(user.fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          )),
                      background: Image.network(
                        user.avatar,
                        fit: BoxFit.cover,
                      ))),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    tabs: [
                      Material(
                          color: darkBlue(),
                          child: Container(
                              child: Center(
                                  child: Text(
                            AppLocalization.of(context).products,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )))),
                      Material(
                          color: darkBlue(),
                          child: Container(
                              child: Center(
                                  child: Text(
                            AppLocalization.of(context).services,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )))),
                    ],
                  ),
                ),
                pinned: false,
              ),
            ];
          },
          body: tabViews()),
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
                  'recipient': user.userName,
                  'subject': "",
                });
              },
            )
          : Container()
    ];
  }

  Widget tabBar() {
    return TabBar(
      indicatorColor: Colors.white,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      controller: _tabController,
      tabs: <Widget>[
        Material(
            color: Colors.transparent,
            child: Container(
                height: 35,
                child: Center(
                    child: Text(
                  AppLocalization.of(context).products,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )))),
        Material(
            color: Colors.transparent,
            child: Container(
                height: 35,
                child: Center(
                    child: Text(
                  AppLocalization.of(context).services,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )))),
      ],
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
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
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
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
                                          color: darkBlue(),
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
                                productList[index].name,
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                productList[index].shortDescription,
                                maxLines: 1,
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
                                          fontFamily: "Roboto",
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
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
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
            userId: user.userName);
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
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
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
                return serviceTile(index);
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
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
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
            userId: user.userName);
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

  Widget serviceTile(int index) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: serviceList[index].serverImages[0],
            height: 50,
            width: 50,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => user.avatar == ""
                ? Icon(Icons.person)
                : CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
          ),
        ),
        title: Text(
          serviceList[index].name,
          maxLines: 1,
          style: TextStyle(color: darkBlue(), fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          serviceList[index].shortDescription,
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
                      "serviceId": serviceList[index].id,
                    },
                  );
                },
              )
            : null,
        onTap: () {
          Navigator.of(context).pushNamed('/service-detail',
              arguments: {"service": serviceList[index]});
        },
      ),
    );
  }

  String getDisplayImage(int index, List<Product> productList) {
    return productList[index].serverImages[0];
  }

  @override
  void dispose() {
    _productScrollController.dispose();
    _productsRefreshController.dispose();
    _servicesRefreshController.dispose();
    _servicesRefreshController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: darkBlue(),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
