import 'package:Slydo/locale/app_localization.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/state_notifier.dart';
import '../../routes/route_constants.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../../widget/noItemInList.dart';
import '../more_apps/shopping/shopping_auth.dart';
import '../more_apps/user_profile/models/user.dart';
import '../more_apps/yarn/utils/yarn_enum.dart';
import '../more_apps/yarn/widgets/yarn_shimmer.dart';

class FindBusinessListScreen extends StatefulWidget {
  Function(bool)? onPageRefresh;
  String? category;

  FindBusinessListScreen({Key? key, this.onPageRefresh, this.category}) : super(key: key);

  @override
  State<FindBusinessListScreen> createState() => FindBusinessListScreenState();
}

class FindBusinessListScreenState extends State<FindBusinessListScreen> {

  List<CustomerProfile> customerProfileList = [];
  List<CustomerProfile> customerProfileListNearBy = [];
  bool isFindBusinessLoading = false;
  bool isNearbyLoading = false;
  bool noFindBusinessInList = false;
  bool noNearByInList = false;
  int? findBusinessCount = 0;
  String? findBusinessNext = "";
  String? findBusinessPrevious = "";
  int? nearByCount = 0;
  String? nearByNext = "";
  String? nearByPrevious = "";
  late DashboardBloc _dashboardBloc;

