import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/disclaimer_dialogue_for_goods.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../locator.dart';
import '../../../../../services/app_config_bloc.dart';
import '../utils.dart';

class ProductTileForChatMessage extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  const ProductTileForChatMessage(
      {super.key, required this.message, this.chatConversation});

  @override
  State<ProductTileForChatMessage> createState() =>
      _ProductTileForChatMessageState();
}

class _ProductTileForChatMessageState extends State<ProductTileForChatMessage> {
  Product? product;

  late BasketBloc basketBloc;

  late UserBloc userBloc;
  late CustomerProfileBloc customerProfileBloc;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'widget.message!["meta_data"].toString()${widget.message!.toString()}');
    if (widget.message!["meta_data"] is String) {
      product = Product.fromJson(jsonDecode(widget.message!["meta_data"]));
    } else if (widget.message!["meta_data"] is Map) {
      product = Product.fromJson(widget.message!["meta_data"]);
    }
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    final bool isSend = widget.message!["author"] == userBloc.user.userName;
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
              if (isSend) Container() else Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width / 1.30,
                  // minWidth: MediaQuery.of(context).size.width / 1.30,
                  // maxHeight: product.seller == userBloc.user.userName
                  //     ? MediaQuery.of(context).size.width / 2
                  //     : MediaQuery.of(context).size.width / 1.65,
                  maxWidth: MediaQuery.of(context).size.width / 1.50,
                  minWidth: MediaQuery.of(context).size.width / 1.50,
                  maxHeight: product!.seller == userBloc.user.userName
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width / 2,
                ),
                decoration: BoxDecoration(
                  color: widget.chatConversation!.isGroupConversation!
                      ? isSend
                          ? Colors.transparent
                          : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    vertical: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.chatConversation!.isGroupConversation!)
                      widget.message!['author'] != userBloc.user.userName
                          ? Column(
                              children: [
                                Text(
                                  widget.message!['author_full_name'] ??
                                      widget.message!['author'],
                                  style: TextStyle(
                                      color: isSend ? Colors.white : navyBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            )
                    else
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                    Expanded(
                      child: CustomBoxShadow(
                        child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.zero,
                            shadowColor: boxShadowTwo,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      imageUrl: product!.cover!,
                                      fit: BoxFit.cover,
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
                                      errorWidget: productAndServiceErrorWidget,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                messageDecoderWithEmoji(
                                                        product?.name) ??
                                                    "",
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
                                                        product!.currency!],
                                                    style: TextStyle(
                                                        fontFamily: "Inter",
                                                        color: navyBlue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14)),
                                                TextSpan(
                                                    // text: widget.product.price.toString(),
                                                    text:
                                                        moneyDisplayNormalizer(
                                                            int.parse(product!
                                                                .price
                                                                .toString())),
                                                    style: TextStyle(
                                                      color: navyBlue,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ))
                                              ]),
                                            )
                                          ],
                                        ),
                                        if (product!.seller ==
                                            userBloc.user.userName)
                                          Container(
                                            height: 4,
                                          )
                                        else
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  addToCartWidget(
                                                      item: product),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: CurvedButton(
                                                      height: 36,
                                                      isPaymentBtn: true,
                                                      textColor: Colors.white,
                                                      backgroundColor: navyBlue,
                                                      text: "BUY NOW",
                                                      borderRadius: 10,
                                                      onPressed: () async {
                                                        if (appConfigurationModel
                                                                ?.enablePayment ==
                                                            true) {
                                                          final bool result =
                                                              await showDisclaimerDialogueForGoods(
                                                                  context);
                                                          if (result) {
                                                            customerProfileBloc
                                                                    .customer =
                                                                await UserAuth()
                                                                    .fetchCustomerProfile(
                                                                        product!
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
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSend)
                SizedBox(
                  width: 20,
                  child: isSend
                      ? Center(
                          child: getMessageTick(message: widget.message!),
                        )
                      : Container(),
                )
              else
                Container(),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isSend)
                Container()
              else
                const SizedBox(
                  width: 20,
                ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              if (isSend)
                const SizedBox(
                  width: 20,
                )
              else
                Container(),
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
        final String type = item is Product ? "product" : "service";
        debugPrint("item $item type:- $type");
        basketBloc.addItemToCart(
          item: item,
          type: type,
          currentUser: userBloc.user.convertToUser(),
        );
        late var mapData;
        for (var element in basketBloc.items) {
          if (element["item"].id == item.id) {
            mapData = element;
            continue;
          }
        }
        final Map<String, dynamic> data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Product Page : $data");
        showToast(message: "Item added to the cart !!");
        await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
      },
    );
  }
}

