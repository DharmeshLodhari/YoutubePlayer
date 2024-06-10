import 'dart:io';

import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/Picture.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
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
  "Barber",
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
  "Software Development",
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
  const PaymentCategory(
    'General',
  ),
  const PaymentCategory(
    'Groceries',
  ),
  const PaymentCategory(
    'Entertainment',
  ),
  const PaymentCategory(
    'Eating out',
  ),
  const PaymentCategory(
    'Bills',
  ),
  const PaymentCategory(
    'Shopping',
  ),
];

class PurchasableItem {
  String? id;

  bool get isProduct => this is Product;

  bool get isService => this is Service;

  PurchasableItem({this.id});
}

class Product extends PurchasableItem {
  String? name;
  String? type;
  String? webUrl;
  String? description;
  String? shortDescription;
  int? price;
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
  int? preparationTime;
  String? manufacturer;
  bool? isAvailable;
  DateTime? availableFrom;
  String? currency;
  List<Picture>? pictureMap;
  double? rating;
  bool? canRate;
  bool? enableInSuperStore;

  // List<dynamic>? variant;
  List<Variant>? variantModels;

  // List<dynamic>? addOns;
  List<AddOns>? addOnsModels;
  double? weight;
  String? weightSiUnit;
  double? height;
  String? heightSiUnit;
  double? width;
  String? widthSiUnit;
  bool? trackInventory;
  // DiscountModel? discount;
  String? discountId;
  int? quantity;
  double? pricePercentageChange;
  int? discountValue;
  String? discountType;
  bool? discountIsActive;
  int? discountedPrice;
  int? oldPrice;
  bool? isShippable;
  String? addressId;
  List<String>? searchKeywords;
  bool isChecked = false;

  // DateTime? createdAt;
  // bool? enableInSuperstore;
  // String? createdBy;
  // String? createdByFullname;
  // String? createdByAvatar;
  // String? updatedBy;
  // String? updatedByFullname;
  // String? updatedByAvatar;
  List<AddedBy>? itemAddedBy;
  // UserFollowers? itemUpdatedBy;
  // int? qty;

  List<UserFollowers> convertToUserFollowersList() {
    List<UserFollowers> userList = [];

    userList =
        (itemAddedBy?.map((e) => e.user?.toUserFollowerModel()).toList() ?? [])
            .cast<UserFollowers>();

    return userList;
  }

  Product({
    super.id,
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
    // this.variant,
    this.variantModels,
    // this.addOns,
    this.addOnsModels,
    this.weight = 0.0,
    this.weightSiUnit,
    this.height = 0.0,
    this.heightSiUnit,
    this.width = 0.0,
    this.widthSiUnit,
    this.trackInventory,
    // this.discount,
    this.quantity,
    this.pricePercentageChange,
    this.canRate = false,
    this.discountValue,
    this.discountType,
    this.discountIsActive,
    this.discountedPrice,
    this.oldPrice,
    this.isShippable,
    this.addressId,
    this.itemAddedBy,
    this.searchKeywords,
    this.isChecked = false,
    // this.itemUpdatedBy,
    // this.qty,
  });

