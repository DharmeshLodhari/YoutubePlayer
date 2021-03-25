import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';

class Address {
  String addressLineOne;
  String addressLineTwo;
  String city;
  String state;
  String country;
  String countryIsoCode;

  Address(
      {this.addressLineOne,
      this.addressLineTwo,
      this.city,
      this.state,
      this.country,
      this.countryIsoCode});

  Address.fromJson(var object) {
    this.addressLineOne = object['address_line_1'] ?? "";
    this.addressLineTwo = object['address_line_2'] ?? "";
    this.city = object['city'] ?? "";
    this.state = object['state'] ?? "";
    this.country = object['country'] ?? "";
    this.countryIsoCode = object['country_iso_code'] ?? "NG";
  }
}

enum UserStatus { ACTIVE, AWAY, UNKNOWN }

class User {
  String uuid;
  String url;
  String phoneNumber;
  String fullName;
  String userName;
  String type;
  String avatar;
  String qrCode;
  String password;
  String currency;
  bool isVerified;
  String conversationId;
  UserStatus status;
  UserAbout userAbout;

  // Pass in as named parameter in constructor
  User({
    this.uuid = "",
    this.url = "",
    this.phoneNumber = "",
    this.fullName = "",
    this.userName = "",
    this.type = "",
    this.avatar = "",
    this.qrCode = "",
    this.password = "",
    this.currency = "₦",
    this.isVerified = false,
    this.conversationId = "",
    this.userAbout,
    this.status = UserStatus.UNKNOWN,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      type: json['account_type'],
      avatar: json['avatar'],
      currency: json['default_currency'],
      fullName: json['full_name'],
      isVerified: json['is_verified'],
      password: json['password'],
      phoneNumber: json['phone_number'],
      qrCode: json['qr_code'],
      url: json['url'],
      userAbout: UserAbout.fromJson(json["profile"]) ?? null,
      userName: json['username'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_type'] = this.type;
    data['avatar'] = this.avatar;
    data['default_currency'] = this.currency;
    data['full_name'] = this.fullName;
    data['is_verified'] = this.isVerified;
    data['password'] = this.password;
    data['phone_number'] = this.phoneNumber;
    data['qr_code'] = this.qrCode;
    data['url'] = this.url;
    data['username'] = this.userName;
    data['uuid'] = this.uuid;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["uuid"] = uuid;
    map["fullName"] = fullName;
    map["userName"] = userName;
    map["phoneNumber"] = phoneNumber;
    map["password"] = password;
    map["avatar"] = avatar;
    map["qrCode"] = qrCode;
    map["url"] = url;
    return map;
  }
}

class Payee {
  //a person to whom money is paid or is to be paid, especially the person
  // to whom a cheque is made payable.
  final String uuid;
  String url = '';
  String fullName = '';
  String userName = '';
  String avatar = '';
  String qrCode = '';
  String currency;

  // Pass in as named parameter in constructor
  Payee(
      {this.uuid,
      this.url,
      this.fullName,
      this.userName,
      this.avatar,
      this.qrCode,
      this.currency = "₦"});
}

class CustomerProfile {
  String fullName;
  String userName;
  String avatar;
  String qrCode;
  String type;
  String conversationId;
  String uuid;
  String defaultCurrency;
  bool isVerified;
  UserAbout userAbout;
  UserStatus status;

  // Pass in as named parameter in constructor
  CustomerProfile({
    this.fullName = "",
    this.userName = "",
    this.avatar = "",
    this.userAbout,
    this.qrCode = "",
    this.type = "user",
    this.conversationId = "",
    this.defaultCurrency = "NGN",
    this.isVerified = false,
    this.uuid = "",
    this.status = UserStatus.UNKNOWN,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    CustomerProfile profile = CustomerProfile(
        fullName: json['full_name'] ?? "",
        userName: json['username'] ?? "",
        avatar: json['avatar'] ?? "",
        qrCode: json['qr_code'] ?? "",
        type: json['type'] ?? json['account_type'] ?? "user",
        conversationId: json['conversation_id'] ?? "",
        status: json['status'] ?? UserStatus.UNKNOWN);
    if (json['default_currency'] != null) {
      profile.defaultCurrency = json['default_currency'] ?? "NGN";
    }
    if (json['is_verified'] != null) {
      profile.isVerified = json['is_verified'] ?? false;
    }
    if (json['uuid'] != null) {
      profile.uuid = json['uuid'] ?? "";
    }
    if (json['profile'] != null) {
      profile.userAbout = UserAbout.fromJson(json['profile']);
    }

    return profile;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['username'] = this.userName;
    data['avatar'] = this.avatar;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    data['conversation_id'] = this.conversationId;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    data['default_currency'] = this.defaultCurrency;
    data['is_verified'] = this.isVerified;
    data['profile'] = this.userAbout.toJson();
    return data;
  }

  Map<String, dynamic> toJsonToSendInToChat() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['username'] = this.userName;
    data['avatar'] = this.avatar;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    return data;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});
}
