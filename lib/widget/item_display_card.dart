import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../routes/route_constants.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';
import '../screens/more_apps/user_profile/models/user.dart';
import '../screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../screens/more_apps/user_profile/user_auth.dart';
import '../screens/more_apps/yarn/models/share_as_yarn_model.dart';
import '../screens/more_apps/yarn/share_as_a_yarn_screen.dart';
import '../screens/more_apps/yarn/utils/utils.dart';
import '../screens/more_apps/yarn/utils/yarn_enum.dart';
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
        currentProduct.discountValue = widget.product.discountValue;
        currentProduct.discountIsActive = widget.product.discountIsActive;
        currentProduct.discountType = widget.product.discountType;
        currentProduct.discountedPrice = widget.product.discountedPrice;
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
            child: SingleChildScrollView(
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
                      widget.product.discountedPrice != null
                          ? (checkDiscount(
                                  widget.product.discountIsActive!,
                                  widget.product.discountedPrice!,
                                  num.parse(widget.product.price!)))
                              ? Positioned(
                                  top: 10,
                                  right: 10,
                                  child: showDiscountValue(
                                      widget.product.discountType!,
                                      widget.product.discountValue!,
                                      widget.product.currency))
                              : SizedBox()
                          : SizedBox(),

                      if ((widget.product.pricePercentageChange != null) &
                          (widget.product.pricePercentageChange != 0.0)) ...[
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 6.0, right: 6.0, top: 4.0, bottom: 4.0),
                            decoration: BoxDecoration(
                              color: naturalGreen,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Text(
                              "${widget.product.pricePercentageChange!.toString()}% off",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],

                      displayShoppingCartControls(),
                      // TODO: to be added in future
                      // Positioned(right: 10, top: 10, child: favouriteIcon())
                    ],
                  ),
                  const SizedBox(
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
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          truncateString(
                            str: widget.product.shortDescription!,
                            lengthToTruncateAt: 60,
                            showEllipsis: true,
                          ),
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: yarnBlack,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        worldCurrencies[
                                            widget.product.currency!]!,
                                        style: TextStyle(
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.8,
                                          color: navyBlue,
                                        ),
                                      ),
                                      Text(
                                        moneyDisplayNormalizer(int.parse(widget
                                                    .product.discountedPrice !=
                                                null
                                            ? ((checkDiscount(
                                                    widget.product
                                                        .discountIsActive!,
                                                    widget.product
                                                        .discountedPrice!,
                                                    num.parse(
                                                        widget.product.price!)))
                                                ? widget.product.discountedPrice
                                                    .toString()
                                                : widget.product.price!)
                                            : widget.product.price!)),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: navyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  widget.product.discountedPrice != null
                                      ? (checkDiscount(
                                              widget.product.discountIsActive!,
                                              widget.product.discountedPrice!,
                                              num.parse(widget.product.price!)))
                                          ? Row(
                                              children: [
                                                Text(
                                                  worldCurrencies[widget
                                                      .product.currency!]!,
                                                  style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12.8,
                                                    color: navyBlue,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                                Text(
                                                  moneyDisplayNormalizer(
                                                      int.parse(widget
                                                          .product.price!)),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: navyBlue,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox()
                                      : SizedBox(),
                                ],
                              ),
                              const Expanded(child: SizedBox(width: 40)),
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
      ),
    );
  }

  void showProductProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
              bool data = await YarnAuth().addYarnAndQuestion(params, '', '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
              }
            }));
  }

  Widget getFavouriteIcon() {
    return !isOwner
        ? const Padding(
            padding: EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              child: Icon(Icons.favorite_border),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget favouriteIcon() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        child: Icon(Icons.favorite_border),
      ),
    );
  }

  void addProductToCart() async {
    if (isOwner) {
      return showToast(
          message: AppLocalization.of(context)!.cantPurchaseYourOwnServices);
    }

    if (widget.product.isAvailable!) {
      String type = "product";
      basketBloc.addItemToCart(
          item: widget.product.copyWith(qty: 1), type: type);
      // late var mapData;
      // basketBloc.items.forEach((element) {
      //   if (element["item"].id == widget.product.id) {
      //     mapData = element;
      //     return;
      //   }
      // });
      // Map<String, dynamic> data = {
      //   "type": type,
      //   "id": mapData["item"].id,
      //   "qty": mapData["qty"],
      // };
      // debugPrint("Data From Display Product widget Page : $data");
      // await _auth.addOrUpdateItemToShoppingCart(data);
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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
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
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${basketBloc.getProductOrServiceQuantityInCart(widget.product.id!)}',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: yarnBlack,
                    ),
                  ),
                  const SizedBox(
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
    var result = false;
    for (var data in basketBloc.basketItems) {
      if (widget.product.id! == data.item?.id) {
        result = true;
        break;
      }
      result = false;
    }
    // if (basketBloc.getProductOrServiceQuantityInCart(widget.product.id!) == 0) {
    //   return false;
    // } else {
    //   return true;
    // }
    return result;
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
      "qty": int.parse(mapData["qty"].toString()) - 1,
    };

    debugPrint("Data send From Remove Main : $data");
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
        height: 500,
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
                        borderRadius: const BorderRadius.only(
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
                const SizedBox(
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
                      const SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        width: 140,
                        height: 14,
                        child: Text(
                          widget.service.shortDescription!,
                          overflow: widget.service.shortDescription!.length > 21
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w300,
                            fontSize: 9,
                            color: yarnBlack,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            worldCurrencies[widget.service.currency!]!,
                            style: TextStyle(
                              fontFamily: "Inter",
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
                          const Expanded(child: SizedBox(width: 50)),
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
    return const Padding(
      padding: EdgeInsets.only(bottom: 4.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
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
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${basketBloc.getProductOrServiceQuantityInCart(widget.service.id!)}',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: yarnBlack,
                    ),
                  ),
                  const SizedBox(
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
        // setState(() {
        //   showAddToCartButton = false;
        // });
        // addServiceToCart();
        showToast(message: 'Coming soon');
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
    if (isOwner) {
      return showToast(
          message: AppLocalization.of(context)!.cantPurchaseYourOwnServices);
    }
    if (widget.service.isAvailable!) {
      String type = "service";
      basketBloc.addItemToCart(item: widget.service, type: type);
      late var mapData;
      basketBloc.items.forEach((element) {
        if (element["item"].id == widget.service.id) {
          mapData = element;
          return;
        }
      });
      Map<String, dynamic> data = {
        "type": type,
        "id": mapData["item"].id,
        "qty": mapData["qty"],
      };
      debugPrint("Data From Display Product widget Page : $data");
      await _auth.addOrUpdateItemToShoppingCart(data);
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
              bool data = await YarnAuth().addYarnAndQuestion(params, '', '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
              }
            }));
  }
}

class FindBusiness extends StatefulWidget {
  CustomerProfile customerProfile;
  final Function()? onProductRefresh;
  final TileRenderPlace tileRenderPlace;
  final Function(String, bool) callback;

  FindBusiness(
      {Key? key,
      required this.customerProfile,
      this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
      this.onProductRefresh,
      required this.callback})
      : super(key: key);

  @override
  State<FindBusiness> createState() => _FindBusinessState();
}

class _FindBusinessState extends State<FindBusiness> {
  bool isLoadingFollowingAction = false;
  late UserBloc userBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return getNearByBusiness();
  }

  Widget getNearByBusiness() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.zero,
      shadowColor: boxShadow,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                  height: getContainerHeight(widget.tileRenderPlace, context),
                  child: getWallpaper()),
              Positioned(
                left: 10,
                top: getContainerHeight(widget.tileRenderPlace, context) - 20,
                child: InkWell(
                  onTap: () {
                    String? image = '';
                    if (widget.customerProfile.avatar! == "" ||
                        widget.customerProfile.avatar! ==
                            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
                      image = getInitials(widget.customerProfile.fullName!)
                          .toUpperCase();
                    } else {
                      image = widget.customerProfile.avatar!;
                    }

                    Navigator.of(context)
                        .pushNamed(Routes.PHOTO_VIEWER, arguments: image);
                  },
                  child: SizedBox(
                      width: widget.tileRenderPlace == TileRenderPlace.Thiny
                          ? 40
                          : 50,
                      height: widget.tileRenderPlace == TileRenderPlace.Thiny
                          ? 40
                          : 50,
                      child: CircularUserColorImage(
                          imageUrl: widget.customerProfile.avatar!,
                          name: widget.customerProfile.fullName!)),
                ),
              ),
            ],
          ),
          Container(
            padding: widget.tileRenderPlace == TileRenderPlace.Thiny
                ? const EdgeInsets.only(left: 15, top: 20, bottom: 5, right: 15)
                : const EdgeInsets.only(
                    left: 15, top: 30, bottom: 10, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.USER_PROFILE, arguments: {
                            "searchedUserName": widget.customerProfile.userName
                          });
                        },
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    appendStringDot(
                                        messageDecoderWithEmoji(widget
                                                    .customerProfile.fullName ??
                                                "") ??
                                            "",
                                        widget.tileRenderPlace ==
                                                TileRenderPlace.Thiny
                                            ? 13
                                            : 20),
                                    style: TextStyle(
                                        fontSize: widget.tileRenderPlace ==
                                                TileRenderPlace.Thiny
                                            ? 12
                                            : 16,
                                        fontWeight: FontWeight.w700,
                                        color: yarnBlack),
                                  )),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: userNameWithVerifiedIcon(
                                    name: appendStringDot(
                                        messageDecoderWithEmoji(
                                                '@${widget.customerProfile.userName}') ??
                                            "",
                                        widget.tileRenderPlace ==
                                                TileRenderPlace.Thiny
                                            ? 13
                                            : 20),
                                    isVerified:
                                        widget.customerProfile.isVerified,
                                    textStyle: TextStyle(
                                      fontSize: widget.tileRenderPlace ==
                                              TileRenderPlace.Thiny
                                          ? 11
                                          : 14,
                                      color: HexColor("#151515"),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    verifiedIconColor: verifyGreen,
                                    verifiedIconSize: widget.tileRenderPlace ==
                                            TileRenderPlace.Thiny
                                        ? 12
                                        : 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: getFollowUnFollowBtn(),
                    ),
                  ],
                ),
                SizedBox(
                  height: widget.tileRenderPlace == TileRenderPlace.Thiny
                      ? 2.0
                      : 5.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: widget.tileRenderPlace == TileRenderPlace.Thiny
                      ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                      : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: getRating(
                      numberOfRating: widget.customerProfile.rating.toInt()),
                ),
                if (widget.customerProfile.bio!.isNotEmpty ||
                    widget.customerProfile.bio != null) ...[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(widget.customerProfile.bio) ??
                              "",
                          style: TextStyle(
                            fontSize:
                                getFontSize(widget.tileRenderPlace, context),
                            fontWeight: FontWeight.w600,
                            color: blackFont,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height:
                widget.tileRenderPlace == TileRenderPlace.Thiny ? 5.0 : 10.0,
          ),
        ],
      ),
    );
  }

  Widget getFollowUnFollowBtn() {
    if (isLoadingFollowingAction) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (widget.customerProfile.userName! == userBloc.user.userName) {
      return const SizedBox.shrink();
    }
    if (widget.customerProfile.isFollowing != null &&
        widget.customerProfile.isFollowing == true) {
      return InkWell(
        onTap: () {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          UserAuth()
              .followOrUnfollowUser(widget.customerProfile.userName!,
                  shouldFollow: false)
              .then((value) async {
            if (value == true) {
              // await getSearchedUser(load: false);
              // Call the callback function and pass the username and bool as false
              widget.callback(widget.customerProfile.userName!, false);
            }
            isLoadingFollowingAction = false;
            if (mounted) setState(() {});
          }).catchError((e) {
            isLoadingFollowingAction = false;
            if (mounted) setState(() {});
            showToast(message: e.toString());
          });
        },
        child: Container(
          height: widget.tileRenderPlace == TileRenderPlace.Thiny ? 20 : 30,
          width: widget.tileRenderPlace == TileRenderPlace.Thiny ? 60 : 80,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: blackFont,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: HexColor("#292929"), width: 1)),
          child: Center(
            child: Text(
              'Following',
              style: TextStyle(
                fontSize:
                    widget.tileRenderPlace == TileRenderPlace.Thiny ? 10 : 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        isLoadingFollowingAction = true;
        if (mounted) setState(() {});
        UserAuth()
            .followOrUnfollowUser(widget.customerProfile.userName!,
                shouldFollow: true)
            .then((value) async {
          if (value == true) {
            // await getSearchedUser(load: false);
            // Call the callback function and pass the username and bool as true
            widget.callback(widget.customerProfile.userName!, true);
          }
          isLoadingFollowingAction = false;
          if (mounted) setState(() {});
        }).catchError((e) {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          showToast(message: e.toString());
        });
      },
      child: Container(
        height: widget.tileRenderPlace == TileRenderPlace.Thiny ? 20 : 30,
        width: widget.tileRenderPlace == TileRenderPlace.Thiny ? 60 : 80,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: HexColor("#292929"), width: 1)),
        child: Center(
          child: Text(
            'Follow',
            style: TextStyle(
              fontSize:
                  widget.tileRenderPlace == TileRenderPlace.Thiny ? 11 : 13,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget getWallpaper() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: widget.customerProfile.wallpaper == "" ||
              widget.customerProfile.wallpaper == null
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: widget.customerProfile.wallpaper);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  // height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: widget.customerProfile.wallpaper!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
    );
  }

  Future<void> getSearchedUser({bool load = true}) async {
    late CustomerProfile user;

    if (load) {
      isLoadingFollowingAction = true;
      if (mounted) setState(() {});
    }

    try {
      user = await UserAuth().fetchCustomerProfileWithAuth(
          widget.customerProfile.userName!.toString());
    } catch (e) {
      Navigator.pop(context);
      showToast(message: 'User not found');
    }

    widget.customerProfile = user;

    isLoadingFollowingAction = false;
    if (mounted) setState(() {});
  }
}

class CircularUserColorImage extends StatelessWidget {
  final String imageUrl;
  final String name;

  const CircularUserColorImage(
      {Key? key, required this.imageUrl, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: naturalGreen,
            width: 3.0,
          ),
        ),
        child: getUserProfilePic(imageUrl, name),
      ),
    );
  }
}
