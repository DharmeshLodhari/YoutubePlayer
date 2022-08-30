import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../locale/app_localization.dart';
import '../utils/slydo_app_icon_icons.dart';
import 'bottom_sheet_item.dart';

class DisplayProduct extends StatefulWidget {
  final Product product;
  final bool giveRightPadding;
  final Function()? onProductRefresh;
  const DisplayProduct(
      {Key? key,
      required this.product,
      this.giveRightPadding = false,
      this.onProductRefresh})
      : super(key: key);

  @override
  State<DisplayProduct> createState() => _DisplayProductState();
}

class _DisplayProductState extends State<DisplayProduct> {
  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.product.seller == getLoggedInUserName(context);
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(
          right: widget.giveRightPadding ? 10 : 0.0, bottom: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadow,
      child: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width - 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.cover!,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        errorWidget: productAndServiceBigErrorWidget,
                      ),
                    ),
                    Positioned(
                        right: 10,
                        bottom: 10,
                        child: getRating(
                            numberOfRating: widget.product.rating?.toInt())),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            truncateString(
                              str: widget.product.name!,
                              lengthToTruncateAt: 16,
                              showEllipsis: false,
                            ),
                            style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        isOwner
                            ? InkWell(
                                onTap: () => showUserProfileActionsSheet(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(SlydoAppIcon.menu, size: 16),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    Row(
                      children: [
                        // Expanded(
                        //   child: Text(
                        //     product.shortDescription ?? "",
                        //     style: TextStyle(
                        //       color: darkGrey,
                        //       fontSize: 12,
                        //     ),
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // ),
                        Text(
                          worldCurrencies[widget.product.currency!]!,
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                        Text(
                          moneyDisplayNormalizer(
                              int.parse(widget.product.price!)),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              // ListTile(
              //   dense: true,
              //   title: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         child: Text(
              //           product.name!,
              //           style: TextStyle(
              //             color: blackFont,
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //           ),
              //           maxLines: 1,
              //           softWrap: false,
              //           overflow: TextOverflow.fade,
              //         ),
              //       ),
              //       SizedBox(width: 12),
              //       Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: <Widget>[
              //           Text(
              //             worldCurrencies[product.currency!]!,
              //             style: TextStyle(
              //               fontFamily: "Roboto",
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14,
              //               color: navyBlue,
              //             ),
              //           ),
              //           Text(
              //             moneyDisplayNormalizer(int.parse(product.price!)),
              //             style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14,
              //               color: navyBlue,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              //   subtitle: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         child: Text(
              //           product.shortDescription ?? "",
              //           style: TextStyle(
              //             color: darkGrey,
              //             fontSize: 12,
              //           ),
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //       getRating(numberOfRating: product.rating?.toInt()),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
        onTap: () {
          Product currentProduct = Product();
          currentProduct.name = widget.product.name;
          currentProduct.id = widget.product.id;
          currentProduct.shortDescription = widget.product.shortDescription;
          currentProduct.description = "";
          currentProduct.condition = widget.product.condition;
          currentProduct.currency = widget.product.currency;
          currentProduct.price = widget.product.price;
          currentProduct.availableFrom =
              widget.product.availableFrom ?? DateTime.now();
          currentProduct.isAvailable = widget.product.isAvailable;
          currentProduct.qrCode = widget.product.qrCode;
          currentProduct.seller = widget.product.seller;
          currentProduct.manufacturer = widget.product.manufacturer;
          currentProduct.serverImages = widget.product.serverImages;
          currentProduct.rating = widget.product.rating;
          Navigator.pushNamed(context, '/product',
              arguments: {"product": currentProduct});
        },
      ),
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

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.print,
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(
            '/print-qr',
            arguments: {
              "imageUrl": widget.product.qrCode,
              "itemName": widget.product.name,
            },
          );
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Edit product",
        iconData: SlydoAppIcon.edit,
        onTap: () async {
          Navigator.pop(context);

          var result = await Navigator.of(context).pushNamed(
            '/edit-product',
            arguments: {
              "productId": widget.product.id.toString(),
            },
          );

          if (result != null) {
            if (result is String) {
              if (result == "delete_item" || result == "update_item") {
                if (widget.onProductRefresh != null) {
                  widget.onProductRefresh!();
                }
              }
            }
          }
        },
      ),
    );

    return list;
  }
}

class DisplayService extends StatefulWidget {
  final Service service;
  final bool giveRightPadding;
  final Function()? onServiceRefresh;
  const DisplayService(
      {Key? key,
      required this.service,
      this.giveRightPadding = false,
      this.onServiceRefresh})
      : super(key: key);

  @override
  State<DisplayService> createState() => _DisplayServiceState();
}

class _DisplayServiceState extends State<DisplayService> {
  @override
  Widget build(BuildContext context) {
    bool isOwner =
        widget.service.getMerchantUserName() == getLoggedInUserName(context);

    debugPrint(widget.service.getMerchantUserName());
    debugPrint('LOGED IN -> ${getLoggedInUserName(context)}');
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(
          right: widget.giveRightPadding ? 10 : 0.0, bottom: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadow,
      child: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width - 220,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: CachedNetworkImage(
                        imageUrl: widget.service.cover!,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        errorWidget: productAndServiceBigErrorWidget,
                      ),
                    ),
                    Positioned(
                        right: 10,
                        bottom: 10,
                        child: getRating(
                            numberOfRating: widget.service.rating?.toInt())),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            truncateString(
                              str: widget.service.name!,
                              lengthToTruncateAt: 16,
                              showEllipsis: false,
                            ),
                            style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        isOwner
                            ? InkWell(
                                onTap: () => showUserProfileActionsSheet(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(SlydoAppIcon.menu, size: 16),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          worldCurrencies[widget.service.currency!]!,
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                        Text(
                          moneyDisplayNormalizer(
                              int.parse(widget.service.price!)),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Service currentService = Service();
          currentService.name = widget.service.name;
          currentService.id = widget.service.id;
          currentService.shortDescription = widget.service.shortDescription;
          currentService.currency = widget.service.currency;
          currentService.price = widget.service.price;
          currentService.isAvailable = widget.service.isAvailable;
          currentService.qrCode = widget.service.qrCode;
          currentService.provider = widget.service.provider;
          currentService.serverImages = widget.service.serverImages;
          currentService.currency = widget.service.currency;
          currentService.description = widget.service.description;
          currentService.availableFrom = DateTime.now();
          currentService.rating = currentService.rating;

          Navigator.pushNamed(context, '/service-detail',
              arguments: {"service": currentService});
        },
      ),
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

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.print,
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(
            '/print-qr',
            arguments: {
              "imageUrl": widget.service.qrCode,
              "itemName": widget.service.name,
            },
          );
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Edit Service",
        iconData: SlydoAppIcon.edit,
        onTap: () async {
          Navigator.pop(context);

          var result = await Navigator.of(context).pushNamed(
            '/edit-service',
            arguments: {
              "serviceId": widget.service.id.toString(),
            },
          );

          if (result != null) {
            if (result is String) {
              if (result == "delete_item" || result == "update_item") {
                if (widget.onServiceRefresh != null) {
                  widget.onServiceRefresh!();
                }
              }
            }
          }
        },
      ),
    );

    return list;
  }
}

