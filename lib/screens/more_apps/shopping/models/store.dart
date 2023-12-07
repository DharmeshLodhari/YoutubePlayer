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
List<ProductCondition> deliverTimeCondition = <ProductCondition>[
  
     
  const ProductCondition(
    '10',
    "5-10 mins",
  ),
  const ProductCondition(
    '20',
    "10-20 mins",
  ),
  const ProductCondition(
    '30',
    "20-30 mins",
  ),
  const ProductCondition(
    '40',
    "30-40 mins",
  ),
  const ProductCondition(
    '50',
    "40-50 mins",
  ),
 
  const ProductCondition(
    '60',
    "50mins - 1hr",
  ),
  const ProductCondition(
    '70',
    "1hr - 1hr 10 mins",
  ),
  const ProductCondition(
    '80',
    "1hr 10 mins - 1hr 20 mins",
  ),
  const ProductCondition(
    '90',
    "1hr 20 mins- 1hr 30 mins",
  ),

  
  const ProductCondition(
    '100',
    "1hrs 30 mins- 1hr 40 mins",
  ),
  const ProductCondition(
    '110',
    "1hrs 40 mins - 1hr 50 mins",
  ),
  const ProductCondition(
    '120',
    "1hrs 50 mins - 2hr",
  ),
  const ProductCondition(
    '130',
    "2hrs - 2hr 10mins",
  ),
  const ProductCondition(
    '140',
    "2hrs 10 mins- 2hr 20 mins",
  ),
  const ProductCondition(
    '150',
    "2hrs 20 mins - 2hr 30 mins",
  ),
  const ProductCondition(
    '160',
    "2hrs 30 mins - 2hr 40 mins",
  ),
  const ProductCondition(
    '170',
    "2hrs 40 mins - 2hr 50mins",
  ),
  const ProductCondition(
    '180',
    "2hrs 50 mins - 3hr",
  ),
  const ProductCondition(
    '190',
    "3hrs - 3hr 10 mins",
  ),
  const ProductCondition(
    '200',
    "3hrs 10 mins - 3hr 20 mins",
  ),
  const ProductCondition(
    '210',
    "3hrs 20 mins - 3hr 30 mins",
  ),
  const ProductCondition(
    '220',
    "3hrs 30 mins - 3hr 40mins",
  ),
  const ProductCondition(
    '230',
    "3hrs 40 mins - 3hr 50 mins",
  ),
  const ProductCondition(
    '240',
    "3hrs 50 mins- 4hr",
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
  ProductCategory? category;
  ProductCategory? subCategory;
  ProductCategory? customCategory;
  List<Tags>? tags;
  num? preparationTime;
  String? manufacturer;
  bool? isAvailable;
  DateTime? availableFrom;
  String? currency;
  List<dynamic>? pictureMap;
  double? rating;
  bool? canRate;
  bool? enableInSuperStore;
  List<dynamic>? variant;
  List<dynamic>? addOns;
  double? weight;
  String? weightSiUnit;
  double? height;
  String? heightSiUnit;
  double? width;
  String? widthSiUnit;
  bool? trackInventory;
  int? quantity;
  double? pricePercentageChange;
  bool isSelected;
  num? discountValue;
  String? discountType;
  bool? discountIsActive;
  num? discountedPrice;
  int? oldPrice;
  bool? isShippable;

  Product({
    this.id,
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
    this.subCategory,
    this.customCategory,
    this.tags,
    this.preparationTime,
    this.manufacturer,
    this.isAvailable,
    this.availableFrom,
    this.currency,
    this.pictureMap,
    this.rating = 0.0,
    this.variant,
    this.addOns,
    this.weight = 0.0,
    this.weightSiUnit,
    this.height = 0.0,
    this.heightSiUnit,
    this.width = 0.0,
    this.widthSiUnit,
    this.trackInventory,
    this.quantity,
    this.pricePercentageChange,
    this.canRate = false,
    this.isSelected = false,
    this.discountValue,
    this.discountType,
    this.discountIsActive,
    this.discountedPrice,
    this.oldPrice,
    this.isShippable,
    });

  Map toMap() {
    var data =  {
      "name": name,
      "description": description,
      "short_description":
          getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "condition": condition,
      "category":  category!.id,
      "sub_category": subCategory!.id,
      "custom_category": customCategory!.id,
      "tags": tags!.map((e) => e.id!).toList(),
      "cover": cover,
      "manufacturer": manufacturer,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "enable_in_superstore": enableInSuperStore,
      "seller_fullname": sellerFullName,
      "seller_avatar": sellerAvatar,
      "variants": variant,
      "add_ons": addOns,
      "weight": weight,
      'weight_si_unit': weightSiUnit,
      'height': height,
      'height_si_unit': heightSiUnit,
      'width': width,
      'width_si_unit': widthSiUnit,
      'track_inventory': trackInventory,
      'quantity': quantity,
      'price_percentage_change': pricePercentageChange ?? 0.0,
      "discount_value": discountValue,
      "discount_type": discountType,
      "discount_is_active": discountIsActive,
      "discounted_price": discountedPrice,
      'old_price': oldPrice,
      'is_shippable': isShippable,
    };
    if(preparationTime != null && preparationTime! != 0){
      data["preparation_time"] = preparationTime;
    }
    return data;
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
      "category": category!,
      "sub_category": subCategory!,
      "custom_category": customCategory!,
      "tags": tags!.map((v) => v.toJson()).toList(),
      "preparation_time": preparationTime,
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
      "add_ons": addOns,
      "weight": weight,
      'weight_si_unit': weightSiUnit,
      'height': height,
      'height_si_unit': heightSiUnit,
      'width': width,
      'width_si_unit': widthSiUnit,
      'track_inventory': trackInventory,
      'quantity': quantity,
      'price_percentage_change': pricePercentageChange ?? 0.0,
      "discount_value": discountValue,
      "discount_type": discountType,
      "discount_is_active": discountIsActive,
      "discounted_price": discountedPrice,
      'old_price': oldPrice,
      'is_shippable': isShippable,
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

    dynamic getProductCategory(object) {
      try {
        return ProductCategory(object["name"],
            id: object["id"]);
      } catch (e) {
        return null;
      }
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
      category: object['category'] == null ?  null : getProductCategory(object["category"]) ,
      subCategory: object['sub_category'] == null
          ? null
          : getProductCategory(object["sub_category"]),
      customCategory: object['category'] == null
          ? null
          : getProductCategory(object["custom_category"]),
      tags: object['tags'] != null
          ? (object['tags'] as List)
              .map((i) => Tags.fromJson(i))
              .toList()
          : [],
      preparationTime: object["preparation_time"] ?? 0,
      manufacturer: object["manufacturer"] ?? "",
      isAvailable: object["is_available"] ?? true,
      availableFrom: getProductDateTime(object["available_from"]),
      currency: object["currency"] ?? "NGN",
      pictureMap: object["pictureMap"] ?? [],
      rating: formatRating(double.parse(object['rating']?.toString() ?? "0")),
      canRate: object["can_rate"] ?? false,
      variant: object["variants"],
      addOns: object["add_ons"],
      weight: object["weight"],
      weightSiUnit: object["weight_si_unit"],
      height: object["height"],
      heightSiUnit: object["height_si_unit"],
      widthSiUnit: object["width_si_unit"],
      trackInventory: object["track_inventory"],
      quantity: object["quantity"],
      pricePercentageChange: object["price_percentage_change"] ?? 0.0,
      discountValue: object['discount_value'],
      discountType: object['discount_type'],
      discountIsActive: object['discount_is_active'],
      discountedPrice: object['discounted_price'],
      oldPrice: object["old_price"],
      isShippable: object["is_shippable"],
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

  Product copyWith({required int quantity}) {
    return Product(
      id: this.id,
      name: this.name ?? "",
      description: this.description ?? "",
      shortDescription: this.shortDescription ?? "",
      price: this.price,
      enableInSuperStore: this.enableInSuperStore ?? false,
      localImages: this.localImages ?? [],
      serverImages: this.serverImages,
      cover:this.cover ?? "",
      seller: this.seller ?? "",
      sellerAvatar: this.sellerAvatar ?? "",
      sellerFullName: this.sellerFullName ?? "",
      qrCode: this.qrCode ?? "",
      condition: this.condition ?? "",
      category: this.category,
      subCategory: this.subCategory,
      customCategory: this.customCategory,
      tags: this.tags ?? [],
      preparationTime: this.preparationTime ?? 0,
      manufacturer: this.manufacturer ?? "",
      isAvailable: this.isAvailable ?? true,
      availableFrom: this.availableFrom,
      currency: this.currency ?? "NGN",
      pictureMap: this.pictureMap ?? [],
      rating: this.rating,
      canRate: this.canRate ?? false,
      variant: this.variant,
      addOns: this.addOns,
      weight: this.weight,
      weightSiUnit: this.widthSiUnit,
      height: this.height,
      heightSiUnit: this.heightSiUnit,
      widthSiUnit: this.widthSiUnit,
      trackInventory: this.trackInventory,
      quantity: quantity ?? this.quantity,
      pricePercentageChange: this.pricePercentageChange ?? 0.0,

      // discountedPrice: object["discounted_price"],
      // discountIsActive: object["discount_is_active"],
      // discountType: object["discount_type"],
      // discountValue: object["discount_value"],
      oldPrice: this.oldPrice,
      isShippable: this.isShippable,
    );

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

  Variant(
      {this.id,
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

class AddOnOption {
  int? id;
  String? picture;
  String? name;
  String? description;
  String? merchant;
  String? currency;
  String? price;
  bool? isAvailable;
  bool? isChecked;
  DateTime? createdAt;

  AddOnOption(
      {this.id,
        this.picture,
        this.name,
        this.description,
        this.merchant,
        this.currency,
        this.price,
        this.isAvailable,
        this.isChecked,
        this.createdAt});

  AddOnOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    picture = json['picture'];
    name = json['name'];
    description = json['description'];
    merchant = json['merchant'];
    currency = json['currency'];
    price = json['price'].toString();
    isAvailable = json['is_available'];
    isChecked = json['is_checked'] ?? false;
    createdAt = getProductDateTime(json['created_at']);
  }

  static DateTime getProductDateTime(var date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['picture'] = this.picture;
    data['name'] = this.name;
    data['description'] = this.description;
    data['merchant'] = this.merchant;
    data['currency'] = this.currency;
    data['price'] = this.price;
    data['is_available'] = this.isAvailable;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class AddOns {
  int? id;
  List<AddOnOption>? options;
  String? merchant;
  String? name;
  String? description;
  String? inputType;
  String? selectType;
  bool? isRequired;
  bool? isChecked;
  DateTime? createdAt;

  AddOns(
      {this.id,
        this.options,
        this.merchant,
        this.name,
        this.description,
        this.inputType,
        this.selectType,
        this.isRequired,
        this.isChecked,
        this.createdAt});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['options'] != null) {
      options = <AddOnOption>[];
      json['options'].forEach((v) {
        options!.add(new AddOnOption.fromJson(v));
      });
    }
    merchant = json['merchant'];
    name = json['name'];
    description = json['description'];
    inputType = json['input_type'];
    selectType = json['select_type'];
    isRequired = json['is_required'];
    isChecked = json['is_checked'] ?? false;
    createdAt = getProductDateTime(json['created_at']);
  }

  static DateTime getProductDateTime(var date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    data['merchant'] = this.merchant;
    data['name'] = this.name;
    data['description'] = this.description;
    data['input_type'] = this.inputType;
    data['select_type'] = this.selectType;
    data['is_required'] = this.isRequired;
    // if(data['is_checked'] == null){
    //   isRequired = data['is_checked'] ?? false;
    // }
    data['created_at'] = this.createdAt;
    return data;
  }

  static List<AddOns> convertToAddOnList(List<dynamic> dataList) {
    List<AddOns> addOnList = [];

    for (var data in dataList) {
      AddOns addOns = AddOns(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        merchant: data["merchant"] ?? "",
        inputType: data["input_type"],
        selectType: data["select_type"],
        isRequired: data["is_required"] ?? false,
        options: getAddOnOption(data["options"]),
      );
      addOnList.add(addOns);
    }

    return addOnList;
  }

  static List<AddOnOption> getAddOnOption(List? data) {
    List<AddOnOption> addOnOption = [];

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
          addOnOption.add(AddOnOption.fromJson(data[i]));
      }
    }
    return addOnOption;
  }


}

class Tags {
  num? id;
  String? name;

  Tags({this.id, this.name});

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
class SubCategory {
  num? id;
  String? name;
 

  SubCategory(
      {this.id,
      this.name,
     });

  Map toMap() {
    return {
      "name": name,
    };
  }
  Map toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
  SubCategory.fromJson(object) {
    id = object["id"];
    name = object["name"] ?? "";
  }

}
class CustomCategory {
  num? id;
  String? name;
 

  CustomCategory(
      {this.id,
      this.name,
     });

  Map toMap() {
    return {
      "name": name,
    };
  }
  Map toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
  CustomCategory.fromJson(object) {
    id = object["id"];
    name = object["name"] ?? "";
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
    rating = formatRating(double.parse(object['rating']?.toString() ?? "0"));
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
  const ProductCategory(this.name, {this.id = ""});

  final String name;
  final dynamic id;
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

  Order(
      {this.id,
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
      this.statusTimeStamp});

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
