import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';
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
  late bool isOwner;
  late BasketBloc basketBloc;
  bool showAddToCartButton = true;
  final _auth = ShoppingAuthService();

  @override
  void initState() {
    super.initState();
    isOwner = widget.product.seller == getLoggedInUserName(context);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    return SizedBox(
      width: 180,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.only(
            right: widget.giveRightPadding ? 10 : 0.0, bottom: 2),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadow,
        child: GestureDetector(
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
                          numberOfRating: widget.product.rating?.toInt()),
                    ),
                    getMenuIcon(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    Row(
                      children: [
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
                        Spacer(),
                        getFavouriteIcon(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            if (showAddToCartButton == false) {
              showAddToCartButton = true;
              if (mounted) setState(() {});
              return;
            }

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
      ),
    );
  }

  void showProductProfileActionsSheet() {
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

  Widget getMenuIcon() {
    if (basketBloc.getProductOrServiceQuantityInCart(widget.product.id!) == 0) {
      setState(() {
        showAddToCartButton = true;
      });
    }
    if (isOwner) {
      return Positioned(
        top: 5,
        right: 5,
        child: RoundedBackgroundIcon(
          icon: Icon(
            SlydoAppIcon.menu,
            size: 22,
            color: Colors.black,
          ),
          onTap: () {
            showProductProfileActionsSheet();
          },
          backgroundColor: Colors.white.withOpacity(0.5),
        ),
      );
    } else {
      if (showAddToCartButton) {
        return Positioned(
          top: 5,
          right: 5,
          child: RoundedBackgroundIcon(
            icon: Icon(
              SlydoAppIcon.cart,
              size: 16,
              color: blackFont,
            ),
            backgroundColor: Colors.white.withOpacity(0.5),
            onTap: () async {
              setState(() {
                showAddToCartButton = false;
              });
              addProductToCart();
            },
          ),
        );
      } else {
        return Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
            height: 100,
            width: 40,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          addProductToCart();
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: navyBlue,
                      child: Center(
                        child: Text(
                          '${basketBloc.getProductOrServiceQuantityInCart(widget.product.id!)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                          onTap: () {
                            if (basketBloc.getProductOrServiceQuantityInCart(
                                    widget.product.id!) ==
                                1) {
                              setState(() {
                                showAddToCartButton = true;
                              });
                            }

                            removeProductFromCart();
                          },
                          child: Icon(Icons.remove_rounded)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  Widget getFavouriteIcon() {
    return !isOwner
        ? Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              child: Icon(Icons.favorite_border),
            ),
          )
        : SizedBox.shrink();
  }

  void addProductToCart() async {
    if (widget.product.isAvailable!) {
      if (!isOwner) {
        String type = "product";
        basketBloc.addItemToCart(item: widget.product, type: type);
        late var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == widget.product.id) {
            mapData = element;
            return;
          }
        });
        Map data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Display Product widget Page : $data");
        await _auth.addItemToShoppingCart(data);
      } else {
        showToast(
            message: AppLocalization.of(context)!.youCanNotPurchaseThisItem);
      }
    } else {
      showToast(message: AppLocalization.of(context)!.productOutOfStock);
    }
  }

  void removeProductFromCart() async {
    String type = "product";

    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == widget.product.id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"] - 1,
    };

    debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(widget.product);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
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
  late bool isOwner;
  late BasketBloc basketBloc;
  bool showAddToCartButton = true;
  final _auth = ShoppingAuthService();

  @override
  void initState() {
    super.initState();
    isOwner =
        widget.service.getMerchantUserName() == getLoggedInUserName(context);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

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
                        starSize: 22,
                        numberOfRating: widget.service.rating?.toInt(),
                      ),
                    ),
                    getMenuIcon(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
          if (showAddToCartButton == false) {
            showAddToCartButton = true;
            if (mounted) setState(() {});
            return;
          }

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

  Widget getMenuIcon() {
    if (basketBloc.getProductOrServiceQuantityInCart(widget.service.id!) == 0) {
      setState(() {
        showAddToCartButton = true;
      });
    }
    if (isOwner) {
      return Positioned(
        top: 5,
        right: 5,
        child: RoundedBackgroundIcon(
          icon: Icon(
            SlydoAppIcon.menu,
            size: 22,
            color: Colors.black,
          ),
          onTap: () {
            showServiceActionsSheet();
          },
          backgroundColor: Colors.white.withOpacity(0.5),
        ),
      );
    } else {
      if (showAddToCartButton) {
        return Positioned(
          top: 5,
          right: 5,
          child: RoundedBackgroundIcon(
            icon: Icon(
              SlydoAppIcon.cart,
              size: 16,
              color: blackFont,
            ),
            backgroundColor: Colors.white.withOpacity(0.5),
            onTap: () async {
              setState(() {
                showAddToCartButton = false;
              });
              addServiceToCart();
            },
          ),
        );
      } else {
        return Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
            height: 100,
            width: 40,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          addServiceToCart();
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: navyBlue,
                      child: Center(
                        child: Text(
                          '${basketBloc.getProductOrServiceQuantityInCart(widget.service.id!)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          if (basketBloc.getProductOrServiceQuantityInCart(
                                  widget.service.id!) ==
                              1) {
                            setState(() {
                              showAddToCartButton = true;
                            });
                          }

                          removeServiceFromCart();
                        },
                        child: Icon(Icons.remove_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  void showServiceActionsSheet() {
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

  void removeServiceFromCart() async {
    String type = "service";

    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == widget.service.id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"] - 1,
    };

    debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(widget.service);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
  }

  void addServiceToCart() async {
    if (widget.service.isAvailable!) {
      if (!isOwner) {
        String type = "product";
        basketBloc.addItemToCart(item: widget.service, type: type);
        late var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == widget.service.id) {
            mapData = element;
            return;
          }
        });
        Map data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Display Product widget Page : $data");
        await _auth.addItemToShoppingCart(data);
      } else {
        showToast(
            message: AppLocalization.of(context)!.youCanNotPurchaseThisItem);
      }
    } else {
      showToast(message: AppLocalization.of(context)!.serviceOutOfStock);
    }
  }
}
