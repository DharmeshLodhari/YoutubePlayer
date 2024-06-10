import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/basket_bloc.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/all_active_cart.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExploreSingleProduct extends StatefulWidget {
  final Product product;
  final bool giveRightPadding;
  final Function()? onProductRefresh;

  const ExploreSingleProduct(
      {Key? key,
      required this.product,
      this.giveRightPadding = false,
      this.onProductRefresh})
      : super(key: key);

  @override
  State<ExploreSingleProduct> createState() => _ExploreSingleProductState();
}

class _ExploreSingleProductState extends State<ExploreSingleProduct> {
  late bool isOwner;
  late BasketBloc basketBloc;
  late UserBloc userBloc;
  late SharedCartBloc sharedCartBloc;
  bool showAddToCartButton = true;

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: greyBorderColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                buildProductImage(),
                const SizedBox(
                  width: 15,
                ),
                buildProductDetails(),
              ],
            ),
            buildPriceAndCart(),
          ],
        ),
      ),
    );
  }

  Widget buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: CachedNetworkImage(
        imageUrl: widget.product.cover!,
        fit: BoxFit.cover,
        height: 70,
        width: 70,
        errorWidget: productAndServiceBigErrorWidget,
      ),
    );
  }

  Widget buildProductDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          truncateString(
            str: messageDecoderWithEmoji(widget.product.name) ?? "",
            lengthToTruncateAt: 13,
            showEllipsis: false,
          ),
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          messageDecoderWithEmoji(
                truncateString(
                  str: widget.product.shortDescription!,
                  lengthToTruncateAt: 15,
                  showEllipsis: true,
                ),
              ) ??
              "",
          style: TextStyle(
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: yarnBlack,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Row(
          children: [
            Icon(
              SlydoAppIcon.star,
              color: starYellow,
              size: 12,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.product.rating.toString(),
              style: TextStyle(
                color: blackFont,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildPriceAndCart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  worldCurrencies[widget.product.currency!]!,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
                Text(
                  moneyDisplayNormalizer(widget.product.discountedPrice != null
                      ? (widget.product.checkProductDiscount()
                          ? widget.product.discountedPrice
                          : widget.product.price!)
                      : widget.product.price!),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: navyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            if (widget.product.discountedPrice != null)
              (widget.product.checkProductDiscount())
                  ? Row(
                      children: [
                        Text(
                          worldCurrencies[widget.product.currency!]!,
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: navyBlue,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          moneyDisplayNormalizer(widget.product.price!),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: navyBlue,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox()
            else
              const SizedBox(),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        if (isInCart() == false)
          displayShoppingAddingToCartControl()
        else
          displayShoppingCartControls(),
      ],
    );
  }

  Widget displayShoppingCartControls() {
    if (isInCart() == true) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                basketBloc.decreaseQty(
                  currentProduct: widget.product,
                  currentUser: userBloc.user.convertToUser(),
                );
              },
              child: Card(
                color: greyBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.remove_rounded,
                  size: 22,
                  color: black,
                ),
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
                fontSize: 14,
                color: yarnBlack,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
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
              child: Card(
                color: greyBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: black,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
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

  Widget displayShoppingAddingToCartControl() {
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
      onTap: () {
        setState(() {
          showAddToCartButton = false;
        });
        addProductToCart();
      },
      child: Card(
        color: greyBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 22,
          color: black,
        ),
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
}