Widget displayService(
    {required BuildContext context,
    required Service service,
    bool inSuperStore = false}) {
  return Card(
    color: Colors.white,
    margin: EdgeInsets.only(right: inSuperStore ? 0 : 10.0, bottom: 8.0),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    shadowColor: boxShadow,
    child: GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width - 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: service.cover!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: productAndServiceBigErrorWidget,
                    ),
                  ),
                  Positioned(
                      right: 10,
                      bottom: 10,
                      child:
                          getRating(numberOfRating: service.rating?.toInt())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(service.name) ?? "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worldCurrencies[service.currency!]!,
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: navyBlue,
                        ),
                      ),
                      Text(
                        moneyDisplayNormalizer(
                            int.parse(service.price.toString())),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: navyBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Service currentService = Service();
        currentService.name = service.name;
        currentService.id = service.id;
        currentService.shortDescription = service.shortDescription;
        currentService.currency = service.currency;
        currentService.price = service.price;
        currentService.isAvailable = service.isAvailable;
        currentService.qrCode = service.qrCode;
        currentService.provider = service.provider;
        currentService.serverImages = service.serverImages;
        currentService.currency = service.currency;
        currentService.description = service.description;
        currentService.availableFrom = DateTime.now();
        currentService.rating = currentService.rating;

        Navigator.pushNamed(context, '/service-detail',
            arguments: {"service": currentService});
      },
    ),
  );
}
