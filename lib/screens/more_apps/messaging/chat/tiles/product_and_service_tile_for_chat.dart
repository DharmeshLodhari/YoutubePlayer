import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/disclaimer_dialogue_for_goods.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../utils.dart';

// ignore: must_be_immutable
class ProductTileForChatMessage extends StatefulWidget {
  Map<String, dynamic> item;

  ProductTileForChatMessage({@required this.item});

  @override
  _ProductTileForChatMessageState createState() =>
      _ProductTileForChatMessageState();
}

class _ProductTileForChatMessageState extends State<ProductTileForChatMessage> {
  Product product;

  BasketBloc basketBloc;

  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item["meta_data"] is String) {
      product = Product.fromJson(jsonDecode(widget.item["meta_data"]));
    } else if (widget.item["meta_data"] is Map) {
      product = Product.fromJson(widget.item["meta_data"]);
    }

    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    bool isSend = widget.item["author"] == userBloc.user.userName;
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/product", arguments: {"product": product});
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  maxHeight: product.seller == userBloc.user.userName
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width / 1.65,
                ),
                child: CustomBoxShadow(
                  child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      shadowColor: boxShadowTwo,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: product.cover,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation(navyBlue),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                  errorWidget: imageErrorWidget,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.name,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: blackFont),
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: worldCurrencies[
                                                    product.currency],
                                                style: TextStyle(
                                                    fontFamily: "Roboto",
                                                    color: navyBlue,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14)),
                                            TextSpan(
                                                // text: widget.product.price.toString(),
                                                text: moneyDisplayNormalizer(
                                                    int.parse(product.price
                                                        .toString())),
                                                style: TextStyle(
                                                  color: navyBlue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ))
                                          ]),
                                        )
                                      ],
                                    ),
                                    product.seller == userBloc.user.userName
                                        ? Container()
                                        : Container(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: [
                                                    addToCartWidget(
                                                        item: product),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Expanded(
                                                      child: CurvedButton(
                                                          height: 36,
                                                          textColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              navyBlue,
                                                          text: "BUY NOW",
                                                          borderRadius: 10,
                                                          onPressed: () async {
                                                            bool result =
                                                                await showDisclaimerDialogueForGoods(
                                                                    context);
                                                            if (result) {
                                                              customerProfileBloc
                                                                      .customer =
                                                                  await UserAuth()
                                                                      .fetchCustomerProfile(
                                                                          product
                                                                              .seller);

                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                '/send-payment',
                                                                arguments: {
                                                                  'isFromProfile':
                                                                      false,
                                                                  'product':
                                                                      product
                                                                },
                                                              );
                                                            }
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child: getMessageTick(message: widget.item),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.item['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  Widget addToCartWidget({var item}) {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 38,
      width: 38,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: navyBlue,
        size: 20,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        String type = item is Product ? "product" : "service";
        debugPrint("item $item type:- $type");
        basketBloc.addItemToCart(item: item, type: type);
        var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == item.id) {
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
        Toast.show("Item added to the cart !!", context);
        await ShoppingAuthService().addItemToShoppingCart(data);
      },
    );
  }
}

// ignore: must_be_immutable
class ServiceTileChatMessage extends StatefulWidget {
  Map<String, dynamic> item;

  ServiceTileChatMessage({@required this.item});

  @override
  _ServiceTileChatMessageState createState() => _ServiceTileChatMessageState();
}

class _ServiceTileChatMessageState extends State<ServiceTileChatMessage> {
  Service service;

  BasketBloc basketBloc;

  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      service = Service.fromJson(jsonDecode(widget.item["meta_data"]));
    } catch (e) {
      service = Service.fromJson(widget.item["meta_data"]);
    }
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    bool isSend = widget.item["author"] == userBloc.user.userName;
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/service-detail", arguments: {"service": service});
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  maxHeight: service.provider == userBloc.user.userName
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width / 1.65,
                ),
                child: CustomBoxShadow(
                  child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      shadowColor: boxShadowTwo,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: service.cover,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation(navyBlue),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                  errorWidget: imageErrorWidget,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service.name,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: blackFont),
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text: worldCurrencies[
                                                    service.currency],
                                                style: TextStyle(
                                                    fontFamily: "Roboto",
                                                    color: navyBlue,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14)),
                                            TextSpan(
                                                // text: widget.product.price.toString(),
                                                text: moneyDisplayNormalizer(
                                                    int.parse(service.price
                                                        .toString())),
                                                style: TextStyle(
                                                  color: navyBlue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ))
                                          ]),
                                        )
                                      ],
                                    ),
                                    service.provider == userBloc.user.userName
                                        ? Container()
                                        : Container(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: [
                                                    addToCartWidget(
                                                        item: service),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Expanded(
                                                      child: CurvedButton(
                                                          height: 36,
                                                          textColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              navyBlue,
                                                          text: "BUY NOW",
                                                          borderRadius: 10,
                                                          onPressed: () async {
                                                            bool result =
                                                                await showDisclaimerDialogueForGoods(
                                                                    context);
                                                            if (result) {
                                                              customerProfileBloc
                                                                      .customer =
                                                                  await UserAuth()
                                                                      .fetchCustomerProfile(
                                                                          service
                                                                              .provider);

                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                '/send-payment',
                                                                arguments: {
                                                                  'isFromProfile':
                                                                      false,
                                                                  'service':
                                                                      service
                                                                },
                                                              );
                                                            }
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child: getMessageTick(message: widget.item),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.item['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  Widget addToCartWidget({var item}) {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 38,
      width: 38,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: navyBlue,
        size: 20,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        String type = item is Product ? "product" : "service";
        debugPrint("item $item type:- $type");
        basketBloc.addItemToCart(item: item, type: type);
        var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == item.id) {
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
        Toast.show("Item added to the cart !!", context);
        await ShoppingAuthService().addItemToShoppingCart(data);
      },
    );
  }
}
