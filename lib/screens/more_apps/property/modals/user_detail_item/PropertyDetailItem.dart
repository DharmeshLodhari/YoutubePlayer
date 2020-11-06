import 'Location.dart';
import 'Partner.dart';
import 'Review.dart';
import 'SimilarProperty.dart';

class PropertyDetailItem {
  String about;
  List<String> images;
  List<Location> location;
  String name;
  String ownerAvatar;
  String ownerName;
  String ownerUserName;
  List<Partner> partners;
  List<Review> reviews;
  String shortDetail;
  List<SimilarProperty> similarProperties;
  String video;

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
      images:
          json['images'] != null ? new List<String>.from(json['images']) : null,
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['about'] = this.about;
    data['name'] = this.name;
    data['owner_avatar'] = this.ownerAvatar;
    data['owner_name'] = this.ownerName;
    data['owner_user_name'] = this.ownerUserName;
    data['short_detail'] = this.shortDetail;
    data['video'] = this.video;
    if (this.images != null) {
      data['images'] = this.images;
    }
    if (this.location != null) {
      data['location'] = this.location.map((v) => v.toJson()).toList();
    }
    if (this.partners != null) {
      data['partners'] = this.partners.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews.map((v) => v.toJson()).toList();
    }
    if (this.similarProperties != null) {
      data['similar_properties'] =
          this.similarProperties.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
