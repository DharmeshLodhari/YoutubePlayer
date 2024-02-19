import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  late ShoppingDashboardBloc shoppingDashboardBloc;

  List<ShoppingProduct> products = [];
  bool isLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    products.clear();
    if (mounted) setState(() {});

    products = (await ShoppingAuthService().getProductList("", ""))!;

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    shoppingDashboardBloc = Provider.of<ShoppingDashboardBloc>(context);
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      backgroundColor: Colors.white,
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: isLoading
            ? Center(
                child: CircularLoadingIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: products
                        .map(
                          (product) => InkWell(
                            onTap: () {
                              ShoppingAuthService()
                                  .getProduct(product.id!)
                                  .then((value) {
                                Navigator.pushNamed(context, '/product',
                                    arguments: {"product": value});
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: ShoppingTileWithHeart(
                                  product: product,
                                )),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          shoppingDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "My wishlist",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
