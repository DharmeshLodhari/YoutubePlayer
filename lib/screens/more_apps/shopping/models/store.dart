import 'dart:io';

import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class Product {
  String? id;
  String? name;
  String? description;
  String? shortDescription;
  String? price;
  List<File>? localImages;
  List<String?>? serverImages;
  String? cover;
  String? seller;
  String? sellerAvatar;
  String? sellerFullName;
  String? condition;
  String? qrCode;
  String? category;
  String? manufacturer;
  bool? isAvailable;
  DateTime? availableFrom;
  String? currency;
  List<dynamic>? pictureMap;
  double? rating;
  bool? canRate;
  Product(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.price,
      this.localImages,
      this.serverImages,
      this.seller,
      this.cover = "",
      this.sellerAvatar,
      this.sellerFullName,
      this.qrCode,
      this.condition,
      this.category,
      this.manufacturer,
      this.isAvailable,
      this.availableFrom,
      this.currency,
      this.pictureMap,
      this.rating = 0.0,
      this.canRate = false});

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

  Product.fromJson(object) {
    id = object["id"].toString();
    this.name = object["name"] ?? "";
    this.description = object["description"] ?? "";
    this.shortDescription = object["short_description"] ?? "";
    this.price = object["price"].toString();
    this.localImages = object["localImages"] ?? [];
    this.serverImages = getProductImages(object["pictures"]);
    this.cover = object["cover"] ?? "";
    this.seller = object["seller"] ?? "";
    this.sellerAvatar = object["seller_avatar"] ?? "";
    this.sellerFullName = object["seller_fullname"] ?? "";
    this.qrCode = object["qr_code"] ?? "";
    this.condition = object["condition"] ?? "";
    this.category = object["category"] ?? "";
    this.manufacturer = object["manufacturer"] ?? "";
    this.isAvailable = object["is_available"] ?? false;
    this.availableFrom = getProductDateTime(object["available_from"]);
    this.currency = object["currency"] ?? "";
    this.pictureMap = object["pictureMap"] ?? [];
    rating = formatRating(object['rating'] ?? 0.0);
    canRate = object["can_rate"] ?? false;
  }

  List<String> getProductImages(List? data) {
    List<String> images = [];

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        if (data[i].containsKey("file")) {
          images.add(data[i]["file"].toString());
        }
      }
    }
    return images;
  }

  DateTime getProductDateTime(var date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    debugPrint("${this.serverImages}");
    for (var data in this.pictureMap!) {
      if (data['file'] == imageUrl) {
        return data['id'].toString();
      }
    }
    return "";
  }

  List<String?> imageDataToList(List<dynamic> pictures) {
    List<String?> imageLinks = [];
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
  String? id;
  String? name;
  String? description;
  String? shortDescription;
  String? price;
  List<File>? localImages;
  List<String?>? serverImages;
  String? cover;
  String? provider;
  String? providerAvatar;
  String? providerFullName;
  String? qrCode;
  String? category;
  bool? isAvailable;
  DateTime? availableFrom;
  String? currency;
  List<dynamic>? pictureMap;
  double? rating;
  bool? canRate = false;

  Service(
      {this.id,
      this.name,
      this.description,
      this.shortDescription,
      this.price,
      this.localImages,
      this.serverImages,
      this.cover = "",
      this.provider,
      this.providerAvatar,
      this.providerFullName,
      this.qrCode,
      this.category,
      this.isAvailable,
      this.availableFrom,
      this.currency,
      this.pictureMap,
      this.rating = 0.0,
      this.canRate});

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    for (var data in this.pictureMap!) {
      if (data['file'] == imageUrl) {
        return data['id'].toString();
      }
    }
    return "";
  }

  List<String?> imageDataToList(List<dynamic> pictures) {
    List<String?> imageLinks = [];
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

  Service.fromJson(object) {
    this.id = object["id"];
    this.name = object["name"] ?? "";
    this.description = object["description"] ?? "";
    this.shortDescription = object["short_description"] ?? "";
    this.price = object["price"].toString();
    this.localImages = object["localImages"] ?? [];
    this.serverImages = getServiceImages(object["pictures"]);
    this.cover = object["cover"] ?? "";
    this.provider = object["provider"] ?? "";
    this.providerAvatar = object["provider_avatar"] ?? "";
    this.providerFullName = object["provider_fullname"] ?? "";
    this.qrCode = object["qr_code"] ?? "";
    this.category = object["category"] ?? "";
    this.isAvailable = object["is_available"] ?? false;
    this.availableFrom = getServiceDateTime(object["available_from"]);
    this.currency = object["currency"] ?? "";
    this.pictureMap = object["pictureMap"] ?? [];
    rating = formatRating(object['rating'] ?? 0.0);
    canRate = object["can_rate"] ?? false;
  }

  List<String> getServiceImages(List? data) {
    List<String> images = [];

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        if (data[i].containsKey("file")) {
          images.add(data[i]["file"].toString());
        }
      }
    }
    return images;
  }

  DateTime getServiceDateTime(var date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }
}

