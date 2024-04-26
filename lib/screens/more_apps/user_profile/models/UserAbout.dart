import 'OpeningHour.dart';

class UserAbout {
  UserAddress? userAddress;
  String bio;
  String contact;
  String wallpaper;
  List<OpeningHourForDay> openingHours;
  Industry? industry;

  UserAbout(
      {this.bio = '',
      this.userAddress,
      this.contact = "",
      this.wallpaper = "",
      this.openingHours = const [],
      this.industry});

  factory UserAbout.fromJson(Map<String, dynamic> json) {
    return UserAbout(
        userAddress: UserAddress.fromJson(json['address']),
        wallpaper: json['wallpaper'] ?? "",
        contact: json['contact'] ?? "",
        openingHours: json['opening_hours'] != null
            ? (json['opening_hours'] as List)
                .map((i) => OpeningHourForDay.fromJson(i))
                .toList()
            : [],
        industry: Industry.fromJson(json['industry']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['address'] = userAddress?.toJson();
    data['bio'] = bio;
    data['contact'] = contact;
    if (!wallpaper.contains("https") &&
        !wallpaper.contains("http") &&
        wallpaper != "") {
      data['wallpaper'] = wallpaper;
    }

    data['opening_hours'] = openingHours.map((v) => v.toJson()).toList();
    data['industry'] = industry!.toJson();
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['state'] = state;
    data['address_line_1'] = addressLine1;
    data['address_line_2'] = addressLine2;
    data['city'] = city;
    data['post_code'] = postCode;
    return data;
  }
}

class Industry {
  String? id;
  String? name;

  Industry({this.id, this.name});

  factory Industry.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return Industry(
        id: json['id'],
        name: json['name'],
      );
    }

    return Industry();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
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
        json['country'] != null ? Country.fromJson(json['country']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (country != null) {
      data['country'] = country!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['iso_code'] = isoCode;
    return data;
  }
}
