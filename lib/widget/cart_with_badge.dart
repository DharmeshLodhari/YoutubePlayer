import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CartWithBadge extends StatelessWidget {
  List<BasketItem> items;
  Function? onTap;
  double height;
  double width;
  Color? backgroundColor;
  Color? iconColor;
  bool enableMargin;
  BadgePosition? position;

  CartWithBadge({
    super.key,
    required this.items,
    required this.onTap,
    this.height = 30,
    this.width = 30,
    this.backgroundColor,
    this.iconColor,
    this.enableMargin = true,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedBackgroundIcon(
      height: height,
      width: width,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: position ??
            badges.BadgePosition.topEnd(
                end: getBadgeCount().length == 1 ? -2 : 0, top: -10),
        badgeAnimation: const badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: naturalGreen,
          padding:
              items.isEmpty ? const EdgeInsets.all(0) : const EdgeInsets.all(3),
          elevation: 0,
        ),
        child: Center(
          child: Icon(
            SlydoAppIcon.cart,
            size: 15,
            color: iconColor ?? blackFont,
          ),
        ),
      ),
      onTap: onTap,
      backgroundColor: backgroundColor ?? transparent,
      enableMargin: enableMargin,
    );
  }

  Widget? getBadgeContent() {
    if (items.isEmpty) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;

    for (var item in items) {
      if (item.item is Product) {
        if (item.variants != null) {
          // If there are variants, calculate the total quantity from variants

          totalItem +=
              int.parse(item.getVariant()?.quantity?.toString() ?? "0");
        } else {
          // If the variant list is empty, add the quantity to the total
          totalItem += int.parse(item.qty.toString());
        }
      } else if (item.item is Service) {
        totalItem += int.parse(item.qty.toString());
      }
    }

    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  // String getBadgeCount() {
  //   int totalItem = 0;
  //   for (var element in items) {
  //     totalItem = totalItem + int.parse(element.qty.toString());
  //   }
  //   // for (var item in basketBloc.items) {
  //   //
  //   //   if (item['item'] is Product) {
  //   //     var product = item['item'] as Product;
  //   //
  //   //     if (product.variant!.isEmpty && product.variant != null) {
  //   //       // If the variant list is empty, add the quantity to the total
  //   //       totalItem += int.parse(item['qty'].toString());
  //   //     } else {
  //   //       // If there are variants, calculate the total quantity from variants
  //   //       for(var variant in product.variant!){
  //   //         var vProduct = Variant.fromJson(variant);
  //   //         totalItem += int.parse(vProduct.quantity.toString());
  //   //       }
  //   //     }
  //   //
  //   //   } else if (item['item'] is Service) {
  //   //     totalItem += int.parse(item['qty'].toString());
  //   //   }
  //   // }
  //   return totalItem > 99 ? '99+' : totalItem.toString();
  // }
}
