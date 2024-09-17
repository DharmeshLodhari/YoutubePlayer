import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/all_active_cart.dart';
import 'package:Slydo/screens/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../routes/route_constants.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';
import '../screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../screens/yarn/models/share_as_yarn_model.dart';
import '../screens/yarn/share_as_a_yarn_screen.dart';
import '../screens/yarn/yarn_auth.dart';
import '../screens/yarn/yarn_dashboard_bloc.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/slydo_app_icon_new_icons.dart';
import 'bottom_sheet_item.dart';

class DisplayProduct extends StatefulWidget {
  final Product product;
  final bool giveRightPadding;
  final Function()? onProductRefresh;
  final bool isProductShowIcon;

  DisplayProduct(
      {super.key,
      required this.product,
      this.giveRightPadding = false,
      this.onProductRefresh,
      this.isProductShowIcon = false});

  @override
  State<DisplayProduct> createState() => _DisplayProductState();
}

class _DisplayProductState extends State<DisplayProduct> {
  late bool isOwner;
  late BasketBloc basketBloc;
  late UserBloc userBloc;
  late SharedCartBloc sharedCartBloc;
  bool showAddToCartButton = true;
  late YarnDashboardBloc yarnDashboardBloc;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    isOwner = widget.product.seller == getLoggedInUserName(context);
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return GestureDetector(
      onTap: () {
        if (showAddToCartButton == false) {
          showAddToCartButton = true;
          if (mounted) setState(() {});
          return;
        }

        Navigator.pushNamed(context, '/product',
            arguments: {"product": widget.product});
      },
      child: SizedBox(
        width: 170,
        child: Card(
          semanticContainer: true,
          color: Colors.transparent,
          elevation: 0,
          shadowColor: boxShadow,
          child: Column(
            key: _key,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildProductImage(),
              if (widget.product.variantModels?.isEmpty ?? false)
                _buildProductDiscountAndTag(),
              const SizedBox(height: 2),
              _buildItemName(widget.product.name),
              _buildItemShortDescription(widget.product.shortDescription),
              const SizedBox(height: 2),
              Row(
                children: [
                  getRating(numberOfRating: widget.product.rating?.toInt()),
                  const SizedBox(width: 5),
                  _getItemReviews(widget.product.reviewScore),
                ],
              ),
              getPreparationTime(widget.product.preparationTime),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildItemCurrency(widget.product.currency),
                            _buildProductPrice(),
                          ],
                        ),
                        _buildProductNormalPrice(),
                      ],
                    ),
                    displayShoppingAddingToCartControl()
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        _buildItemImage(widget.product.cover),
        _buildHeartIcon(widget.isProductShowIcon),
        displayShoppingCartControls(),
      ],
    );
  }

  Widget _buildProductPrice() {
    String price;
    if (widget.product.priceRange != null && widget.product.priceRange != "0") {
      price = widget.product.priceRange ?? "0";
      if (widget.product.priceRange?.contains('-') == false) {
        price =
            moneyDisplayNormalizer(int.parse(widget.product.priceRange ?? "0"));
      } else {
        price = price.replaceAll(
            " - ", " - ${worldCurrencies[widget.product.currency] ?? "NGN"}");
      }
    } else {
      price = moneyDisplayNormalizer(
        int.parse(
          widget.product.getPriceRange(),
        ),
      );
    }
    return Text(
      price,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: navyBlue,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProductNormalPrice() {
    if ((widget.product.variantModels?.isEmpty ?? false) &&
        widget.product.discountedPrice != null) {
      if (widget.product.checkProductDiscount()) {
        return Row(
          children: [
            Text(
              worldCurrencies[widget.product.currency] ?? "NGN",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: fontLightGrey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              moneyDisplayNormalizer(widget.product.price),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: fontLightGrey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        );
      } else {
        const SizedBox();
      }
    } else {
      const SizedBox();
    }
    return const SizedBox.shrink();
  }

  void addProductToCart() async {
    if (isOwner) {
      return showToast(
          message: AppLocalization.of(context)!.cantPurchaseYourOwnServices);
    }
    if (widget.product.isProductAvailableNow()) {
      const String type = "product";
      if (widget.product.variantModels?.isNotEmpty ?? false) {
        showToast(message: AppLocalization.of(context)!.selectVariantColorSize);
        Navigator.pushNamed(context, '/product',
            arguments: {"product": widget.product});
      } else if (widget.product.addOnsModels?.isNotEmpty ?? false) {
        showToast(message: AppLocalization.of(context)!.selectRequiredAddons);
        Navigator.pushNamed(context, '/product',
            arguments: {"product": widget.product});
      } else {
        basketBloc.addItemToCart(
          item: widget.product.copyWith(quantity: 1),
          type: type,
          currentUser: userBloc.user.convertToUser(),
        );
      }
    } else {
      showToast(message: AppLocalization.of(context)!.productOutOfStock);
    }
  }

  Future<void> addToSharedCart(SharedCartModel result) async {
    const String type = "product";

    final Product products =
        widget.product.copyWith(quantity: 1, withSelectedAddOn: true);

    sharedCartBloc.addItemToSharedCart(
      cart: result,
      item: products,
      type: type,
      currentUser: userBloc.user.convertToUser(),
    );
  }

  Widget buildProductDiscountPrice() {
    if (widget.product.discountedPrice != null &&
        widget.product.discountedPrice != 0) {
      if (widget.product.checkProductDiscount()) {
        return SizedBox(
          width: double.infinity,
          height: 22,
          child: showDiscountValue(
            widget.product.discountType!,
            widget.product.discountValue!,
            widget.product.currency,
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget displayShoppingCartControls() {
    return Positioned(
      right: 10,
      bottom: 5,
      child: isInCart() == true
          ? Container(
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
                        if (widget.product.addOnsModels?.isNotEmpty ?? false) {
                          confirmAddOnsDialog();
                        } else {
                          basketBloc.increaseQty(
                            currentProduct: widget.product,
                            currentUser: userBloc.user.convertToUser(),
                          );
                        }
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
                        basketBloc.decreaseQty(
                          currentProduct: widget.product,
                          currentUser: userBloc.user.convertToUser(),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/images/minus.svg',
                        height: 17,
                        width: 17,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Future<void> confirmAddOnsDialog() async {
    await showDialogBox(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      title: "Repeat last used Add-ons?",
      actionOneText: "I'll choose",
      actionTwoText: "Repeat last",
      leftButtonOnPressed: () {
        Navigator.pushNamed(context, Routes.PRODUCT,
            arguments: {"product": widget.product, "type": "changeAddons"});
      },
      rightButtonOnPressed: () {
        basketBloc.increaseQty(
          currentProduct: widget.product,
          currentUser: userBloc.user.convertToUser(),
        );
      },
    );
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
    return GestureDetector(
      onLongPress: () {
        if (isOwner) {
          return showToast(
              message:
                  AppLocalization.of(context)!.cantPurchaseYourOwnServices);
        }
        if (widget.product.isProductAvailableNow()) {
          if (widget.product.variantModels?.isNotEmpty ?? false) {
            showToast(
                message: AppLocalization.of(context)!.selectVariantColorSize);
            Navigator.pushNamed(context, '/product',
                arguments: {"product": widget.product});
          } else if (widget.product.addOnsModels?.isNotEmpty ?? false) {
            showToast(
                message: AppLocalization.of(context)!.selectRequiredAddons);
            Navigator.pushNamed(context, '/product',
                arguments: {"product": widget.product});
          } else {
            showBottomSheetDialog();
          }
        } else {
          showToast(message: AppLocalization.of(context)!.productOutOfStock);
        }
      },
      child: RoundedBackgroundIcon(
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
      ),
    );
  }

  void showBottomSheetDialog() async {
    final result = await androidBottomSheet(
      enableDrag: true,
      context: context,
      child: const AllActiveCart(),
    );
    if (result != null && result is SharedCartModel) {
      if (result.id == 'my-cart') {
        setState(() {
          showAddToCartButton = false;
        });
        addProductToCart();
      } else {
        await sharedCartBloc.refreshSharedCartProduct(context, result);
        addToSharedCart(result);
      }
    }
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

  Widget _buildProductDiscountAndTag() {
    if ((widget.product.availableFrom?.isAfter(DateTime.now()) ?? false) &&
        (widget.product.variantModels?.isEmpty ?? false)) {
      return SizedBox(
        width: double.infinity,
        height: 22,
        child: showColoredLabeledWidgetProductStock(
          text: AppLocalization.of(context)!.comingSoon,
          color: lightYellow,
          date: formatDate1(widget.product.availableFrom),
          product: widget.product,
        ),
      );
    } else if ((widget.product.variantModels?.isEmpty ?? false) &&
        widget.product.trackInventory == true &&
        (widget.product.variantModels?.isEmpty ?? false) &&
        (widget.product.quantity ?? 0) <= 0) {
      return SizedBox(
        width: double.infinity,
        height: 22,
        child: showColoredLabeledWidgetProductStock(
          text: AppLocalization.of(context)!.outOfStock,
          color: lightRed,
          product: widget.product,
        ),
      );
    } else if ((widget.product.discountedPrice != null &&
            widget.product.discountedPrice != 0) ||
        (widget.product.pricePercentageChange != null &&
            widget.product.pricePercentageChange != 0.0)) {
      return buildProductDiscountPrice();
    } else {
      return const SizedBox();
    }
  }
}

class DisplayService extends StatefulWidget {
  final Service service;
  final Product? product;
  final bool giveRightPadding;
  final Function()? onServiceRefresh;

  const DisplayService(
      {super.key,
      required this.service,
      this.product,
      this.giveRightPadding = false,
      this.onServiceRefresh});

  @override
  State<DisplayService> createState() => _DisplayServiceState();
}

class _DisplayServiceState extends State<DisplayService> {
  late bool isOwner;
  late BasketBloc basketBloc;
  late UserBloc userBloc;
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
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    return GestureDetector(
      onTap: () {
        if (showAddToCartButton == false) {
          showAddToCartButton = true;
          if (mounted) setState(() {});
          return;
        }

        final Service currentService = Service();
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
        width: 170,
        child: Card(
          semanticContainer: true,
          color: Colors.transparent,
          elevation: 0,
          shadowColor: boxShadow,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildServiceImage(),
              _buildServiceStockAndDetailTag(),
              const SizedBox(height: 2),
              _buildItemName(widget.service.name),
              _buildItemShortDescription(widget.service.shortDescription),
              const SizedBox(height: 2),
              Row(
                children: [
                  getRating(numberOfRating: widget.service.rating?.toInt()),
                  const SizedBox(width: 5),
                  _getItemReviews(widget.service.reviewScore),
                ],
              ),
              // getPreparationTime(widget.service.preparationTime),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildItemCurrency(widget.service.currency),
                            _buildServicePrice(),
                          ],
                        ),
                        _buildServiceNormalPrice(),
                      ],
                    ),
                    displayShoppingAddingToCartControl()
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStockAndDetailTag() {
    if (widget.service.availableFrom?.isAfter(DateTime.now()) ?? false) {
      return SizedBox(
        width: double.infinity,
        height: 22,
        child: showColoredLabeledWidgetService(
          date: formatDate1(widget.service.availableFrom),
          service: widget.service,
          text: AppLocalization.of(context)!.comingSoon,
          color: lightYellow,
          fontSize: 12,
          verticalPadding: 5,
        ),
      );
    } else if (widget.service.isAvailable == false) {
      return SizedBox(
        width: double.infinity,
        height: 22,
        child: showColoredLabeledWidgetService(
          service: widget.service,
          text: AppLocalization.of(context)!.outOfStock,
          color: lightRed,
          fontSize: 12,
          verticalPadding: 5,
        ),
      );
    } else if ((widget.service.discountedPrice != null &&
            widget.service.discountedPrice != 0) ||
        (widget.service.pricePercentageChange != null &&
            widget.service.pricePercentageChange != 0.0)) {
      return buildServiceDiscountPrice();
    } else {
      return const SizedBox();
    }
  }

  Widget buildServiceDiscountPrice() {
    if (widget.service.discountedPrice != null &&
        widget.service.discountedPrice != 0) {
      if (widget.service.checkServiceDiscount()) {
        return SizedBox(
          width: double.infinity,
          height: 22,
          child: showDiscountValue(
            widget.service.discountType ?? "",
            widget.service.discountValue ?? 0,
            widget.service.currency,
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
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
                    child: SvgPicture.asset(
                      'assets/images/minus.svg',
                      height: 17,
                      width: 17,
                    ),
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
    final List<Widget> list = [];

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

          final result = await Navigator.of(context).pushNamed(
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
    const String type = "service";

    late var mapData;
    for (var element in basketBloc.items) {
      if (element["item"].id == widget.service.id) {
        mapData = element;
        continue;
      }
    }
    final Map data = {
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
      const String type = "service";
      basketBloc.addItemToCart(
        item: widget.service,
        type: type,
      );
      late var mapData;
      for (var element in basketBloc.items) {
        if (element["item"].id == widget.service.id) {
          mapData = element;
          continue;
        }
      }
      final Map<String, dynamic> data = {
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
    NavigationUtil.push(
      context,
      screen: ShareAsAyarnScreen(
        askCategories: yarnDashboardBloc.yarnCategories,
        shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
        callback: (params) async {
          params.body = widget.service.name ?? "";
          params.attachment = {
            "service": widget.service.toJson().cast<String, dynamic>()
          };
          final bool data = await YarnAuth().addYarnAndQuestion(params, '', '');
          if (data) {
            showToast(message: "Shared in Yarn successfully");
          }
        },
      ),
    );
  }

  Widget _buildServiceImage() {
    return Stack(
      children: [
        _buildItemImage(widget.service.cover),
        displayShoppingCartControls(),
        //TODO: to be implemented later in future
        // Positioned(right: 10, top: 10, child: favouriteIcon())
      ],
    );
  }

  Widget _buildServicePrice() {
    return Text(
      moneyDisplayNormalizer(int.parse(widget.service.getServiceRealPrice())),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: navyBlue,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildServiceNormalPrice() {
    if (widget.service.discountedPrice != null) {
      if (widget.service.checkServiceDiscount()) {
        return Row(
          children: [
            Text(
              worldCurrencies[widget.service.currency] ?? "NGN",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: fontLightGrey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              moneyDisplayNormalizer(int.parse(widget.service.price ?? "0")),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: fontLightGrey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        );
      } else {
        const SizedBox();
      }
    } else {
      const SizedBox();
    }
    return const SizedBox.shrink();
  }
}

Widget _buildItemImage(String? cover) {
  return CachedNetworkImage(
    height: 170,
    imageUrl: cover ?? "",
    fit: BoxFit.cover,
    width: double.infinity,
    errorWidget: productAndServiceBigErrorWidget,
  );
}

Widget _buildHeartIcon(bool isProductShowIcon) {
  return Positioned(
    top: 10,
    left: 10,
    child: isProductShowIcon == true
        ? Image.asset(
            "assets/images/appIcon/heart.png",
            height: 17,
            width: 17,
          )
        : const SizedBox.shrink(),
  );
}

Widget _buildItemName(String? itemName) {
  return Text(
    truncateString(
      str: messageDecoderWithEmoji(itemName) ?? "",
      lengthToTruncateAt: 38,
      showEllipsis: true,
    ),
    maxLines: 2,
    style: TextStyle(
      color: blackFont,
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget _buildItemShortDescription(String? shortDescription) {
  return Text(
    truncateString(
      str: messageDecoderWithEmoji(shortDescription) ?? "",
      lengthToTruncateAt: 60,
      showEllipsis: true,
    ),
    maxLines: 2,
    style: TextStyle(
      fontFamily: "Inter",
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: fontLightGrey,
    ),
  );
}

Widget _getItemReviews(int? reviewScore) {
  if ((reviewScore ?? 0) != 0) {
    return Text(
      "($reviewScore ${(reviewScore ?? 0) <= 1 ? 'review' : 'reviews'})",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        fontFamily: 'Inter',
        color: fontLightGrey,
      ),
    );
  } else {
    return const SizedBox.shrink();
  }
}

Widget getPreparationTime(int? preparationTime) {
  if (preparationTime != null && preparationTime != 0) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Text(
          "$preparationTime",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            fontFamily: 'Inter',
            color: fontLightGrey,
          ),
        ),
      ],
    );
  }
  return const SizedBox.shrink();
}

Widget _buildItemCurrency(String? currency) {
  return Text(
    worldCurrencies[currency] ?? "NGN",
    style: TextStyle(
      fontFamily: "Inter",
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: navyBlue,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
