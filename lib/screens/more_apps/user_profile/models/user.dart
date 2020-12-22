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

  // Pass in as named parameter in constructor
  User({
    this.uuid,
    this.url,
    this.phoneNumber,
    this.fullName,
    this.userName,
    this.type,
    this.avatar,
    this.qrCode,
    this.password,
    this.currency = "₦",
    this.isVerified = false,
    this.conversationId = "",
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

  // Pass in as named parameter in constructor
  CustomerProfile({
    this.fullName,
    this.userName,
    this.avatar,
    this.qrCode,
    this.type = "user",
  });

  CustomerProfile.map(dynamic obj) {
    this.userName = obj["username"];
    this.fullName = obj["fullName"];
    this.avatar = obj["avatar"];
    this.qrCode = obj["qrCode"];
    this.type = obj['type'] ?? 'user';
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["fullName"] = fullName;
    map["userName"] = userName;
    map["avatar"] = avatar;
    map["qrCode"] = qrCode;
    map["type"] = type;
    return map;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});
}
