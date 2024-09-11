import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class UserServiceList extends StatefulWidget {
  CustomerProfile? user;
  bool isOwner;

  UserServiceList({super.key, required this.user, this.isOwner = false});

  @override
  State<UserServiceList> createState() => _UserServiceListState();
}

class _UserServiceListState extends State<UserServiceList> {
  final GlobalKey<ScaffoldState> _serviceScaffoldKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _serviceScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // this variable responsible for service pagination
  int? serviceCount = 0;
  String? serviceNext = "";
  String? servicePrevious = "";
  List<Service> serviceList = [];
  final ScrollController _serviceScrollController = ScrollController();
  final RefreshController _servicesRefreshController =
      RefreshController(initialRefresh: false);
  bool isServiceLoading = false;
  bool noServiceInList = false;

  void _onServiceRefresh() async {
    if (await checkConnection(context)) {
      serviceCount = 0;
      serviceNext = "";
      servicePrevious = "";
      serviceList = [];
      // debugPrint("Refresh called on Service!!  ");
      getServiceList();
      _servicesRefreshController.refreshCompleted();
    } else {
      setState(() {
        _servicesRefreshController.refreshCompleted();
      });
    }
  }

  @override
  void initState() {
    getServiceList();
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
    return ScaffoldMessenger(
      key: _serviceScaffoldMessengerKey,
      child: Scaffold(
        key: _serviceScaffoldKey,
        body: Container(
          color: lightGrey,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _servicesRefreshController,
            onRefresh: _onServiceRefresh,
            child: _buildList(),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (noServiceInList) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.noProducts,
      );
    } else {
      return ListView(
        children: [
          Container(child: _buildServiceList()),
          if (isServiceLoading)
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: greyBorderColor,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 180,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }
  }

  Widget _buildServiceList() {
    return serviceNext == "" && isServiceLoading
        ? const SizedBox.shrink()
        : CustomScrollView(
            physics: const ScrollPhysics(),
            controller: _serviceScrollController,
            shrinkWrap: true,
            slivers: <Widget>[
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(
                    child: DisplayService(
                      service: serviceList[i],
                      onServiceRefresh: () {
                        _onServiceRefresh();
                      },
                    ),
                  ),
                  childCount: serviceList.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 8,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    buildJumpingLoadingIndicator(isLoading: isServiceLoading),
              ),
            ],
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
        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listServicesByProvider(serviceNext, servicePrevious,
                userName: widget.user!.userName);
        if (result == null) {
          isServiceLoading = false;
          return;
        }

        final String? error = result['error'];
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
        final tempList = result['results'];
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
        _serviceScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
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
      return const SizedBox.shrink();
    }
  }
}
