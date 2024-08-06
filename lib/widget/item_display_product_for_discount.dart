import 'package:Slydo/data/currency.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayProductForDiscount extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final void Function(bool) onChange;

  const DisplayProductForDiscount({
    required this.product,
    required this.onChange,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(DateTime.now().toString());
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.PRODUCT,
            arguments: {"product": product});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          // margin: EdgeInsets.only(right: 0.0, bottom: 2),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFDCE0E8)),
              borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: <Widget>[
                Checkbox(
                  activeColor: navyBlue,
                  value: isSelected,
                  onChanged: (value) {
                    onChange(value!);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                SizedBox(
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: CachedNetworkImage(
                      imageUrl: product.cover!,
                      fit: BoxFit.cover,
                      width: 80,
                      errorWidget: productAndServiceBigErrorWidget,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truncateString(
                          str: messageDecoderWithEmoji(product.name) ?? "",
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
                          str: messageDecoderWithEmoji(
                                  product.shortDescription) ??
                              "",
                          lengthToTruncateAt: 45,
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
                      getRating(numberOfRating: product.rating?.toInt()),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          worldCurrencies[product.currency] ?? "NGN",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: navyBlue,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        priceText(),
                      ],
                    ),
                    if ((product.variantModels?.isEmpty ?? false) &&
                        product.discountedPrice != null)
                      product.checkProductDiscount()
                          ? Row(
                              children: [
                                Text(
                                  worldCurrencies[product.currency] ?? "NGN",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: navyBlue,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  moneyDisplayNormalizer(product.price),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget priceText() {
    String price;
    if (product.priceRange != null && product.priceRange != "0") {
      price = product.priceRange ?? "0";
    } else {
      price = moneyDisplayNormalizer(
        int.parse(product.getPriceRange()),
      );
    }
    return Text(
      price,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: navyBlue,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
