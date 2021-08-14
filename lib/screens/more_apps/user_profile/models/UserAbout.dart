import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:provider/provider.dart';

import 'OpeningHour.dart';

class UserAbout {
  String address;
  String bio;
  String contact;
  String wallpaper;
  List<OpeningHour> openingHours;

  UserAbout(
      {this.address = "",
      this.bio = "",
      this.contact = "",
      this.wallpaper = "",
      this.openingHours = const []});

  factory UserAbout.fromJson(Map<String, dynamic> json) {
    UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext,
        listen: false);

    if (json['nickname'] != null && json['nickname'] != "") {
      userBloc.user.nickName = json['nickname'];
    }

    return UserAbout(
      address: json['address'] ?? "",
      bio: json['bio'] ?? "",
      wallpaper: json['wallpaper'] ?? "",
      contact: json['contact'] ?? "",
      openingHours: json['opening_hours'] != null
          ? (json['opening_hours'] as List)
              .map((i) => OpeningHour.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['address'] = this.address;
    data['bio'] = this.bio;
    data['contact'] = this.contact;
    if (!this.wallpaper.contains("https")) {
      data['wallpaper'] = this.wallpaper;
    }

    if (this.openingHours != null) {
      data['opening_hours'] = this.openingHours.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
