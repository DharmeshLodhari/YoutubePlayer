import 'dart:io';

import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

class Product {
  int id;
  String title;
  String description;
  String price;
  List<File> images;
  String seller;
  String condition;
  String category;

  Product({
    this.id,
    this.title,
    this.description,
    this.price,
    this.images,
    this.seller,
    this.condition,
    this.category,
  });
}

class Service {
  int id;
  String title;
  String shortDescription;
  String description;
  String image;

  Service({
    this.id,
    this.title,
    this.shortDescription,
    this.description,
    this.image,
  });
}

class Category {
  const Category(this.name, this.icon);
  final String name;
  final Icon icon;
}

List<Category> categories = <Category>[
  Category(
      'Food',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  Category(
      'Movie & Music',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  Category(
      'Motor',
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  Category(
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
