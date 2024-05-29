import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_edit_shipping_address.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class DispatchAddress extends StatefulWidget {
  DispatchAddress({Key? key, this.arguments}) : super(key: key);

  final dynamic arguments;

  @override
  _DispatchAddressState createState() => _DispatchAddressState();
}

class _DispatchAddressState extends State<DispatchAddress> {
  // this variable responsible for product pagination
  int? itemCount = 0;
  String? next = "";
  String? previous = "";
  List<ShippingAddress> itemList = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late SharedPreferences _sharedPreferences;
  bool isLoading = false;
  bool noItemInList = false;

  bool isForSelection = false;
  Function(ShippingAddress)? onShippingAddressChange;
  ShippingAddress? selectedShippingAddress;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _sharedPreferences = await SharedPreferences.getInstance();
    });

    if (widget.arguments != null) {
      isForSelection = widget.arguments?["isForSelection"] as bool;
      onShippingAddressChange = widget.arguments?["onShippingAddressChange"]
          as Function(ShippingAddress)?;
      selectedShippingAddress =
          widget.arguments?["shippingAddress"] as ShippingAddress?;
    }

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
            await ShoppingAuthService().listOfDispatchAddress(next, previous);

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

        noItemInList = false;
        isLoading = false;
        itemList.addAll(tempList);

        if (itemList.length == 1) {
          await _sharedPreferences.setBool("isCurrentLocation", false);
        }

        if (mounted) setState(() {});

        /// to getDefault selected address
        for (ShippingAddress address in itemList) {
          if (address.is_default == true && isForSelection == false) {
            selectedShippingAddress = address;
            break;
          }

          if (isForSelection == true &&
              selectedShippingAddress != null &&
              selectedShippingAddress?.id == address.id) {
            selectedShippingAddress = address;
            break;
          }
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

  void setDefaultAddress(String? id) async {
    itemList = [];
    if (mounted) {
      setState(() {});
    }

    final Map<String, dynamic>? result =
        await ShoppingAuthService().setDefaultAddress(id);

    if (result == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    itemCount = result['count'];
    next = result['next'];
    previous = result['previous'];
    final tempList = result['results'];

    itemList.addAll(tempList);

    /// to getDefault selected address
    for (ShippingAddress address in itemList) {
      if (address.is_default == true && isForSelection == false) {
        selectedShippingAddress = address;
        await _sharedPreferences.setBool("isCurrentLocation", false);
        setState(() {});
        break;
      }

      if (isForSelection == true &&
          selectedShippingAddress != null &&
          selectedShippingAddress?.id == address.id) {
        selectedShippingAddress = address;
        await _sharedPreferences.setBool("isCurrentLocation", false);
        setState(() {});
        break;
      }
    }

    if (mounted) setState(() {});

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
        floatingActionButton: isForSelection ? selectionSaveBtn() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget selectionSaveBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CurvedButton(
        text: "Save",
        onPressed: selectedShippingAddress != null
            ? () {
                onShippingAddressChange?.call(selectedShippingAddress!);
                Navigator.pop(context);
              }
            : null,
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
        'Dispatch Address',
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
              screen: AddEditShippingAddress(),
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
    // if (itemList[index].is_default == true) {
    //   selectedShippingAddress = itemList[index];
    // }
    return Container(
      // height: 120,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: CustomBoxShadow(
        child: Card(
          elevation: 2.5,
          shadowColor: boxShadowTwo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          color: white,
          child: Container(
            padding: const EdgeInsets.only(top: 23, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      itemList[index].name!,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Inter",
                        color: blackFont,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isForSelection)
                      Radio<ShippingAddress>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity,
                          ),
                          value: itemList[index],
                          activeColor: navyBlue,
                          groupValue: selectedShippingAddress,
                          onChanged: (val) {
                            if (isForSelection) {
                              selectedShippingAddress = val;
                              if (mounted) setState(() {});
                            }
                          })
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  itemList[index].toFullAddress(),
                  // "${itemList[index].line_1!}, ${itemList[index].line_2}, ${itemList[index].city}, ${itemList[index].stateName}, ${itemList[index].country}, ${itemList[index].zip}",
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      fontFamily: "Inter",
                      color: darkGrey),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (!isForSelection)
                      InkWell(
                        onTap: itemList[index].is_default!
                            ? null
                            : () {
                                setDefaultAddress(itemList[index].id);
                              },
                        child: Text(
                          itemList[index].is_default!
                              ? "Default"
                              : "Set as Default",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: "Inter",
                              color: itemList[index].is_default!
                                  ? blackFont
                                  : navyBlue),
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final result = await NavigationUtil.push(
                          context,
                          screen: AddEditShippingAddress(
                            shippingAddress: itemList[index],
                          ),
                        );
                        if (result != null && result == true) {
                          getList(fetchFresh: true);
                        }
                      },
                      icon: const Icon(Icons.edit),
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
