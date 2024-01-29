import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/share_cart_details.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SharedCartScreen extends StatefulWidget {
  SharedCartScreen({
    Key? key,
    this.onPageRefresh,
  }) : super(key: key);

  Function(bool)? onPageRefresh;

  @override
  State<SharedCartScreen> createState() => SharedCartScreenState();
}

class SharedCartScreenState extends State<SharedCartScreen> {
  bool isLoading = false;
  List<SharedCartModel> cartGroupDetails = [];
  int? listCount = 0;
  bool noDataInList = false;
  String? listNext = "";
  String? listPrevious = "";

  final GlobalKey<ScaffoldMessengerState> _sharedCartScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _sharedScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    getSharedCartListing();

    _sharedScrollController.addListener(() {
      if (_sharedScrollController.position.pixels ==
              _sharedScrollController.position.maxScrollExtent &&
          _sharedScrollController.position.pixels != 0) {
        getSharedCartListing();
      }
    });
  }

  @override
  void dispose() {
    _sharedScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void getSharedCartListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await SharedCartAuthService()
            .getSharedCartList(listNext, listPrevious);

        if (result == null) {
          noDataInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        listCount = result['count'];
        listNext = result['next'];
        listPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noDataInList = false;
            isLoading = false;
            cartGroupDetails.addAll(tempList!);
          });
        }
      }
      if (cartGroupDetails.isEmpty) {
        if (mounted) {
          setState(() {
            noDataInList = true;
          });
        }
      } else if (listNext == null && cartGroupDetails.length > 6) {
        _sharedCartScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _sharedCartScaffoldMessengerKey,
      child: SafeArea(
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
            child: _buildBodyOfCart(),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyOfCart() {
    return noDataInList == true
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: cartGroupDetails.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index));
  }

  Widget getItemTile(int index) {
    return Container(
      color: Colors.white,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: getTitle(index),
                  subtitle: followersWidget(
                      userImages: cartGroupDetails[index].membersDetails),
                  trailing: getTrailing(),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SharedCartDetails()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitle(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        appendStringDot("${cartGroupDetails[index].name}", 30),
        maxLines: 1,
        style: TextStyle(
          color: blackFont,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget getTrailing() {
    return Text(
      "₦0.00",
      maxLines: 1,
      style: TextStyle(
        color: navyBlue,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        fontFamily: "Inter",
      ),
    );
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getSharedCartListing();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }
}