class PaymentCategory {
  const PaymentCategory(this.name);

  final String name;
}

List<PaymentCategory> paymentCategories = <PaymentCategory>[
  PaymentCategory(
    'General',
  ),
  PaymentCategory(
    'Groceries',
  ),
  PaymentCategory(
    'Entertainment',
  ),
  PaymentCategory(
    'Eating out',
  ),
  PaymentCategory(
    'Bills',
  ),
  PaymentCategory(
    'Shopping',
  ),
];

class ProductCategory {
  const ProductCategory(this.name);

  final String name;
}

List<String> productCategoryList = [
  "All categories",
  "Auto & Large Appliances",
  "Automotive",
  "Baby & Kids",
  "Beauty & Spas",
  "Electronics",
  "Entertainment",
  "Food & Drink",
  "Grocery & Household",
  "Health & Beauty",
  "Health & Fitness",
  "Home & Garden",
  "Jewellery & Watches",
  "Men's Fashion",
  "Personalised",
  "Pet Supplies",
  "Sports & Outdoors",
  "Toys",
  "Women’s Fashion",
];

List<String> serviceCategoryList = [
  "All categories",
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

class ProductCondition {
  const ProductCondition(this.name, this.description);

  final String name;
  final String description;
}

List<ProductCondition> conditions = <ProductCondition>[
  const ProductCondition(
    'Fair',
    'Original packaging or with tag',
  ),
  const ProductCondition(
    'Good',
    'Original packaging or with tag',
  ),
  const ProductCondition(
    'Like New',
    'Original packaging or with tag',
  ),
  const ProductCondition(
    'New',
    'Original packaging or with tag',
  ),
  const ProductCondition(
    'Poor',
    'Original packaging or with tag',
  ),
];

class ServiceCategory {
  const ServiceCategory(this.name);

  final String name;
}

class Order {
  String? id;
  String? status;
  String? customer;
  String? merchant;
  String? customerAvatar;
  String? customerType;
  String? merchantAvatar;
  String? merchantType;
  bool? isPaid;
  String? transactionId;
  String? note;
  String? createdAt;
  int? totalPrice;
  String? currency;

  Order({
    this.id,
    this.status,
    this.customer,
    this.merchant,
    this.customerAvatar,
    this.customerType = "User",
    this.merchantAvatar,
    this.merchantType = "Business",
    this.isPaid,
    this.transactionId,
    this.note,
    this.createdAt,
    this.totalPrice,
    this.currency,
  });

  Order.fromJson(object) {
    this.id = object["id"].toString();
    this.status = object["status"];
    this.customer = object["customer"];
    this.merchant = object["merchant"];
    this.customerAvatar = object["customer_avatar"];
    this.customerType = object["customer_type"] ?? "User";
    this.merchantType = object["merchant_type"] ?? "Business";
    this.merchantAvatar = object["merchant_avatar"];
    this.isPaid = object["is_paid"];
    this.transactionId = object["transaction_id"];
    this.note = object["note"];
    this.createdAt = object["created_at"];
    this.totalPrice = object["total_price"];
    this.currency = object["currency"] ?? "NGN";
  }
}
