import 'package:Slydo/data/currency.dart';
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("${DateTime.now().toString()}");
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product',
            arguments: {"product": product});
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Colors.white,
          // margin: EdgeInsets.only(right: 0.0, bottom: 2),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFFDCE0E8)),
              borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
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
                Container(
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
                          str: product.name!,
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
                        messageDecoderWithEmoji(
                              truncateString(
                                str: product.shortDescription!,
                                lengthToTruncateAt: 60,
                                showEllipsis: true,
                              ),
                            ) ??
                            "",
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    worldCurrencies[product.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      fontSize: 14.8,
                      color: navyBlue,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(product.price!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: navyBlue,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
