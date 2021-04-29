import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

import '../../../user_profile/user_auth.dart';
import '../../shopping_auth.dart';

// ignore: must_be_immutable
class ProductDetailPage extends StatefulWidget {
  var arguments;

  ProductDetailPage({@required this.arguments});

  @override
  _ProductDetailPageState createState() =>
      _ProductDetailPageState(arguments: arguments);
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  var arguments;

  _ProductDetailPageState({this.arguments});

  final _auth = ShoppingAuthService();
  Product product;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  BasketBloc basketBloc;
  List<String> imgList = [];

  bool isValidCustomer;
  bool isOtherItemFetched = false;
  bool isOtherItemIsEmpty = true;
  ScrollController _scrollController = new ScrollController();

  DashboardBloc _dashboardBloc;

  List<dynamic> sellersOtherItems = List<dynamic>();

  int _current = 0;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        product = arguments['product'];
      });
    }
    fetchProduct(product.id.toString());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isOtherItemFetched) {
          getOtherItems();
        }
      }
    });
    super.initState();
  }

  void fetchProduct(String productId) async {
    _auth.getProduct(productId).then((value) {
      if (mounted) {
        setState(() {
          product = value;
          imgList = product.serverImages;
        });
      }
    });
  }

  void getOtherItems() {
    _auth
        .ownersOrderProductsAndServices(
            type: "products", userId: product.seller, exclude: product.id)
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
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    isValidCustomer = userBloc.user.userName != product.seller;

    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context).productDetail,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        shareItemBtn(),
        isValidCustomer
            ? SizedBox(
                width: 8,
              )
            : Container(),
        isValidCustomer ? goToCartWidget() : Container(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget shareItemBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        selectShareOptionBottomSheet();
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

    list.add(bottomSheetItem(
      title: "Share",
      icon: SlydoAppIcon.share,
      onTap: () async {
        Navigator.pop(context);
        var shareBody = "${product.name}\n" +
            "http://slydo.co/products/" +
            product.id.toString();
        Share.share(shareBody, subject: "${product.name}");
      },
    ));

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        isLast: true,
        icon: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          sendItemToUsersInChat();
        },
      ),
    );

    return list;
  }

  void sendItemToUsersInChat() async {
    List<ChatConversation> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    String url = secureBaseUrl +
        "/api/v1/${product is Product ? "products" : "services"}/" +
        product.id +
        "/";

    Map<String, dynamic> itemData =
        await ShoppingAuthService().getProductOrService(url);

    listOfRecipient.forEach((recipient) {
      addProductOrServiceToChat(
          item: product,
          itemData: itemData,
          recipientUser: recipient,
          url: url);
    });
  }

  void addProductOrServiceToChat(
      {Map<String, dynamic> itemData,
        ChatConversation recipientUser,
      String url,
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
      icon: Badge(
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: getBadgeContent(),
        padding: basketBloc.items.length == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.all(4),
        position: BadgePosition(end: 0, top: 0),
        child: Icon(
          SlydoAppIcon.cart,
          size: 16,
          color: blackFont,
        ),
      ),
      onTap: () {
        _dashboardBloc.index = 3;
        Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
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
            imageUrl: product.sellerAvatar != null
                ? product.sellerAvatar
                : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
      onTap: () async {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": product.seller});
      },
    );
  }

  Widget messageSellerWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.text_message,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        if (isValidCustomer) {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': product.seller,
            'subject': product.name,
          });
        } else {
          Toast.show("You can not message yourself !!", context,
              textColor: Colors.white, duration: Toast.LENGTH_LONG);
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
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        if (isValidCustomer) {
          String type = product is Product ? "product" : "service";
          basketBloc.addItemToCart(item: product, type: type);
          var mapData;
          basketBloc.items.forEach((element) {
            if (element["item"].id == product.id) {
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
          Toast.show(
              AppLocalization.of(context).youCanNotPurchaseThisItem, context,
              textColor: Colors.white, duration: Toast.LENGTH_LONG);
        }
      },
    );
  }

  Widget goToBasket() {
    return Badge(
      badgeColor: Colors.green,
      animationType: BadgeAnimationType.slide,
      badgeContent: getBadgeContent(),
      padding:
          basketBloc.items.length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(end: 6, top: 6),
      child: IconButton(
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/dashboard",
            (Route<dynamic> route) => false,
            arguments: {"dashboardIndex": 2},
          );
        },
      ),
    );
  }

  Widget getBadgeContent() {
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
      totalItem = totalItem + element['qty'];
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
                    height: 12,
                  ),
                  _buildSellerInfoWidget(),
                  SizedBox(
                    height: 16,
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

  Widget _buildProductImagesWidgets() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: imgList.length == 0
          ? AspectRatio(
              aspectRatio: 1.7,
              child: Center(
                child: CircularLoadingIndicator(),
              ),
            )
          : imgList.length == 1
              ? AspectRatio(
                  aspectRatio: 1.7,
                  child: Container(
                    child: Center(
                        child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Center(child: CircularLoadingIndicator()),
                        imageUrl: imgList[0],
                        fit: BoxFit.fill,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    )),
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
                                if (mounted) {
                                  setState(() {
                                    _current = index;
                                  });
                                }
                              }),
                          items: imgList
                              .map((item) => Container(
                                    child: Center(
                                        child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Center(
                                            child: CircularLoadingIndicator()),
                                        imageUrl: item,
                                        fit: BoxFit.fill,
                                        height: double.infinity,
                                        width: double.infinity,
                                      ),
                                    )),
                                  ))
                              .toList(),
                        ),
                        Positioned(
                          bottom: 0,
                          left: MediaQuery.of(context).size.width / 2 -
                              (5 * imgList.length),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imgList.map((url) {
                              int index = imgList.indexOf(url);
                              return Container(
                                width: 5.0,
                                height: 5.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
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
  }

  Widget _buildProductTitleAndPriceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                //name,
                product.name,
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
                      worldCurrencies[product.currency],
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 18.0,
                          color: navyBlue,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(product.price.toString())),
                      style: TextStyle(
                          fontSize: 18.0,
                          color: navyBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        copyQrCode(),
      ],
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
          child: product.qrCode == ""
              ? Center(child: CircularLoadingIndicator())
              : CachedNetworkImage(
                  imageUrl: product.qrCode,
                  height: 40,
                  width: 40,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fill,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                ),
          onTap: () {
            Clipboard.setData(new ClipboardData(text: product.qrCode));
            Toast.show(AppLocalization.of(context).copied, context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
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
                product.shortDescription,
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
                "${product.availableFrom.day}/${product.availableFrom.month}/${product.availableFrom.year}",
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
          product.description,
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
    return product.sellerAvatar == null
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
                leading: Container(
                  height: 48,
                  width: 48,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: product.sellerAvatar,
                      fit: BoxFit.fill,
                      errorWidget: imageErrorWidget,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                title: Text(
                  product.seller,
                  style: TextStyle(
                    fontSize: 14,
                    color: blackFont,
                  ),
                  textAlign: TextAlign.justify,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/profile',
                      arguments: {"searchedUserName": product.seller});
                },
              ),
            ],
          );
  }

  Widget _buildSellersOtherProducts() {
    return Container(
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context).sellersOtherProduct,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context).seeAll,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile', arguments: {
                      "searchedUserName": product.seller,
                      "index": 2
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: sellersOtherItems.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => displayProduct(
                context: context,
                product: sellersOtherItems[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButtonWidget() {
    return Expanded(
      child: CurvedButton(
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "BUY NOW",
        onPressed: () {
          if (isValidCustomer) {
            getRecipient();
            navigateToSendPayment();
          } else {
            Toast.show(
                AppLocalization.of(context).youCanNotPurchaseThisItem, context,
                textColor: Colors.white, duration: Toast.LENGTH_LONG);
          }
        },
      ),
    );
  }

  // Pull the user from the server
  void getRecipient() async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product.seller);
  }

  void navigateToSendPayment() {
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {'isFromProfile': false, 'product': product},
    );
  }

  @override
  void dispose() {
    imgList.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