class ServiceTileChatMessage extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  const ServiceTileChatMessage(
      {super.key, required this.message, this.chatConversation});

  @override
  State<ServiceTileChatMessage> createState() => _ServiceTileChatMessageState();
}

class _ServiceTileChatMessageState extends State<ServiceTileChatMessage> {
  Service? service;

  late BasketBloc basketBloc;

  late UserBloc userBloc;
  late CustomerProfileBloc customerProfileBloc;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
  }

  @override
  Widget build(BuildContext context) {
    try {
      service = Service.fromJson(jsonDecode(widget.message!["meta_data"]));
    } catch (e) {
      service = Service.fromJson(widget.message!["meta_data"]);
    }
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    final bool isSend = widget.message!["author"] == userBloc.user.userName;
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
              if (isSend) Container() else Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width / 1.30,
                  // minWidth: MediaQuery.of(context).size.width / 1.30,
                  // maxHeight: service.provider == userBloc.user.userName
                  //     ? MediaQuery.of(context).size.width / 2
                  //     : MediaQuery.of(context).size.width / 1.65,
                  maxWidth: MediaQuery.of(context).size.width / 1.50,
                  minWidth: MediaQuery.of(context).size.width / 1.50,
                  maxHeight: service!.provider == userBloc.user.userName
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width / 2,
                ),
                decoration: BoxDecoration(
                  color: widget.chatConversation!.isGroupConversation!
                      ? isSend
                          ? Colors.transparent
                          : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    vertical: widget.chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.chatConversation!.isGroupConversation!)
                      widget.message!['author'] != userBloc.user.userName
                          ? Column(
                              children: [
                                Text(
                                  widget.message!['author_full_name'] ??
                                      widget.message!['author'],
                                  style: TextStyle(
                                      color: isSend ? Colors.white : navyBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            )
                    else
                      const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                    Expanded(
                      child: CustomBoxShadow(
                        child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.zero,
                            shadowColor: boxShadowTwo,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      imageUrl: service!.cover!,
                                      fit: BoxFit.cover,
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
                                      errorWidget:
                                          productAndServiceBigErrorWidget,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                messageDecoderWithEmoji(
                                                        service?.name) ??
                                                    "",
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
                                                        service!.currency!],
                                                    style: TextStyle(
                                                        fontFamily: "Inter",
                                                        color: navyBlue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14)),
                                                TextSpan(
                                                    // text: widget.product.price.toString(),
                                                    text:
                                                        moneyDisplayNormalizer(
                                                            int.parse(service!
                                                                .price
                                                                .toString())),
                                                    style: TextStyle(
                                                      color: navyBlue,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ))
                                              ]),
                                            )
                                          ],
                                        ),
                                        if (service!.provider ==
                                            userBloc.user.userName)
                                          Container()
                                        else
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  addToCartWidget(
                                                      item: service),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: CurvedButton(
                                                      height: 36,
                                                      isPaymentBtn: false,
                                                      textColor: Colors.white,
                                                      backgroundColor: navyBlue,
                                                      text: "PAY NOW",
                                                      borderRadius: 10,
                                                      onPressed: () async {
                                                        if (appConfigurationModel
                                                                ?.enablePayment ==
                                                            true) {
                                                          final bool result =
                                                              await showDisclaimerDialogueForGoods(
                                                                  context);
                                                          if (result) {
                                                            customerProfileBloc
                                                                    .customer =
                                                                await UserAuth()
                                                                    .fetchCustomerProfile(
                                                                        service!
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
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSend)
                SizedBox(
                  width: 20,
                  child: isSend
                      ? Center(
                          child: getMessageTick(message: widget.message!),
                        )
                      : Container(),
                )
              else
                Container(),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isSend)
                Container()
              else
                const SizedBox(
                  width: 20,
                ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              if (isSend)
                const SizedBox(
                  width: 20,
                )
              else
                Container(),
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
        final String type = item is Product ? "product" : "service";
        debugPrint("item $item type:- $type");
        basketBloc.addItemToCart(
          item: item,
          type: type,
          currentUser: userBloc.user.convertToUser(),
        );
        late var mapData;
        for (var element in basketBloc.items) {
          if (element["item"].checkID == item.checkID) {
            mapData = element;
            continue;
          }
        }
        final Map<String, dynamic> data = {
          "type": type,
          "id": mapData["item"].checkID,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Product Page : $data");
        showToast(message: "Item added to the cart !!");
        await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
      },
    );
  }
}
