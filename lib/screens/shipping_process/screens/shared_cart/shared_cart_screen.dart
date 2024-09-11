import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SharedCartScreen extends StatefulWidget {
  const SharedCartScreen({
    super.key,
    this.onPageRefresh,
  });

  final Function(bool)? onPageRefresh;

  @override
  State<SharedCartScreen> createState() => SharedCartScreenState();
}

class SharedCartScreenState extends State<SharedCartScreen> {
  bool isLoading = false;
  // List<SharedCartModel> cartGroupDetails = [];
  int? listCount = 0;
  bool noDataInList = false;
  String? listNext = "";
  String? listPrevious = "";

  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;

  final GlobalKey<ScaffoldMessengerState> _sharedCartScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _sharedScrollController = ScrollController();

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

  Future<void> getSharedCartListing() async {
    if (!isLoading) {
      if (listNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await SharedCartAuthService()
            .getSharedCartList(listNext, listPrevious);

        if (result == null) {
          noDataInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        sharedCartBloc.cartList = [];
        listCount = result['count'];
        listNext = result['next'];
        listPrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noDataInList = false;
            isLoading = false;
            // cartGroupDetails.addAll(tempList!);
            sharedCartBloc.cartList.addAll(tempList);
            // sharedCartBloc.cartList = tempList;
          });
        }
      }
      if (sharedCartBloc.cartList.isEmpty) {
        if (mounted) {
          setState(() {
            noDataInList = true;
          });
        }
      } else if (listNext == null && sharedCartBloc.cartList.length > 6) {
        _sharedCartScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return ScaffoldMessenger(
      key: _sharedCartScaffoldMessengerKey,
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
              child: _buildBodyOfCart(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyOfCart() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    }

    return noDataInList == true
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: sharedCartBloc.cartList.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index));
  }

  Widget getItemTile(int index) {
    return Container(
      color: Colors.white,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: getTitle(index),
                  subtitle: followersWidget(
                      userImages: sharedCartBloc.cartList[index]
                          .convertToUserFollowersList()),
                  trailing: getTrailing(index),
                  onTap: () async {
                    sharedCartBloc.currentSelectedIndex = index;

                    final result = await Navigator.of(context)
                        .pushNamed(Routes.SHARED_CARD_DETAILS);

                    // var result = await Navigator.of(context)
                    //     .pushNamed(Routes.SHARED_CARD_DETAILS, arguments: {
                    //   "cart_details": sharedCartBloc.cartList[index]
                    // });

                    if (result != null && result is bool && result == true) {
                      _onRefresh();
                    }
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
        appendStringDot("${sharedCartBloc.cartList[index].name}", 30),
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

  Widget getTrailing(int index) {
    return SizedBox(
      width: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            worldCurrencies[userBloc.user.currency]!,
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
          Text(
            moneyDisplayNormalizer(
                int.parse(sharedCartBloc.cartList[index].subtotal.toString())),
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      listCount = 0;
      listNext = "";
      listPrevious = "";
      sharedCartBloc.cartList = [];
      if (mounted) setState(() {});
      getSharedCartListing();
      setState(() {
        // Call the callback function with the updated list
        //to pass the list back to edit product page
        // widget.onListRefreshed!(productVariantList);
        _refreshController.refreshCompleted();
      });
    } else {
      _refreshController.refreshCompleted();
    }
  }
}
