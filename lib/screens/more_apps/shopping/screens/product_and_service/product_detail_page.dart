import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/checkout_product_service.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/disclaimer_dialogue_for_goods.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../../widget/item_display_card.dart';
import '../../../../home_tab/qr_code_page.dart';
import '../../../payment_and_banking/models/FinancialInstitution.dart';
import '../../../payment_and_banking/models/VirtualAccount.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../user_profile/user_auth.dart';
import '../../../yarn/models/share_as_yarn_model.dart';
import '../../../yarn/share_as_a_yarn_screen.dart';
import '../../../yarn/yarn_auth.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';
import '../../shopping_auth.dart';
import '../checkout_screen.dart';

class ProductDetailPage extends StatefulWidget {
  var arguments;

  ProductDetailPage({required this.arguments});

  @override
  _ProductDetailPageState createState() =>
      _ProductDetailPageState(arguments: arguments);
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  var arguments;
  bool canRate = false;

  _ProductDetailPageState({this.arguments});

  final _auth = ShoppingAuthService();
  Product? product;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc? userBloc;
  late BasketBloc basketBloc;
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
  List<Variant> productVariantList = [];
  List<String> oneImageEach = [];
  String selectedColor = "";
  String selectedSize = "";
  String selectedVariantId = "";
  String selectedVariantImage = "";
  String selectedVariantPrice = "";
  int selectedImageColorIndex = -1;
  int selectedSizeIndex = -1;
  String price = "";
  String moreInformation = "";
  int stockLeft = 0;
  Map<String, List<Variant>> colorGroups = {};
  Map<String, List<Variant>> sizeGroups = {};
  String staticImage = "";
  List addOnList = [];
  ScrollController scrollControllerAddOn = ScrollController();
  bool isLoading = false;
  @override
  void initState() {
    product = arguments[
        'product']; // We get this when we are coming from the product list page.
    if (product != null) {
      productId = product!.id;
    } else {
      productId = arguments[
          'productId']; // We get this when we are coming from the moment detail page.
    }

    userBloc = Provider.of<UserBloc>(context, listen: false);

    if (mounted) setState(() {});
    fetchProduct(productId!);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isOtherItemFetched) {
          getOtherItems();
        }
      }
    });
    canReviewProduct();

    fetchReviewList();
    super.initState();
  }

  void fetchReviewList() async {
    isReviewLoading = true;
    if (mounted) setState(() {});

    await ReviewAuth().fetchProductReviews(product: product).then((value) {
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
    data['provider'] = product!.seller!.toString();
    data['buyer'] = userBloc!.user.userName!;
    data['type'] = 'products';
    data['id'] = product!.id!;

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
    _auth
        .ownersOrderProductsAndServices(
            type: "products", userId: product!.seller, exclude: product!.id)
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
            isOtherItemIsEmpty = true;
          });
        }
      }
    });
    isOtherItemFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    if (productIsLoading) {
      return Scaffold(
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }
    basketBloc = Provider.of<BasketBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    isValidCustomer = userBloc?.user.userName != product!.seller;
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

        var shareBody = "http://slydo.co/store/${product!.seller}/products/" +
            product!.id.toString();
        Share.share(shareBody, subject: "${product!.name}");
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
        product!.id! +
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
      "author": userBloc?.user.userName,
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
            padding: basketBloc.items.length == 0
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
            arguments: {"searchedUserName": product!.seller});
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
            'recipient': product!.seller,
            'subject': product!.name,
          });
        } else {
          showToast(message: "You can not message yourself !!");
        }
      },
    );
  }

  Widget addToCartWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: product!.isAvailable! ? navyBlue : greyBorderColor,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        if (product!.isAvailable!) {
          if (isValidCustomer) {
            if (productVariantList.isNotEmpty) {
              if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
                // print("Both color and size lists are showing.");
                if (selectedColor.isNotEmpty && selectedSize.isNotEmpty) {
                  addToCart();
                  return true;
                } else {
                  showToast(
                      message:
                          AppLocalization.of(context)!.selectVariantColorSize);
                }
              } else if (sizeGroups.isNotEmpty && colorGroups.isEmpty) {
                // print("color list is showing.");
                if (selectedSize.isNotEmpty) {
                  addToCart();
                  return true;
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantSize);
                }
              } else if (sizeGroups.isEmpty && colorGroups.isNotEmpty) {
                // print("size list is showing.");
                if (selectedColor.isNotEmpty) {
                  addToCart();
                  return true;
                } else {
                  showToast(
                      message: AppLocalization.of(context)!.selectVariantColor);
                }
              }
            } else if (addOnList.isNotEmpty) {
              addToCart();
              return true;
            } else {
              //product has no variant or is a service
              addToCart();
              return true;
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
    );
  }

  Future<void> addToCart() async {
    String type = product is Product ? "product" : "service";
    Map<String, dynamic> variantPayLoad = {};
    Map<String, dynamic> addOnPayLoad = {};
    List<Map<String, dynamic>> selectedAddOnsCartServerList = [];
    List<Map<String, dynamic>> selectedAddOnsList = [];

    Product productSend = product!;
    productSend = productSend.copyWith(quantity: 1);
    if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
      variantPayLoad = {
        "id": selectedVariantId,
        "quantity": 1,
        "image": selectedVariantImage,
        "price": selectedVariantPrice,
        "colour": selectedColor,
        "value": selectedSize,
        "type": "Color n Size",
      };
    } else if (colorGroups.isNotEmpty) {
      variantPayLoad = {
        "id": selectedVariantId,
        "quantity": 1,
        "image": selectedVariantImage,
        "price": selectedVariantPrice,
        "colour": selectedColor,
        "type": "Color",
      };
    } else if (sizeGroups.isNotEmpty) {
      variantPayLoad = {
        "id": selectedVariantId,
        "quantity": 1,
        "image": selectedVariantImage,
        "price": selectedVariantPrice,
        "value": selectedSize,
        "type": "Size",
      };
    }
    addOnList.forEach((addOn) {
      if (addOn.options != null) {
        // Filter the options to include only those with option.isChecked == true
        List<AddOnOption> selectedOptions =
            addOn.options!.where((option) => option.isChecked == true).toList();

        if (selectedOptions.isNotEmpty) {
          Map<String, dynamic> selectedAddOn = {
            "id": addOn.id,
            "options": selectedOptions
                .map((option) => {
                      "id": option.id,
                      "quantity": 1,
                      "name": option.name,
                      "price": option.price,
                      "currency": option.currency,
                    })
                .toList(),
          };

          Map<String, dynamic> selectedAddOnServer = {
            "id": addOn.id,
            "options": selectedOptions
                .map((option) => {
                      "id": option.id,
                      "quantity": 1,
                    })
                .toList(),
          };

          selectedAddOnsList.add(selectedAddOn);
          selectedAddOnsCartServerList.add(selectedAddOnServer);
        }
      }
    });

    // debugPrint("Data From Product Page v-id : $selectedVariantId");
    // debugPrint("Data From Product Page v-id : $variantPayLoad");
    // debugPrint("Data From Product Page v-id one : ${basketBloc.items}");
    if (selectedAddOnsList.isNotEmpty && addOnList.isNotEmpty) {
      addOnPayLoad = {
        "id": productId,
        "qty": 1,
        "type": type,
        "add_ons": selectedAddOnsList,
      };

      // basketBloc.addItemInBasketWithAddOns(product, type, selectedAddOnsCartServerList);
      basketBloc.addItemToCart(
          item: productSend,
          type: type,
          variant: null,
          addOns: selectedAddOnsList);

      await _auth.addItemToShoppingCart(addOnPayLoad);
      return;
    }
    if (basketBloc.items.isEmpty && variantPayLoad.isNotEmpty) {
      basketBloc.addItemToCart(
          item: productSend, type: type, variant: variantPayLoad, addOns: null);
    } else {
      for (var item in basketBloc.items) {
        Product productInCart = item['item'];

        if (productInCart.id.toString() == productId) {
          List variantList = item['item'].variant;

          for (var variant in variantList) {
            if (variant['id'].toString() == selectedVariantId) {
              int currentQuantity = int.parse(variant['quantity'].toString());
              variant['quantity'] = currentQuantity + 1;

              Map<String, dynamic> dataInfo =
                  getUpdatedCartItem(productId!, type);
              await _auth.addItemToShoppingCart(dataInfo);
              return;
            }
          }

          basketBloc.addItemToCart(
              item: productSend,
              type: type,
              variant: variantPayLoad,
              addOns: null);

          // debugPrint("Data From Product Page v-id 2 : $variantPayLoad");
          // debugPrint("Data From Product Page v-id 3 : $variantList");

          Map<String, dynamic> dataInfo = getUpdatedCartItem(productId!, type);
          debugPrint("Data From Product Page exist : $dataInfo");

          await _auth.addItemToShoppingCart(dataInfo);
          // for(var item in basketBloc.items){
          //   // Product productInCart = item['item'];
          //   List variantList = item['item'].variant;
          //   debugPrint('fola chat one twoo::: ${variantList.length}');
          //   debugPrint('fola chat one twoo::: ${item['item'].variant}');
          // }
          return;
        }
      }

      // Product ID doesn't exist in the cart, add it with the variant
      basketBloc.addItemToCart(
          item: productSend, type: type, variant: variantPayLoad, addOns: null);
    }

    Map<String, dynamic> dataInfo = getUpdatedCartItem(productId!, type);
    debugPrint("Data From Product Page : $dataInfo");

    await _auth.addItemToShoppingCart(dataInfo);
  }

  Map<String, dynamic> getUpdatedCartItem(String productId, String type) {
    Map<String, dynamic> dataInfo = {};

    for (var element in basketBloc.items) {
      final item = element["item"];
      int totalVariantQuantity = 0;

      if (element["variants"] != null &&
          element.containsKey("variants") &&
          productId == item.id) {
        List variantsList = element['item'].variant;

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
            if (variant.containsKey("id") && variant["id"] != null) {
              int variantId = int.parse(variant["id"].toString());
              int variantQuantity = int.parse(variant["quantity"].toString());

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
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;

    basketBloc.items.forEach((element) {
      totalItem = totalItem + int.parse(element['qty'].toString());
    });

    // for (var item in basketBloc.items) {
    //
    //    if (item['item'] is Product) {
    //     var product = item['item'] as Product;
    //
    //     if (product.variant!.isEmpty && product.variant != null) {
    //       // If the variant list is empty, add the quantity to the total
    //       totalItem += int.parse(item['qty'].toString());
    //     } else {
    //       // If there are variants, calculate the total quantity from variants
    //       for(var variant in product.variant!){
    //         var vProduct = Variant.fromJson(variant);
    //         totalItem += int.parse(vProduct.quantity.toString());
    //       }
    //     }
    //
    //   } else if (item['item'] is Service) {
    //     totalItem += int.parse(item['qty'].toString());
    //   }
    // }

    return totalItem;
  }

  Widget floatingActionBar() {
    return Card(
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
                  if (addOnList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildAddonWidget(),
                    ),
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
            isOtherItemIsEmpty ? Container() : _buildSellersOtherProducts(),
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
    if (product?.seller == userBloc?.user.userName) {
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
            child: displayProductImages!.length == 0
                ? AspectRatio(
                    aspectRatio: 1.7,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : displayProductImages?.length == 1
                    ? Stack(
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
                                      imageUrl: displayProductImages?[0] ?? "",
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                      errorWidget:
                                          productAndServiceBigErrorWidget,
                                    ),
                                    if (checkDiscount(
                                        product!.discountIsActive!,
                                        product!.discountedPrice!,
                                        num.parse(product!.price!)))
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
                                      (item) => Stack(
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
                                                    fit: BoxFit.fitHeight,
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
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8)),
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
                                          getOutOfStockTag(),
                                        ],
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
    if (!product!.isAvailable!) {
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
      staticImage = product!.serverImages![0]!;
      productIsLoading = false;
      productVariantList = Variant.convertToVariantList(product!.variant!);

      //get the price and more information to string
      price = product!.price.toString();
      moreInformation = product!.description.toString();

      addOnList = product!.addOns != null
          ? AddOns.convertToAddOnList(product!.addOns!)
          : [];

      colorGroups = {};
      sizeGroups = {};
      colorGroups = groupVariantsByColor(productVariantList);
      sizeGroups = groupVariantsBySize(productVariantList);

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

  // Group variants by color
  Map<String, List<Variant>> groupVariantsByColor(List<Variant> variants) {
    Map<String, List<Variant>> groupedVariants = {};

    for (var variant in variants) {
      if (variant.colour != null && variant.colour!.isNotEmpty) {
        if (!groupedVariants.containsKey(variant.colour!)) {
          groupedVariants[variant.colour!] = [];
        }
        groupedVariants[variant.colour]!.add(variant);
      }
    }

    return groupedVariants;
  }

  // Group variants by size
  Map<String, List<Variant>> groupVariantsBySize(List<Variant> variants) {
    Map<String, List<Variant>> groupedVariants = {};

    for (var variant in variants) {
      if (variant.value != null && variant.value!.isNotEmpty) {
        if (!groupedVariants.containsKey(variant.value)) {
          groupedVariants[variant.value!] = [];
        }
        groupedVariants[variant.value]!.add(variant);
      }
    }

    return groupedVariants;
  }

  // Define a function to group variants by size for the selected color/image
  Map<String, List<Variant>> groupVariantsBySizeForSelectedColor(
      String selectedColor, List<Variant> allVariants) {
    Map<String, List<Variant>> sizeGroups = {};

    // Filter variants that match the selected color
    List<Variant> selectedColorVariants = allVariants
        .where((variant) => variant.colour == selectedColor)
        .toList();

    // Group the selected color variants by size, only if variant.value is not empty or null
    for (var variant in selectedColorVariants) {
      if (variant.value != null && variant.value!.isNotEmpty) {
        if (!sizeGroups.containsKey(variant.value)) {
          sizeGroups[variant.value!] = [];
        }
        sizeGroups[variant.value]!.add(variant);
      }
    }

    return sizeGroups;
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

  bool hasVariantsWithoutColor(
      List<Variant> productVariantList, String variantId) {
    // Iterate through the productVariantList
    for (var variant in productVariantList) {
      // Check if the variant has the specified variantId
      if (variant.id == variantId) {
        // Check if the variant has a color
        if (variant.colour == null || variant.colour!.isEmpty) {
          // Variant has no color
          return true;
        }
      }
    }
    // No variants without color found for the specified variantId
    return false;
  }

  bool hasVariantsWithoutSize(
      List<Variant> productVariantList, String variantId) {
    // Iterate through the productVariantList
    for (var variant in productVariantList) {
      // Check if the variant has the specified variantId
      if (variant.id == variantId) {
        // Check if the variant has a color
        if (variant.value == null || variant.value!.isEmpty) {
          // Variant has no color
          return true;
        }
      }
    }
    // No variants without color found for the specified variantId
    return false;
  }

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
                    messageDecoderWithEmoji(product!.name)!,
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
                          worldCurrencies[product!.currency!]!,
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 18.0,
                              color: navyBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          moneyDisplayNormalizer(int.parse(((checkDiscount(
                                  product!.discountIsActive!,
                                  product!.discountedPrice!,
                                  num.parse(product!.price!)))
                              ? product!.discountedPrice.toString()
                              : product!.price!))),
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
                      if (checkDiscount(
                          product!.discountIsActive!,
                          product!.discountedPrice!,
                          num.parse(product!.price!)))
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
                              moneyDisplayNormalizer(
                                  int.parse(product!.price!)),
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
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                selectedColor,
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
          showVariantFirstImages(),
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
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                selectedSize,
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

  String getVariantImage(List<Variant> variantsWithSize) {
    String? image;

    for (Variant img in variantsWithSize) {
      if (img.serverImages!.isNotEmpty) {
        image = img.serverImages!.first;
        break;
      }
    }
    return image!;
  }

  Widget showVariantFirstImages() {
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

          String image = getVariantImage(variantsWithSize);

          return Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: GestureDetector(
              onTap: () {
                //update the price, more information and list of images
                displayProductImages = [];
                selectedColor = color;
                selectedImageColorIndex = index;

                // Get the ID of the selected image
                String? selectedImageId = variantsWithSize[0].id;

                // Find the variant in the original list by ID
                Variant selectedVariant = productVariantList
                    .firstWhere((variant) => variant.id == selectedImageId);

                // Retrieve all images associated with the selected variant
                List<String?>? allImages = selectedVariant.serverImages;

                // Now you have all the images for the selected variant
                displayProductImages = allImages;
                bool allKeysAreNullOrEmpty = areAllKeysNullOrEmpty(sizeGroups);

                if (allKeysAreNullOrEmpty) {
                  for (int index = 0;
                      index < variantsWithSize.length;
                      index++) {
                    Variant variant = variantsWithSize[index];
                    // Update price or any other state based on the selected variant
                    price = variant.price!;
                    selectedVariantId = variant.id!;
                    selectedVariantImage = variant.serverImages![0]!;
                    selectedVariantPrice = variant.price!;
                    stockLeft = int.parse(variant.quantity!);
                  }
                } else {
                  //set the selected size to zero
                  selectedSizeIndex = -1;
                }

                sizeGroups = {};
                selectedSize = "";
                sizeGroups = groupVariantsBySizeForSelectedColor(
                    selectedColor, productVariantList);

                //check if size is not empty, set stock to zero
                if (sizeGroups.isNotEmpty && selectedSizeIndex == -1) {
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
                    color:
                        index == selectedImageColorIndex ? black : transparent,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CachedNetworkImage(
                      imageUrl: image,
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
              selectedSize = sizeGroups.keys.elementAt(index);
              selectedSizeIndex = index;

              for (int index = 0; index < variantsWithSize.length; index++) {
                Variant variant = variantsWithSize[index];
                // Update price or any other state based on the selected variant
                price = variant.price!;
                selectedVariantId = variant.id!;
                selectedVariantImage = variant.serverImages!.isNotEmpty
                    ? variant.serverImages![0]!
                    : staticImage;
                selectedVariantPrice = variant.price!;
                stockLeft = int.parse(variant.quantity!);
              }

              if (mounted) setState(() {});
            },
            child: SizedBox(
              height: 20.0,
              child: Container(
                // height: 20.0,
                decoration: BoxDecoration(
                  color: index == selectedSizeIndex ? black : white,
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
                        color: index == selectedSizeIndex ? white : blackFont,
                        fontWeight: FontWeight.bold),
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
        Text(
          "Available Add-ons",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          "Spices up your orders with the available aad-ons below.",
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
          textAlign: TextAlign.justify,
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
        ...addOnList.map((addon) => addOnTile(addOns: addon)).toList()
      ],
    );
  }

  Widget _buildAddonList() {
    return Container(
      // height: 200,
      height: 100 * addOnList.length.toDouble(),
      child: ListView.builder(
        // physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        //+1 for progressbar
        itemCount: addOnList.length + 1,
        controller: scrollControllerAddOn,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          if (index == addOnList.length) {
            return buildLoadingIndicator(isLoading: isLoading);
          } else {
            return addOnTile(
              addOns: addOnList[index],
            );
          }
        },
      ),
    );
  }

  Widget addOnTile({required AddOns addOns}) {
    List<AddOnOption>? addOnOption = addOns.options;

    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1, color: greyBorderColor),
        //   borderRadius: BorderRadius.all(Radius.circular(10)),
        // ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appendStringDot(addOns.name!, 15),
                  maxLines: 1,
                  style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: navyBlue),
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    color: addOns.isRequired == true ? navyBlue : white,
                  ),
                  child: Text(
                    addOns.isRequired == true ? 'Required' : 'Optional',
                    maxLines: 1,
                    style: TextStyle(
                        color: addOns.isRequired == true ? white : navyBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 10),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Divider(
              height: 0,
              color: dividerColor,
              thickness: 1,
            ),
            // Container(
            //   child: ListView.builder(
            //     itemCount: addOnOption!.length,
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemBuilder: (context, index) => _displayAddOnOption(
            //       addOnOption[index],
            //       addOns,
            //     ),
            //   ),
            // )
            ...addOnOption!
                .map((option) => _displayAddOnOption(option, addOns))
                .toList()
          ],
        ),
      ),
    );
  }

  Widget _displayAddOnOption(AddOnOption addOnOption, AddOns addOns) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (addOnOption.picture != null)
                Container(
                  height: 48,
                  width: 48,
                  decoration:
                      BoxDecoration(border: Border.all(color: dividerColor)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: CachedNetworkImage(
                      imageUrl: addOnOption.picture!,
                      fit: BoxFit.fill,
                      errorWidget: productAndServiceErrorWidget,
                    ),
                  ),
                ),
              SizedBox(width: 8),
              Text(
                appendStringDot(addOnOption.name!, 15),
                maxLines: 2,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  if (addOns.inputType == 'checkbox') {
                    addOns.options!.forEach((data) {
                      if (data.id == addOnOption.id) {
                        // Found the option with the target ID, change its isChecked value
                        addOnOption.isChecked = !addOnOption.isChecked!;
                      }
                    });
                    if (mounted) setState(() {});
                  } else if (addOns.inputType == 'radio') {
                    updateAddOnOptions(addOns.options!, addOnOption.id!);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '(${worldCurrencies[addOnOption.currency!]!}',
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14.0,
                          color: blackFont.withOpacity(.5),
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${moneyDisplayNormalizer(int.parse(addOnOption.price.toString()))})',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: darkGrey,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500),
                    ),
                    if (addOns.inputType == 'checkbox') ...[
                      SizedBox(width: 10),
                      Checkbox(
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: addOnOption.isChecked,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        side: BorderSide(width: 1, color: darkGrey),
                        activeColor: navyBlue,
                        onChanged: (bool? value) {
                          // Handle checkbox state change here
                          addOns.options!.forEach((data) {
                            if (data.id == addOnOption.id) {
                              // Found the option with the target ID, change its isChecked value
                              addOnOption.isChecked = !addOnOption.isChecked!;
                            }
                          });
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                    if (addOns.inputType == 'radio') ...[
                      SizedBox(width: 10),
                      Radio<bool>(
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: addOnOption.isChecked!,
                        groupValue:
                            true, // You need to provide a unique group value for the radio buttons
                        activeColor: navyBlue,
                        onChanged: (bool? value) {
                          // Handle radio button selection here
                          updateAddOnOptions(addOns.options!, addOnOption.id!);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Divider(
            height: 0,
            color: dividerColor,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  void updateAddOnOptions(List<AddOnOption> options, int targetId) {
    options.forEach((addOnOption) {
      if (addOnOption.id == targetId) {
        addOnOption.isChecked = true;
      } else {
        addOnOption.isChecked = false;
      }
      if (mounted) setState(() {});
    });
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
        backgroundColor: product!.isAvailable! ? navyBlue : greyBorderColor,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () async {
          if (product!.isAvailable!) {
            if (isValidCustomer) {
              //check if product has variant
              if (productVariantList.isNotEmpty) {
                if (colorGroups.isNotEmpty && sizeGroups.isNotEmpty) {
                  // print("Both color and size lists are showing.");
                  if (selectedColor.isNotEmpty && selectedSize.isNotEmpty) {
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message: AppLocalization.of(context)!
                            .selectVariantColorSize);
                  }
                } else if (colorGroups.isNotEmpty && sizeGroups.isEmpty) {
                  // print("color list is showing.");
                  if (selectedColor.isNotEmpty) {
                    // print("Color list is showing.");
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantColor);
                  }
                } else if (colorGroups.isEmpty && sizeGroups.isNotEmpty) {
                  // print("size list is showing.");
                  if (selectedSize.isNotEmpty) {
                    // print("Size list is showing.");
                    processCartBuyNow(context);
                  } else {
                    showToast(
                        message:
                            AppLocalization.of(context)!.selectVariantSize);
                  }
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

  Future<void> processCartBuyNow(BuildContext context) async {
    bool result = await showDisclaimerDialogueForGoods(context);
    if (result) {
      getRecipient();
      navigateToSendPayment();
    }
    return;
  }

  // Pull the user from the server
  void getRecipient() async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product!.seller);
  }

  void navigateToSendPayment() {
    basketBloc.productOrService.clear();

    List<Map<String, dynamic>> selectedAddOnsCartServerList = [];
    List<Map<String, dynamic>> selectedAddOnsList = [];
    int addOnPrice = 0;

    addOnList.forEach((addOn) {
      if (addOn.options != null) {
        // Filter the options to include only those with option.isChecked == true
        List<AddOnOption> selectedOptions =
            addOn.options!.where((option) => option.isChecked == true).toList();

        if (selectedOptions.isNotEmpty) {
          for (var item in selectedOptions) {
            debugPrint("Data From Product addOnPrice : ${item.price}");
            addOnPrice += int.parse(item.price.toString());
          }

          debugPrint("Data From Product addOnPrice Total : ${addOnPrice}");

          Map<String, dynamic> selectedAddOn = {
            "id": addOn.id,
            "options": selectedOptions
                .map((option) => {
                      "id": option.id,
                      "quantity": 1,
                      "name": option.name,
                      "price": option.price,
                      "currency": option.currency,
                    })
                .toList(),
          };

          Map<String, dynamic> selectedAddOnServer = {
            "id": addOn.id,
            "options": selectedOptions
                .map((option) => {
                      "id": option.id,
                      "quantity": 1,
                    })
                .toList(),
          };

          selectedAddOnsList.add(selectedAddOn);
          selectedAddOnsCartServerList.add(selectedAddOnServer);
        }
      }
    });

    debugPrint("Data From Product option : $selectedAddOnsList");
    debugPrint(
        "Data From Product selectedAddOnsCartServerList : $selectedAddOnsCartServerList");

    Map<String, dynamic> variants = {
      "id": selectedVariantId,
      "quantity": 1,
      "current_price": selectedVariantPrice
    };

    Map<String, dynamic> addOn = {
      "id": productId,
      "quantity": 1,
      "current_price": addOnPrice
    };

    Map<dynamic, dynamic> result = {};

    if (selectedAddOnsCartServerList.isNotEmpty) {
      result = {
        "type": 'product',
        "results": product!.toJson(),
        "add_ons": addOn,
        "add_ons_list": selectedAddOnsCartServerList,
      };
    } else {
      result = {
        "type": 'product',
        "results": product!.toJson(),
        "variant": variants
      };
    }

    debugPrint('Product check result:::: ${result}');
    debugPrint('Product check:::: ${variants}');

    basketBloc.buyProductOrServiceNow('product', result);
    NavigationUtil.push(context, screen: CheckoutProductService());
  }

  @override
  void dispose() {
    displayProductImages!.clear();
    _scrollController.dispose();
    sliderIndex.close();
    super.dispose();
  }
}
