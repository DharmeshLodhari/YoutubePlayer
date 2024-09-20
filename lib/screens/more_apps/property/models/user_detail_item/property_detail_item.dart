import 'location_model.dart';
import 'partner.dart';
import 'review.dart';
import 'similar_property.dart';

class PropertyDetailItem {
  String? about;
  List<String>? images;
  List<Location>? location;
  String? name;
  String? ownerAvatar;
  String? ownerName;
  String? ownerUserName;
  List<Partner>? partners;
  List<Review>? reviews;
  String? shortDetail;
  List<SimilarProperty>? similarProperties;
  String? video;

  PropertyDetailItem(
      {this.about = "",
      this.images = const [],
      this.location = const [],
      this.name = "",
      this.ownerAvatar = "",
      this.ownerName = "",
      this.ownerUserName = "",
      this.partners = const [],
      this.reviews = const [],
      this.shortDetail = "",
      this.similarProperties = const [],
      this.video = ""});

  factory PropertyDetailItem.fromJson(Map<String, dynamic> json) {
    return PropertyDetailItem(
      about: json['about'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      location: json['location'] != null
          ? (json['location'] as List).map((i) => Location.fromJson(i)).toList()
          : null,
      name: json['name'],
      ownerAvatar: json['owner_avatar'],
      ownerName: json['owner_name'],
      ownerUserName: json['owner_user_name'],
      partners: json['partners'] != null
          ? (json['partners'] as List).map((i) => Partner.fromJson(i)).toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((i) => Review.fromJson(i)).toList()
          : null,
      shortDetail: json['short_detail'],
      similarProperties: json['similar_properties'] != null
          ? (json['similar_properties'] as List)
              .map((i) => SimilarProperty.fromJson(i))
              .toList()
          : null,
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['about'] = about;
    data['name'] = name;
    data['owner_avatar'] = ownerAvatar;
    data['owner_name'] = ownerName;
    data['owner_user_name'] = ownerUserName;
    data['short_detail'] = shortDetail;
    data['video'] = video;
    if (images != null) {
      data['images'] = images;
    }
    if (location != null) {
      data['location'] = location!.map((v) => v.toJson()).toList();
    }
    if (partners != null) {
      data['partners'] = partners!.map((v) => v.toJson()).toList();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    if (similarProperties != null) {
      data['similar_properties'] =
          similarProperties!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
