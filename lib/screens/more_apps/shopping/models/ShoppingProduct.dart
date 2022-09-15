import 'Picture.dart';

class ShoppingProduct {
  String? availableFrom;
  String? category;
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
  String? sellerFullname;
  String? shortDescription;
  String? type;

  ShoppingProduct(
      {this.availableFrom,
      this.category,
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
      this.sellerFullname,
      this.shortDescription,
      this.type});

  factory ShoppingProduct.fromJson(Map<String, dynamic> json) {
    return ShoppingProduct(
      availableFrom: json['available_from'],
      category: json['category'],
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
      sellerFullname: json['seller_fullname'],
      shortDescription: json['short_description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available_from'] = this.availableFrom;
    data['category'] = this.category;
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
    if (this.images != null) {
      data['pictures'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
