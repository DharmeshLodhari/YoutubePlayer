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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../../widget/item_display_card.dart';
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
  List<String> sizes = [];
  List<String> colors = [];
  List<String> oneImageEach = [];
  String selectedColor = "";
  String selectedSize = "";
  int selectedImageColorIndex = -1;
  int selectedSizeIndex = -1;
  String price = "";
  String moreInformation = "";

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
      productVariantList = Variant.convertToVariantList(product!.variant!);

      //get the price and more information to string
      price = product!.price.toString();
      moreInformation = product!.description.toString();

      for (var variant in productVariantList) {
        //get all sizes in variant list
        if (variant.type == 'Size' && variant.type != null) {
          sizes.add(variant.value.toString());
        }
        if (variant.type == 'Color' && variant.type != null) {
          colors.add(variant.colour.toString());
        }
        if(variant.serverImages!.isNotEmpty){
          var serverImages = variant.serverImages![0];
          oneImageEach.add(serverImages!);
        }

      }


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
    data['provider'] = product!.seller!;
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
    // productServiceBloc =
    //     Provider.of<ProductServiceBloc>(context, listen: false);

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
        var shareBody =
            "http://slydo.co/store/product/" + product!.id.toString();
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
              bool data = await YarnAuth().addYarnAndQuestion(params, '');
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
        badgeAnimation: badges.BadgeAnimation.rotation(
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
            String type = product is Product ? "product" : "service";
            basketBloc.addItemToCart(item: product, type: type);
            late var mapData;
            basketBloc.items.forEach((element) {
              if (element["item"].id == product!.id) {
                mapData = element;
                return;
              }
            });
            Map data = {
              "type": type,
              "id": mapData["item"].id,
              "qty": mapData["qty"],
            };
            debugPrint("Data From Product Page : $data");
            await _auth.addItemToShoppingCart(data);
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
      totalItem = totalItem + element['qty'] as int;
    });
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
              padding: EdgeInsets.only(right: 20, left: 20, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductTitleAndPriceWidget(),
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
                  _buildShortInfoWidget(),
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
                  _buildAvailableFromAndShareWidgets(),
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
                  _buildDescriptionWidget(),
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
                  _buildSellerInfoWidget(),
                  SizedBox(height: 10),
                  _buildReviewList(),
                  SizedBox(height: 16),
                  _buildWriteReview(),
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
                fontFamily: "roberto",
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
                                    BorderRadius.all(Radius.circular(10)),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Center(child: CircularLoadingIndicator()),
                                  imageUrl: displayProductImages?[0] ?? "",
                                  fit: BoxFit.fitHeight,
                                  height: double.infinity,
                                  width: double.infinity,
                                  errorWidget: productAndServiceBigErrorWidget,
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
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
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
                                    int index = displayProductImages!.indexOf(url);
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

  Widget _buildProductTitleAndPriceWidget() {
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
                              fontFamily: "Roboto",
                              fontSize: 18.0,
                              color: navyBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          moneyDisplayNormalizer(
                              int.parse(price)),
                          style: TextStyle(
                              fontSize: 18.0,
                              color: navyBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  getRating(numberOfRating: product?.rating!.toInt())
                ],
              ),
            ),
            copyQrCode(),
          ],
        ),

        if(colors.isNotEmpty)...[
          SizedBox(height: 10.0,),
          Row(
            children: [
              Text('Color : ',
                style: TextStyle(
                    fontSize: 16,
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5.0,),
              Text(
                selectedColor,
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.bold),
              ),

            ],
          ),
          SizedBox(height: 5.0,),
          showVariantFirstImages(),
        ],

        if(sizes.isNotEmpty)...[
          SizedBox(height: 10.0,),
          Row(
            children: [
              Text('Size : ',
                style: TextStyle(
                    fontSize: 16,
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5.0,),
              Text(
                selectedSize,
                style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          showVariantSizes(),
        ],

      ],
    );
  }

  Widget showVariantFirstImages(){
    return Container(
      height: 80.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: oneImageEach.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                //update the price, more information and list of images
                // moreInformation = product!.description.toString();

                displayProductImages = [];
                for(var item in productVariantList){

                  var pictures = item.serverImages as List<String>?;
                  if(pictures != null){
                    for(var image in pictures){
                      if (image == oneImageEach[index]) {

                        if (image != null) {
                          displayProductImages = pictures;
                        }

                        price = item.price.toString();
                        selectedColor = item.colour.toString();
                      }

                    }
                  }
                  
                }
                selectedImageColorIndex = index;

                if(mounted) setState(() {});
              },
              child: Container(
                height: 70.0,
                width: 70.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: index == selectedImageColorIndex ? black : greyBorderColor,
                    width: 1.0,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: oneImageEach[index],
                  placeholder: (context, url) => Container(
                    height: 20.0,
                      width: 20.0,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );

  }

  Widget showVariantSizes(){
    return Container(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                selectedSize = sizes[index];
                selectedSizeIndex = index;
                for(var item in productVariantList){

                  //update price for selected size
                  if(item.value == sizes[index]){
                    price = item.price.toString();
                  }

                }

                if(mounted) setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: index == selectedSizeIndex ? black : white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: black,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                  child: Center(
                    child: Text(
                       sizes[index] ,
                      style: TextStyle(
                          fontSize: 14,
                          color: index == selectedSizeIndex ? white : blackFont,
                          fontWeight: FontWeight.bold),
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

  void variantActionsSheet(String type) {
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
                  children: variantBottomSheetItem(type),
                ),
              ));
        });
  }

  List<Widget> variantBottomSheetItem(String type) {
    List<Widget> list = [];

    if(type == "size"){
      for(var item in sizes){
        list.add(
          bottomSheetItem(
            title: item,
            // iconData: SlydoAppIcon.share,
            onTap: () {
              selectedSize = item;
              if(mounted)setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      }
    }else if(type == "color"){
      for(var item in colors){
        list.add(
          bottomSheetItem(
            title: item,
            // iconData: SlydoAppIcon.share,
            onTap: () {
              selectedColor = item;
              if(mounted)setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      }
    }



    return list;
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
              bool result = await showDisclaimerDialogueForGoods(context);
              if (result) {
                getRecipient();
                navigateToSendPayment();
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

  // Pull the user from the server
  void getRecipient() async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product!.seller);
  }

  void navigateToSendPayment() {
    basketBloc.productOrService.clear();
    Map<dynamic, dynamic> result = {
      "type": 'product',
      "results": product!.toJson()
    };

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
