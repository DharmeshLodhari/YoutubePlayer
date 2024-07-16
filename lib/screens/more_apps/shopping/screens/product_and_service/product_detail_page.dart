import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
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
import 'package:Slydo/screens/more_apps/yarn/widgets/overlay_yarn_photo.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/cart_with_badge.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../../widget/item_display_card.dart';
import '../../../../home_tab/qr_code_page.dart';
import '../../../payment_and_banking/models/financial_institution.dart';
import '../../../payment_and_banking/models/virtual_account.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../yarn/models/share_as_yarn_model.dart';
import '../../../yarn/share_as_a_yarn_screen.dart';
import '../../../yarn/yarn_auth.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';
import '../../shopping_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final dynamic arguments;

  const ProductDetailPage({super.key, required this.arguments});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
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

  final ScrollController _scrollController = ScrollController();

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

  String moreInformation = "";
  int stockLeft = 0;

  Map<String, List<Variant>> colorGroups = {};
  Map<String, List<Variant>> sizeGroups = {};

  StreamController<Widget> overlayController =
      StreamController<Widget>.broadcast();

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
      final List tempList =
          value.containsKey('results') ? value['results'] as List : [];
      value.containsKey('count') ? reviewCount = value["count"] : 0;
      debugPrint('RESULTS :: ${value['results']}');

      reviewList = [];

      tempList?.forEach((element) {
        reviewList.add(Review.fromJson(element));
      });

      for (var element in reviewList) {
        debugPrint('LIKES :: ${element.likes}');
      }

      isReviewLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      isReviewLoading = false;
      if (mounted) setState(() {});
    });
  }

  Future canReviewProduct() async {
    final Map<String, String> data = {};
    data['provider'] = product?.seller?.toString() ?? "";
    data['buyer'] = userBloc.user.userName!;
    data['type'] = 'products';
    data['id'] = product?.id ?? "";

    debugPrint('product URL :: $data');

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

    isValidCustomer = userBloc.user.userName != product?.seller;
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          customerProfileBloc.customer = null;
          return;
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        floatingActionButton: isValidCustomer ? floatingActionBar() : null,
        body: _buildProductDetailsPage(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        if (isValidCustomer) goToCartWidget() else Container(),
        const SizedBox(
          width: 15,
        ),
        menuBtn(),
        const SizedBox(width: 15),
      ],
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
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
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
        showUserProfileActionsSheet();
      },
      backgroundColor: transparent,
      enableMargin: true,
    );
  }

  void selectShareOptionBottomSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: generateBottomSheetItem(),
              ));
        });
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

  void sendItemToUsersInChat() async {
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

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

  Widget getUserProfile() {
    return GestureDetector(
      child: ClipOval(
        child: SizedBox(
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
                // debugPrint("Both color and size lists are showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message:
                          AppLocalization.of(context)!.selectVariantColorSize);
                }
              } else if (sizeGroups.isNotEmpty && colorGroups.isEmpty) {
                // debugPrint("color list is showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantSize);
                }
              } else if (sizeGroups.isEmpty && colorGroups.isNotEmpty) {
                // debugPrint("size list is showing.");
                if (selectedVariant != null) {
                  showBottomSheetDialog();
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantColor);
                }
              }
            } else if (product?.addOnsModels?.isNotEmpty ?? false) {
              final bool isRequired =
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
                  // debugPrint("Both color and size lists are showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message: AppLocalization.of(context)!
                            .selectVariantColorSize);
                  }
                } else if (sizeGroups.isNotEmpty && colorGroups.isEmpty) {
                  // debugPrint("color list is showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantSize);
                  }
                } else if (sizeGroups.isEmpty && colorGroups.isNotEmpty) {
                  // debugPrint("size list is showing.");
                  if (selectedVariant != null) {
                    addToCart();
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantColor);
                  }
                }
              } else if (product?.addOnsModels?.isNotEmpty ?? false) {
                final bool isRequired =
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

  void showBottomSheetDialog() async {
    final result = await androidBottomSheet(
      context: context,
      child: const AllActiveCart(),
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
    const String type = "product";

    debugPrint("BASKETBLOC:- ${basketBloc.basketItems}");
    final Product products =
        product!.copyWith(quantity: 1, withSelectedAddOn: true);

    basketBloc.addItemToCart(
      item: products,
      type: type,
      variant: selectedVariant?.copyWith(quantity: 1),
      addOns: products.addOnsModels,
      currentUser: userBloc.user.convertToUser(),
    );
  }

  Future<void> addToSharedCart(SharedCartModel result) async {
    const String type = "product";

    final Product products =
        product!.copyWith(quantity: 1, withSelectedAddOn: true);

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
        final List<Variant> variantsList =
            (element['item'] as Product).variantModels ?? [];

        // debugPrint('fola chat one fourrrr::: ${variantsList.length}');

        // Initialize dataInfo with common information
        dataInfo = {
          "id": item.id,
          "type": type,
        };

        // Check if variantsList is not empty
        if (variantsList.isNotEmpty) {
          final List<Map<String, dynamic>> variantDataList = [];

          // Iterate through the variants and add each variant to the variantDataList
          for (var variant in variantsList) {
            if (variant.id != null) {
              final int variantId = int.parse(variant.id.toString());
              final int? variantQuantity = variant.quantity;

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

  int getTotalVariantQuantity(List<dynamic> variantsList) {
    int totalQuantity = 0;

    if (variantsList.isNotEmpty) {
      // Iterate through the productView and add them to dataInfo
      for (var variant in variantsList) {
        if (variant.containsKey("id") && variant["id"] != null) {
          final int variantQuantity = int.parse(variant['quantity'].toString());
          totalQuantity += variantQuantity;
        }
      }
    }

    return totalQuantity;
  }

  Widget floatingActionBar() {
    return widget.arguments["type"] == "changeAddons"
        ? Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: _buildOkButtonWidget(),
            ),
          )
        : Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
              child: Row(
                children: <Widget>[
                  messageSellerWidget(),
                  const SizedBox(
                    width: 8,
                  ),
                  addToCartWidget(),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildBuyButtonWidget(),
                ],
              ),
            ),
          );
  }

  Widget _buildProductDetailsPage(BuildContext context) {
    if (productIsLoading) {
      return buildProductShimmerLoadingIndicator(isLoading: productIsLoading);
    }

    return ListView(
      controller: _scrollController,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProductImagesWidgets(),
            Container(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildProductTitleAndPriceWidget(),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildShortInfoWidget(),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  if (product?.availableFrom?.isAfter(DateTime.now()) ?? false)
                    _showAvailableDate(),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildDescriptionWidget(),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (product?.addOnsModels?.isNotEmpty == true) ...[
                    _buildAddonWidget(),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSellerInfoWidget(),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildReviewList(),
                  ),
                  const SizedBox(height: 16),
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
            const SizedBox(
              height: 16,
            ),
            if (isOtherItemIsEmpty)
              Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: greyBorderColor,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
            else
              sellersOtherItems.isEmpty
                  ? Container()
                  : _buildSellersOtherProducts(),
            SizedBox(height: isValidCustomer ? 60.0 : 20),
          ],
        ),
      ],
    );
  }

  Widget _showAvailableDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildAvailableFromAndShareWidgets(),
        ),
        const SizedBox(
          height: 16,
        ),
        Divider(
          height: 0,
          color: dividerColor,
          thickness: 1,
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
    return reviewList.isEmpty
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
              const SizedBox(height: 12),
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
            final result = await Navigator.of(context).pushNamed(
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
          child: SizedBox(
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductImagesWidgets() {
    return StreamBuilder<int>(
        initialData: 0,
        stream: sliderIndex.stream,
        builder: (context, snapshot) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: displayProductImages?.length == 0
                ? AspectRatio(
                    aspectRatio: 1.5,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : displayProductImages?.length == 1
                    ? GestureDetector(
                        onTap: () {
                          if (displayProductImages?[0] != null) {
                            // Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                            //     arguments: displayProductImages?[0]);
                            showSliderGallery(displayProductImages);
                          }
                        },
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: Center(
                                  child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      placeholder: (context, url) => Center(
                                          child: CircularLoadingIndicator()),
                                      imageUrl: displayProductImages?[0] ?? "",
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                      errorWidget:
                                          productAndServiceBigErrorWidget,
                                    ),
                                    productStockAndDetailTag(),
                                  ],
                                ),
                              )),
                            ),
                            // getOutOfStockTag(),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                    enableInfiniteScroll: false,
                                    viewportFraction: 1.0,
                                    enlargeCenterPage: true,
                                    autoPlay: false,
                                    aspectRatio: 1.5,
                                    onPageChanged: (index, _) {
                                      sliderIndex.sink.add(index);
                                    }),
                                items: displayProductImages!
                                    .map(
                                      (item) => GestureDetector(
                                        onTap: () {
                                          if (item != null) {
                                            // Navigator.of(context).pushNamed(
                                            //     Routes.PHOTO_VIEWER,
                                            //     arguments: item);

                                            showSliderGallery(
                                                displayProductImages);
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
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
                                                    productStockAndDetailTag(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // getOutOfStockTag(),
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
                                    final int index =
                                        displayProductImages!.indexOf(url);
                                    return Container(
                                      width: 5.0,
                                      height: 5.0,
                                      margin: const EdgeInsets.symmetric(
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

  Future<void> showSliderGallery(List<String?>? displayProductImages) {
    final List<Widget> imageList = [];

    for (var item in displayProductImages ?? []) {
      imageList.add(Image.network(item));
    }
    return SwipeImageGallery(
      context: context,
      children: imageList,
      onSwipe: (index) {
        overlayController.add(OverlayYarnPhoto(
          title: '${index + 1}/${imageList.length}',
        ));
      },
      overlayController: overlayController,
      initialOverlay: OverlayYarnPhoto(
        title: '1/${imageList.length}',
      ),
    ).show();
  }

  Widget productStockAndDetailTag() {
    if (product?.availableFrom?.isAfter(DateTime.now()) ?? false) {
      return Positioned(
        top: 20,
        right: 10,
        child: showColoredLabeledWidget(
            text: AppLocalization.of(context)!.comingSoon, color: starYellow),
      );
    } else if (product?.trackInventory == true &&
        ((product?.quantity ?? 0) <= 0)) {
      return Positioned(
        top: 20,
        right: 10,
        child: showColoredLabeledWidget(
            text: AppLocalization.of(context)!.outOfStock, color: red),
      );
    } else if ((product?.discountedPrice != null &&
            product?.discountedPrice != 0) ||
        (product?.pricePercentageChange != null &&
                product?.pricePercentageChange != 0.0 ||
            selectedVariant != null)) {
      return buildDiscountPrice();
    } else {
      return const SizedBox();
    }
  }

  Widget buildDiscountPrice() {
    if (selectedVariant != null) {
      if (product?.checkVariantDiscount(selectedVariant) ?? false) {
        return Positioned(
          top: 20,
          right: 10,
          child: showDiscountValue(
            selectedVariant?.discountType ?? "",
            selectedVariant?.discountValue ?? 0,
            selectedVariant?.currency,
          ),
        );
      } else {
        return const SizedBox();
      }
    } else if (product?.discountedPrice != null &&
        product?.discountedPrice != 0) {
      if (product?.checkProductDiscount() ?? false) {
        return Positioned(
          top: 20,
          right: 10,
          child: showDiscountValue(
            product?.discountType ?? "",
            product?.discountValue ?? 0,
            product?.currency,
          ),
        );
      } else {
        return const SizedBox();
      }

      //   if (product!.pricePercentageChange != 0.0) ...[
      // Positioned(
      // top: 8,
      // right: 100,
      // child: Container(
      // padding: EdgeInsets.only(
      // left: 6.0,
      // right: 6.0,
      // top: 4.0,
      // bottom: 4.0),
      // decoration: BoxDecoration(
      // color: naturalGreen,
      // borderRadius: BorderRadius.all(
      // Radius.circular(8)),
      // ),
      // child: Text(
      // "${product!.pricePercentageChange!.toInt()}% off",
      // style: TextStyle(
      // color: Colors.white,
      // ),
      // ),
      // ),
      // ),
      // ]
    } else if (product!.pricePercentageChange != 0.0) {
      return Positioned(
        top: 8,
        right: 100,
        child: Container(
          padding: const EdgeInsets.only(
              left: 6.0, right: 6.0, top: 4.0, bottom: 4.0),
          decoration: BoxDecoration(
            color: naturalGreen,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Text(
            "${product!.pricePercentageChange!.toInt()}% off",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
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
    return const SizedBox.shrink();
  }

  void fetchProduct(String productId) async {
    debugPrint('PRODUCT ID ::$productId');
    if (mounted) {
      setState(() {
        productIsLoading = true;
      });
    }
    await _auth.getProduct(productId).then((value) {
      if (value != null) {
        product = value;

        displayProductImages = product!.serverImages;
        productIsLoading = false;

        //     Variant.convertToVariantList(product!.variantModels!);

        moreInformation = product!.description.toString();

        // addOnList = product!.addOns != null
        //     ? AddOns.convertToAddOnList(product!.addOns!)
        //     : [];

        colorGroups = {};
        sizeGroups = {};
        colorGroups =
            product?.getVariants(variantType: VariantTypes.Color) ?? {};
        sizeGroups = product?.getVariants(variantType: VariantTypes.Size) ?? {};

        if (mounted) setState(() {});
      } else {
        if (mounted) {
          setState(() {
            productIsLoading = false;
          });
        }
        Navigator.pop(context);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          productIsLoading = false;
        });
      }
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
  //
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
    final bool allKeysAreNullOrEmpty = areAllKeysNullOrEmpty(sizeGroups);
    final bool allKeysAreNullOrEmptyColor = areAllKeysNullOrEmpty(colorGroups);

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
                  _buildProductName(),
                  _buildDiscountedPrice(),
                  if ((product?.checkProductDiscount() ?? false) ||
                      (product?.checkVariantDiscount(selectedVariant) ?? false))
                    _buildOriginalPrice(),
                  const SizedBox(height: 5),
                  getRating(numberOfRating: product?.rating!.toInt()),
                  stockStatus(),
                ],
              ),
            ),
            qrCodeIcon(),
          ],
        ),
        if (!allKeysAreNullOrEmptyColor) _buildVariantColor(),
        if (!allKeysAreNullOrEmpty) _buildVariantSize(),
      ],
    );
  }

  Widget _buildProductName() {
    return Text(
      //name,
      messageDecoderWithEmoji(product?.name) ?? "",
      style: TextStyle(
          fontSize: 16, color: blackFont, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDiscountedPrice() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            worldCurrencies[product?.currency] ?? "NGN",
            style: TextStyle(
                fontFamily: "Inter",
                fontSize: 18.0,
                color: navyBlue,
                fontWeight: FontWeight.bold),
          ),
          Text(
            moneyDisplayNormalizer(
                product?.getDiscountedPrice(selectedVariant)),
            style: TextStyle(
                fontSize: 18.0, color: navyBlue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalPrice() {
    return Row(
      children: [
        Text(
          worldCurrencies[product!.currency] ?? "NGN",
          style: TextStyle(
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            fontSize: 12.8,
            color: navyBlue,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Text(
          moneyDisplayNormalizer(product?.getOriginalPrice(selectedVariant)),
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: navyBlue,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  Widget stockStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stockLeft >= 10) ...[
          const SizedBox(
            height: 10.0,
          ),
          Text(
            'In Stock',
            style: TextStyle(
                fontSize: 16, color: naturalGreen, fontWeight: FontWeight.bold),
          ),
        ] else if (stockLeft == 0) ...[
          const SizedBox.shrink()
        ] else if (stockLeft <= 9) ...[
          const SizedBox(
            height: 10.0,
          ),
          Text(
            'Only ${stockLeft.toString()} left in stock',
            style: TextStyle(
                fontSize: 16, color: mateRed, fontWeight: FontWeight.bold),
          ),
        ]
      ],
    );
  }

  Widget _buildVariantColor() {
    return Column(
      children: [
        const SizedBox(
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
            const SizedBox(
              width: 5.0,
            ),
            Text(
              selectedVariant?.getColor() ?? "",
              style: TextStyle(
                  fontSize: 14, color: blackFont, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        showVariantColorSelection(),
      ],
    );
  }

  Widget _buildVariantSize() {
    return Column(
      children: [
        const SizedBox(
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
            const SizedBox(
              width: 5.0,
            ),
            Text(
              selectedVariant?.getSize() ?? "",
              style: TextStyle(
                  fontSize: 14, color: blackFont, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        showVariantSizes(),
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
        final Map<String, dynamic> financial = {};

        final VirtualAccount virtualAccount = VirtualAccount(
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
                  "https://slydo.co/store/${product!.seller}/products/${product!.id}"
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
    final int itemCount =
        colorGroups.length; // Replace with your actual item count
    const int maxItemsPerRow = 5;
    final int totalColumns = calculateColumnCount(itemCount, maxItemsPerRow);

    return SizedBox(
      height: 82.0 * totalColumns,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 1.1,
        ),
        // scrollDirection: Axis.horizontal,
        itemCount: colorGroups.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final String color = colorGroups.keys.elementAt(index);
          final List<Variant> variantsWithSize = colorGroups[color]!;

          // Get the first variant with this size (assuming at least one variant exists)

          final Variant availableVariant = getVariantImage(variantsWithSize);

          return Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: GestureDetector(
              onTap: () {
                /// IMAGE DISPLAY ACCORDING TO COLOR STARTS
                //update the price, more information and list of images
                displayProductImages = [];

                // Get the ID of the selected image
                final String? selectedImageId = availableVariant.id;

                // Find the variant in the original list by ID
                final Variant selectedVariant = (product?.variantModels ?? [])
                    .firstWhere((variant) => variant.id == selectedImageId);

                this.selectedVariant = variantsWithSize.first;

                // Retrieve all images associated with the selected variant
                final List<String?>? allImages = selectedVariant.serverImages;
                // Now you have all the images for the selected variant
                displayProductImages = allImages;

                /// IMAGE DISPLAY ACCORDING TO COLOR ENDS

                /// STOCK AVAILABILITY CHECK START
                final bool allKeysAreNullOrEmpty =
                    areAllKeysNullOrEmpty(sizeGroups);

                if (allKeysAreNullOrEmpty) {
                  // for (int index = 0;
                  //     index < variantsWithSize.length;
                  //     index++) {
                  final Variant variant = availableVariant;
                  // Update price or any other state based on the selected variant
                  stockLeft = variant.getQuantity();
                  // }
                } else {
                  //set the selected size to zero
                  // selectedSizeIndex = -1;
                  // this.selectedVariant = null;
                }

                /// STOCK AVAILABILITY CHECK ENDS

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
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
    final int itemCount =
        sizeGroups.length; // Replace with your actual item count
    const int maxItemsPerRow = 3;
    final int totalColumns = calculateColumnCount(itemCount, maxItemsPerRow);

    return SizedBox(
      height: 35.0 * totalColumns,
      child: GridView.builder(
        // gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // maxCrossAxisExtent: maxTextLengthWithSpace, // Maximum width for each item
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        itemCount: sizeGroups.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final String size = sizeGroups.keys.elementAt(index);
          final List<Variant> variantsWithSize = sizeGroups[size]!;

          for (int index = 0; index < variantsWithSize.length; index++) {
            final Variant variant = variantsWithSize[index];
            if (variant.value == null) {
              return const SizedBox.shrink();
            }
          }

          return GestureDetector(
            onTap: () {
              for (int index = 0; index < variantsWithSize.length; index++) {
                final Variant variant = variantsWithSize[index];

                stockLeft = variant.getQuantity();
              }
              selectedVariant = variantsWithSize.first;

              if (mounted) setState(() {});
            },
            child: SizedBox(
              height: 20.0,
              child: Container(
                // height: 20.0,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: selectedVariant?.value == size ? black : white,
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  border: Border.all(
                    color: black,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    messageDecoderWithEmoji(size) ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedVariant?.value == size
                          ? white
                          : blackFont.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(10),
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
        const SizedBox(
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
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: lightGrey),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                SlydoAppIcon.date,
                color: Colors.black,
                size: 16,
              ),
              const SizedBox(
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
        const SizedBox(
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
        const SizedBox(
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
        const SizedBox(
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
              const SizedBox(
                height: 8,
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
    return SizedBox(
      height: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
        // backgroundColor: product?.isProductAvailableNow() ?? false
        //     ? navyBlue
        //     : greyBorderColor,
        backgroundColor: greyBorderColor,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () async {
          // if (product?.isProductAvailableNow() ?? false) {
          //   if (isValidCustomer) {
          //     //check if product has variant
          //     if (product?.variantModels?.isNotEmpty ?? false) {
          //       if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
          //         // debugPrint("Both color and size lists are showing.");
          //         if (selectedVariant != null) {
          //           processCartBuyNow(context);
          //         } else {
          //           showToast(
          //               message: AppLocalization.of(context)!
          //                   .selectVariantColorSize);
          //         }
          //       } else if (colorGroups.isNotEmpty && sizeGroups.isEmpty) {
          //         // debugPrint("color list is showing.");
          //         if (selectedVariant != null) {
          //           // debugPrint("Color list is showing.");
          //           processCartBuyNow(context);
          //         } else {
          //           showToast(
          //               message:
          //                   AppLocalization.of(context)!.selectVariantColor);
          //         }
          //       } else if (colorGroups.isEmpty && sizeGroups.isNotEmpty) {
          //         // debugPrint("size list is showing.");
          //         if (selectedVariant != null) {
          //           // debugPrint("Size list is showing.");
          //           processCartBuyNow(context);
          //         } else {
          //           showToast(
          //               message:
          //                   AppLocalization.of(context)!.selectVariantSize);
          //         }
          //       }
          //     }
          //     //check if product has add-ons
          //     else if (product?.addOnsModels?.isNotEmpty ?? false) {
          //       final bool isRequired =
          //           product?.isAllRequiredProductSelected() ?? false;
          //       if (isRequired == true) {
          //         processCartBuyNow(context);
          //       } else {
          //         showToast(
          //             message:
          //                 AppLocalization.of(context)!.selectRequiredAddons);
          //       }
          //     } else {
          //       processCartBuyNow(context);
          //     }
          //   } else {
          //     showToast(
          //         message:
          //             AppLocalization.of(context)!.youCanNotPurchaseThisItem);
          //   }
          // } else {
          //   showToast(message: AppLocalization.of(context)!.productOutOfStock);
          // }
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
            final bool isRequired =
                product?.isAllRequiredProductSelected() ?? false;
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
    final Product products =
        product!.copyWith(quantity: 1, withSelectedAddOn: true);

    final Variant? variant = selectedVariant?.copyWith(quantity: 1);
    final List<AddOns> addOns = products.addOnsModels ?? [];

    final ShippingProcessBloc shippingProcessBloc =
        Provider.of<ShippingProcessBloc>(context, listen: false);
    shippingProcessBloc.isUseCartProcess(false);
    final List<ShippingAddress> addresses =
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
