import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/utils/util.dart';

class Address {
  String? addressLineOne;
  String? addressLineTwo;
  String? city;
  String? state;
  String? country;
  String? countryIsoCode;
  String? shippingNote;

  Address(
      {this.addressLineOne,
      this.addressLineTwo,
      this.city,
      this.state,
      this.country,
      this.shippingNote,
      this.countryIsoCode});

  Address.fromJson(var object) {
    this.addressLineOne = object['address_line_1'] ?? "";
    this.addressLineTwo = object['address_line_2'] ?? "";
    this.city = object['city'] ?? "";
    this.state = object['state'] ?? "";
    this.country = object['country'] ?? "";
    this.countryIsoCode = object['country_iso_code'] ?? "NG";
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'shipping_note': shippingNote,
      'address_line_1': addressLineOne,
      'address_line_2': addressLineTwo,
      'country_iso_code': countryIsoCode,
    };
  }
}

enum UserStatus { ACTIVE, AWAY, UNKNOWN }

class User {
  String? uuid;
  String? url;
  String? phoneNumber;
  String? fullName;
  String? userName;
  String? nickName;
  String? type;
  String? avatar;
  String? qrCode;
  String? password;
  String? currency;
  bool? isVerified;
  String conversationId;
  UserStatus status;
  double? rating;
  UserAbout? userAbout;

  // Pass in as named parameter in constructor
  User({
    this.uuid = "",
    this.url = "",
    this.phoneNumber = "",
    this.fullName = "",
    this.userName = "",
    this.nickName = "==>",
    this.type = "",
    this.avatar = "",
    this.qrCode = "",
    this.password = "",
    this.currency = "₦",
    this.isVerified = false,
    this.conversationId = "",
    this.rating = 0.0,
    this.userAbout,
    this.status = UserStatus.UNKNOWN,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nickName: json['nickname'] ?? "",
      type: json['account_type'],
      avatar: json['avatar'],
      currency: json['default_currency'],
      fullName: json['full_name'],
      isVerified: json['is_verified'],
      password: json['password'],
      phoneNumber: json['phone_number'],
      qrCode: json['qr_code'],
      url: json['url'],
      rating: formatRating(json['rating']),
      userAbout: UserAbout.fromJson(json["profile"]),
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
    data['nickname'] = this.nickName;
    data['is_verified'] = this.isVerified;
    data['password'] = this.password;
    data['phone_number'] = this.phoneNumber;
    data['qr_code'] = this.qrCode;
    data['url'] = this.url;
    data['rating'] = this.rating;
    data['username'] = this.userName;
    data['uuid'] = this.uuid;
    return data;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["uuid"] = uuid;
    map["fullName"] = fullName;
    map["nickname"] = nickName;
    map["userName"] = userName;
    map["phoneNumber"] = phoneNumber;
    map["password"] = password;
    map["avatar"] = avatar;
    map["qrCode"] = qrCode;
    map["url"] = url;
    map["rating"] = rating;
    return map;
  }

  String? displayName() {
    if (this.nickName != "" && this.nickName != null) {
      if (this.type != null &&
          this.type != "" &&
          this.type != "Business" &&
          this.type != "Developer") {
        return this.nickName;
      }
    }

    if (this.fullName != null && this.fullName != "") {
      return this.fullName;
    }
    return this.userName;
  }
}

class CustomerProfile {
  String? fullName;
  String? userName;
  String? avatar;
  String? qrCode;
  String? nickName;
  String? type;
  String? conversationId;
  String uuid;
  String defaultCurrency;
  bool isVerified;
  UserAbout? userAbout;
  UserStatus status;
  double rating;

  // Pass in as named parameter in constructor
  CustomerProfile(
      {this.fullName = "",
      this.userName = "",
      this.avatar = "",
      this.userAbout,
      this.qrCode = "",
      this.nickName = "",
      this.type = "user",
      this.conversationId = "",
      this.defaultCurrency = "NGN",
      this.isVerified = false,
      this.uuid = "",
      this.status = UserStatus.UNKNOWN,
      this.rating = 0.0});

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    CustomerProfile profile = CustomerProfile(
        fullName: json['full_name'] ?? json['name'] ?? "",
        userName: json['username'] ?? "",
        avatar: json['avatar'] ?? "",
        qrCode: json['qr_code'] ?? "",
        nickName: json['nickname'] ?? json['name'] ?? "",
        type: json['type'] ?? json['account_type'] ?? "user",
        conversationId: json['conversation_id'] ?? "",
        status: json['status'] ?? UserStatus.UNKNOWN,
        rating: json['rating'] ?? 0.0);
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

  factory CustomerProfile.fromDBJson(Map<String, dynamic> json) {
    CustomerProfile profile = CustomerProfile(
        fullName: json['full_name'],
        userName: json['username'],
        avatar: json['avatar'],
        nickName: json['nickname'],
        qrCode: json['qr_code'],
        type: json['type'],
        conversationId: json['conversation_id'],
        rating: json['rating'] ?? 0.0);
    return profile;
  }

  factory CustomerProfile.fromChatConversation(
      ChatConversation chatConversation) {
    CustomerProfile profile = CustomerProfile(
      fullName: chatConversation.fullName,
      userName: chatConversation.userName,
      avatar: chatConversation.avatar,
      qrCode: chatConversation.qrCode,
      type: chatConversation.type,
      conversationId: chatConversation.conversationId,
    );
    return profile;
  }

  factory CustomerProfile.fromGroupParticipant(Participant participant) {
    CustomerProfile profile = CustomerProfile(
      fullName: participant.fullName,
      userName: participant.userName,
      avatar: participant.avatar,
      type: participant.type,
    );
    return profile;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['username'] = this.userName;
    data['nickname'] = this.nickName;
    data['avatar'] = this.avatar;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    data['conversation_id'] = this.conversationId;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    data['default_currency'] = this.defaultCurrency;
    data['is_verified'] = this.isVerified;
    data['profile'] = this.userAbout!.toJson();
    return data;
  }

  Map<String, dynamic> toJsonForDB() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['full_name'] = this.fullName;
    data['username'] = this.userName;
    data['avatar'] = this.avatar;
    data['nickname'] = this.nickName;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    data['conversation_id'] = this.conversationId;
    data['rating'] = this.rating;

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

  String? displayName() {
    if (this.nickName != "" && this.nickName != null) {
      if (this.type != null &&
          this.type != "" &&
          this.type != "Business" &&
          this.type != "Developer") {
        return this.nickName;
      }
    }

    if (this.fullName != null && this.fullName != "") {
      return this.fullName;
    }
    return this.userName;
  }
}

class UserLocation {
  final double? latitude;
  final double? longitude;

  UserLocation({this.latitude, this.longitude});
}
