import 'dart:io';

import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

class Product {
  int id;
  String title;
  String description;
  String price;
  List<File> localImages;
  List<String> serverImages;
  String seller;
  String condition;
  String category;

  Product({
    this.id,
    this.title,
    this.description,
    this.price,
    this.localImages,
    this.serverImages,
    this.seller,
    this.condition,
    this.category,
  });
}

class Service {
  int id;
  String title;
  String description;
  String price;
  List<File> localImages;
  List<String> serverImages;
  String seller;
  String shortDescription;
  String category;

  Service({
    this.id,
    this.title,
    this.description,
    this.price,
    this.localImages,
    this.serverImages,
    this.seller,
    this.shortDescription,
    this.category,
  });
}

class ProductCategory {
  const ProductCategory(this.name, this.icon);
  final String name;
  final Icon icon;
}

List<ProductCategory> productCategories = <ProductCategory>[
  ProductCategory(
      'Food',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ProductCategory(
      'Movie & Music',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  ProductCategory(
      'Motor',
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Property',
      Icon(
        Icons.home,
        color: darkBlue(),
      )),
];

class ProductCondition {
  const ProductCondition(this.name, this.description);
  final String name;
  final String description;
}

List<ProductCondition> conditions = <ProductCondition>[
  const ProductCondition(
    'New',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Like New',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Good',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Fair',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Poor',
    'Orignal packaging or with tag',
  ),
];
