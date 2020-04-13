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
  String id;
  String name;
  String description;
  String shortDescription;
  String price;
  List<File> localImages;
  List<String> serverImages;
  String provider;
  String qrCode;
  String category;
  bool isAvailable;
  DateTime availableFrom;
  String currency;
  List<dynamic> pictureMap;

  Service({
    this.id,
    this.name,
    this.description,
    this.shortDescription,
    this.price,
    this.localImages,
    this.serverImages,
    this.provider,
    this.qrCode,
    this.category,
    this.isAvailable,
    this.availableFrom,
    this.currency,
    this.pictureMap,
  });

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

  Map toMap() {
    return {
      "name": this.name,
      "description": this.description,
      "short_description": this.shortDescription,
      "price": this.price,
      "category": this.category,
      "is_available": this.isAvailable,
      "available_from": this.availableFrom,
    };
  }
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

class ServiceCatagory {
  const ServiceCatagory(this.name, this.icon);
  final String name;
  final Icon icon;
}

List<ServiceCatagory> serviceCategories = <ServiceCatagory>[
  ServiceCatagory(
      'Alarms – Security & Fire',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Appliance Repairs',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Architect',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Block laye',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Brick layer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Builder - General',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Builder - Ground Works',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Builder - House Extensions',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Builder - New Builds',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Building Surveyor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'CCTV Cameras',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Carpenter/Joiner',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Carpet fitter',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Civil Engineer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Cleaning Service',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Computer Systems',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Conservatories & Sunrooms',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Curtain maker',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Drain & Sewer Cleaning',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Electrician',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Fencing Contractor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Fitter/Welder',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Flooring',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Gardening/Landscaping',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Gas Fitter',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'General Work/Miscellaneous Work',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Gutters Fascia & Soffit',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Handyman',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Heating Contractor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Insulation - Pumped',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Insulation Contractor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Interior Designer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Kitchens & Fitted Furniture',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Locks & Locksmiths',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Mechanic',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Painter/Decorator',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Paving Contractor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Phone Systems',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Plasterer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Plumber',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Quantity Surveyor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Removal & Storage',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Roofer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Slabbing Contractor',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Solar Panels',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Steel Erector',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Stone Mason',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Tiler',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Tree Surgeon',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Underfloor Heating',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Upholsterer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Window & Door Repairs,Other',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
  ServiceCatagory(
      'Window Installer',
      Icon(
        Icons.fastfood,
        color: darkBlue(),
      )),
];
