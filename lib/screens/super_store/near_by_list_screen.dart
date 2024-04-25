import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../locale/app_localization.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../../widget/no_item_in_list.dart';
import '../more_apps/shopping/shopping_auth.dart';
import '../more_apps/user_profile/models/user.dart';
import '../more_apps/yarn/utils/yarn_enum.dart';

class NearByListScreen extends StatefulWidget {
  final dynamic arguments;

  NearByListScreen({this.arguments, Key? key}) : super(key: key);

  @override
  State<NearByListScreen> createState() => _NearByListScreenState();
}

class _NearByListScreenState extends State<NearByListScreen> {
  List<CustomerProfile> customerProfileList = [];
  bool isNearbyLoading = false;
  bool noNearByInList = false;
  int? nearByCount = 0;
  String? nearByNext = "";
  String? nearByPrevious = "";

  final GlobalKey<ScaffoldMessengerState> _findBusinessScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ScrollController _scrollController = ScrollController();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    customerProfileList = widget.arguments["customerProfile"];
    nearByNext = widget.arguments["next"];
    nearByCount = widget.arguments["count"];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getNearByBusinessList();
      }
    });
    super.initState();
  }

  void getNearByBusinessList() async {
    if (!isNearbyLoading) {
      if (nearByNext != null && !isNearbyLoading) {
        isNearbyLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(nearByNext, nearByPrevious, '', nearBy: true);

        if (result == null) {
          noNearByInList = true;

          isNearbyLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        nearByCount = result['count'];
        nearByNext = result['next'];
        nearByPrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noNearByInList = false;
            isNearbyLoading = false;
            customerProfileList.addAll(tempList);
          });
        }
      }
      if (customerProfileList.isEmpty) {
        if (mounted) {
          setState(() {
            noNearByInList = true;
          });
        }
      } else if (nearByNext == null && customerProfileList.length > 6) {
        _findBusinessScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: yarnBlack,
        ),
        controller: refreshController,
        onRefresh: onRefresh,
        child: _buildListView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Text(
          'NearBy Business',
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 21,
            fontFamily: "Inter",
            fontWeight: FontWeight.w700,
            color: yarnBlack,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: yarnBlack,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildListView() {
    return !isNearbyLoading && customerProfileList.isEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
          )
        : ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            controller: _scrollController,
            itemCount: customerProfileList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == customerProfileList.length) {
                return buildShimmerLoadingIndicator(isLoading: isNearbyLoading);
              }

              return Container(
                margin: const EdgeInsets.all(10.0),
                child: FindBusiness(
                  customerProfile: customerProfileList[index],
                  tileRenderPlace: TileRenderPlace.YarnTimeLine,
                  callback: (username, value) {
                    //create a list to edit
                    final List<CustomerProfile> customerProfileListEdit =
                        customerProfileList;

                    // modify customerProfileList for the username and refresh the list
                    // set the isFollowing for that particular user
                    customerProfileListEdit.forEach((customer) {
                      if (customer.userName == username) {
                        customer.isFollowing =
                            value; // Modify the isFollowing property
                      }
                    });

                    customerProfileList = [];
                    customerProfileList = customerProfileListEdit;

                    if (mounted) setState(() {});
                  },
                ),
              );
            }
            //   separatorBuilder: (context, int) {
            //     return Column(
            //       children: [
            //         const SizedBox(
            //           height: 20,
            //         ),
            //         Divider(
            //           height: 0,
            //           thickness: 0.5,
            //           color: greySecondaryYarn,
            //         ),
            //       ],
            //     );
            //   },
            );
  }

  void onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        nearByCount = 0;
        nearByNext = "";
        nearByPrevious = "";
        customerProfileList = [];
        if (mounted) setState(() {});

        getNearByBusinessList();
        setState(() {
          refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          refreshController.refreshCompleted();
        });
      }
    });
  }
}
