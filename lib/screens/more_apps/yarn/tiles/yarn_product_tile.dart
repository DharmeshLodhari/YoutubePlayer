import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency.dart';
import '../../../../data/state_notifier.dart';
import '../../../../locator.dart';
import '../../../../services/app_config_bloc.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../utils/util.dart';
import '../../../../widget/CustomBoxShadow.dart';
import '../../../../widget/curved_btn.dart';
import '../../../../widget/disclaimer_dialogue_for_goods.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../shopping/models/store.dart';
import '../../shopping/shopping_auth.dart';
import '../../user_profile/user_auth.dart';

class YarnProductTile extends StatefulWidget {
  final Product? product;
  final TileRenderPlace tileRenderPlace;
  const YarnProductTile({
    Key? key,
    this.product,
    this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
  }) : super(key: key);

  @override
  State<YarnProductTile> createState() => _YarnProductTileState();
}

class _YarnProductTileState extends State<YarnProductTile> {
  late BasketBloc basketBloc;

  late UserBloc userBloc;
  late CustomerProfileBloc customerProfileBloc;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/product", arguments: {"product": widget.product});
      },
      child: Container(
        height: getItemHeight(widget.tileRenderPlace, context),
        width: double.infinity,
        child: CustomBoxShadow(
          child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: greySecondaryYarn),
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.zero,
              shadowColor: boxShadowTwo,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(children: [
                          CachedNetworkImage(
                            width: double.infinity,
                            imageUrl: widget.product!.cover!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(navyBlue),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            errorWidget: productAndServiceErrorWidget,
                          ),
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: InkWell(
                              onTap: () {
                                // Navigator.pushNamed(
                                //     context, Routes.SERVICE_DETAIL, arguments: {
                                //   "searchedUserName": widget.service!.description
                                // });
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: widget.product!.sellerAvatar!,
                                        errorWidget: imageErrorWidget,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  userNameWithVerifiedIcon(
                                    name: widget.product?.sellerFullName ?? '',
                                    isVerified: false,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: getFontSize(
                                          widget.tileRenderPlace, context),
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: blackFont,
                                          offset: Offset(0.0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.product!.name!,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: getFontSize(
                                            widget.tileRenderPlace, context),
                                        color: blackFont),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: worldCurrencies[
                                            widget.product!.currency!],
                                        style: TextStyle(
                                          fontFamily: "Inter",
                                          color: navyBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: getFontSize(
                                              widget.tileRenderPlace, context),
                                        )),
                                    TextSpan(
                                        // text: widget.product.price.toString(),
                                        text: moneyDisplayNormalizer(int.parse(
                                            widget.product!.price.toString())),
                                        style: TextStyle(
                                          color: navyBlue,
                                          fontSize: getFontSize(
                                              widget.tileRenderPlace, context),
                                          fontWeight: FontWeight.w700,
                                        ))
                                  ]),
                                )
                              ],
                            ),
                            SizedBox(
                              height: getSizeBoxHeight(
                                  widget.tileRenderPlace, context),
                            ),
                            Text(
                              messageDecoderWithEmoji(
                                      widget.product!.shortDescription!)! ??
                                  "",
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: getFontSize(
                                      widget.tileRenderPlace, context),
                                  color: blackFont),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            widget.product!.seller == userBloc.user.userName
                                ? Container(
                                    height: 4,
                                  )
                                : Container(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            addToCartWidget(
                                                item: widget.product),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: CurvedButton(
                                                height: getButtonSize(
                                                    widget.tileRenderPlace,
                                                    context),
                                                isPaymentBtn: true,
                                                textColor: Colors.white,
                                                backgroundColor: navyBlue,
                                                text: "BUY NOW",
                                                borderRadius: 10,
                                                onPressed: () async {
                                                  // if (appConfigurationModel
                                                  //         ?.enablePayment ==
                                                  //     true) {
                                                    bool result =
                                                        await showDisclaimerDialogueForGoods(
                                                            context);
                                                    if (result) {
                                                      customerProfileBloc
                                                              .customer =
                                                          await UserAuth()
                                                              .fetchCustomerProfile(
                                                                  widget
                                                                      .product!
                                                                      .seller);

                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        '/send-payment',
                                                        arguments: {
                                                          'isFromProfile':
                                                              false,
                                                          'product':
                                                              widget.product
                                                        },
                                                      );
                                                    }
                                                  // }
                                                },
                                              ),
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
        late var mapData;
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
        showToast(message: "Item added to the cart !!");
        await ShoppingAuthService().addItemToShoppingCart(data);
      },
    );
  }
}
