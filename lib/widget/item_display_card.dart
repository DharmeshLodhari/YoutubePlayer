import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget displayProduct({BuildContext context, Product product}) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    color: Colors.white,
    elevation: 5,
    child: GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                child: CachedNetworkImage(
                  imageUrl: product.cover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                product.name,
                style: TextStyle(color: lightBlue()),
                maxLines: 1,
              ),
              subtitle: Text(
                product.shortDescription,
                maxLines: 1,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[product.currency],
                    style: TextStyle(fontFamily: "Roboto"),
                  ),
                  Text(
                    product.price.toString(),
                  ),
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
        Navigator.pushNamed(context, '/product',
            arguments: {"product": currentProduct});
      },
    ),
  );
}
