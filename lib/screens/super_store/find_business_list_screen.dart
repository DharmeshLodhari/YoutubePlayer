import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/currency.dart';
import '../../data/state_notifier.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../more_apps/shopping/models/ShoppingProduct.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/shopping/shopping_auth.dart';
import '../more_apps/user_profile/models/user.dart';
import '../more_apps/yarn/widgets/yarn_shimmer.dart';

class FindBusinessListScreen extends StatefulWidget {
  Function(bool)? onPageRefresh;

  FindBusinessListScreen({Key? key, this.onPageRefresh,}) : super(key: key);

  @override
  State<FindBusinessListScreen> createState() => FindBusinessListScreenState();
}

class FindBusinessListScreenState extends State<FindBusinessListScreen> {

  List<CustomerProfile> customerProfileList = [];
  bool isFindBusinessLoading = false;
  bool noFindBusinessInList = false;
  int? findBusinessCount = 0;
  String? findBusinessNext = "";
  String? findBusinessPrevious = "";
  late BasketBloc basketBloc;

  final GlobalKey<ScaffoldMessengerState> _findBusinessScaffoldMessengerKey =
  new GlobalKey<ScaffoldMessengerState>();

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  ScrollController _scrollController = new ScrollController();

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'Nearby Business',
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        // _cartBtn(),
        // SizedBox(width: 12),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getNearByBusinessList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getNearByBusinessList();
      }
    });
  }

  void getNearByBusinessList() async {
    if (!isFindBusinessLoading) {
      if (findBusinessNext != null && !isFindBusinessLoading) {
        isFindBusinessLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(findBusinessNext, findBusinessPrevious, otherDeals: true);

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
          duration: Duration(milliseconds: 500),
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
    customerProfileList = [];

    getNearByBusinessList();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

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
        // appBar: appBar(),
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
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                controller: _scrollController,
                itemCount: customerProfileList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == customerProfileList.length) {
                    return _buildLoadingIndicator();
                  }

                  return InkWell(
                    onTap: () async {

                      if (mounted) setState(() {});
                    },
                    child: FindBusiness(
                        customerProfile: customerProfileList[index],
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
                    ),
                  );
                },
                separatorBuilder: (context, int) {
                  return Column(
                    children: [
                      SizedBox(
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isFindBusinessLoading ? 1.0 : 00,
      child: isFindBusinessLoading ? YarnShimmer() : Container(),
    );
  }

}