  Map toMap() {
    final data = {
      "name": name,
      "description": description,
      "short_description":
          getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "condition": condition,
      "category": category?.id,
      "sub_category": subCategory?.id,
      "custom_category": customCategory?.id,
      "tags": tags!.map((e) => e.id!).toList(),
      "cover": cover,
      "manufacturer": manufacturer,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "enable_in_superstore": enableInSuperStore,
      "seller_fullname": sellerFullName,
      "seller_avatar": sellerAvatar,
      // "variants": variant,
      "variants": variantModels,
      // "add_ons": addOns,
      "add_ons": addOnsModels,
      "weight": weight,
      'weight_si_unit': weightSiUnit,
      'height': height,
      'height_si_unit': heightSiUnit,
      'width': width,
      'width_si_unit': widthSiUnit,
      'track_inventory': trackInventory,
      'quantity': quantity,
      'price_percentage_change': pricePercentageChange ?? 0.0,
      "discount": discountId,
      'old_price': oldPrice,
      'is_shippable': isShippable,
      'address_id': addressId,
      'added_by': itemAddedBy,
      'search_keywords': searchKeywords,
      'is_checked': isChecked,
      // 'item_updated_by': itemUpdatedBy,
      // 'qty': qty,
    };
    if (preparationTime != null && preparationTime! != 0) {
      data["preparation_time"] = preparationTime;
    }
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "short_description":
          getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "condition": condition,
      "category": category,
      "sub_category": subCategory,
      "custom_category": customCategory,
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
      // "variants": variant,
      "variants": variantModels,
      // "add_ons": addOns,
      "add_ons": addOnsModels,
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
      'address_id': addressId,
      "added_by": itemAddedBy?.map((v) => v.toJson()).toList(),
      "search_keywords": searchKeywords == null
          ? []
          : List<String>.from(searchKeywords!.map((x) => x)),
      'is_checked': isChecked,
      // "item_updated_by": itemUpdatedBy?.toJson(),
      // 'qty': qty,
    };
  }

  // String getName() {
  //   if (name == null || name == "") {
  //     return "";
  //   }
  //   // The encoded string
  //   String encodedString = name!;
  //
  //   // Decoding the string using utf8 decoding
  //   String decodedString = utf8.decode(encodedString.runes.toList());
  //
  //   // Printing the decoded string
  //   return decodedString;
  // }

  int? getBuyNowProductPrice() {
    int? totalPrice = 0;
    totalPrice = getProductRealPrice();
    return totalPrice;
  }

  bool checkProductDiscount() {
    if (discountIsActive == true && discountedPrice != null) {
      return true;
    }
    return false;
  }

  bool checkVariantDiscount(Variant? selectedVariant) {
    if (selectedVariant?.discountIsActive == true &&
        selectedVariant?.discountedPrice != null) {
      return true;
    }
    return false;
  }

  int getProductRealPrice() {
    if (discountedPrice != null || discountedPrice != 0) {
      if (checkProductDiscount()) {
        return discountedPrice ?? 0;
      }
    }
    return price ?? 0;
  }

  int? getOriginalPrice(Variant? selectedVariant) {
    if (selectedVariant != null) {
      return int.parse(selectedVariant.price ?? "0");
    } else {
      return price;
    }
  }

  int? getDiscountedPrice(Variant? selectedVariant) {
    if (selectedVariant != null) {
      if (selectedVariant.price != null) {
        if (checkVariantDiscount(selectedVariant)) {
          return selectedVariant.discountedPrice;
        } else {
          if (checkProductDiscount()) {
            return getCalDiscountedPrice(discountType, discountValue,
                int.parse(selectedVariant.price ?? "0"));
          } else {
            return int.parse(selectedVariant.price ?? "0");
          }
        }
      } else {
        if (checkVariantDiscount(selectedVariant)) {
          return getCalDiscountedPrice(selectedVariant.discountType,
              selectedVariant.discountValue, price ?? 0);
        } else {
          return getProductRealPrice();
        }
      }
    } else {
      return getProductRealPrice();
    }
  }

  int getCalDiscountedPrice(
      String? discountType, int? discountValue, int price) {
    if (discountType == "percentage") {
      return (price * (discountValue ?? 0)) ~/ 100;
    } else {
      return price - (discountValue ?? 0);
    }
  }

  factory Product.fromJson(object) {
    List<String> getProductImages(List? data) {
      final List<String> images = [];

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
        final DateTime dateTime = DateTime.parse(date);
        return dateTime;
      }
      return DateTime.now();
    }

    dynamic getProductCategory(object) {
      try {
        return ProductCategory(object["name"], id: object["id"]);
      } catch (e) {
        return null;
      }
    }

    return Product(
      id: object["id"].toString(),
      name: object["name"] ?? "",
      description: object["description"] ?? "",
      shortDescription: object["short_description"] ?? "",
      price: object["price"],
      enableInSuperStore: object["enable_in_superstore"] ?? false,
      localImages: object["localImages"] ?? [],
      serverImages: getProductImages(object["pictures"]),
      cover: object["cover"] ?? "",
      seller: object["seller"] ?? "",
      sellerAvatar: object["seller_avatar"] ?? "",
      sellerFullName: object["seller_fullname"] ?? "",
      qrCode: object["qr_code"] ?? "",
      condition: object["condition"] ?? "",
      category: object['category'] == null
          ? null
          : getProductCategory(object["category"]),
      subCategory: object['sub_category'] == null
          ? null
          : getProductCategory(object["sub_category"]),
      customCategory: object['category'] == null
          ? null
          : getProductCategory(object["custom_category"]),
      tags: object['tags'] != null
          ? (object['tags'] as List).map((i) => Tags.fromJson(i)).toList()
          : [],
      preparationTime: object["preparation_time"] ?? 0,
      manufacturer: object["manufacturer"] ?? "",
      isAvailable: object["is_available"] ?? true,
      availableFrom: getProductDateTime(object["available_from"]),
      currency: object["currency"] ?? "NGN",
      pictureMap: object["pictureMap"] ?? [],
      rating: formatRating(double.parse(object['rating']?.toString() ?? "0")),
      canRate: object["can_rate"] ?? false,
      // variant: object["variants"],
      variantModels: object["variants"] == null
          ? []
          : List<Variant>.from(
              object["variants"]!.map((x) => Variant.fromJson(x))),
      // addOns: object["add_ons"],
      addOnsModels: object["add_ons"] == null
          ? []
          : List<AddOns>.from(
              object["add_ons"]!.map((x) => AddOns.fromJson(x))),
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
      itemAddedBy: object["added_by"] == null
          ? []
          : List<AddedBy>.from(
              object["added_by"].map((x) => AddedBy.fromJson(x))),
      searchKeywords: object["search_keywords"] == null
          ? <String>[]
          : List<String>.from(object["search_keywords"].map((x) => x)),
      // itemUpdatedBy: object["item_updated_by"] == null
      //     ? null
      //     : UserFollowers.fromJson(object["item_updated_by"]),
      // qty: object["qty"],
    );
  }

  bool isProductAvailableNow() {
    if ((isAvailable ?? false) &&
        quantity! >= 1 &&
        ((availableFrom?.isBefore(DateTime.now()) ?? false) ||
            (availableFrom?.isAtSameMomentAs(DateTime.now()) ?? false))) {
      return true;
    }
    return false;
  }

  String getShortDescription(String short, String long) {
    if (short.length > 100) return long;

    return short;
  }

  List<String> getProductImages(List? data) {
    final List<String> images = [];

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
      final DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    debugPrint("${serverImages}");
    for (var data in pictureMap!) {
      if (data.path == imageUrl) {
        return data.id.toString();
      }
    }
    return "";
  }

  List<String?> imageDataToList(List<dynamic> pictures) {
    final List<String?> imageLinks = [];
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

  Product copyWith({int? quantity, bool withSelectedAddOn = false}) {
    final Product product = Product(
      id: id,
      name: name ?? "",
      description: description ?? "",
      shortDescription: shortDescription ?? "",
      price: price,
      enableInSuperStore: enableInSuperStore ?? false,
      localImages: localImages ?? [],
      serverImages: serverImages,
      cover: cover ?? "",
      seller: seller ?? "",
      sellerAvatar: sellerAvatar ?? "",
      sellerFullName: sellerFullName ?? "",
      qrCode: qrCode ?? "",
      condition: condition ?? "",
      category: category,
      subCategory: subCategory,
      customCategory: customCategory,
      tags: tags ?? [],
      preparationTime: preparationTime ?? 0,
      manufacturer: manufacturer ?? "",
      isAvailable: isAvailable ?? true,
      availableFrom: availableFrom,
      currency: currency ?? "NGN",
      pictureMap: pictureMap ?? [],
      rating: rating,
      canRate: canRate ?? false,
      // variant: this.variant,
      variantModels: variantModels?.map((e) => e.copyWith()).toList(),
      // addOns: this.addOns,
      addOnsModels: addOnsModels?.map((e) => e.copyWith()).toList(),
      weight: weight,
      weightSiUnit: widthSiUnit,
      height: height,
      heightSiUnit: heightSiUnit,
      widthSiUnit: widthSiUnit,
      trackInventory: trackInventory,
      quantity: quantity ?? this.quantity,
      pricePercentageChange: pricePercentageChange ?? 0.0,
      // isSelected: this.isSelected ?? 0.0,
      discountedPrice: discountedPrice,
      discountIsActive: discountIsActive,
      discountType: discountType,
      discountValue: discountValue,
      oldPrice: oldPrice,
      isShippable: isShippable,
      addressId: addressId,
      itemAddedBy: itemAddedBy,
      searchKeywords: searchKeywords,
      // itemUpdatedBy: this.itemUpdatedBy,
      // qty: qty ?? this.qty,
    );
    if (withSelectedAddOn) {
      product.addOnsModels =
          getSelectedAddsOns(listOfAddonModel: product.addOnsModels);

      for (AddOns addOns in product.addOnsModels ?? []) {
        addOns.options = addOns.getSelectedAddsOnsOption(addOns);
      }
    }
    return product;
  }

  Map<String, List<Variant>> getVariants(
      {required VariantTypes variantType, String? selectedColor}) {
    switch (variantType) {
      case VariantTypes.Color:
        return groupVariantsByColor();

      case VariantTypes.Size:
        return groupVariantsBySize();

      case VariantTypes.ColorAndSize:
        return groupVariantsBySizeForSelectedColor(selectedColor);
    }
  }

  // Group variants by color
  Map<String, List<Variant>> groupVariantsByColor() {
    final Map<String, List<Variant>> groupedVariants = {};

    for (var variant in variantModels ?? []) {
      if (variant.colour != null && variant.colour!.isNotEmpty) {
        if (!groupedVariants.containsKey(variant.colour!)) {
          groupedVariants[variant.colour!] = [];
        }
        groupedVariants[variant.colour]!.add(variant);
      }
    }

    return groupedVariants;
  }

  // Group variants by size
  Map<String, List<Variant>> groupVariantsBySize() {
    final Map<String, List<Variant>> groupedVariants = {};

    for (var variant in variantModels ?? []) {
      if (variant.value != null && variant.value!.isNotEmpty) {
        if (!groupedVariants.containsKey(variant.value)) {
          groupedVariants[variant.value!] = [];
        }
        groupedVariants[variant.value]!.add(variant);
      }
    }

    return groupedVariants;
  }

  // Define a function to group variants by size for the selected color/image
  Map<String, List<Variant>> groupVariantsBySizeForSelectedColor(
      String? selectedColor) {
    final Map<String, List<Variant>> sizeGroups = {};

    // Filter variants that match the selected color
    final List<Variant> selectedColorVariants = (variantModels ?? [])
        .where((variant) => variant.colour == selectedColor)
        .toList();

    // Group the selected color variants by size, only if variant.value is not empty or null
    for (var variant in selectedColorVariants) {
      if (variant.value != null && variant.value!.isNotEmpty) {
        if (!sizeGroups.containsKey(variant.value)) {
          sizeGroups[variant.value!] = [];
        }
        sizeGroups[variant.value]!.add(variant);
      }
    }

    return sizeGroups;
  }

  List<AddOns> getSelectedAddsOns(
      {bool isRequired = false, List<AddOns>? listOfAddonModel}) {
    final List<AddOns> selectedAddOnsList = [];

    for (AddOns addOn in listOfAddonModel ?? addOnsModels ?? []) {
      bool isSelected = false;

      isSelected = addOn
          .getSelectedAddsOnsOption(addOn)
          .where((addOns) => addOns.isAddOnsSelected(addOn) == true)
          .toList()
          .isNotEmpty;

      if (isSelected) selectedAddOnsList.add(addOn);
    }
    return selectedAddOnsList;
  }

  bool isAllRequiredProductSelected() {
    bool isAllSelected = false;
    for (AddOns addOn in addOnsModels ?? []) {
      bool isSelected = false;
      if (addOn.isRequired == true) {
        isSelected = addOn
            .getSelectedAddsOnsOption(addOn)
            .where((addOns) => addOns.isAddOnsSelected(addOn) == true)
            .toList()
            .isNotEmpty;
      } else {
        isSelected = true;
      }

      if (!isSelected) {
        isAllSelected = false;
        break;
      }
      isAllSelected = true;
    }
    return isAllSelected;
  }

  void getItemAddedByDetails(SharedCartMemberModel? currentUser,
      {required BasketListModifierAction actionType}) {
    bool isAlreadyPresent = false;

    for (AddedBy addedBy in itemAddedBy ?? []) {
      if (addedBy.user?.userName == currentUser?.userName) {
        if (actionType == BasketListModifierAction.increaseQty) {
          addedBy.quantity = (addedBy.quantity ?? 0) + 1;
          isAlreadyPresent = true;
          break;
        } else if (actionType == BasketListModifierAction.decreaseQty) {
          if ((addedBy.quantity ?? 0) > 0) {
            addedBy.quantity = (addedBy.quantity ?? 0) - 1;
            if (addedBy.quantity == 0) {
              itemAddedBy?.removeWhere(
                  (element) => element.user?.userName == currentUser?.userName);
            }
          }

          isAlreadyPresent = true;
          break;
        }
      }
    }

    if (isAlreadyPresent == false) {
      if (actionType == BasketListModifierAction.increaseQty) {
        itemAddedBy ??= [];
        itemAddedBy?.add(AddedBy(user: currentUser, quantity: 1));
      } else if (actionType == BasketListModifierAction.decreaseQty) {
        if ((itemAddedBy?.first.quantity ?? 0) > 0) {
          itemAddedBy?.first.quantity = (itemAddedBy?.first.quantity ?? 0) - 1;
          if (itemAddedBy?.first.quantity == 0) {
            itemAddedBy?.removeWhere(
                (element) => element.user?.userName == currentUser?.userName);
          }
        }
      }
    }
  }
}

