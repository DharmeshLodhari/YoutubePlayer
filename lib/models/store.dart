import 'dart:io';

import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

class Product {
  String id;
  String name;
  String description;
  String shortDescription;
  String price;
  List<File> localImages;
  List<String> serverImages;
  String seller;
  String condition;
  String qrCode;
  String category;
  String manufacturer;
  bool isAvailable;
  DateTime availableFrom;
  String currency;
  List<dynamic> pictureMap;

  Product(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.price,
      this.localImages,
      this.serverImages,
      this.seller,
      this.qrCode,
      this.condition,
      this.category,
      this.manufacturer,
      this.isAvailable,
      this.availableFrom,
      this.currency,
      this.pictureMap});

  Map toMap() {
    return {
      "name": this.name,
      "description": this.description,
      "short_description": this.shortDescription,
      "price": this.price,
      "condition": this.condition,
      "category": this.category,
      "manufacturer": this.manufacturer,
      "is_available": this.isAvailable,
      "available_from": this.availableFrom,
    };
  }

  String getImageId(String imageUrl) {
    for (var data in this.pictureMap) {
      if (data['file'] == imageUrl) {
        return data['id'].toString();
      }
    }
  }

  List<String> imageDataToList(List<dynamic> pictures) {
    List<String> imageLinks = [];
    if (pictures.length > 0) {
      for (var data in pictures) {
        imageLinks.add(data["file"]);
      }
    } else {
      imageLinks.add(
          "https://borinhalbich.com/wp-content/uploads/2018/06/placeholder-250x300.png");
    }
    return imageLinks;
  }
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
      'Auto & Large Appliances',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ProductCategory(
      'Automotive',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  ProductCategory(
      "Baby & Kids",
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Beauty & Spas',
      Icon(
        Icons.home,
        color: darkBlue(),
      )),
  ProductCategory(
      'Electronics',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ProductCategory(
      'Entertainment',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  ProductCategory(
      "Food & Drink",
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Grocery & Household',
      Icon(
        Icons.home,
        color: darkBlue(),
      )),
  ProductCategory(
      'Health & Beauty',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ProductCategory(
      'Health & Fitness',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  ProductCategory(
      "Home & Garden",
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Jewellery & Watches',
      Icon(
        Icons.home,
        color: darkBlue(),
      )),
  ProductCategory(
      "Men's Fashion",
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ProductCategory(
      'Personalised',
      Icon(
        Icons.movie,
        color: darkBlue(),
      )),
  ProductCategory(
      "Pet Supplies",
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Sports & Outdoors',
      Icon(
        Icons.home,
        color: darkBlue(),
      )),
  ProductCategory(
      "Toys",
      Icon(
        Icons.directions_car,
        color: darkBlue(),
      )),
  ProductCategory(
      'Women’s Fashion',
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
    'Fair',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Good',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Like New',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'New',
    'Orignal packaging or with tag',
  ),
  const ProductCondition(
    'Poor',
    'Orignal packaging or with tag',
  ),
];

List temp = [
  "Alarms – Security & Fire",
  "Appliance Repairs",
  "Architect",
  "Block laye",
  "Brick layer",
  "Builder - General",
  "Builder - Ground Works",
  "Builder - House Extensions",
  "Builder - New Builds",
  "Building Surveyor",
  "CCTV Cameras",
  "Carpenter/Joiner",
  "Carpet fitter",
  "Civil Engineer",
  "Cleaning Service",
  "Computer Systems",
  "Conservatories & Sunrooms",
  "Curtain maker",
  "Drain & Sewer Cleaning",
  "Electrician",
  "Fencing Contractor",
  "Fitter/Welder",
  "Flooring",
  "Gardening/Landscaping",
  "Gas Fitter",
  "General Work/Miscellaneous Work",
  "Gutters Fascia & Soffit",
  "Handyman",
  "Heating Contractor",
  "Insulation - Pumped",
  "Insulation Contractor",
  "Interior Designer",
  "Kitchens & Fitted Furniture",
  "Locks & Locksmiths",
  "Mechanic",
  "Painter/Decorator",
  "Paving Contractor",
  "Phone Systems",
  "Plasterer",
  "Plumber",
  "Quantity Surveyor",
  "Removal & Storage",
  "Roofer",
  "Slabbing Contractor",
  "Solar Panels",
  "Steel Erector",
  "Stone Mason",
  "Tiler",
  "Tree Surgeon",
  "Underfloor Heating",
  "Upholsterer",
  "Window & Door Repairs,Other",
  "Window Installer"
];

List<ProductCategory> services = <ProductCategory>[
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
