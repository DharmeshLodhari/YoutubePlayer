import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class UserServiceList extends StatefulWidget {
  CustomerProfile? user;
  bool isOwner;

  UserServiceList({required this.user, this.isOwner = false});

  @override
  _UserServiceListState createState() => _UserServiceListState();
}

class _UserServiceListState extends State<UserServiceList> {
  final GlobalKey<ScaffoldState> _serviceScaffoldKey =
      new GlobalKey<ScaffoldState>();

  // this variable responsible for service pagination
  int? serviceCount = 0;
  String? serviceNext = "";
  String? servicePrevious = "";
  List<Service> serviceList = [];
  ScrollController _serviceScrollController = new ScrollController();
  RefreshController _servicesRefreshController =
      RefreshController(initialRefresh: false);
  bool isServiceLoading = false;
  bool noServiceInList = false;

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
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _servicesRefreshController.refreshCompleted();
      }
    });
  }

  @override
  void initState() {
    this.getServiceList();
    _serviceScrollController.addListener(() {
      if (_serviceScrollController.position.pixels ==
              _serviceScrollController.position.maxScrollExtent &&
          _serviceScrollController.position.pixels != 0) {
        getServiceList();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _serviceScaffoldKey,
      body: Container(
        color: lightGrey,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
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
            msg: AppLocalization.of(context)!.noServices,
          )
        : ListView.builder(
            itemCount: serviceList.length + 1,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            controller: _serviceScrollController,
            itemBuilder: (context, index) {
              if (index == serviceList.length) {
                return _buildServiceIndicator();
              } else {
                return serviceTile(index);
              }
            },
          );

    // StaggeredGridView.countBuilder(
    //   controller: _serviceScrollController,
    //   crossAxisCount: 2,
    //   shrinkWrap: true,
    //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    //   mainAxisSpacing: 20,
    //   itemCount: serviceList.length + 1,
    //   itemBuilder: (BuildContext context, int index) {
    //     if (index == serviceList.length) {
    //       return _buildServiceIndicator();
    //     } else {
    //       return serviceTile(index);
    //     }
    //   },
    //   staggeredTileBuilder: (int index) => new StaggeredTile.count(2, 1.2),
    // );
  }

  Widget _buildServiceIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isServiceLoading ? 1.0 : 00,
            child: isServiceLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  void getServiceList() async {
    if (!isServiceLoading) {
      if (serviceNext != null && !isServiceLoading) {
        if (mounted) {
          setState(() {
            isServiceLoading = true;
          });
        }
        Map<String, dynamic>? result = await ShoppingAuthService()
            .listServicesByProvider(serviceNext, servicePrevious,
                userName: widget.user!.userName);
        if (result == null) {
          isServiceLoading = false;
          return;
        }

        String? error = result['error'];
        if (error != null && error.toLowerCase().contains('review not found')) {
          noServiceInList = true;
          isServiceLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        serviceCount = result['count'];
        serviceNext = result['next'];
        servicePrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noServiceInList = false;
            isServiceLoading = false;
            serviceList.addAll(tempList);
          });
        }
      }
      if (serviceList.isEmpty) {
        if (mounted) {
          setState(() {
            noServiceInList = true;
          });
        }
      } else if (serviceNext == null && serviceList.length > 6) {
        _serviceScaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget serviceTile(int index) {
    return CustomBoxShadow(
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: DisplayService(
            service: serviceList[index],
            onServiceRefresh: () {
              _onServiceRefresh();
            },
          ),
        ),
      ),
    );

    Widget getOutOfStockTag(int index) {
      if (!serviceList[index].isAvailable!) {
        if (widget.isOwner) {
          return Positioned(
            left: 38,
            top: 24,
            child: getColoredLabeledWidget(
                text: AppLocalization.of(context)!.outOfStock,
                color: starYellow),
          );
        } else {
          return Positioned(
            left: 8,
            top: 20,
            child: getColoredLabeledWidget(
                text: AppLocalization.of(context)!.outOfStock,
                color: starYellow),
          );
        }
      }
      return SizedBox.shrink();
    }
  }
}