enum VariantTypes { Color, Size, ColorAndSize }

extension StringOperations on VariantTypes {
  // 'Size', 'Color', 'Color n Size'
  VariantTypes fromString(String type) {
    if (type == 'Size') {
      return VariantTypes.Size;
    } else if (type == "Color") {
      return VariantTypes.Color;
    } else if (type == "Color n Size") {
      return VariantTypes.ColorAndSize;
    }
    return VariantTypes.Size;
  }

  String toName() {
    switch (this) {
      case VariantTypes.Color:
        return "Color";

      case VariantTypes.Size:
        return "Size";

      case VariantTypes.ColorAndSize:
        return "Color n Size";

      default:
        return "Size";
    }
  }
}

class Variant {
  String? id;
  String? title;
  String? colour;
  VariantTypes? type;
  String? price;
  String? value;
  // DiscountModel? discount;
  String? discountId;
  List<File>? localImages;
  List<String?>? serverImages;
  int? quantity;
  bool? isAvailable;
  String? availableFrom;
  String? currency;
  bool? trackInventory;
  List<AddedBy>? addedBy;
  List<Picture>? pictures;
  // DateTime? createdAt;
  // String? merchant;
  // int? oldPrice;
  int? discountValue;
  String? discountType;
  bool? discountIsActive;
  int? discountedPrice;

