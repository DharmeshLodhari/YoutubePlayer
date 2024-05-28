import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class FormVariantsTile extends StatelessWidget {
  FormVariantsTile(
      {required this.productVariantList,
      required this.index,
      super.key,
      required this.type});

  List<Variant> productVariantList;
  int index;
  String type;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appendStringDot(productVariantList[index].title!, 10),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    fontSize: 14),
              ),
              const SizedBox(height: 3.0),
              Text(
                'Available . ${productVariantList[index].quantity!}',
                maxLines: 1,
                style: TextStyle(
                    color: darkGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontSize: 12),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  worldCurrencies[productVariantList[index].currency!]!,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: blackFont,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    moneyDisplayNormalizer(
                        int.parse(productVariantList[index].price.toString())),
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          leading: getVariantLeading(productVariantList[index]),
          trailing: getVariantTrailing(productVariantList[index]),
        ),
      ),
    );
  }

  Widget getVariantLeading(Variant productVariant) {
    // Retrieve the first image from the 'pictures' list
    String? sercerUrl = "";
    String? localUrl = "";

    if (productVariant.serverImages != null) {
      for (var item in productVariant.serverImages ?? []) {
        sercerUrl = item;
      }
      sercerUrl = sercerUrl!.replaceAll('https//', 'https://');
    } else {
      if (productVariant.localImages != null &&
          (productVariant.localImages?.isNotEmpty ?? false)) {
        localUrl = productVariant.localImages?[0].path;
      }
    }

    if (sercerUrl == "" && localUrl == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(productVariant.title!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: localUrl != null && localUrl.isNotEmpty
                  ? FileImage(
                      File(localUrl),
                    )
                  : NetworkImage(
                      sercerUrl,
                    ) as ImageProvider,
              fit: BoxFit.cover),
        ),
      );
    }
  }

  Widget getVariantTrailing(Variant productVariant) {
    return IconButton(
      padding: const EdgeInsets.only(right: 5),
      alignment: Alignment.topRight,
      icon: Container(
        child: Icon(
          SlydoAppIcon.remove,
          color: blackFont,
          size: 15,
        ),
      ),
      onPressed: () {
        removeSelectedVariant(productVariant.title.toString());
      },
    );
  }

  void removeSelectedVariant(String selectedVariantTitle) {
    // Use the removeWhere method to remove the variant with the specified title.
    productVariantList
        .removeWhere((variant) => variant.title == selectedVariantTitle);
  }
}