  final GlobalKey<ScaffoldMessengerState> _findBusinessScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  ScrollController scrollController = ScrollController();
  String _currentCategory = '';
  // Define a boolean variable to track if the app bar is expanded or not
  bool _isAppBarExpanded = true;


  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category!;
    getNearByBusinessList();
    getSuggestionBusinessList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getSuggestionBusinessList();
      }
    });
    // Listen for scroll offset changes
    scrollController.addListener(() {
      if (scrollController.offset > 0 && _isAppBarExpanded) {
        // App bar is not expanded
        setState(() {
          _isAppBarExpanded = false;
        });
      } else if (scrollController.offset <= 0 && !_isAppBarExpanded) {
        // App bar is expanded
        setState(() {
          _isAppBarExpanded = true;
        });
      }
    });

  }

  @override
  void didUpdateWidget(FindBusinessListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != _currentCategory) {
      _currentCategory = widget.category!;
      if (mounted) {
        setState(() {});
      }
      _refreshPage(); // Reload find business list when category changes
    }
  }

  void getNearByBusinessList() async {
    if (!isNearbyLoading) {
      if (nearByNext != null && !isNearbyLoading) {
        isNearbyLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(nearByNext, nearByPrevious, _currentCategory, nearBy: true);

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
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noNearByInList = false;
            isNearbyLoading = false;
            customerProfileListNearBy.addAll(tempList);
          });
        }

        // for(var item in customerProfileListNearBy){
        //   debugPrint('Fola near by:::: ${item.toJson()}');
        // }

      }
      if (customerProfileListNearBy.isEmpty) {
        if (mounted) {
          setState(() {
            noNearByInList = true;
          });
        }
      } else if (nearByNext == null && customerProfileListNearBy.length > 6) {
        _findBusinessScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
          Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getSuggestionBusinessList() async {
    if (!isFindBusinessLoading) {
      if (findBusinessNext != null && !isFindBusinessLoading) {
        isFindBusinessLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(findBusinessNext, findBusinessPrevious, _currentCategory, nearBy: false);

        if (result == null) {
          noFindBusinessInList = true;

          isFindBusinessLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        findBusinessCount = result['count'];
        findBusinessNext = result['next'];
        findBusinessPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noFindBusinessInList = false;
            isFindBusinessLoading = false;
            customerProfileList.addAll(tempList);
          });
        }

        // for(var item in customerProfileList){
        //   debugPrint('Fola suggest by:::: ${item.toJson()}');
        // }

      }
      if (customerProfileList.isEmpty) {
        if (mounted) {
          setState(() {
            noFindBusinessInList = true;
          });
        }
      } else if (findBusinessNext == null && customerProfileList.length > 6) {
        _findBusinessScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
          Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
            AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  _refreshPage() {
    findBusinessNext = "";
    findBusinessCount = 0;
    findBusinessPrevious = "";
    isFindBusinessLoading = false;
    isNearbyLoading = false;
    nearByNext = "";
    nearByCount = 0;
    nearByPrevious = "";
    customerProfileList = [];
    customerProfileListNearBy = [];

    getNearByBusinessList();
    getSuggestionBusinessList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _dashboardBloc = Provider.of<DashboardBloc>(context);

    /// check if super store bottom navigation is clicked
    /// scroll back to the top of the page
    if (_dashboardBloc.topYarn == true) {
      _dashboardBloc.topYarn = false;
      if (_scrollController.hasClients) {
        final position = _scrollController.position.minScrollExtent;
        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.pixels == 0) {
        // Scroll controller is at the top
        widget.onPageRefresh!(true);
        if (mounted) setState(() {});
      }
    });

    return ScaffoldMessenger(
      key: _findBusinessScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: bodyList(),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isFindBusinessLoading ? 1.0 : 00,
      child: isFindBusinessLoading ? const YarnShimmer() : Container(),
    );
  }


  Widget bodyList() {

    if (isFindBusinessLoading && isNearbyLoading) {
      return _buildLoadingIndicator();
    } else {
      return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true,
                elevation: 0,
                stretch: true,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title:
                Column(
                  children: [
                    const SizedBox(height: 30.0,),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Nearby Business",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: blackFont,
                            ),
                          ),
                          GestureDetector(
                            child: Row(
                              children: [
                                Text(
                                  "View more",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: blackFont),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios_sharp,
                                    size: 14, color: blackFont),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.NEAR_BY_LIST_SCREEN,
                                  arguments: {"customerProfile": customerProfileListNearBy,
                                    "count": nearByCount,
                                    "next": nearByNext
                                  });

                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50.0,),
                  ],
                ),
                // Text(_isAppBarExpanded ? '' : 'check', style: TextStyle(
                //   fontWeight: FontWeight.w700,
                //   fontSize: 18,
                //   color: blackFont,
                // ),),
                expandedHeight: 250, // Set the desired expanded height of the app bar
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      if(customerProfileListNearBy.isNotEmpty)...[
                        const SizedBox(height: 30.0,),
                        nearByBuildView(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            if (customerProfileList.isNotEmpty) ...[
              // const SizedBox(height: 10.0,),
               Container(
                margin: const EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggestions",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: blackFont,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0,),
              suggestionBuildView(),
            ],
            Visibility(
              visible: !isFindBusinessLoading &&
                  !isNearbyLoading &&
                  customerProfileList.isEmpty &&
                  customerProfileListNearBy.isEmpty,
              child: Center(
                child: NoItemInList(
                  msg: AppLocalization.of(context)!.noResultFound,
                ),
              ),
            ),
          ],
        ),

      );
    }
  }

  Widget suggestionBuildView() {

    return Expanded(
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        controller: _scrollController,
        itemCount: customerProfileList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == customerProfileList.length) {
            return _buildLoadingIndicator();
          }

          return FindBusiness(
            customerProfile: customerProfileList[index],
            tileRenderPlace: TileRenderPlace.YarnProductService,
            callback: (username, value) {
              //create a list to edit
              List<CustomerProfile> customerProfileListEdit = customerProfileList;

              // modify customerProfileList for the username and refresh the list
              // set the isFollowing for that particular user
              customerProfileListEdit.forEach((customer) {
                if (customer.userName == username) {
                  customer.isFollowing = value; // Modify the isFollowing property
                }
              });

              customerProfileList = [];
              customerProfileList = customerProfileListEdit;

              if(mounted)setState(() {});

            },
          );
        },
        separatorBuilder: (context, int) {
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Divider(
                height: 0,
                thickness: 0.5,
                color: greySecondaryYarn,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget nearByBuildView() {

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var item in customerProfileListNearBy)
            Container(
              width: 200,
              // height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: FindBusiness(
                customerProfile: item,
                tileRenderPlace: TileRenderPlace.Thiny,
                callback: (username, value) {
                  //create a list to edit
                  List<CustomerProfile> customerProfileListEdit = customerProfileListNearBy;

                  // modify customerProfileList for the username and refresh the list
                  // set the isFollowing for that particular user
                  customerProfileListEdit.forEach((customer) {
                    if (customer.userName == username) {
                      customer.isFollowing = value; // Modify the isFollowing property
                    }
                  });

                  customerProfileListNearBy = [];
                  customerProfileListNearBy = customerProfileListEdit;

                  if(mounted)setState(() {});

                },
              ),
            )

        ],
      ),
    );
  }

}

