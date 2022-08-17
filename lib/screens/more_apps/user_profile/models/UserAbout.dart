import 'OpeningHour.dart';

class UserAbout {
  UserAddress? userAddress;
  String bio;
  String contact;
  String wallpaper;
  List<OpeningHourForDay> openingHours;

  UserAbout(
      {this.userAddress,
      this.bio = "",
      this.contact = "",
      this.wallpaper = "",
      this.openingHours = const []});

  factory UserAbout.fromJson(Map<String, dynamic> json) {
    return UserAbout(
      userAddress: UserAddress.fromJson(json['address']),
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

    data['address'] = this.userAddress;
    data['bio'] = this.bio;
    data['contact'] = this.contact;
    if (!this.wallpaper.contains("https") && this.wallpaper != "") {
      data['wallpaper'] = this.wallpaper;
    }

    data['opening_hours'] = this.openingHours.map((v) => v.toJson()).toList();
    return data;
  }
}

class UserAddress {
  int? id;
  dynamic state;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? postCode;

  UserAddress(
      {this.id,
      this.state,
      this.addressLine1,
      this.addressLine2,
      this.city,
      this.postCode});

  factory UserAddress.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return UserAddress(
        id: json['id'],
        state: json['state'],
        addressLine1: json['address_line_1'],
        addressLine2: json['address_line_2'],
        city: json['city'],
        postCode: json['post_code'],
      );
    }

    return UserAddress();
  }

  // _InternalLinkedHashMap<String, dynamic>

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['state'] = this.state!;
    data['address_line_1'] = this.addressLine1;
    data['address_line_2'] = this.addressLine2;
    data['city'] = this.city;
    data['post_code'] = this.postCode;
    return data;
  }
}

class UserState {
  int? id;
  String? name;
  Country? country;

  UserState({this.id, this.name, this.country});

  UserState.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country =
        json['country'] != null ? new Country.fromJson(json['country']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    return data;
  }
}

class Country {
  int? id;
  String? name;
  String? isoCode;

  Country({this.id, this.name, this.isoCode});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isoCode = json['iso_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['iso_code'] = this.isoCode;
    return data;
  }
}
