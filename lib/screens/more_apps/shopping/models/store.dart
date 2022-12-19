import 'dart:io';

import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

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

class Product {
  String? id;
  String? name;
  String? type;
  String? webUrl;
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
  bool? enableInSuperStore;
  Product(
      {this.id,
      this.name,
      this.type,
      this.webUrl,
      this.enableInSuperStore,
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
      "enable_in_superstore": this.enableInSuperStore,
    };
  }

  Map toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "description": this.description,
      "short_description": this.shortDescription,
      "price": this.price,
      "condition": this.condition,
      "category": this.category,
      "manufacturer": this.manufacturer,
      "is_available": this.isAvailable,
      "available_from": this.availableFrom.toString(),
      "enable_in_superstore": this.enableInSuperStore,
      "cover": this.cover,
    };
  }

  factory Product.fromJson(object) {
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

    return Product(
      id: object["id"].toString(),
      name: object["name"] ?? "",
      description: object["description"] ?? "",
      shortDescription: object["short_description"] ?? "",
      price: object["price"].toString(),
      enableInSuperStore: object["enable_in_superstore"] ?? false,
      localImages: object["localImages"] ?? [],
      serverImages: getProductImages(object["pictures"]),
      cover: object["cover"] ?? "",
      seller: object["seller"] ?? "",
      sellerAvatar: object["seller_avatar"] ?? "",
      sellerFullName: object["seller_fullname"] ?? "",
      qrCode: object["qr_code"] ?? "",
      condition: object["condition"] ?? "",
      category: object["category"] ?? "",
      manufacturer: object["manufacturer"] ?? "",
      isAvailable: object["is_available"] ?? false,
      availableFrom: getProductDateTime(object["available_from"]),
      currency: object["currency"] ?? "",
      pictureMap: object["pictureMap"] ?? [],
      rating: formatRating(double.parse(object['rating']?.toString() ?? "0")),
      canRate: object["can_rate"] ?? false,
    );
    // id = object["id"].toString();
    // this.name = object["name"] ?? "";
    // this.description = object["description"] ?? "";
    // this.shortDescription = object["short_description"] ?? "";
    // this.price = object["price"].toString();
    // this.enableInSuperStore = object["enable_in_superstore"]?? false;
    // this.localImages = object["localImages"] ?? [];
    // this.serverImages = getProductImages(object["pictures"]);
    // this.cover = object["cover"] ?? "";
    // this.seller = object["seller"] ?? "";
    // this.sellerAvatar = object["seller_avatar"] ?? "";
    // this.sellerFullName = object["seller_fullname"] ?? "";
    // this.qrCode = object["qr_code"] ?? "";
    // this.condition = object["condition"] ?? "";
    // this.category = object["category"] ?? "";
    // this.manufacturer = object["manufacturer"] ?? "";
    // this.isAvailable = object["is_available"] ?? false;
    // this.availableFrom = getProductDateTime(object["available_from"]);
    // this.currency = object["currency"] ?? "";
    // this.pictureMap = object["pictureMap"] ?? [];
    // rating = formatRating(object['rating'] ?? 0.0);
    // canRate = object["can_rate"] ?? false;
  }

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   map['id'] = id;
  //   map['name'] = name;
  //   map['type'] = type;
  //   map['cover'] = cover;
  //   map['price'] = price;
  //   map['rating'] = rating;
  //   map['seller'] = seller;
  //   map['qr_code'] = qrCode;
  //   map['web_url'] = webUrl;
  //   map['category'] = category;
  //   map['currency'] = currency;
  //   // if (pictures != null) {
  //   //   map['pictures'] = pictures?.map((v) => v.toJson()).toList();
  //   // }
  //   map['condition'] = condition;
  //   map['description'] = description;
  //   map['is_available'] = isAvailable;
  //   map['manufacturer'] = manufacturer;
  //   map['seller_avatar'] = sellerAvatar;
  //   map['available_from'] = availableFrom;
  //   map['seller_fullname'] = sellerFullName;
  //   map['short_description'] = shortDescription;
  //   map['enable_in_superstore'] = enableInSuperStore;
  //   return map;
  // }

  String? getMerchantUserName() {
    return this.seller;
  }

  String? getMerchantName() {
    return this.sellerFullName;
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

  String? getMerchantUserName() {
    return this.provider;
  }

  String? getMerchantName() {
    return this.providerFullName;
  }

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

  Map toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "short_description": this.shortDescription,
      "price": this.price,
      "category": this.category,
      "is_available": this.isAvailable,
      "available_from": this.availableFrom.toString(),
      "cover": this.cover,
      "provider": this.provider,
      "currency": this.currency,
      'rating': this.rating,
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
    this.rating = formatRating(double.parse(object['rating']?.toString() ?? "0"));
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

class ProductCategory {
  const ProductCategory(this.name);

  final String name;
}

class ProductCondition {
  const ProductCondition(this.name, this.description);

  final String name;
  final String description;
}

class ServiceCategory {
  const ServiceCategory(this.name);

  final String name;
}

class Order {
  String? id;
  String? status;
  String? customerName;
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
    this.customerName,
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
    this.customerName = object["customer"];
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
