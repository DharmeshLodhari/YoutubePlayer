import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_edit_discount.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class DiscountList extends StatefulWidget {
  DiscountList({Key? key}) : super(key: key);

  @override
  _DiscountListState createState() => _DiscountListState();
}

class _DiscountListState extends State<DiscountList> {
  // this variable responsible for product pagination
  int? itemCount = 0;
  String? next = "";
  String? previous = "";
  List<DiscountModel> itemList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    this.getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    super.initState();
  }

  void _onProductRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        itemCount = 0;
        next = "";
        previous = "";
        itemList = [];
        debugPrint("Refresh called on discount!!  ");
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void getList({bool fetchFresh = false}) async {
    if (fetchFresh) {
      itemCount = 0;
      next = "";
      previous = "";
      itemList = [];
    }

    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result =
            await ShoppingAuthService().listOfDiscounts(next, previous);

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        itemCount = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isLoading = false;
            itemList.addAll(tempList);
          });
        }
      }
      if (itemList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && itemList.length > 6) {
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
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
      key: _messengerScaffoldKey,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: Container(
          color: white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onProductRefresh,
            child: noItemInList
                ? NoItemInList(msg: AppLocalization.of(context)!.noResultFound
                    // msg: AppLocalization.of(context)!.noProducts,
                    )
                : isLoading
                    ? _buildShimmerEffect()
                    : _buildItemList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: greyBorderColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return CustomBoxShadow(
            child: Container(
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CustomBoxShadow(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.zero,
                  shadowColor: boxShadowTwo,
                  color: lightGrey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  width: 50,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  height: 8,
                                  width: 50,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 10,
                            width: 50,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        'Discount',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      actions: _buildAppBarActions(),
      elevation: 0.5,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () async {
            final result = await NavigationUtil.push(
              context,
              screen: AddEditDiscount(),
            );
            if (result != null && result == true) {
              getList(fetchFresh: true);
            }
          },
          height: 20,
          width: 20,
          icon: SvgPicture.asset(
            "add_payment".toSVG(),
            height: 12,
            width: 12,
          )),
      const SizedBox(width: 30),
    ];
  }

  Widget _buildItemList() {
    return next == "" && isLoading
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return itemTile(index);
              },
            ),
          );
  }

  Widget itemTile(int index) {
    return InkWell(
      onTap: () async {
        final result = await NavigationUtil.push(
          context,
          screen: AddEditDiscount(
            discountModel: itemList[index],
          ),
        );
        if (result != null && result == true) {
          getList(fetchFresh: true);
        }
      },
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: selectedListItemBackgroundBlue),
              borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          color: white,
          child: Container(
            padding: const EdgeInsets.only(top: 23, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messageDecoderWithEmoji(itemList[index].name) ??
                            itemList[index].merchant ??
                            "",
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: "Inter",
                            color: blackFont),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Last Updated: ${itemList[index].updatedAt?.toDateFormatString(dateFormat: "dd/MM/yyyy")}",
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            fontFamily: "Inter",
                            color: darkGrey),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  itemList[index].type.toString().contains("Percentage")
                      ? "${itemList[index].value.toString()} % off"
                      : "₦${itemList[index].value.toString()} off",
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      color: navyBlue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
