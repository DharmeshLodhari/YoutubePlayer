import 'dart:math';

import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../data/currency.dart';
import '../../models/store.dart';
import '../../shopping_auth.dart';

// ignore: must_be_immutable
class ShoppingTile extends StatelessWidget {
  final ShoppingProduct? product;

  const ShoppingTile({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: product!.cover!,
                    fit: BoxFit.fill,
                    height: 60,
                    width: 68,
                    errorWidget: productAndServiceErrorWidget,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        flexibleSpace(flex: 2),
                        Text(
                          product!.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                          maxLines: 1,
                        ),
                        flexibleSpace(),
                        Text(
                          product!.shortDescription!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                          maxLines: 2,
                        ),
                        flexibleSpace(flex: 5),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          SlydoAppIcon.naira,
                          color: navyBlue,
                          size: 10,
                        ),
                        Text(
                          product!.price.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class ShoppingTileWithHeart extends StatefulWidget {
  final ShoppingProduct? product;

  const ShoppingTileWithHeart({Key? key, this.product}) : super(key: key);
  @override
  _ShoppingTileWithHeartState createState() => _ShoppingTileWithHeartState();
}

class _ShoppingTileWithHeartState extends State<ShoppingTileWithHeart> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ShoppingAuthService().getProduct(widget.product!.id!).then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.product!.cover!,
                    fit: BoxFit.fill,
                    height: 60,
                    width: 60,
                    errorWidget: productAndServiceErrorWidget,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.product!.name!,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.product!.seller!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              worldCurrencies[widget.product!.currency!]!,
                              style: TextStyle(
                                  fontFamily: "Inter",
                                  color: navyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(
                              moneyDisplayNormalizer(widget.product!.price!),
                              style: TextStyle(
                                color: navyBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                getCircularUserAvatar(widget.product!.sellerAvatar!),
                // Container(
                //   height: 60,
                //   child: Center(
                //     child: IconButton(
                //       icon: Icon(
                //         isChange
                //             ? SlydoAppIcon.heart_empty
                //             : SlydoAppIcon.heart_1,
                //         color: isChange ? blackFont : navyBlue,
                //         size: 20,
                //       ),
                //       onPressed: () {
                //         isChange = !isChange;
                //         setState(() {});
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShoppingTileWithHeartWithProduct extends StatefulWidget {
  final Product? product;

  const ShoppingTileWithHeartWithProduct({Key? key, this.product})
      : super(key: key);
  @override
  _ShoppingTileWithHeartWithProductState createState() =>
      _ShoppingTileWithHeartWithProductState();
}

class _ShoppingTileWithHeartWithProductState
    extends State<ShoppingTileWithHeartWithProduct> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ShoppingAuthService().getProduct(widget.product!.id!).then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.product!.cover!,
                    fit: BoxFit.fill,
                    height: 60,
                    width: 60,
                    errorWidget: productAndServiceErrorWidget,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.6).toInt(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.product!.name!,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.product!.seller!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              worldCurrencies[widget.product!.currency!]!,
                              style: TextStyle(
                                  fontFamily: "Inter",
                                  color: navyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(
                              moneyDisplayNormalizer(widget.product!.price!),
                              style: TextStyle(
                                color: navyBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                getCircularUserAvatar(widget.product!.sellerAvatar!),
                // Container(
                //   height: 60,
                //   child: Center(
                //     child: IconButton(
                //       icon: Icon(
                //         isChange
                //             ? SlydoAppIcon.heart_empty
                //             : SlydoAppIcon.heart_1,
                //         color: isChange ? blackFont : navyBlue,
                //         size: 20,
                //       ),
                //       onPressed: () {
                //         isChange = !isChange;
                //         setState(() {});
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MovieTileGeneral extends StatefulWidget {
  @override
  _MovieTileGeneralState createState() => _MovieTileGeneralState();
}

class _MovieTileGeneralState extends State<MovieTileGeneral> {
  bool isDownloaded = Random().nextBool();

  bool isChange = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Container(
              height: 68,
              width: 68,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                  fit: BoxFit.fill,
                  errorWidget: productAndServiceErrorWidget,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dawn Of Thunder",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.star,
                      color: starYellow,
                      size: 12,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "7.8",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                      ),
                    )
                  ],
                ),
              ],
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SlydoAppIcon.naira,
                  color: navyBlue,
                  size: 10,
                ),
                Text(
                  "34.00",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isDownloaded
                    ? SlydoAppIcon.video_play
                    : isChange
                        ? SlydoAppIcon.heart_empty
                        : SlydoAppIcon.heart_1,
                color: isDownloaded
                    ? navyBlue
                    : isChange
                        ? blackFont
                        : navyBlue,
                size: 20,
              ),
              onPressed: () {
                isChange = !isChange;
                setState(() {});
              },
            ),
          ),
        ));
  }
}

class ShoppingTileWithHeartWithService extends StatefulWidget {
  final Service? service;

  const ShoppingTileWithHeartWithService({Key? key, this.service})
      : super(key: key);
  @override
  _ShoppingTileWithHeartWithServiceState createState() =>
      _ShoppingTileWithHeartWithServiceState();
}

class _ShoppingTileWithHeartWithServiceState
    extends State<ShoppingTileWithHeartWithService> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ShoppingAuthService().getService(widget.service!.id!).then((value) {
          Navigator.pushNamed(context, '/service-detail',
              arguments: {"service": value});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.service!.cover!,
                    fit: BoxFit.fill,
                    height: 60,
                    width: 60,
                    errorWidget: productAndServiceErrorWidget,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.6).toInt(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.service!.name!,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        // SizedBox(height: 2),
                        // Text(
                        //   widget.service!.seller!,
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w400,
                        //     color: blackFont,
                        //   ),
                        // ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              worldCurrencies[widget.service!.currency!]!,
                              style: TextStyle(
                                  fontFamily: "Inter",
                                  color: navyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(
                              moneyDisplayNormalizer(
                                  int.parse(widget.service!.price!)),
                              style: TextStyle(
                                color: navyBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // getCircularUserAvatar(widget.service!.sellerAvatar!),
                // Container(
                //   height: 60,
                //   child: Center(
                //     child: IconButton(
                //       icon: Icon(
                //         isChange
                //             ? SlydoAppIcon.heart_empty
                //             : SlydoAppIcon.heart_1,
                //         color: isChange ? blackFont : navyBlue,
                //         size: 20,
                //       ),
                //       onPressed: () {
                //         isChange = !isChange;
                //         setState(() {});
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
