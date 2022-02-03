import 'OpeningHour.dart';

class UserAbout {
  String address;
  String bio;
  String contact;
  String wallpaper;
  List<OpeningHourForDay> openingHours;

  UserAbout(
      {this.address = "",
      this.bio = "",
      this.contact = "",
      this.wallpaper = "",
      this.openingHours = const []});

  factory UserAbout.fromJson(Map<String, dynamic> json) {
    return UserAbout(
      address: json['address'] ?? "",
      bio: json['bio'] ?? "",
      wallpaper: json['wallpaper'] ?? "",
      contact: json['contact'] ?? "",
      openingHours: json['opening_hours'] != null
          ? (json['opening_hours'] as List)
              .map((i) => OpeningHourForDay.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['address'] = this.address;
    data['bio'] = this.bio;
    data['contact'] = this.contact;
    if (!this.wallpaper.contains("https") && this.wallpaper != "") {
      data['wallpaper'] = this.wallpaper;
    }

    data['opening_hours'] = this.openingHours.map((v) => v.toJson()).toList();
    return data;
  }
}
