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
  List<dynamic>? variant;
  double? weight;
  String? weightSiUnit;
  double? height;
  String? heightSiUnit;
  double? width;
  String? widthSiUnit;
  bool? trackInventory;
  int? quantity;

  Product({this.id,
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
    this.variant,
    this.weight = 0.0,
    this.weightSiUnit,
    this.height = 0.0,
    this.heightSiUnit,
    this.width = 0.0,
    this.widthSiUnit,
    this.trackInventory,
    this.quantity,
    this.canRate = false});

  Map toMap() {
    return {
      "name": name,
      "description": description,
      "short_description":
      getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "condition": condition,
      "category": category,
      "manufacturer": manufacturer,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "enable_in_superstore": enableInSuperStore,
      "seller_fullname": sellerFullName,
      "seller_avatar": sellerAvatar,
      "variants": variant,
      "weight": weight,
      'weight_si_unit': weightSiUnit,
      'height': height,
      'height_si_unit': heightSiUnit,
      'width': width,
      'width_si_unit': widthSiUnit,
      'track_inventory': trackInventory,
      'quantity': quantity,
    };
  }

  Map toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "short_description":
      getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "condition": condition,
      "category": category,
      "manufacturer": manufacturer,
      "is_available": isAvailable,
      "available_from": availableFrom.toString(),
      "enable_in_superstore": enableInSuperStore,
      "cover": cover,
      "seller": seller,
      "seller_fullname": sellerFullName,
      "seller_avatar": sellerAvatar,
      "currency": currency,
      "variants": variant,
      "weight": weight,
      'weight_si_unit': weightSiUnit,
      'height': height,
      'height_si_unit': heightSiUnit,
      'width': width,
      'width_si_unit': widthSiUnit,
      'track_inventory': trackInventory,
      'quantity': quantity,
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
      isAvailable: object["is_available"] ?? true,
      availableFrom: getProductDateTime(object["available_from"]),
      currency: object["currency"] ?? "NGN",
      pictureMap: object["pictureMap"] ?? [],
      rating: formatRating(double.parse(object['rating']?.toString() ?? "0")),
      canRate: object["can_rate"] ?? false,
      variant: object["variants"],
      weight: object["weight"],
      weightSiUnit: object["weight_si_unit"],
      height: object["height"],
      heightSiUnit: object["height_si_unit"],
      widthSiUnit: object["width_si_unit"],
      trackInventory: object["track_inventory"],
      quantity: object["quantity"],
    );
  }

  String getShortDescription(String short, String long) {
    if (short.length > 100) return long;

    return short;
  }

  String? getMerchantUserName() {
    return seller;
  }

  String? getMerchantName() {
    return sellerFullName;
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
    debugPrint("${serverImages}");
    for (var data in pictureMap!) {
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

class Variant {
  String? id;
  String? title;
  String? size;
  String? colour;
  String? type;
  String? price;
  String? value;
  List<File>? localImages;
  List<String?>? serverImages;
  String? quantity;
  bool? isAvailable;
  DateTime? availableFrom;
  String? currency;
  bool? trackInventory;

  Variant({this.id,
    this.title,
    this.size,
    this.colour,
    this.trackInventory,
    this.type,
    this.price,
    this.value,
    this.quantity,
    this.localImages,
    this.serverImages,
    this.isAvailable,
    this.availableFrom,
    this.currency});

  Map toMap() {
    return {
      "id": id,
      "title": title,
      "size": size,
      "colour": colour,
      "price": price,
      "type": type,
      "value": value,
      "quantity": quantity,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "track_inventory": trackInventory,
      "currency": currency
    };
  }

  Map toJson() {
    return {
      "id": id,
      "title": title,
      "size": size,
      "colour": colour,
      "price": price,
      "type": type,
      "value": value,
      "quantity": quantity,
      "is_available": isAvailable,
      "available_from": availableFrom.toString(),
      "track_inventory": trackInventory,
      "currency": currency,
    };
  }

  static List<Variant> convertToVariantList(List<dynamic> dataList) {
    List<Variant> variantList = [];

    for (var data in dataList) {
      Variant variant = Variant(
        id: data['id'].toString(),
        title: data['title'],
        quantity: data['quantity'].toString(),
        colour: data["colour"] ?? "",
        value: data["value"] ?? "",
        type: data["type"] ?? "",
        price: data["price"].toString(),
        trackInventory: data["track_inventory"] ?? false,
        localImages: data["localImages"] ?? [],
        serverImages: getProductImages(data["pictures"]),
        isAvailable: data["is_available"] ?? true,
        availableFrom: getProductDateTime(data["available_from"]),
        currency: data["currency"] ?? "NGN",
      );
      variantList.add(variant);
    }

    return variantList;
  }

  factory Variant.fromJson(object) {
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

    return Variant(
      id: object["id"].toString(),
      title: object["title"].toString(),
      colour: object["colour"] ?? "",
      quantity: object["quantity"] ?? "",
      value: object["value"] ?? "",
      price: object["price"].toString(),
      trackInventory: object["track_inventory"] ?? false,
      localImages: object["localImages"] ?? [],
      serverImages: getProductImages(object["pictures"]),
      isAvailable: object["is_available"] ?? true,
      availableFrom: getProductDateTime(object["available_from"]),
      currency: object["currency"] ?? "NGN",

    );
  }


  static List<String> getProductImages(List? data) {
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

  static DateTime getProductDateTime(var date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    debugPrint("${serverImages}");
    // for (var data in this.pictureMap!) {
    //   if (data['file'] == imageUrl) {
    //     return data['id'].toString();
    //   }
    // }
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
    return provider;
  }

  String? getMerchantName() {
    return providerFullName;
  }

  String getShortDescription(String short, String long) {
    if (short.length > 100) return long;

    return short;
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    for (var data in pictureMap!) {
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
      "name": name,
      "description": description,
      "short_description":
      getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "category": category,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "provider_avatar": providerAvatar,
      "provider_fullname": providerFullName
    };
  }

  Map toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "short_description":
      getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "category": category,
      "is_available": isAvailable,
      "available_from": availableFrom.toString(),
      "cover": cover,
      "provider": provider,
      "currency": currency,
      'rating': rating,
      "provider_avatar": providerAvatar,
      "provider_fullname": providerFullName
    };
  }

  Service.fromJson(object) {
    id = object["id"];
    name = object["name"] ?? "";
    description = object["description"] ?? "";
    shortDescription = object["short_description"] ?? "";
    price = object["price"].toString();
    localImages = object["localImages"] ?? [];
    serverImages = getServiceImages(object["pictures"]);
    cover = object["cover"] ?? "";
    provider = object["provider"] ?? "";
    providerAvatar = object["provider_avatar"] ?? "";
    providerFullName = object["provider_fullname"] ?? "";
    qrCode = object["qr_code"] ?? "";
    category = object["category"] ?? "";
    isAvailable = object["is_available"] ?? true;
    availableFrom = getServiceDateTime(object["available_from"]);
    currency = object["currency"] ?? "";
    pictureMap = object["pictureMap"] ?? [];
    rating =
        formatRating(double.parse(object['rating']?.toString() ?? "0"));
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
  List<dynamic>? statusTimeStamp;

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
    this.statusTimeStamp
  });

  Order.fromJson(object) {
    id = object["id"].toString();
    status = object["status"];
    customerName = object["customer"];
    merchant = object["merchant"];
    customerAvatar = object["customer_avatar"];
    customerType = object["customer_type"] ?? "User";
    merchantType = object["merchant_type"] ?? "Business";
    merchantAvatar = object["merchant_avatar"];
    isPaid = object["is_paid"];
    transactionId = object["transaction_id"];
    note = object["note"];
    createdAt = object["created_at"];
    totalPrice = object["total_price"];
    currency = object["currency"] ?? "NGN";
    statusTimeStamp = object["status_time_stamps"];
  }
}