  Variant({
    this.id,
    this.title,
    this.colour,
    this.trackInventory,
    this.type,
    this.price,
    this.value,
    // this.discount,
    this.discountId,
    this.quantity,
    this.localImages,
    this.serverImages,
    this.isAvailable,
    this.availableFrom,
    this.currency,
    this.addedBy,
    this.pictures,
    this.discountValue,
    this.discountType,
    this.discountIsActive,
    this.discountedPrice,
  });

  Map toMap() {
    final Map<String, dynamic> data = {};

    if (id != null && id != "") {
      data.addAll({"id": id});
    }
    data.addAll({
      "title": title,
      "colour": colour,
      "price": price,
      "type": type?.toName(),
      "value": value,
      "discount": discountId,
      "quantity": quantity,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "track_inventory": trackInventory,
      "currency": currency,
      "added_by": "blackstriker",
      "pictures": pictures,
    });
    return data;
  }

  Map toJson() {
    return {
      "id": id,
      "title": title,
      "colour": colour,
      "price": price,
      "type": type,
      "value": value,
      "quantity": quantity,
      "is_available": isAvailable,
      "available_from": availableFrom,
      "track_inventory": trackInventory,
      "currency": currency,
      "added_by": addedBy,
      "pictures": pictures,
      "discount_value": discountValue,
      "discount_type": discountType,
      "discount_is_active": discountIsActive,
      "discounted_price": discountedPrice,
    };
  }

