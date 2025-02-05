import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/screens/currency/add_edit_currency.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/screens/user_profile/utils.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<CurrencyModel> currencyList = [];
  int? count = 0;
  String? next = "";
  String? previous = "";
  final _auth = UserAuth();
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    getCurrencyList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getCurrencyList();
      }
    });
    super.initState();
  }

  Future<void> getCurrencyList() async {
    if (!isLoading) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final Map<String, dynamic> result =
          await _auth.getCurrency(next, previous);
      if (result == null) {
        isLoading = false;
        noItemInList = true;
        return;
      }

      currencyList = [];
      count = result['count'];
      next = result['next'];
      previous = result['previous'];
      final tempList = result['results'];

      currencyList.addAll(tempList);

      if (mounted) {
        setState(() {
          isLoading = false;
          noItemInList = false;
        });
      }

      if (currencyList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && currencyList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: navyBlue,
            size: 24,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          }),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.currency,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addCurrencyBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget addCurrencyBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        final result = await NavigationUtil.push(
          context,
          screen: AddEditCurrency(
            currencyList: currencyList,
          ),
        );
        if (result != null && result == true) {
          _onRefresh();
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: noItemInList
          ? NoItemInList(
              msg: AppLocalization.of(context)!.noResultFound,
            )
          : isLoading && currencyList.isEmpty
              ? buildShimmerEffect()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: currencyList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == currencyList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          final result = await NavigationUtil.push(
                            context,
                            screen: AddEditCurrency(
                              currencyList: currencyList,
                              currencyModel: currencyList[index],
                            ),
                          );

                          if (result != null && result == true) {
                            _onRefresh();
                          }
                        },
                        child: currencyTile(
                            data: currencyList[index], index: index),
                      );
                    }
                  },
                ),
    );
  }

  Widget currencyTile({required CurrencyModel data, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            '${data.currency} (${worldCurrencies[data.currency]})',
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            '1(${worldCurrencies[data.currency]}) ${moneyDisplayNormalizer(data.rate)}',
            maxLines: 1,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              fontFamily: "Inter",
            ),
          ),
        ),
      ),
    );
  }

  // refresh the list when lifecycle called onResume method
  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      count = 0;
      next = "";
      previous = "";
      currencyList = [];
      if (mounted) setState(() {});
      getCurrencyList();
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

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
