import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget displayProduct(
    {required BuildContext context, required Product product}) {
  return Card(
    color: Colors.white,
    margin: EdgeInsets.only(right: 10.0, bottom: 8.0),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    shadowColor: boxShadow,
    child: GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width - 80,
        height: MediaQuery.of(context).size.height / 2.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: CachedNetworkImage(
                  imageUrl: product.cover!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: productAndServiceBigErrorWidget,
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name!,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        worldCurrencies[product.currency!]!,
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: navyBlue,
                        ),
                      ),
                      Text(
                        moneyDisplayNormalizer(int.parse(product.price!)),
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
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.shortDescription ?? "",
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  getRating(numberOfRating: product.rating?.toInt()),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Product currentProduct = Product();
        currentProduct.name = product.name;
        currentProduct.id = product.id;
        currentProduct.shortDescription = product.shortDescription;
        currentProduct.description = "";
        currentProduct.condition = product.condition;
        currentProduct.currency = product.currency;
        currentProduct.price = product.price;
        currentProduct.availableFrom = product.availableFrom ?? DateTime.now();
        currentProduct.isAvailable = product.isAvailable;
        currentProduct.qrCode = product.qrCode;
        currentProduct.seller = product.seller;
        currentProduct.manufacturer = product.manufacturer;
        currentProduct.serverImages = product.serverImages;
        currentProduct.rating = product.rating;
        Navigator.pushNamed(context, '/product',
            arguments: {"product": currentProduct});
      },
    ),
  );
}

Widget displayService(
    {required BuildContext context, required Service service}) {
  return Card(
    color: Colors.white,
    margin: EdgeInsets.only(right: 10, bottom: 8.0),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    shadowColor: boxShadow,
    child: GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width - 80,
        height: MediaQuery.of(context).size.height / 2.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
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
            ),
            ListTile(
              dense: true,
              title: Row(
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
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      messageDecoderWithEmoji(service.shortDescription) ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  getRating(numberOfRating: service.rating?.toInt()),
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
