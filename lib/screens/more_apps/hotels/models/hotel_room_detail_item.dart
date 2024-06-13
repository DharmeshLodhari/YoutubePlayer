import 'package:Slydo/screens/more_apps/hotels/models/partial_hotel_room_item.dart';

import 'Location.dart';
import 'Partner.dart';
import 'Review.dart';

class HotelRoomDetailItem {
  String? about;
  List<String>? images;
  List<Location>? location;
  String? name;
  String? ownerAvatar;
  String? ownerName;
  String? ownerUserName;
  List<Partner>? partners;
  List<PartialHotelRoomItem>? recommendedItem;
  List<Review>? reviews;
  String? shortDetail;

  HotelRoomDetailItem(
      {this.about,
      this.images,
      this.location,
      this.name,
      this.ownerAvatar,
      this.ownerName,
      this.ownerUserName,
      this.partners,
      this.recommendedItem,
      this.reviews,
      this.shortDetail});

  factory HotelRoomDetailItem.fromJson(Map<String, dynamic> json) {
    return HotelRoomDetailItem(
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
      recommendedItem: json['recommended_item'] != null
          ? (json['recommended_item'] as List)
              .map((i) => PartialHotelRoomItem.fromJson(i))
              .toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((i) => Review.fromJson(i)).toList()
          : null,
      shortDetail: json['short_detail'],
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
    if (images != null) {
      data['images'] = images;
    }
    if (location != null) {
      data['location'] = location!.map((v) => v.toJson()).toList();
    }
    if (partners != null) {
      data['partners'] = partners!.map((v) => v.toJson()).toList();
    }
    if (recommendedItem != null) {
      data['recommended_item'] =
          recommendedItem!.map((v) => v.toJson()).toList();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
