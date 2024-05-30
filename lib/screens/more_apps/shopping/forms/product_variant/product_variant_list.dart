import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../data/currency.dart';
import '../../../../../routes/route_constants.dart';
import '../../models/store.dart';
import '../../shopping_auth.dart';

class ProductVariantList extends StatefulWidget {
  final dynamic arguments;
  final Function(List<Variant>)? onListRefreshed;

  ProductVariantList({this.arguments, this.onListRefreshed, Key? key})
      : super(key: key);

  @override
  _ProductVariantListState createState() => _ProductVariantListState();
}

class _ProductVariantListState extends State<ProductVariantList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Get list of users bank account
  late UserBloc userBloc;
  int? count = 0;
  String? next = "";
  String? previous = "";
  String? productId = "";
  List<Variant> productVariantList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  final _auth = ShoppingAuthService();

  late final SlidableController _slideController = SlidableController(this);

  @override
  void initState() {
    productId = widget.arguments["productId"];

    getVariantList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getVariantList();
      }
    });
  }

  void getVariantList() async {
    if (!isLoading) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final Map<String, dynamic>? result =
          await _auth.getVariantList(productId!, next, previous);
      if (result == null) {
        isLoading = false;
        noItemInList = true;
        return;
      }
      // count = result['count'];
      // next = result['next'];
      // previous = result['previous'];
      final tempList = result['results'];

      // productVariantList = Variant.convertToVariantList(tempList);
      // productVariantList = tempList;
      productVariantList.addAll(tempList);

      if (mounted) {
        setState(() {
          isLoading = false;
          noItemInList = false;
        });
      }

      if (productVariantList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && productVariantList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  // refresh the list when lifecycle called onResume method
  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        productVariantList = [];
        if (mounted) setState(() {});
        getVariantList();
        setState(() {
          // Call the callback function with the updated list
          //to pass the list back to edit product page
          // widget.onListRefreshed!(productVariantList);
          _refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, productVariantList);
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
              child: _buildProductVariantList()),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, productVariantList);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.variant,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addOptionBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget addOptionBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        final result = await Navigator.of(context)
            .pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
          'option': 'edit',
          'productId': productId,
        });

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is Variant) {
          //save the variant details for later use
          _onRefresh();
          // variantData = result;
          if (mounted) setState(() {});
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildProductVariantList() {
    return noItemInList
        ? NoItemInList(
            title: AppLocalization.of(context)!.noVariantYet,
            msg: AppLocalization.of(context)!.noVariantDetail,
          )
        : isLoading && productVariantList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                //+1 for progressbar
                itemCount: productVariantList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == productVariantList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                        context,
                        productVariantTile(
                          variant: productVariantList[index],
                        ),
                        productVariantList[index]);
                  }
                },
                controller: _scrollController,
              );
  }

  Widget productVariantTile({required Variant variant}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appendStringDot(variant.title!, 20),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    fontSize: 14),
              ),
              const SizedBox(height: 3.0),
              Text(
                'Available . ${variant.quantity!}',
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontSize: 12),
              ),
              const SizedBox(height: 3.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[variant.currency!]!,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14.0,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    moneyDisplayNormalizer(int.parse(variant.price.toString())),
                    style: TextStyle(
                        fontSize: 14.0,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
          leading: GestureDetector(
            onTap: () {
              final String? url = variant.serverImages![0]!;
              Navigator.of(context).pushNamed("/photo-viewer", arguments: url);
            },
            child: checkProductImage(variant),
          ),
        ),
      ),
    );
  }

  Widget checkProductImage(Variant variant) {
    // Retrieve the first image from the 'pictures' list

    String? url = "";

    for (var item in variant.serverImages!) {
      url = item;
    }

    final String imageUrl = url!.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(variant.title!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: NetworkImage(
                imageUrl,
              ),
              fit: BoxFit.cover),
        ),
      );
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, Variant variant) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(variant: variant),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(variant: variant),
      ),
      child: VerticalListItem(bankAccountTile),
    );
  }

  List<Widget> listSecondaryActions({required Variant variant}) {
    return [
      SlideActionButton(
          backgroundColor: starYellow,
          icon: Icons.edit,
          onTap: () async {
            final data = await Navigator.of(context)
                .pushNamed(Routes.PRODUCT_VARIANT_UPDATE, arguments: {
              'variant': variant,
            });

            // Handle the result (map) received from PRODUCT_VARIANT_UPDATE
            if (data != null && data is Variant) {
              //save the variant details for later use
              // variantData = data;
              _onRefresh();
              if (mounted) setState(() {});
            }
          },
          title: AppLocalization.of(context)!.edit,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions({Variant? variant}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () async {
            deleteProductVariant(variant);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  void deleteProductVariant(Variant? variant) {
    _auth.deleteVariant(variant!.id!.toString()).then((value) {
      if (value) {
        showToast(
            message: AppLocalization.of(context)!.variantDeletedSuccessfully);
        _onRefresh();
      } else {
        showToast(message: AppLocalization.of(context)!.variantIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  @override
  void dispose() {
    // unsecureScreen();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