  factory Variant.fromJson(object) {
    List<String> getVariantImages(List? data) {
      final List<String> images = [];

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
        final DateTime dateTime = DateTime.parse(date);
        return dateTime;
      }
      return DateTime.now();
    }

    return Variant(
      id: object["id"].toString(),
      title: object["title"].toString(),
      colour: object["colour"] ?? "",
      quantity: object["quantity"] ?? 0,
      value: object["value"] ?? "",
      price: object["price"].toString(),
      trackInventory: object["track_inventory"] ?? false,
      localImages: object["localImages"] ?? [],
      serverImages: getVariantImages(object["pictures"]),
      isAvailable: object["is_available"] ?? true,
      availableFrom: object["available_from"],
      currency: object["currency"] ?? "NGN",
      addedBy: object["added_by"] == null
          ? []
          : List<AddedBy>.from(
              object["added_by"]!.map((x) => AddedBy.fromJson(x))),
      pictures: object['pictures'] == null
          ? []
          : List<Picture>.from(
              object['pictures'].map((i) => Picture.fromJson(i))),
      type: getVariantType(object),
      discountId: object['discount'],
      discountValue: object['discount_value'],
      discountType: object['discount_type'],
      discountIsActive: object['discount_is_active'],
      discountedPrice: object['discounted_price'],
    );
  }

  List<UserFollowers> convertToUserFollowersList() {
    List<UserFollowers> userList = [];

    userList =
        (addedBy?.map((e) => e.user?.toUserFollowerModel()).toList() ?? [])
            .cast<UserFollowers>();

    return userList;
  }

  void getVariantAddedByDetails(SharedCartMemberModel? currentUser,
      {required BasketListModifierAction actionType}) {
    bool isAlreadyPresent = false;
    for (AddedBy variantAddedBy in addedBy ?? []) {
      if (variantAddedBy.user?.userName == currentUser?.userName) {
        if (actionType == BasketListModifierAction.increaseQty) {
          variantAddedBy.quantity = (variantAddedBy.quantity ?? 0) + 1;
          isAlreadyPresent = true;
          break;
        } else if (actionType == BasketListModifierAction.decreaseQty) {
          if ((variantAddedBy.quantity ?? 0) > 0) {
            variantAddedBy.quantity = (variantAddedBy.quantity ?? 0) - 1;
            if (variantAddedBy.quantity == 0) {
              addedBy?.removeWhere(
                  (element) => element.user?.userName == currentUser?.userName);
            }
          }
          isAlreadyPresent = true;
          break;
        }
      }
    }

    if (isAlreadyPresent == false) {
      if (actionType == BasketListModifierAction.increaseQty) {
        addedBy ??= [];
        addedBy?.add(AddedBy(user: currentUser, quantity: 1));
      } else if (actionType == BasketListModifierAction.decreaseQty) {
        if ((addedBy?.first.quantity ?? 0) > 0) {
          addedBy?.first.quantity = (addedBy?.first.quantity ?? 0) - 1;
          if (addedBy?.first.quantity == 0) {
            addedBy?.removeWhere(
                (element) => element.user?.userName == currentUser?.userName);
          }
        }
      }
    }
  }

  static List<String> getProductImages(List? data) {
    final List<String> images = [];

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
      final DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    debugPrint("${serverImages}");
    for (Picture data in pictures ?? []) {
      if (data.path == imageUrl) {
        return data.id.toString();
      }
    }
    return "";
  }

  List<String?> imageDataToList(List<dynamic> pictures) {
    final List<String?> imageLinks = [];
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

  int getQuantity() {
    if (quantity != null) {
      return quantity ?? 0;
    }
    return 0;
  }

  String getSize() {
    if (value != null && value != "") {
      return messageDecoderWithEmoji(value) ?? "";
    }
    return "";
  }

  String getColor() {
    if (colour != null && colour != "") {
      return colour ?? "";
    }
    return "";
  }

  static VariantTypes? getVariantType(Map<String, dynamic> object) {
    final String? color = object['colour'];
    final String? size = object['value'];

    if (color != null && color != "" && size != null && size != "") {
      return VariantTypes.ColorAndSize;
    } else if (color != null && color != "") {
      return VariantTypes.Color;
    } else if (size != null && size != "") {
      return VariantTypes.Size;
    }
    return null;
  }

  Variant copyWith(
      {String? id,
      String? title,
      String? size,
      String? colour,
      VariantTypes? type,
      String? price,
      String? value,
      List<File>? localImages,
      List<String?>? serverImages,
      int? quantity,
      bool? isAvailable,
      DateTime? availableFrom,
      String? currency,
      List<AddedBy>? addedBy,
      bool? trackInventory,
      int? discountValue,
      String? discountType,
      bool? discountIsActive,
      int? discountedPrice}) {
    return Variant(
      id: id ?? this.id,
      title: title ?? this.title,
      colour: colour ?? this.colour,
      type: type ?? this.type,
      price: price ?? this.price,
      value: value ?? this.value,
      localImages: localImages ?? this.localImages,
      serverImages: serverImages ?? this.serverImages,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: this.availableFrom,
      currency: currency ?? this.currency,
      addedBy: addedBy ?? this.addedBy,
      trackInventory: trackInventory ?? this.trackInventory,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountIsActive: discountIsActive ?? this.discountIsActive,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }

  String? getCoverImage() {
    if (serverImages != null && serverImages!.isNotEmpty) {
      return serverImages!.first;
    }
    return null;
  }
}

class AddOnOption {
  int? id;
  String? picture;
  String? name;
  String? description;
  String? merchant;
  String? selectType;
  String? currency;
  String? price;
  bool? isAvailable;
  bool isSelected = false;
  DateTime? createdAt;
  int quantity = 0;
  bool isChecked = false;
  List<AddedBy>? addedBy;

  AddOnOption({
    this.id,
    this.picture,
    this.name,
    this.description,
    this.merchant,
    this.selectType,
    this.currency,
    this.price,
    this.isAvailable,
    this.isSelected = false,
    this.createdAt,
    this.quantity = 0,
    this.isChecked = false,
    this.addedBy,
  });

  AddOnOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    picture = json['picture'];
    name = json['name'];
    description = json['description'];
    merchant = json['merchant'];
    selectType = json['select_type'];
    currency = json['currency'];
    price = json['price'].toString();
    isAvailable = json['is_available'];
    isSelected = json['is_selected'] ?? false;
    createdAt = getProductDateTime(json['created_at']);
    quantity = json['quantity'] ?? 0;
    isChecked = json['is_checked'] ?? false;
    addedBy = json['added_by'] == null
        ? []
        : List<AddedBy>.from(json['added_by'].map((x) => AddedBy.fromJson(x)));
  }

  AddOnOption copyWith({
    int? id,
    String? picture,
    String? name,
    String? description,
    String? merchant,
    String? selectType,
    String? currency,
    String? price,
    bool? isAvailable,
    bool? isSelected,
    DateTime? createdAt,
    int? quantity,
    bool? isChecked,
    List<AddedBy>? addedBy,
  }) {
    return AddOnOption(
      id: id ?? this.id,
      picture: picture ?? this.picture,
      name: name ?? this.name,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      selectType: selectType ?? this.selectType,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt ?? this.createdAt,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      addedBy: addedBy ?? this.addedBy,
    );
  }

  static DateTime getProductDateTime(var date) {
    if (date != null) {
      final DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['picture'] = picture;
    data['name'] = name;
    data['description'] = description;
    data['merchant'] = merchant;
    data['select_type'] = selectType;
    data['currency'] = currency;
    data['price'] = price;
    data['is_available'] = isAvailable;
    data['created_at'] = createdAt;
    data['quantity'] = quantity;
    data['added_by'] = addedBy;
    return data;
  }

  void getAddOnOptionAddedByDetails(SharedCartMemberModel? currentUser,
      {required BasketListModifierAction actionType}) {
    bool isAlreadyPresent = false;

    for (AddedBy addOnsAddedBy in addedBy ?? []) {
      if (addOnsAddedBy.user?.userName == currentUser?.userName) {
        if (actionType == BasketListModifierAction.increaseQty) {
          addOnsAddedBy.quantity = (addOnsAddedBy.quantity ?? 0) + 1;
          isAlreadyPresent = true;
          break;
        } else if (actionType == BasketListModifierAction.decreaseQty) {
          if ((addOnsAddedBy.quantity ?? 0) > 0) {
            addOnsAddedBy.quantity = (addOnsAddedBy.quantity ?? 0) - 1;
            if (addOnsAddedBy.quantity == 0) {
              addedBy?.removeWhere(
                  (element) => element.user?.userName == currentUser?.userName);
            }
          }
          isAlreadyPresent = true;
          break;
        }
      }
    }

    if (isAlreadyPresent == false) {
      if (actionType == BasketListModifierAction.increaseQty) {
        addedBy ??= [];
        addedBy?.add(AddedBy(user: currentUser, quantity: 1));
      } else if (actionType == BasketListModifierAction.decreaseQty) {
        if ((addedBy?.first.quantity ?? 0) > 0) {
          addedBy?.first.quantity = (addedBy?.first.quantity ?? 0) - 1;
          if (addedBy?.first.quantity == 0) {
            addedBy?.removeWhere(
                (element) => element.user?.userName == currentUser?.userName);
          }
        }
      }
    }
  }

  bool isAddOnsSelected(AddOns addon) {
    if (addon.inputType == "radio") {
      if (name == addon.groupValue) {
        return true;
      } else {
        return false;
      }
    } else if (addon.inputType == "checkbox") {
      if (isChecked) {
        return true;
      } else {
        return false;
      }
    }
    return false;
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
  String? groupValue;

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
      this.createdAt,
      this.groupValue});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['options'] != null) {
      options = <AddOnOption>[];
      json['options'].forEach((v) {
        options!.add(AddOnOption.fromJson(v));
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
    groupValue = json['group_value'] ?? null;
  }

  AddOns copyWith({
    int? id,
    List<AddOnOption>? options,
    String? merchant,
    String? name,
    String? description,
    String? inputType,
    String? selectType,
    bool? isRequired,
    bool? isChecked,
    DateTime? createdAt,
    String? groupValue,
  }) {
    return AddOns(
      id: id ?? this.id,
      options: options ?? this.options?.map((e) => e.copyWith()).toList(),
      merchant: merchant ?? this.merchant,
      name: name ?? this.name,
      description: description ?? this.description,
      inputType: inputType ?? this.inputType,
      selectType: selectType ?? this.selectType,
      isRequired: isRequired ?? this.isRequired,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      groupValue: groupValue ?? this.groupValue,
    );
  }

  List<AddOnOption> getSelectedAddsOnsOption(AddOns addOns) {
    final List<AddOnOption> selectedAddOnsList = [];

    for (AddOnOption addOn in options ?? []) {
      if (addOn.isAddOnsSelected(addOns)) selectedAddOnsList.add(addOn);
    }
    return selectedAddOnsList;
  }

  static DateTime getProductDateTime(var date) {
    if (date != null) {
      final DateTime dateTime = DateTime.parse(date);
      return dateTime;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['merchant'] = merchant;
    data['name'] = name;
    data['description'] = description;
    data['input_type'] = inputType;
    data['select_type'] = selectType;
    data['is_required'] = isRequired;
    // if(data['is_checked'] == null){
    //   isRequired = data['is_checked'] ?? false;
    // }
    data['created_at'] = createdAt;
    return data;
  }

  static List<AddOns> convertToAddOnList(List<dynamic> dataList) {
    final List<AddOns> addOnList = [];

    for (var data in dataList) {
      final AddOns addOns = AddOns(
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
    final List<AddOnOption> addOnOption = [];

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        addOnOption.add(AddOnOption.fromJson(data[i]));
      }
    }
    return addOnOption;
  }
}

class ProductCondition {
  const ProductCondition(this.name, this.description);

  final String name;
  final String description;
}

class Tags {
  num? id;
  String? name;
  bool isSelected;

  Tags({this.id, this.name, this.isSelected = false});

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SubCategory {
  num? id;
  String? name;

  SubCategory({
    this.id,
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

  CustomCategory({
    this.id,
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

class Service extends PurchasableItem {
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
  String? discountId;
  bool? discountIsActive;
  String? currency;
  List<dynamic>? pictureMap;
  double? rating;
  bool? canRate = false;
  List<String>? searchKeywords;
  bool isChecked = false;

  Service({
    super.id,
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
    this.discountId,
    this.discountIsActive,
    this.currency,
    this.pictureMap,
    this.rating = 0.0,
    this.canRate,
    this.searchKeywords,
    this.isChecked = false,
  });

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
    final List<String?> imageLinks = [];
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
      "discount": discountId,
      "discount_is_active": discountIsActive,
      "provider_avatar": providerAvatar,
      "provider_fullname": providerFullName,
      "search_keywords": searchKeywords,
      "is_checked": isChecked,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "description": description,
      "short_description":
          getShortDescription(shortDescription ?? '', description ?? ''),
      "price": price,
      "category": category,
      "is_available": isAvailable,
      "available_from": availableFrom.toString(),
      "discount_is_active": discountIsActive,
      "cover": cover,
      "provider": provider,
      "currency": currency,
      'rating': rating,
      "provider_avatar": providerAvatar,
      "provider_fullname": providerFullName,
      "search_keywords": searchKeywords == null
          ? []
          : List<String>.from(searchKeywords!.map((x) => x)),
      "is_checked": isChecked,
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
    discountIsActive = object["discount_is_active"] ?? false;
    currency = object["currency"] ?? "";
    pictureMap = object["pictureMap"] ?? [];
    rating = formatRating(double.parse(object['rating']?.toString() ?? "0"));
    canRate = object["can_rate"] ?? false;
    // searchKeywords = object["search_keywords"] ?? <String>[];
    searchKeywords =
    object["search_keywords"] == null
        ? <String>[]
        : List<String>.from(object["search_keywords"].map((x) => x));
    isChecked = object["is_checked"] ?? false;
  }

  bool isServiceAvailableNow() {
    if ((isAvailable ?? false) &&
        ((availableFrom?.isBefore(DateTime.now()) ?? false) ||
            (availableFrom?.isAtSameMomentAs(DateTime.now()) ?? false))) {
      return true;
    }
    return false;
  }

  List<String> getServiceImages(List? data) {
    final List<String> images = [];

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
      final DateTime dateTime = DateTime.parse(date);
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

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}

// class ProductCategory {
//   String? name;
//   dynamic id;
//
//   ProductCategory(
//     this.name, {this.id = ""});
//
//   ProductCategory.fromJson(object) {
//     id = object["id"];
//     name = object["name"];
//   }
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "id": id,
//   };
// }

class ServiceCategory {
  const ServiceCategory(this.name);

  final String name;
}

class AddedBy {
  SharedCartMemberModel? user;
  int? quantity;

  AddedBy({
    this.user,
    this.quantity,
  });

  factory AddedBy.fromJson(Map<String, dynamic> json) => AddedBy(
        user: json["user"] == null
            ? null
            : SharedCartMemberModel.fromJson(json["user"]),
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "quantity": quantity,
      };
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
  String? customer;
  // ShippingAddress? deliveryAddress;
  String? deliveryAddressId;
  String? journeyId;
  String? paymentType;
  String? pickupAddressId;
  int? price;
  String? rateId;
  int? shippingOption;
  int? shippingPrice;
  DateTime? updatedAt;
  DateTime? date;
  String? qty;
  List<Map<String, dynamic>>? items;

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
    this.statusTimeStamp,
    this.customer,
    // this.deliveryAddress,
    this.deliveryAddressId,
    this.journeyId,
    this.paymentType,
    this.pickupAddressId,
    this.price,
    this.rateId,
    this.shippingOption,
    this.shippingPrice,
    this.updatedAt,
    this.date,
    this.qty,
    this.items,
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

    customer = object["customer"];
    // deliveryAddress = object["delivery_address"] == null
    //     ? null
    //     : ShippingAddress.fromJson(object["delivery_address"]);
    deliveryAddressId = object["delivery_address_id"];
    journeyId = object["journey_id"];
    paymentType = object["payment_type"];
    pickupAddressId = object["pickup_address_id"];
    price = object["price"];
    rateId = object["rate_id"];
    shippingOption = object["shipping_option"];
    shippingPrice = object["shipping_price"];
    updatedAt = object["updated_at"] == null
        ? null
        : DateTime.parse(object["updated_at"]);
    date = object["date"] == null ? null : DateTime.parse(object["date"]);
    qty = object["qty"];

    if (object["item"] != null &&
        object["item"] is Map &&
        (object["item"] as Map).isNotEmpty) {
      items ??= [];
      if (object["item"].containsKey("manufacturer")) {
        final product = Product.fromJson(object["item"]);
        items?.add({
          "type": "product",
          "item": product,
          "qty": int.parse(object["qty"]),
        });
      }
      if (!object["item"].containsKey("manufacturer")) {
        final service = Service.fromJson(object["item"]);
        items?.add({
          "type": "service",
          "item": service,
          "qty": int.parse(object["qty"]),
        });
      }
    }
  }
}
