import 'Geometry.dart';
import 'OpeningHours.dart';
import 'Photo.dart';
import 'PlusCode.dart';

class PlaceModal {
  String? businessStatus;
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  OpeningHours? openingHours;
  List<Photo>? photos;
  String? placeId;
  PlusCode? plusCode;
  int? priceLevel;
  double? rating;
  String? reference;
  List<String>? types;
  int? userRatingsTotal;

  PlaceModal(
      {this.businessStatus = "",
      this.formattedAddress = "",
      this.geometry,
      this.icon = "",
      this.iconBackgroundColor = "",
      this.iconMaskBaseUri = "",
      this.name,
      this.openingHours,
      this.photos = const [],
      this.placeId,
      this.plusCode,
      this.priceLevel,
      this.rating,
      this.reference,
      this.types,
      this.userRatingsTotal});

  factory PlaceModal.fromJson(Map<String, dynamic> json) {
    return PlaceModal(
      businessStatus: json['business_status'],
      formattedAddress: json['formatted_address'],
      geometry:
          json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
      icon: json['icon'],
      iconBackgroundColor: json['icon_background_color'],
      iconMaskBaseUri: json['icon_mask_base_uri'],
      name: json['name'],
      openingHours: json['opening_hours'] != null
          ? OpeningHours.fromJson(json['opening_hours'])
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List).map((i) => Photo.fromJson(i)).toList()
          : null,
      placeId: json['place_id'],
      plusCode: json['plus_code'] != null
          ? PlusCode.fromJson(json['plus_code'])
          : null,
      priceLevel: json['price_level'],
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : json['rating'],
      reference: json['reference'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      userRatingsTotal: json['user_ratings_total'],
    );
  }

  Map<String, dynamic> toJson() {
    // ignore: unnecessary_new
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_status'] = businessStatus;
    data['formatted_address'] = formattedAddress;
    data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_mask_base_uri'] = iconMaskBaseUri;
    data['name'] = name;
    data['place_id'] = placeId;
    data['price_level'] = priceLevel;
    data['rating'] = rating;
    data['reference'] = reference;
    data['user_ratings_total'] = userRatingsTotal;
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    if (openingHours != null) {
      data['opening_hours'] = openingHours!.toJson();
    }
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    if (plusCode != null) {
      data['plus_code'] = plusCode!.toJson();
    }
    if (types != null) {
      data['types'] = types;
    }
    return data;
  }
}
