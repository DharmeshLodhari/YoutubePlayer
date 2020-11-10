import 'package:Slydo/screens/more_apps/events/models/PartialEventItem.dart';

import 'Location.dart';

class EventDetailItem {
  String about;
  String currency;
  String eventTime;
  String image;
  List<Location> location;
  String name;
  String ownerAvatar;
  String ownerName;
  String ownerUserName;
  String price;
  List<PartialEventItem> similarEvent;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['about'] = this.about;
    data['currency'] = this.currency;
    data['event_time'] = this.eventTime;
    data['image'] = this.image;
    data['name'] = this.name;
    data['owner_avatar'] = this.ownerAvatar;
    data['owner_name'] = this.ownerName;
    data['owner_user_name'] = this.ownerUserName;
    data['price'] = this.price;
    if (this.location != null) {
      data['location'] = this.location.map((v) => v.toJson()).toList();
    }
    if (this.similarEvent != null) {
      data['similar_event'] = this.similarEvent.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
