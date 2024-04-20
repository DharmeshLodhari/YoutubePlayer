import 'dart:convert';
import 'dart:ui';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/utils.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/add_on_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/all_active_cart.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../../widget/item_display_card.dart';
import '../../../../home_tab/qr_code_page.dart';
import '../../../payment_and_banking/models/FinancialInstitution.dart';
import '../../../payment_and_banking/models/VirtualAccount.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../yarn/models/share_as_yarn_model.dart';
import '../../../yarn/share_as_a_yarn_screen.dart';
import '../../../yarn/yarn_auth.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';
import '../../shopping_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final arguments;

  ProductDetailPage({required this.arguments});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  bool canRate = false;

  final _auth = ShoppingAuthService();
  Product? product;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  late SharedCartBloc sharedCartBloc;
  late ShippingProcessBloc shippingProcessBloc;

  List<String?>? displayProductImages = [];

  late bool isValidCustomer;

  ScrollController _scrollController = ScrollController();

  List<dynamic> sellersOtherItems = [];

  BehaviorSubject<int> sliderIndex = BehaviorSubject<int>();

  bool isOtherItemIsEmpty = false;
  bool isOtherItemFetched = false;

  /// variables for reviews
  List<Review> reviewList = [];
  bool isReviewLoading = false;
  int? reviewCount;

  String? productId;
  bool productIsLoading = false;
  late YarnDashboardBloc yarnDashboardBloc;
  List<String> oneImageEach = [];

  Variant? selectedVariant;

  String price = "";
  String moreInformation = "";
  int stockLeft = 0;

  Map<String, List<Variant>> colorGroups = {};
  Map<String, List<Variant>> sizeGroups = {};

  final GlobalKey<ScaffoldMessengerState> _cartScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    product = widget.arguments[
        'product']; // We get this when we are coming from the product list page.
    if (product != null) {
      productId = product?.id;
    } else {
      productId = widget.arguments[
          'productId']; // We get this when we are coming from the moment detail page.
    }

    userBloc = Provider.of<UserBloc>(context, listen: false);

    if (mounted) setState(() {});
    fetchProduct(productId!);

    if ((window.physicalSize.longestSide / window.devicePixelRatio) >= 870) {
      getOtherItems();
    } else {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          if (!isOtherItemFetched) {
            getOtherItems();
          }
        }
      });
    }

    canReviewProduct();

    fetchReviewList();

    super.initState();
  }

  void fetchReviewList() async {
    isReviewLoading = true;
    if (mounted) setState(() {});

    await ReviewAuth().fetchProductReviews(productId: productId).then((value) {
      List? tempList =
          value.containsKey('results') ? value['results'] as List : [];
      value.containsKey('count') ? reviewCount = value["count"] : 0;
      debugPrint('RESULTS :: ${value['results']}');

      reviewList = [];

      tempList.forEach((element) {
        reviewList.add(Review.fromJson(element));
      });

      reviewList.forEach((element) {
        debugPrint('LIKES :: ${element.likes}');
      });

      isReviewLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      isReviewLoading = false;
      if (mounted) setState(() {});
    });
  }

  Future canReviewProduct() async {
    Map<String, String> data = {};
    data['provider'] = product?.seller?.toString() ?? "";
    data['buyer'] = userBloc.user.userName!;
    data['type'] = 'products';
    data['id'] = product?.id ?? "";

    debugPrint('product URL :: ${data}');

    ReviewAuth().checkIfCanReviewProductOrService(data).then((value) {
      canRate = value;
      if (mounted) setState(() {});
    }).catchError(
      (error) {},
    );
    return true;
  }

  void getOtherItems() {
    if (mounted) {
      setState(() {
        isOtherItemIsEmpty = true;
      });
    }
    _auth
        .ownersOrderProductsAndServices(
            type: "products", userId: product?.seller, exclude: product?.id)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            isOtherItemIsEmpty = false;
            sellersOtherItems = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isOtherItemIsEmpty = false;
          });
        }
      }
    });
    isOtherItemFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);

    if (productIsLoading) {
      return Scaffold(
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    isValidCustomer = userBloc.user.userName != product?.seller;
    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        floatingActionButton: isValidCustomer ? floatingActionBar() : null,
        body: _buildProductDetailsPage(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
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
        AppLocalization.of(context)!.productDetail,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        menuBtn(),
        isValidCustomer
            ? SizedBox(
                width: 8,
              )
            : Container(),
        isValidCustomer ? goToCartWidget() : Container(),
        SizedBox(width: 16),
      ],
    );
  }

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  Widget menuBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showUserProfileActionsSheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  void selectShareOptionBottomSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    if (!isValidCustomer) {
      list.add(
        bottomSheetItem(
          title: "Edit",
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            var result = await Navigator.of(context).pushNamed(
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
          },
        ),
      );
    }

    list.add(bottomSheetItem(
      title: "Share",
      iconData: SlydoAppIcon.share,
      onTap: () async {
        Navigator.pop(context);

        var shareBody = "http://slydo.co/store/${product?.seller}/products/" +
            (product?.id.toString() ?? "");
        Share.share(shareBody,
            subject: "${messageDecoderWithEmoji(product?.name) ?? ""}");
      },
    ));

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

  Future shareAsYarn() async {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            productModel: product,
            callback: (params) async {
              params
                ..attachment = {
                  "product": product?.toJson().cast<String, dynamic>() ?? {}
                };
              bool data = await YarnAuth().addYarnAndQuestion(params, '', '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
              }
            }));
  }

  void sendItemToUsersInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    String url = AppConfig.baseUrl +
        "/api/v1/${product is Product ? "products" : "services"}/" +
        (product?.id ?? "") +
        "/";

    Map<String, dynamic>? itemData =
        await ShoppingAuthService().getProductOrService(url);

    listOfRecipient.forEach((recipient) {
      addProductOrServiceToChat(
          item: product,
          itemData: itemData,
          recipientUser: recipient!,
          url: url);
    });
  }

  void addProductOrServiceToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url,
      dynamic item}) async {
    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is Product ? "product" : "service",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
  }

  Widget goToCartWidget() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(end: 0, top: 0),
        badgeAnimation: const badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: naturalGreen,
            padding: basketBloc.basketItems.length == 0
                ? EdgeInsets.all(0)
                : EdgeInsets.all(4)),
        child: Center(
          child: Icon(
            SlydoAppIcon.cart,
            size: 16,
            color: blackFont,
          ),
        ),
      ),
      onTap: () {
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget getUserProfile() {
    return GestureDetector(
      child: ClipOval(
        child: Container(
          height: 40,
          width: 40,
          child: CachedNetworkImage(
            imageUrl: product!.sellerAvatar != null
                ? product!.sellerAvatar!
                : defaultImage,
            fit: BoxFit.fill,
            errorWidget: productAndServiceErrorWidget,
          ),
        ),
      ),
      onTap: () async {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": product?.seller});
      },
    );
  }

  Widget messageSellerWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.message,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        if (isValidCustomer) {
          Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
            'recipient': product?.seller,
            'subject': product?.name,
          });
        } else {
          showToast(message: "You can not message yourself !!");
        }
      },
    );
  }

  Widget addToCartWidget() {
    return GestureDetector(
      onLongPress: () async {
        if (product?.isProductAvailableNow() ?? false) {
          if (isValidCustomer) {
            if (product?.variantModels?.isNotEmpty ?? false) {
              if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
                // print("Both color and size lists are showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message:
                          AppLocalization.of(context)!.selectVariantColorSize);
                }
              } else if (sizeGroups.isNotEmpty && colorGroups.isEmpty) {
                // print("color list is showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantSize);
                }
              } else if (sizeGroups.isEmpty && colorGroups.isNotEmpty) {
                // print("size list is showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantColor);
                }
              }
            } else if (product?.addOnsModels?.isNotEmpty ?? false) {
              bool isRequired =
                  product?.isAllRequiredProductSelected() ?? false;
              if (isRequired == true) {
                showBottomSheetDialog();
              } else {
                showToast(
                    message: AppLocalization.of(context)!.selectRequiredAddons);
              }
            } else {
              //product has no variant or is a service
              showBottomSheetDialog();
            }
          } else {
            showToast(
                message:
                    AppLocalization.of(context)!.youCanNotPurchaseThisItem);
          }
        } else {
          showToast(message: AppLocalization.of(context)!.productOutOfStock);
        }
      },
      child: RoundedBackgroundIcon(
        onTap: () {
          if (product?.isProductAvailableNow() ?? false) {
            if (isValidCustomer) {
              if (product?.variantModels?.isNotEmpty ?? false) {
                if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
                  // print("Both color and size lists are showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message: AppLocalization.of(context)!
                            .selectVariantColorSize);
                  }
                } else if (sizeGroups.isNotEmpty && colorGroups.isEmpty) {
                  // print("color list is showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantSize);
                  }
                } else if (sizeGroups.isEmpty && colorGroups.isNotEmpty) {
                  // print("size list is showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantColor);
                  }
                }
              } else if (product?.addOnsModels?.isNotEmpty ?? false) {
                bool isRequired =
                    product?.isAllRequiredProductSelected() ?? false;
                if (isRequired == true) {
                  addToCart();
                } else {
                  showToast(
                      message:
                          AppLocalization.of(context)!.selectRequiredAddons);
                }
              } else {
                //product has no variant or is a service
                addToCart();
              }
            } else {
              showToast(
                  message:
                      AppLocalization.of(context)!.youCanNotPurchaseThisItem);
            }
          } else {
            showToast(message: AppLocalization.of(context)!.productOutOfStock);
          }
        },
        borderRadius: 16,
        height: 44,
        width: 44,
        icon: Icon(
          SlydoAppIcon.add_cart,
          color: product?.isProductAvailableNow() ?? false
              ? navyBlue
              : greyBorderColor,
          size: 22,
        ),
        backgroundColor: navyBlue.withOpacity(0.08),
      ),
    );
  }

  showBottomSheetDialog() async {
    var result = await androidBottomSheet(
      context: context,
      child: AllActiveCart(),
    );
    if (result != null && result is SharedCartModel) {
      if (result.id == 'my-cart') {
        addToCart();
      } else {
        await sharedCartBloc.refreshSharedCartProduct(context, result);
        addToSharedCart(result);
      }
    }
  }

  Future<void> addToCart() async {
    String type = "product";

    print("BASKETBLOC:- ${basketBloc.basketItems}");
    Product products = product!.copyWith(quantity: 1, withSelectedAddOn: true);

    basketBloc.addItemToCart(
      item: products,
      type: type,
      variant: selectedVariant?.copyWith(quantity: 1),
      addOns: products.addOnsModels,
      currentUser: userBloc.user.convertToUser(),
    );
  }

  Future<void> addToSharedCart(SharedCartModel result) async {
    String type = "product";

    Product products = product!.copyWith(quantity: 1, withSelectedAddOn: true);

    sharedCartBloc.addItemToSharedCart(
      cart: result,
      item: products,
      type: type,
      variant: selectedVariant?.copyWith(quantity: 1),
      addOns: products.addOnsModels,
      currentUser: userBloc.user.convertToUser(),
    );
  }

  // Future<void> addToCartOld() async {
  //   // Todo check this call
  //   String type = product is Product ? "product" : "service";
  //   Map<String, dynamic> addOnPayLoad = {};
  //   List<Map<String, dynamic>> selectedAddOnsCartServerList = [];
  //   List<AddOns> selectedAddOnsList = [];
  //
  //   Product productSend = product!;
  //   productSend = productSend.copyWith(quantity: 1);
  //
  //   /// TODO:BRIJESH CHECK ADDON
  //   // product?.addOnsModels?.forEach((addOn) {
  //   //   final options = addOn.options;
  //   //   if (options != null) {
  //   //     // Filter the options to include only those with option.isChecked == true
  //   //     // List<AddOnOption> selectedOptions =
  //   //     //     addOn.options!.where((option) => option.isChecked == true).toList();
  //   //     //
  //   //     // if (selectedOptions.isNotEmpty) {
  //   //     //   Map<String, dynamic> selectedAddOn = {
  //   //     //     "id": addOn.id,
  //   //     //     "options": selectedOptions
  //   //     //         .map((option) => {
  //   //     //               "id": option.id,
  //   //     //               "quantity": 1,
  //   //     //               "name": option.name,
  //   //     //               "price": option.price,
  //   //     //               "currency": option.currency,
  //   //     //             })
  //   //     //         .toList(),
  //   //     //   }; // Todo check this call
  //   //
  //   //     Map<String, dynamic> selectedAddOnServer = {
  //   //       "id": addOn.id,
  //   //       "options": options
  //   //           .map((option) => {
  //   //                 "id": option.id,
  //   //                 "quantity": 1,
  //   //               })
  //   //           .toList(),
  //   //     }; // Todo check this call
  //   //
  //   //     selectedAddOnsList.add(addOn);
  //   //     selectedAddOnsCartServerList.add(selectedAddOnServer);
  //   //     // }
  //   //   }
  //   // });
  //   selectedVariant?.quantity = 1;
  //
  //   if (selectedAddOnsList.isNotEmpty &&
  //       product?.addOnsModels?.isNotEmpty == true) {
  //     addOnPayLoad = {
  //       "id": productId,
  //       "qty": 1,
  //       "type": type,
  //       "add_ons": selectedAddOnsList,
  //     };
  //
  //     // basketBloc.addItemInBasketWithAddOns(product, type, selectedAddOnsCartServerList);
  //     basketBloc.addItemToCart(
  //       item: productSend,
  //       type: type,
  //       variant: null,
  //       addOns: selectedAddOnsList,
  //     );
  //
  //     // await _auth.addItemToShoppingCart(addOnPayLoad);
  //     return;
  //   }
  //   if (basketBloc.items.isEmpty) {
  //     basketBloc.addItemToCart(
  //       item: productSend,
  //       type: type,
  //       variant: selectedVariant,
  //       addOns: null,
  //     );
  //   } else {
  //     for (var item in basketBloc.items) {
  //       Product productInCart = item['item'];
  //
  //       if (productInCart.id.toString() == productId) {
  //         List<Variant>? variantList = productInCart.variantModels;
  //
  //         for (var variant in variantList!) {
  //           if (variant.id.toString() == selectedVariant?.id) {
  //             int currentQuantity = int.parse(variant.quantity.toString());
  //             variant.quantity = currentQuantity + 1;
  //
  //             Map<String, dynamic> dataInfo =
  //                 getUpdatedCartItem(productId!, type);
  //             // await _auth.addItemToShoppingCart(addOnPayLoad);
  //             return;
  //           }
  //         }
  //
  //         basketBloc.addItemToCart(
  //           item: productSend,
  //           type: type,
  //           variant: selectedVariant,
  //           addOns: null,
  //         );
  //
  //         // debugPrint("Data From Product Page v-id 2 : $variantPayLoad");
  //         // debugPrint("Data From Product Page v-id 3 : $variantList");
  //
  //         Map<String, dynamic> dataInfo = getUpdatedCartItem(productId!, type);
  //         debugPrint("Data From Product Page exist : $dataInfo");
  //
  //         // await _auth.addItemToShoppingCart(addOnPayLoad);
  //
  //         // for(var item in basketBloc.items){
  //         //   // Product productInCart = item['item'];
  //         //   List variantList = item['item'].variant;
  //         //   debugPrint('fola chat one twoo::: ${variantList.length}');
  //         //   debugPrint('fola chat one twoo::: ${item['item'].variant}');
  //         // }
  //         return;
  //       }
  //     }
  //
  //     // Product ID doesn't exist in the cart, add it with the variant
  //     basketBloc.addItemToCart(
  //       item: productSend,
  //       type: type,
  //       variant: selectedVariant,
  //       addOns: null,
  //     );
  //   }
  //
  //   Map<String, dynamic> dataInfo = getUpdatedCartItem(productId!, type);
  //   debugPrint("Data From Product Page : $dataInfo");
  //
  //   // await _auth.addItemToShoppingCart(dataInfo);
  // }

  Map<String, dynamic> getUpdatedCartItem(String productId, String type) {
    Map<String, dynamic> dataInfo = {};

    for (var element in basketBloc.items) {
      final item = element["item"];
      int totalVariantQuantity = 0;

      if (element["variants"] != null &&
          element.containsKey("variants") &&
          productId == item.id) {
        List<Variant> variantsList =
            (element['item'] as Product).variantModels ?? [];

        // debugPrint('fola chat one fourrrr::: ${variantsList.length}');

        // Initialize dataInfo with common information
        dataInfo = {
          "id": item.id,
          "type": type,
        };

        // Check if variantsList is not empty
        if (variantsList.isNotEmpty) {
          List<Map<String, dynamic>> variantDataList = [];

          // Iterate through the variants and add each variant to the variantDataList
          for (var variant in variantsList) {
            if (variant.id != null) {
              int variantId = int.parse(variant.id.toString());
              int? variantQuantity = variant.quantity;

              // debugPrint("Data From Product Page v-id 5 : ${variant}");

              variantDataList.add({
                "id": variantId,
                "quantity": variantQuantity,
              });
            }
          }

          // Add the variantDataList to dataInfo["variants"]
          dataInfo["variants"] = variantDataList;

          // Calculate the totalVariantQuantity based on variantDataList
          totalVariantQuantity = variantDataList.fold<int>(
              0,
              (sum, variant) =>
                  sum + int.parse(variant['quantity'].toString()));
        }

        // Set the total quantity in dataInfo
        dataInfo["qty"] =
            variantsList.isNotEmpty ? totalVariantQuantity : item.quantity;
      } else {
        dataInfo = {
          "id": item.id,
          "qty": element['qty'],
          "type": type,
          "variants": [],
        };
      }
    }
    return dataInfo;
  }

  int getTotalVariantQuantity(List<dynamic> variantsList, id) {
    int totalQuantity = 0;

    if (variantsList.isNotEmpty) {
      // Iterate through the productView and add them to dataInfo
      for (var variant in variantsList) {
        if (variant.containsKey("id") && variant["id"] != null) {
          int variantQuantity = int.parse(variant['quantity'].toString());
          totalQuantity += variantQuantity;
        }
      }
    }

    return totalQuantity;
  }

  Widget? getBadgeContent() {
    if (basketBloc.basketItems.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;

    for (var item in basketBloc.basketItems) {
      if (item.item is Product) {
        if (item.variants != null) {
          // If there are variants, calculate the total quantity from variants

          totalItem +=
              int.parse(item.getVariant()?.quantity?.toString() ?? "0");
        } else {
          // If the variant list is empty, add the quantity to the total
          totalItem += int.parse(item.qty.toString());
        }
      } else if (item.item is Service) {
        totalItem += int.parse(item.qty.toString());
      }
    }

    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  Widget floatingActionBar() {
    return widget.arguments["type"] == "changeAddons"
        ? Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: _buildOkButtonWidget(),
            ),
          )
        : Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                children: <Widget>[
                  messageSellerWidget(),
                  SizedBox(
                    width: 8,
                  ),
                  addToCartWidget(),
                  SizedBox(
                    width: 8,
                  ),
                  _buildBuyButtonWidget(),
                ],
              ),
            ),
          );
  }

  Widget _buildProductDetailsPage(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProductImagesWidgets(),
            Container(
              padding: EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildProductTitleAndPriceWidget(),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildShortInfoWidget(),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildAvailableFromAndShareWidgets(),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildDescriptionWidget(),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (product?.addOnsModels?.isNotEmpty == true) ...[
                    _buildAddonWidget(),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSellerInfoWidget(),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildReviewList(),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildWriteReview(),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0,
              color: dividerColor,
              thickness: 1,
            ),
            SizedBox(
              height: 16,
            ),
            isOtherItemIsEmpty
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisExtent: 180,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 15,
                        maxCrossAxisExtent: 200,
                      ),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  )
                : sellersOtherItems.isEmpty
                    ? Container()
                    : _buildSellersOtherProducts(),
            SizedBox(height: isValidCustomer ? 60.0 : 20),
          ],
        ),
      ],
    );
  }

  Widget buildReviewTitle() {
    return Text(
      reviewCount != null ? "Review ($reviewCount)" : "Reviews",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: blackFont,
      ),
    );
  }

  Widget _buildReviewList() {
    return reviewList.length == 0
        ? Center(
            child: Text(
              "No Review yet",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  buildReviewTitle(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.REVIEW_LIST_SCREEN,
                          arguments: {"reviewedProduct": product});
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: navyBlue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Column(
                children: reviewList
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReviewTile(
                          review: review,
                          product: product,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
  }

  Widget _buildWriteReview() {
    debugPrint('CAN RATE :: $canRate');
    if (product?.seller == userBloc.user.userName) {
      return Container();
    }

    if (!canRate) {
      return Container();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            var result = await Navigator.of(context).pushNamed(
              Routes.ADD_REVIEW,
              arguments: {
                "product": product,
              },
            );

            if (result != null) {
              if (result is bool) {
                if (result) fetchReviewList();
              }
            }
          },
          child: Container(
            width: double.infinity,
            child: Center(
              child: Text(
                "Write a review",
                style: TextStyle(
                    color: navyBlue, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductImagesWidgets() {
    return StreamBuilder<int>(
        initialData: 0,
        stream: sliderIndex.stream,
        builder: (context, snapshot) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: displayProductImages?.length == 0
                ? AspectRatio(
                    aspectRatio: 1.7,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : displayProductImages?.length == 1
                    ? GestureDetector(
                        onTap: () {
                          if (displayProductImages?[0] != null) {
                            Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                                arguments: displayProductImages?[0]);
                          }
                        },
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.7,
                              child: Container(
                                child: Center(
                                    child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        placeholder: (context, url) => Center(
                                            child: CircularLoadingIndicator()),
                                        imageUrl:
                                            displayProductImages?[0] ?? "",
                                        fit: BoxFit.cover,
                                        height: double.infinity,
                                        width: double.infinity,
                                        errorWidget:
                                            productAndServiceBigErrorWidget,
                                      ),
                                      if (checkDiscount(
                                          product!.discountIsActive!,
                                          product!.discountedPrice!,
                                          product!.price!))
                                        Positioned(
                                          top: 20,
                                          right: 10,
                                          child: showDiscountValue(
                                              product!.discountType!,
                                              product!.discountValue!,
                                              product!.currency),
                                        ),
                                      if (product!.pricePercentageChange !=
                                          0.0) ...[
                                        Positioned(
                                          top: 8,
                                          right: 100,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 6.0,
                                                right: 6.0,
                                                top: 4.0,
                                                bottom: 4.0),
                                            decoration: BoxDecoration(
                                              color: naturalGreen,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            child: Text(
                                              "${product!.pricePercentageChange!.toInt()}% off",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                )),
                              ),
                            ),
                            getOutOfStockTag(),
                          ],
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              CarouselSlider(
                                options: CarouselOptions(
                                    enableInfiniteScroll: false,
                                    viewportFraction: 1.0,
                                    enlargeCenterPage: true,
                                    autoPlay: false,
                                    aspectRatio: 1.7,
                                    onPageChanged: (index, _) {
                                      sliderIndex.sink.add(index);
                                    }),
                                items: displayProductImages!
                                    .map(
                                      (item) => GestureDetector(
                                        onTap: () {
                                          if (item != null) {
                                            Navigator.of(context).pushNamed(
                                                Routes.PHOTO_VIEWER,
                                                arguments: item);
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Center(
                                                  child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child:
                                                                  CircularLoadingIndicator()),
                                                      imageUrl: item!,
                                                      fit: BoxFit.cover,
                                                      height: double.infinity,
                                                      width: double.infinity,
                                                      errorWidget:
                                                          productAndServiceBigErrorWidget,
                                                    ),
                                                    if (product!
                                                            .pricePercentageChange !=
                                                        0.0) ...[
                                                      Positioned(
                                                        top: 8,
                                                        right: 100,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 6.0,
                                                                  right: 6.0,
                                                                  top: 4.0,
                                                                  bottom: 4.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: naturalGreen,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                          child: Text(
                                                            "${product!.pricePercentageChange!.toInt()}% off",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                              )),
                                            ),
                                            getOutOfStockTag(),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              Positioned(
                                bottom: 0,
                                left: MediaQuery.of(context).size.width / 2 -
                                    (5 * displayProductImages!.length),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: displayProductImages!.map((url) {
                                    int index =
                                        displayProductImages!.indexOf(url);
                                    return Container(
                                      width: 5.0,
                                      height: 5.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: snapshot.data == index
                                            ? navyBlue
                                            : navyBlueLight,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
          );
        });
  }

  Widget getOutOfStockTag() {
    if (!(product?.isProductAvailableNow() ?? false)) {
      return Positioned(
        left: 8,
        top: 8,
        child: getColoredLabeledWidget(
            text: AppLocalization.of(context)!.outOfStock, color: starYellow),
      );
    }
    return SizedBox.shrink();
  }

  void fetchProduct(String productId) async {
    debugPrint('PRODUCT ID ::$productId');
    if (mounted)
      setState(() {
        productIsLoading = true;
      });
    await _auth.getProduct(productId).then((value) {
      product = value;

      displayProductImages = product!.serverImages;
      productIsLoading = false;

      //     Variant.convertToVariantList(product!.variantModels!);

      //get the price and more information to string
      price = product!.price.toString();
      moreInformation = product!.description.toString();

      // addOnList = product!.addOns != null
      //     ? AddOns.convertToAddOnList(product!.addOns!)
      //     : [];

      colorGroups = {};
      sizeGroups = {};
      colorGroups = product?.getVariants(variantType: VariantTypes.Color) ?? {};
      sizeGroups = product?.getVariants(variantType: VariantTypes.Size) ?? {};

      if (mounted) setState(() {});
    }).catchError((e) {
      if (mounted)
        setState(() {
          productIsLoading = false;
        });
      Navigator.pop(context);
      showToast(message: e.toString());
    });
  }

  // Define a function to group variants by color for the selected color/image
  // Map<String, List<Variant>> groupVariantsByColorForSelectedSize(
  //     String selectedSize, List<Variant> allVariants) {
  //   Map<String, List<Variant>> colorGroups = {};
  //
  //   // Filter variants that match the selected color
  //   List<Variant> selectedSizeVariants = allVariants
  //       .where((variant) => variant.size == selectedSize)
  //       .toList();
  //
  //   // Group the selected color variants by size, only if variant.value is not empty or null
  //   for (var variant in selectedSizeVariants) {
  //
  //     if (variant.colour != null && variant.colour!.isNotEmpty) {
  //       if (!colorGroups.containsKey(variant.colour)) {
  //         colorGroups[variant.colour!] = [];
  //       }
  //       colorGroups[variant.colour]!.add(variant);
  //     }
  //   }
  //
  //   return colorGroups;
  // }

  // bool hasVariantsWithoutColor(
  //     List<Variant> productVariantList, String variantId) {
  //   // Iterate through the productVariantList
  //   for (var variant in productVariantList) {
  //     // Check if the variant has the specified variantId
  //     if (variant.id == variantId) {
  //       // Check if the variant has a color
  //       if (variant.colour == null || variant.colour!.isEmpty) {
  //         // Variant has no color
  //         return true;
  //       }
  //     }
  //   }
  //   // No variants without color found for the specified variantId
  //   return false;
  // }
  //
  // bool hasVariantsWithoutSize(
  //     List<Variant> productVariantList, String variantId) {
  //   // Iterate through the productVariantList
  //   for (var variant in productVariantList) {
  //     // Check if the variant has the specified variantId
  //     if (variant.id == variantId) {
  //       // Check if the variant has a color
  //       if (variant.value == null || variant.value!.isEmpty) {
  //         // Variant has no color
  //         return true;
  //       }
  //     }
  //   }
  //   // No variants without color found for the specified variantId
  //   return false;
  // }

  bool areAllKeysNullOrEmpty(Map<String, List<Variant>> sizeViewGroups) {
    return sizeViewGroups.keys.every((key) => key == null || key.isEmpty);
  }

  Widget _buildProductTitleAndPriceWidget() {
    bool allKeysAreNullOrEmpty = areAllKeysNullOrEmpty(sizeGroups);
    bool allKeysAreNullOrEmptyColor = areAllKeysNullOrEmpty(colorGroups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    //name,
                    messageDecoderWithEmoji(product?.name) ?? "",
                    style: TextStyle(
                        fontSize: 16,
                        color: blackFont,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          worldCurrencies[product?.currency] ?? "0",
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18.0,
                              color: navyBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          moneyDisplayNormalizer((checkDiscount(
                                  product!.discountIsActive!,
                                  product!.discountedPrice!,
                                  product!.price!))
                              ? product!.discountedPrice
                              : product!.price!),
                          style: TextStyle(
                              fontSize: 18.0,
                              color: navyBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (checkDiscount(product!.discountIsActive!,
                          product!.discountedPrice!, product!.price!))
                        Row(
                          children: [
                            Text(
                              worldCurrencies[product!.currency!]!,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                                fontSize: 12.8,
                                color: navyBlue,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              moneyDisplayNormalizer(product!.price!),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: navyBlue,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 5),
                  getRating(numberOfRating: product?.rating!.toInt()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stockLeft >= 10) ...[
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'In Stock',
                          style: TextStyle(
                              fontSize: 16,
                              color: naturalGreen,
                              fontWeight: FontWeight.bold),
                        ),
                      ] else if (stockLeft == 0) ...[
                        SizedBox.shrink()
                      ] else if (stockLeft <= 9) ...[
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Only ${stockLeft.toString()} left in stock',
                          style: TextStyle(
                              fontSize: 16,
                              color: mateRed,
                              fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                qrCodeIcon(),
              ],
            ),
          ],
        ),
        if (!allKeysAreNullOrEmptyColor) ...[
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Text(
                'Color : ',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                    color: darkGrey,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                selectedVariant?.getColor() ?? "",
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          showVariantColorSelection(),
        ],
        if (!allKeysAreNullOrEmpty) ...[
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Text(
                'Size : ',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: darkGrey,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                selectedVariant?.getSize() ?? "",
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          showVariantSizes(),
        ],
      ],
    );
  }

  Widget qrCodeIcon() {
    return RoundedBackgroundIcon(
      height: 54,
      width: 54,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 36,
        color: black,
      ),
      onTap: () async {
        //get the account detail of clicked user
        Map<String, dynamic> financial = {};

        VirtualAccount virtualAccount = VirtualAccount(
          accountName: product!.shortDescription,
          accountNumber: product!.name,
          financialInstitution: FinancialInstitution.fromJson(financial),
          customerUsername: product!.seller,
          note: "",
        );

        NavigationUtil.push(context,
            screen: QrCodePage(arguments: {
              'isProfile': 'false',
              'virtualAccount': virtualAccount,
              'product': product!.seller,
              'productUrl':
                  "https://slydo.co/store/${product!.seller}/products/" +
                      product!.id.toString()
            }));
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: false,
    );
  }

  Variant getVariantImage(List<Variant> variantsWithSize) {
    Variant? imageVariant;

    for (Variant img in variantsWithSize) {
      if (img.serverImages!.isNotEmpty) {
        imageVariant = img;
        break;
      }
    }
    return imageVariant!;
  }

  Widget showVariantColorSelection() {
    int itemCount = colorGroups.length; // Replace with your actual item count
    int maxItemsPerRow = 5;
    int totalColumns = calculateColumnCount(itemCount, maxItemsPerRow);

    return SizedBox(
      height: 82.0 * totalColumns,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 1.1,
        ),
        // scrollDirection: Axis.horizontal,
        itemCount: colorGroups.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          String color = colorGroups.keys.elementAt(index);
          List<Variant> variantsWithSize = colorGroups[color]!;

          // Get the first variant with this size (assuming at least one variant exists)

          Variant availableVariant = getVariantImage(variantsWithSize);

          return Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: GestureDetector(
              onTap: () {
                //update the price, more information and list of images
                displayProductImages = [];

                // Get the ID of the selected image
                String? selectedImageId = availableVariant.id;

                // Find the variant in the original list by ID
                Variant selectedVariant = (product?.variantModels ?? [])
                    .firstWhere((variant) => variant.id == selectedImageId);

                this.selectedVariant = variantsWithSize.first;

                // Retrieve all images associated with the selected variant
                List<String?>? allImages = selectedVariant.serverImages;
                // Now you have all the images for the selected variant
                displayProductImages = allImages;
                bool allKeysAreNullOrEmpty = areAllKeysNullOrEmpty(sizeGroups);

                if (allKeysAreNullOrEmpty) {
                  // for (int index = 0;
                  //     index < variantsWithSize.length;
                  //     index++) {
                  Variant variant = availableVariant;
                  // Update price or any other state based on the selected variant
                  price = variant.price!;
                  stockLeft = variant.getQuantity();
                  // }
                } else {
                  //set the selected size to zero
                  // selectedSizeIndex = -1;
                  // this.selectedVariant = null;
                }

                sizeGroups = {};

                sizeGroups = product?.getVariants(
                        variantType: VariantTypes.ColorAndSize,
                        selectedColor: selectedVariant.getColor()) ??
                    {};

                //check if size is not empty, set stock to zero
                if (sizeGroups.isNotEmpty && this.selectedVariant == null) {
                  stockLeft = 0;
                }

                if (mounted) setState(() {});
              },
              child: Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(
                    color: selectedVariant?.colour == availableVariant.colour
                        ? black
                        : transparent,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CachedNetworkImage(
                      imageUrl: availableVariant.serverImages!.first!,
                      placeholder: (context, url) => Center(
                          child: Transform.scale(
                        scale: 0.5,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(navyBlue),
                          strokeWidth: 2.0,
                        ),
                      )),
                      errorWidget: (context, url, error) => Icon(Icons.error),
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

  int calculateColumnCount(int itemCount, int maxItemsPerRow) {
    return (itemCount / maxItemsPerRow).ceil();
  }

  Widget showVariantSizes() {
    int itemCount = sizeGroups.length; // Replace with your actual item count
    int maxItemsPerRow = 3;
    int totalColumns = calculateColumnCount(itemCount, maxItemsPerRow);

    return SizedBox(
      height: 35.0 * totalColumns,
      child: GridView.builder(
        // gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // maxCrossAxisExtent: maxTextLengthWithSpace, // Maximum width for each item
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        itemCount: sizeGroups.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          String size = sizeGroups.keys.elementAt(index);
          List<Variant> variantsWithSize = sizeGroups[size]!;

          for (int index = 0; index < variantsWithSize.length; index++) {
            Variant variant = variantsWithSize[index];
            if (variant.value == null) {
              return SizedBox.shrink();
            }
          }

          return GestureDetector(
            onTap: () {
              for (int index = 0; index < variantsWithSize.length; index++) {
                Variant variant = variantsWithSize[index];

                // Update price or any other state based on the selected variant
                price = variant.price!;

                stockLeft = variant.getQuantity();
              }
              selectedVariant = variantsWithSize.first;

              if (mounted) setState(() {});
            },
            child: SizedBox(
              height: 20.0,
              child: Container(
                // height: 20.0,
                decoration: BoxDecoration(
                  color: selectedVariant?.value == size ? black : white,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  border: Border.all(
                    color: black,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                        fontSize: 14,
                        color: selectedVariant?.value == size
                            ? white
                            : blackFont.withOpacity(0.5),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget copyQrCode() {
    return Card(
      shadowColor: boxShadow,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dividerColor)),
        padding: EdgeInsets.all(10),
        child: InkWell(
          child: product!.qrCode == ""
              ? Center(child: CircularLoadingIndicator())
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed("/photo-viewer", arguments: product!.qrCode);
                  },
                  child: CachedNetworkImage(
                    imageUrl: product!.qrCode!,
                    height: 40,
                    width: 40,
                    errorWidget: imageErrorWidget,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        Center(child: CircularLoadingIndicator()),
                  ),
                ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: product!.qrCode!));
            showToast(message: AppLocalization.of(context)!.copied);
          },
        ),
      ),
    );
  }

  Widget _buildShortInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                messageDecoderWithEmoji(product!.shortDescription)!,
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableFromAndShareWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Date",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: lightGrey),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                SlydoAppIcon.date,
                color: Colors.black,
                size: 16,
              ),
              SizedBox(
                width: 8.0,
              ),
              Text(
                "${product!.availableFrom!.day}/${product!.availableFrom!.month}/${product!.availableFrom!.year}",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "More Information",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          messageDecoderWithEmoji(product?.description ?? "")!,
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildAddonWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Available Add-ons",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Spices up your orders with the available aad-ons below.",
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        // Divider(
        //   height: 0,
        //   color: dividerColor,
        //   thickness: 1,
        // ),
        // _buildAddonList(),
        ...product?.addOnsModels
                ?.map((addon) =>
                    AddOnTile(addOns: addon, isValidCustomer: isValidCustomer))
                .toList() ??
            []
      ],
    );
  }

  Widget _buildSellerInfoWidget() {
    return product!.sellerAvatar == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Seller",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                leading: GestureDetector(
                  onTap: () {
                    String? image = '';
                    if (product!.sellerAvatar! == "" ||
                        product!.sellerAvatar! ==
                            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
                      image =
                          getInitials(product!.sellerFullName!).toUpperCase();
                    } else {
                      image = product!.sellerAvatar!;
                    }

                    Navigator.of(context)
                        .pushNamed(Routes.PHOTO_VIEWER, arguments: image);
                  },
                  child: userImageUserInitialsPic(
                      product!.sellerAvatar!, product!.sellerFullName!, 15, 35),
                ),
                title: userNameWithVerifiedIcon(
                  name: product!.sellerFullName ?? '',
                  isVerified: false,
                  textStyle: TextStyle(
                      fontSize: 14,
                      color: blackFont,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  product!.seller ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGrey,
                  ),
                  textAlign: TextAlign.justify,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/profile',
                      arguments: {"searchedUserName": product!.seller});
                },
              ),
            ],
          );
  }

  Widget _buildSellersOtherProducts() {
    return Container(
      height: 310,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.sellersOtherProduct,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context)!.seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.USER_PROFILE,
                        arguments: {
                          "searchedUserName": product!.seller,
                          "index": 2
                        });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: sellersOtherItems.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DisplayProduct(
                  product: sellersOtherItems[index],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBuyButtonWidget() {
    return Expanded(
      child: CurvedButton(
        isPaymentBtn: true,
        backgroundColor: product?.isProductAvailableNow() ?? false
            ? navyBlue
            : greyBorderColor,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () async {
          if (product?.isProductAvailableNow() ?? false) {
            if (isValidCustomer) {
              //check if product has variant
              if (product?.variantModels?.isNotEmpty ?? false) {
                if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
                  // print("Both color and size lists are showing.");
                  if (selectedVariant != null) {
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message: AppLocalization.of(context)!
                            .selectVariantColorSize);
                  }
                } else if (colorGroups.isNotEmpty && sizeGroups.isEmpty) {
                  // print("color list is showing.");
                  if (selectedVariant != null) {
                    // print("Color list is showing.");
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantColor);
                  }
                } else if (colorGroups.isEmpty && sizeGroups.isNotEmpty) {
                  // print("size list is showing.");
                  if (selectedVariant != null) {
                    // print("Size list is showing.");
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantSize);
                  }
                }
              }
              //check if product has add-ons
              else if (product?.addOnsModels?.isNotEmpty ?? false) {
                bool isRequired =
                    product?.isAllRequiredProductSelected() ?? false;
                if (isRequired == true) {
                  processCartBuyNow(context);
                } else {
                  showToast(
                      message:
                          AppLocalization.of(context)!.selectRequiredAddons);
                }
              } else {
                processCartBuyNow(context);
              }
            } else {
              showToast(
                  message:
                      AppLocalization.of(context)!.youCanNotPurchaseThisItem);
            }
          } else {
            showToast(message: AppLocalization.of(context)!.productOutOfStock);
          }
        },
      ),
    );
  }

  Widget _buildOkButtonWidget() {
    return Expanded(
      child: CurvedButton(
        isPaymentBtn: true,
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Ok",
        onPressed: () async {
          if (product?.addOnsModels?.isNotEmpty ?? false) {
            bool isRequired = product?.isAllRequiredProductSelected() ?? false;
            if (isRequired == true) {
              addToCart();
              Navigator.pop(context);
            } else {
              showToast(
                  message: AppLocalization.of(context)!.selectRequiredAddons);
            }
          }
        },
      ),
    );
  }

  Future<void> processCartBuyNow(BuildContext context) async {
    Product products = product!.copyWith(quantity: 1, withSelectedAddOn: true);

    Variant? variant = selectedVariant?.copyWith(quantity: 1);
    List<AddOns> addOns = products.addOnsModels ?? [];

    ShippingProcessBloc shippingProcessBloc =
        Provider.of<ShippingProcessBloc>(context, listen: false);
    shippingProcessBloc.isUseCartProcess(false);
    List<ShippingAddress> addresses =
        await getAddressListing([product?.addressId]);
    if (addresses.isNotEmpty) {
      shippingProcessBloc.updateBuyNowProduct(
          product, variant, addOns, addresses[0]);
      Navigator.pushNamed(context, Routes.DELIVERY_OPTION);
    } else {
      await Navigator.of(context)
          .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
        "isForSelection": false,
      });
      setState(() {});
    }
    // bool result = await showDisclaimerDialogueForGoods(context);
    // if (result) {
    //   getRecipient();
    //   navigateToSendPayment();
    // }
    return;
  }

  // // Pull the user from the server
  // void getRecipient() async {
  //   customerProfileBloc.customer =
  //       await UserAuth().fetchCustomerProfile(product!.seller);
  // }
  //
  // void navigateToSendPayment() {
  //   basketBloc.productOrService.clear();
  //
  //   List<Map<String, dynamic>> selectedAddOnsCartServerList = [];
  //   List<Map<String, dynamic>> selectedAddOnsList = [];
  //   int addOnPrice = 0;
  //
  //   product?.addOnsModels?.forEach((addOn) {
  //     if (addOn.options != null) {
  //       // Filter the options to include only those with option.isChecked == true
  //       List<AddOnOption> selectedOptions =
  //           addOn.options!.where((option) => option.isChecked == true).toList();
  //
  //       if (selectedOptions.isNotEmpty) {
  //         for (var item in selectedOptions) {
  //           debugPrint("Data From Product addOnPrice : ${item.price}");
  //           addOnPrice += int.parse(item.price.toString());
  //         }
  //
  //         debugPrint("Data From Product addOnPrice Total : ${addOnPrice}");
  //
  //         Map<String, dynamic> selectedAddOn = {
  //           "id": addOn.id,
  //           "options": selectedOptions
  //               .map((option) => {
  //                     "id": option.id,
  //                     "quantity": 1,
  //                     "name": option.name,
  //                     "price": option.price,
  //                     "currency": option.currency,
  //                   })
  //               .toList(),
  //         };
  //
  //         Map<String, dynamic> selectedAddOnServer = {
  //           "id": addOn.id,
  //           "options": selectedOptions
  //               .map((option) => {
  //                     "id": option.id,
  //                     "quantity": 1,
  //                   })
  //               .toList(),
  //         };
  //
  //         selectedAddOnsList.add(selectedAddOn);
  //         selectedAddOnsCartServerList.add(selectedAddOnServer);
  //       }
  //     }
  //   });
  //
  //   debugPrint("Data From Product option : $selectedAddOnsList");
  //   debugPrint(
  //       "Data From Product selectedAddOnsCartServerList : $selectedAddOnsCartServerList");
  //
  //   Map<String, dynamic> variants = {
  //     "id": selectedVariantId,
  //     "quantity": 1,
  //     "current_price": selectedVariantPrice
  //   };
  //
  //   Map<String, dynamic> addOn = {
  //     "id": productId,
  //     "quantity": 1,
  //     "current_price": addOnPrice
  //   };
  //
  //   Map<dynamic, dynamic> result = {};
  //
  //   if (selectedAddOnsCartServerList.isNotEmpty) {
  //     result = {
  //       "type": 'product',
  //       "results": product!.toJson(),
  //       "add_ons": addOn,
  //       "add_ons_list": selectedAddOnsCartServerList,
  //     };
  //   } else {
  //     result = {
  //       "type": 'product',
  //       "results": product!.toJson(),
  //       "variant": variants
  //     };
  //   }
  //
  //   debugPrint('Product check result:::: ${result}');
  //   debugPrint('Product check:::: ${variants}');
  //
  //   basketBloc.buyProductOrServiceNow('product', result);
  //   NavigationUtil.push(context, screen: CheckoutProductService());
  // }

  @override
  void dispose() {
    displayProductImages!.clear();
    _scrollController.dispose();
    sliderIndex.close();
    super.dispose();
  }
}
