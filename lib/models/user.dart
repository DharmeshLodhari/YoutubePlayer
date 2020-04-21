import 'package:Slydo/models/store.dart';

class User {
  String uuid;
  String url;
  String phoneNumber;
  String fullName;
  String userName;
  String avatar;
  String qrCode;
  String password;
  String currency;
  String type;
  bool isVerified;
  final Setting setting = Setting(
      enableService: true,
      enableProduct: true,
      enableExplore: false,
      enableTransactionDetailPage: true);

  // Pass in as named parameter in constructor
  User({
    this.uuid,
    this.url,
    this.phoneNumber,
    this.fullName,
    this.userName,
    this.avatar,
    this.qrCode,
    this.password,
    this.currency = "€",
    this.type = "user",
    this.isVerified = false,
  });

  bool isAuthenticated() {
    //  We should check here if instance has username then user is not Anonymous
    return userName != null ? true : false;
  }

  User.map(dynamic obj) {
    this.userName = obj["username"];
    this.password = obj["password"];
    this.uuid = obj["uuid"];
    this.url = obj["url"];
    this.phoneNumber = obj["phoneNumber"];
    this.fullName = obj["fullName"];
    this.avatar = obj["avatar"];
    this.qrCode = obj["qrCode"];
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
      this.currency = "€"});
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
