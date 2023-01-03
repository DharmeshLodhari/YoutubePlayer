import 'dart:math';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';
import '../screens/more_apps/yarn/models/share_as_yarn_model.dart';
import '../screens/more_apps/yarn/share_as_a_yarn_screen.dart';
import '../screens/more_apps/yarn/yarn_auth.dart';
import '../screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/slydo_app_icon_new_icons.dart';
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
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    super.initState();
    isOwner = widget.product.seller == getLoggedInUserName(context);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    return GestureDetector(
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
      child: SizedBox(
        width: 200,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          margin: EdgeInsets.only(
              right: widget.giveRightPadding ? 10 : 0.0, bottom: 2),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: boxShadow,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: 155,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.cover!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: productAndServiceBigErrorWidget,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: getRating(
                          numberOfRating: widget.product.rating?.toInt()),
                    ),
                    displayShoppingCartControls(),
                    // TODO: to be added in future
                    // Positioned(right: 10, top: 10, child: favouriteIcon())
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${widget.product.shortDescription}',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: yarnBlack,
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              worldCurrencies[widget.product.currency!]!,
                              style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 14.8,
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
                            Expanded(child: SizedBox(width: 40)),
                            displayShoppingAddingToCartControl()
                          ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  void shareAsYarn() {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            callback: (params) async {
              params..body = widget.product.name ?? "";
              params
                ..attachment = {
                  "product": widget.product.toJson().cast<String, dynamic>()
                };
              bool data = await YarnAuth().addYarnAndQuestion(params);
              if (data) {
                showToast(message: "Share in Yarn successfully created");
              }
            }));
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

  Widget favouriteIcon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        child: Icon(Icons.favorite_border),
      ),
    );
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

  Widget displayShoppingCartControls() {
    if (isInCart() == true) {
      return Positioned(
          right: 10,
          bottom: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            height: 25,
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      addProductToCart();
                    },
                    child: SvgPicture.asset(
                      'assets/images/add.svg',
                      height: 17,
                      width: 17,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${basketBloc.getProductOrServiceQuantityInCart(widget.product.id!)}',
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: yarnBlack,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      removeProductFromCart();
                    },
                    child: SvgPicture.asset('assets/images/minus.svg',
                        height: 17, width: 17),
                  ),
                ],
              ),
            ),
          ));
    } else {
      return Positioned(
        right: 10,
        bottom: 5,
        child: Container(),
      );
    }
  }

  Widget displayShoppingAddingToCartControl() {
    IconData iconValue = SlydoAppIcon.add_cart;
    Color iconBackgroundColor = greyBorderColor;
    Color iconColor = blackFont;

    if (isInCart() == true) {
      iconValue = SlydoAppIcon.cart;
      iconBackgroundColor = navyBlue;
      iconColor = white;
    } else {
      iconValue = SlydoAppIcon.add_cart;
      iconBackgroundColor = greyBorderColor;
      iconColor = blackFont;
    }
    return RoundedBackgroundIcon(
      height: 30,
      width: 30,
      borderRadius: 20,
      icon: Icon(
        iconValue,
        size: 14,
        color: iconColor,
      ),
      backgroundColor: iconBackgroundColor,
      onTap: () async {
        setState(() {
          showAddToCartButton = false;
        });
        addProductToCart();
      },
    );
  }

  bool isInCart() {
    if (basketBloc.getProductOrServiceQuantityInCart(widget.product.id!) == 0) {
      return false;
    } else {
      return true;
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
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    super.initState();
    isOwner =
        widget.service.getMerchantUserName() == getLoggedInUserName(context);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return GestureDetector(
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
      child: SizedBox(
        width: 180,
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.only(
              right: widget.giveRightPadding ? 10 : 0.0, bottom: 8.0),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: boxShadow,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: 155,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          imageUrl: widget.service.cover!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: productAndServiceBigErrorWidget,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: getRating(
                        numberOfRating: widget.service.rating?.toInt(),
                      ),
                    ),
                    displayShoppingCartControls(),
                    //TODO: to be implemented later in future
                    // Positioned(right: 10, top: 10, child: favouriteIcon())
                  ],
                ),
                SizedBox(
                  height: 10,
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
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.service.shortDescription!,
                        overflow: widget.service.shortDescription!.length > 60
                            ? TextOverflow.ellipsis
                            : TextOverflow.visible,
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          color: yarnBlack,
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
                          Expanded(child: SizedBox(width: 50)),
                          displayShoppingAddingToCartControl()
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget favouriteIcon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        child: Icon(Icons.favorite_border),
      ),
    );
  }

  Widget displayShoppingCartControls() {
    if (isInCart() == true) {
      return Positioned(
          right: 10,
          bottom: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            height: 25,
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      addServiceToCart();
                    },
                    child: SvgPicture.asset(
                      'assets/images/add.svg',
                      height: 17,
                      width: 17,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${basketBloc.getProductOrServiceQuantityInCart(widget.service.id!)}',
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: yarnBlack,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      removeServiceFromCart();
                    },
                    child: SvgPicture.asset('assets/images/minus.svg',
                        height: 17, width: 17),
                  ),
                ],
              ),
            ),
          ));
    } else {
      return Positioned(
        right: 10,
        bottom: 5,
        child: Container(),
      );
    }
  }

  Widget displayShoppingAddingToCartControl() {
    IconData iconValue = SlydoAppIcon.add_cart;
    Color iconBackgroundColor = greyBorderColor;
    Color iconColor = blackFont;

    if (isInCart() == true) {
      iconValue = SlydoAppIcon.cart;
      iconBackgroundColor = navyBlue;
      iconColor = white;
    } else {
      iconValue = SlydoAppIcon.add_cart;
      iconBackgroundColor = greyBorderColor;
      iconColor = blackFont;
    }
    return RoundedBackgroundIcon(
      height: 30,
      width: 30,
      borderRadius: 20,
      icon: Icon(
        iconValue,
        size: 14,
        color: iconColor,
      ),
      backgroundColor: iconBackgroundColor,
      onTap: () async {
        setState(() {
          showAddToCartButton = false;
        });
        addServiceToCart();
      },
    );
  }

  bool isInCart() {
    if (basketBloc.getProductOrServiceQuantityInCart(widget.service.id!) == 0) {
      return false;
    } else {
      return true;
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

  void shareAsYarn() {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            callback: (params) async {
              params..body = widget.service.name ?? "";
              params
                ..attachment = {
                  "service":
                      widget.service.toJson().cast<String, dynamic>() ?? {}
                };
              bool data = await YarnAuth().addYarnAndQuestion(params);
              if (data) {
                showToast(message: "Share in Yarn successfully created");
              }
            }));
  }
}
