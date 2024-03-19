import 'Picture.dart';

class ShoppingProduct {
  String? availableFrom;
  // String? category;
  String? condition;
  String? cover;
  String? createdAt;
  String? currency;
  String? description;
  String? id;
  bool? isAvailable;
  String? manufacturer;
  String? name;
  List<Picture>? images;
  int? price;
  String? qrCode;
  String? seller;
  String? sellerAvatar;
  String? sellerFullName;
  String? shortDescription;
  String? type;
  int? discountValue;
  String? discountType;
  bool? discountIsActive;
  int? discountedPrice;

  ShoppingProduct({
    this.availableFrom,
    // this.category,
    this.condition,
    this.cover,
    this.createdAt,
    this.currency,
    this.description,
    this.id,
    this.isAvailable,
    this.manufacturer,
    this.name,
    this.images,
    this.price,
    this.qrCode,
    this.seller,
    this.sellerAvatar,
    this.sellerFullName,
    this.shortDescription,
    this.type,
    this.discountValue,
    this.discountType,
    this.discountIsActive,
    this.discountedPrice,
  });

  factory ShoppingProduct.fromJson(Map<String, dynamic> json) {
    return ShoppingProduct(
      availableFrom: json['available_from'],
      // category: json['category'],
      condition: json['condition'],
      cover: json['cover'],
      createdAt: json['created_at'],
      currency: json['currency'],
      description: json['description'],
      id: json['id'],
      isAvailable: json['is_available'],
      manufacturer: json['manufacturer'],
      name: json['name'],
      images: json['pictures'] != null
          ? (json['pictures'] as List).map((i) => Picture.fromJson(i)).toList()
          : null,
      price: json['price'],
      qrCode: json['qr_code'],
      seller: json['seller'],
      sellerAvatar: json['seller_avatar'],
      sellerFullName: json['seller_fullname'],
      shortDescription: json['short_description'],
      type: json['type'],
      discountValue: json['discount_value'],
      discountType: json['discount_type'],
      discountIsActive: json['discount_is_active'],
      discountedPrice: json['discounted_price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available_from'] = this.availableFrom;
    // data['category'] = this.category;
    data['condition'] = this.condition;
    data['cover'] = this.cover;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['id'] = this.id;
    data['is_available'] = this.isAvailable;
    data['manufacturer'] = this.manufacturer;
    data['name'] = this.name;
    data['price'] = this.price;
    data['qr_code'] = this.qrCode;
    data['seller'] = this.seller;
    data['seller_avatar'] = this.sellerAvatar;
    data['short_description'] = this.shortDescription;
    data['type'] = this.type;
    data["discount_value"] = this.discountValue;
    data["discount_type"] = this.discountType;
    data["discount_is_active"] = this.discountIsActive;
    data["discounted_price"] = this.discountedPrice;
    if (this.images != null) {
      data['pictures'] = this.images!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
