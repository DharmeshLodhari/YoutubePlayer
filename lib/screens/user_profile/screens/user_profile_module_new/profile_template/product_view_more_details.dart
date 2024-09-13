import 'dart:convert';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifiers/basket_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/yarn/share_as_a_yarn_screen.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/screens/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/cart_with_badge.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../super_store/shop_list_screen.dart';

class ProductViewMoreDetails extends StatefulWidget {
  final String? industryId;
  final String? merchantId;
  final String? appTitle;
  const ProductViewMoreDetails({
    super.key,
    this.appTitle,
    this.merchantId,
    this.industryId,
  });

  @override
  State<ProductViewMoreDetails> createState() => _ProductViewMoreDetailsState();
}

class _ProductViewMoreDetailsState extends State<ProductViewMoreDetails> {
  late BasketBloc basketBloc;
  late UserBloc userBloc;
  late YarnDashboardBloc yarnDashboardBloc;
  bool isLoading = false;
  bool isFirstTime = true;
  bool todaysDealsEmpty = false;
  int? count = 0;
  Product? product;
  late bool isValidCustomer;
  String? productId;
  String? todayDealNext = "";
  String? todayDealPrevious = "";
  List<Product> productDealOfTheDayList = [];
  String urlLink = "";
  final ScrollController _scrollController = ScrollController();

  // fetch api call
  void fetchProducts() async {
    if (!isLoading) {
      if (todayDealNext != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? response =
            await ShoppingAuthService().getProductsDealsOfTheDay(
          todayDealNext,
          todayDealPrevious,
          merchantId: widget.merchantId,
          industryId: widget.industryId,
        );
        if (response == null) {
          isLoading = false;
          return;
        }
        todayDealNext = response['next'];
        count = response['count'];
        todayDealPrevious = response['previous'];
        final tempList = response['results'];

        isLoading = false;
        productDealOfTheDayList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && todayDealNext != null && todayDealNext != "") {
          isFirstTime = false;
          fetchProducts();
        }
      }
      if (productDealOfTheDayList.isEmpty) {
        todaysDealsEmpty = true;

        if (mounted) setState(() {});
      } else if (todayDealNext == null && productDealOfTheDayList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
    if (!isLoading && todayDealNext != null) {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic>? response =
          await ShoppingAuthService().getProductsDealsOfTheDay(
        todayDealNext,
        todayDealPrevious,
        merchantId: widget.merchantId,
        industryId: widget.industryId,
      );

      if (response == null) {
        setState(() {
          todaysDealsEmpty = true;
          isLoading = false;
        });
        return;
      }

      todayDealNext = response['next'];
      todayDealPrevious = response['previous'];
      final tempList = response['results'];

      setState(() {
        productDealOfTheDayList.addAll(tempList);
        isLoading = false;
        todaysDealsEmpty = productDealOfTheDayList.isEmpty;
      });
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (todayDealNext == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void initState() {
    // get api
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading) {
        fetchProducts();
      }
    });
    fetchProducts();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
      title: Text(
        AppLocalization.of(context)?.newArrivals ?? "",
        // messageDecoderWithEmoji(widget.appTitle ?? "") ?? "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      // actions: <Widget>[
      //   searchIcon(),
      //   const SizedBox(
      //     width: 15,
      //   ),
      //   goToCartWidget(),
      //   const SizedBox(
      //     width: 15,
      //   ),
      //   menuBtn(),
      //   const SizedBox(width: 15),
      // ],
    );
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {},
    );
  }

  Widget goToCartWidget() {
    return CartWithBadge(
      items: basketBloc.basketItems,
      height: 30,
      width: 30,
      backgroundColor: transparent,
      enableMargin: true,
      onTap: () {
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
    );
  }

  Widget menuBtn() {
    return RoundedBackgroundIcon(
      height: 30,
      width: 30,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // showUserProfileActionsSheet();
      },
      backgroundColor: transparent,
      enableMargin: true,
    );
  }

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          color: Colors.white,
          margin: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: generateBottomSheetItem(),
            ),
          ),
        );
      },
    );
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.product);

    if (!isValidCustomer) {
      list.add(
        bottomSheetItem(
          title: "Edit",
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            if (hasPermission == PermissionType.WRITE) {
              Navigator.pop(context);
              final result = await Navigator.of(context).pushNamed(
                '/edit-product',
                arguments: {
                  "productId": productId,
                },
              );

              if (result != null) {
                if (result is String) {
                  if (result == "delete_item" || result == "update_item") {
                    //To refresh the product list page
                    Navigator.pop(context, 'update_item');
                  }
                }
              }
            } else {
              showToast(
                  message: AppLocalization.of(context)?.doNotPermission ?? "");
            }
          },
        ),
      );
    }

    list.add(
      bottomSheetItem(
        title: "Share",
        iconData: SlydoAppIcon.share,
        onTap: () async {
          Navigator.pop(context);

          final shareBody =
              "http://slydo.co/store/${product?.seller}/products/${product?.id.toString() ?? ""}";
          Share.share(shareBody,
              subject: messageDecoderWithEmoji(product?.name) ?? "");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        iconData: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          sendItemToUsersInChat();
        },
      ),
    );

    list.add(
      bottomSheetItem(
        isLast: true,
        title: "Share As A Yarn",
        iconData: SlydoAppIconNew.dashboard_yarn,
        onTap: () async {
          Navigator.pop(context);
          shareAsYarn();
        },
      ),
    );

    return list;
  }

  void sendItemToUsersInChat() async {
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    // debugPrint("Selected users = ${listOfRecipient.length}");

    final String url =
        "${AppConfig.baseUrl}/api/v1/${product is Product ? "products" : "services"}/${product?.id ?? ""}/";

    final Map<String, dynamic>? itemData =
        await ShoppingAuthService().getProductOrService(url);

    for (var recipient in listOfRecipient) {
      addProductOrServiceToChat(
          item: product,
          itemData: itemData,
          recipientUser: recipient!,
          url: url);
    }
  }

  void addProductOrServiceToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url,
      dynamic item}) async {
    final Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": const Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is Product ? "product" : "service",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
  }

  Future shareAsYarn() async {
    NavigationUtil.push(
      context,
      screen: ShareAsAyarnScreen(
        askCategories: yarnDashboardBloc.yarnCategories,
        shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
        productModel: product,
        callback: (params) async {
          params.attachment = {
            "product": product?.toJson().cast<String, dynamic>() ?? {}
          };
          final bool data = await YarnAuth().addYarnAndQuestion(params, '', '');
          if (data) {
            showToast(message: "Shared in Yarn successfully");
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return todaysDealsEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.emptyList,
          )
        : isLoading && productDealOfTheDayList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Found $count results",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: "Inter",
                        color: blackFont,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (c, i) => SizedBox(
                              child: SuperStoreSingleCard(
                                product: productDealOfTheDayList[i],
                              ),
                            ),
                            childCount: productDealOfTheDayList.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            mainAxisSpacing: 8,
                            mainAxisExtent: 280,
                            crossAxisSpacing: 8,
                            maxCrossAxisExtent: 300,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: buildJumpingLoadingIndicator(
                              isLoading: isLoading),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }
}
