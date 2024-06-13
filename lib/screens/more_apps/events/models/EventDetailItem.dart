import 'package:Slydo/screens/more_apps/events/models/partial_event_item.dart';

import 'Location.dart';

class EventDetailItem {
  String? about;
  String? currency;
  String? eventTime;
  String? image;
  List<Location>? location;
  String? name;
  String? ownerAvatar;
  String? ownerName;
  String? ownerUserName;
  String? price;
  List<PartialEventItem>? similarEvent;

  EventDetailItem(
      {this.about,
      this.currency,
      this.eventTime,
      this.image,
      this.location,
      this.name,
      this.ownerAvatar,
      this.ownerName,
      this.ownerUserName,
      this.price,
      this.similarEvent});

  factory EventDetailItem.fromJson(Map<String, dynamic> json) {
    return EventDetailItem(
      about: json['about'],
      currency: json['currency'],
      eventTime: json['event_time'],
      image: json['image'],
      location: json['location'] != null
          ? (json['location'] as List).map((i) => Location.fromJson(i)).toList()
          : null,
      name: json['name'],
      ownerAvatar: json['owner_avatar'],
      ownerName: json['owner_name'],
      ownerUserName: json['owner_user_name'],
      price: json['price'],
      similarEvent: json['similar_event'] != null
          ? (json['similar_event'] as List)
              .map((i) => PartialEventItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['about'] = about;
    data['currency'] = currency;
    data['event_time'] = eventTime;
    data['image'] = image;
    data['name'] = name;
    data['owner_avatar'] = ownerAvatar;
    data['owner_name'] = ownerName;
    data['owner_user_name'] = ownerUserName;
    data['price'] = price;
    if (location != null) {
      data['location'] = location!.map((v) => v.toJson()).toList();
    }
    if (similarEvent != null) {
      data['similar_event'] = similarEvent!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
