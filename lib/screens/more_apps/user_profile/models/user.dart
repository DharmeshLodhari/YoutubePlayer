import 'package:Slydo/constant.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/participant_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/utils/util.dart';

import '../../payment_and_banking/models/FinancialInstitution.dart';

enum UserStatus { ACTIVE, AWAY, UNKNOWN }

enum PermissionType { READ, WRITE }

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
  String? bio;
  String? wallpaper;
  String? chatWallpaper;
  UserAbout? userAbout;
  RiderModel? rider;
  Staff? staff;
  Permissions? permissions;
  ShippingAddress? defaultAddress;

  // Pass in as named parameter in constructor
  User({
    this.bio = "",
    this.uuid = "",
    this.url = "",
    this.wallpaper = "",
    this.chatWallpaper = "",
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
    this.rider,
    this.staff,
    this.permissions,
    this.defaultAddress,
  });

  factory User.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? staff, Map<String, dynamic>? permissions}) {
    // debugPrint('IS-VERIFIED --> ${json['is_verified']}');
    final User user = User(
      nickName: json['nickname'] ?? "",
      type: json['account_type'],
      avatar: json['avatar'] ?? defaultImage,
      currency: json['default_currency'],
      fullName: json['full_name'],
      isVerified: json['is_verified'],
      password: json['password'],
      phoneNumber: json['phone_number'],
      qrCode: json['qr_code'],
      url: json['url'],
      bio: json['bio'] ?? '',
      userAbout: UserAbout.fromJson(json["profile"]),
      chatWallpaper: json['chat_wallpaper'],
      wallpaper: json['wallpaper'],
      rating: formatRating(json['rating']),
      userName: json['username'],
      uuid: json['uuid'],
      rider: (json["rider"] != null && (json["rider"] as Map).isNotEmpty)
          ? RiderModel.fromJson(json["rider"])
          : null,
      staff: staff != null ? Staff.fromJson(staff) : null,
      permissions:
          permissions != null ? Permissions.fromJson(permissions) : null,
      defaultAddress: json["default_address"] == null
          ? null
          : ShippingAddress.fromJson(json["default_address"]),
    );
    // userAbout.bio = user.bio == null ? '' : user.bio!;
    // user.userAbout = userAbout;

    return user;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_type'] = type;
    data['avatar'] = avatar;
    data['default_currency'] = currency;
    data['full_name'] = fullName;
    data['nickname'] = nickName;
    data['is_verified'] = isVerified;
    data['password'] = password;
    data['phone_number'] = phoneNumber;
    data['qr_code'] = qrCode;
    data['url'] = url;
    data['rating'] = rating;
    data['username'] = userName;
    data['uuid'] = uuid;
    data['rider'] = rider;
    data['staff'] = staff;
    data['permissions'] = permissions;
    data['default_address'] = defaultAddress;
    return data;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
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

  UserFollowers toUserFollowerModel() {
    final UserFollowers userFollowers = UserFollowers();
    userFollowers.avatar = avatar;
    return userFollowers;
  }

  SharedCartMemberModel convertToUser() {
    final SharedCartMemberModel user = SharedCartMemberModel();

    user.userName = userName;
    user.avatar = avatar;
    user.fullName = fullName;
    return user;
  }

  String? displayName() {
    if (nickName != "" && nickName != null) {
      if (type != null &&
          type != "" &&
          type != "Business" &&
          type != "Developer") {
        return nickName;
      }
    }

    if (fullName != null && fullName != "") {
      return fullName;
    }
    return userName;
  }

  PermissionType? hasWritePermission(String title) {
    if (staff != null && permissions != null) {
      return permissions?.hasWritePermissionForStaff(title);
    } else if ((type?.toLowerCase() == 'user' && title == 'Product') ||
        (type?.toLowerCase() == 'user' && title == 'Services')) {
      return null;
    } else {
      return PermissionType.WRITE;
    }
  }
}

class Staff {
  String? employerUsername;
  String? userUsername;
  String? userAvatar;
  String? employerAvatar;
  int? employer;
  String? user;
  String? status;
  String? role;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;
  String? userFullName;
  String? employerFullName;
  bool? userIsVerified;
  bool? employerIsVerified;
  String? nickname;
  String? phoneNumber;
  String? fullName;
  String? username;
  String? avatar;
  String? qrCode;
  String? uuid;
  String? defaultCurrency;
  String? accountType;
  String? type;
  String? conversationId;
  double? rating;
  String? bio;
  bool? isVerified;
  String? chatWallpaper;
  String? wallpaper;
  DateTime? dateJoined;
  int? followers;
  int? following;

  Staff({
    this.employerUsername,
    this.userUsername,
    this.userAvatar,
    this.employerAvatar,
    this.employer,
    this.user,
    this.status,
    this.role,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.userFullName,
    this.employerFullName,
    this.userIsVerified,
    this.employerIsVerified,
    this.nickname,
    this.phoneNumber,
    this.fullName,
    this.username,
    this.avatar,
    this.qrCode,
    this.uuid,
    this.defaultCurrency,
    this.accountType,
    this.type,
    this.conversationId,
    this.rating,
    this.bio,
    this.isVerified,
    this.chatWallpaper,
    this.wallpaper,
    this.dateJoined,
    this.followers,
    this.following,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        employerUsername: json["employer_username"],
        userUsername: json["user_username"],
        userAvatar: json["user_avatar"],
        employerAvatar: json["employer_avatar"],
        employer: json["employer"],
        user: json["user"],
        status: json["status"],
        role: json["role"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["id"],
        userFullName: json["user_full_name"],
        employerFullName: json["employer_full_name"],
        userIsVerified: json["user_is_verified"],
        employerIsVerified: json["employer_is_verified"],
        nickname: json["nickname"],
        phoneNumber: json["phone_number"],
        fullName: json["full_name"],
        username: json["username"],
        avatar: json["avatar"],
        qrCode: json["qr_code"],
        uuid: json["uuid"],
        defaultCurrency: json["default_currency"],
        accountType: json["account_type"],
        type: json["type"],
        conversationId: json["conversation_id"],
        rating: json["rating"],
        bio: json["bio"],
        isVerified: json["is_verified"],
        chatWallpaper: json["chat_wallpaper"],
        wallpaper: json["wallpaper"],
        dateJoined: json["date_joined"] == null
            ? null
            : DateTime.parse(json["date_joined"]),
        followers: json["followers"],
        following: json["following"],
      );

  Map<String, dynamic> toJson() => {
        "employer_username": employerUsername,
        "user_username": userUsername,
        "user_avatar": userAvatar,
        "employer_avatar": employerAvatar,
        "employer": employer,
        "user": user,
        "status": status,
        "role": role,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
        "user_full_name": userFullName,
        "employer_full_name": employerFullName,
        "user_is_verified": userIsVerified,
        "employer_is_verified": employerIsVerified,
        "nickname": nickname,
        "phone_number": phoneNumber,
        "full_name": fullName,
        "username": username,
        "avatar": avatar,
        "qr_code": qrCode,
        "uuid": uuid,
        "default_currency": defaultCurrency,
        "account_type": accountType,
        "type": type,
        "conversation_id": conversationId,
        "rating": rating,
        "bio": bio,
        "is_verified": isVerified,
        "chat_wallpaper": chatWallpaper,
        "wallpaper": wallpaper,
        "date_joined": dateJoined?.toIso8601String(),
        "followers": followers,
        "following": following,
      };
}

class Permissions {
  String? payment;
  String? product;
  String? service;
  String? blog;
  String? yarn;
  String? moment;
  String? order;
  String? message;
  String? staff;
  String? paymentRequest;
  String? invoice;
  String? contract;
  String? profile;

  Permissions({
    this.payment,
    this.product,
    this.service,
    this.blog,
    this.yarn,
    this.moment,
    this.order,
    this.message,
    this.staff,
    this.paymentRequest,
    this.invoice,
    this.contract,
    this.profile,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
        payment: json["payment"],
        product: json["product"],
        service: json["service"],
        blog: json["blog"],
        yarn: json["yarn"],
        moment: json["moment"],
        order: json["order"],
        message: json["message"],
        staff: json["staff"],
        paymentRequest: json["payment-request"],
        invoice: json["invoice"],
        contract: json["contract"],
        profile: json["profile"],
      );

  Map<String, dynamic> toJson() => {
        "payment": payment,
        "product": product,
        "service": service,
        "blog": blog,
        "yarn": yarn,
        "moment": moment,
        "order": order,
        "message": message,
        "staff": staff,
        "payment-request": paymentRequest,
        "invoice": invoice,
        "contract": contract,
        "profile": profile,
      };

  PermissionType? getPermissionLevel(String? permission) {
    switch (permission) {
      case ProtectionPermissionType.read:
        return PermissionType.READ;
      case ProtectionPermissionType.write:
        return PermissionType.WRITE;
      default:
        return null;
    }
  }

  PermissionType? hasWritePermissionForStaff(String permissionName) {
    switch (permissionName) {
      case ProtectionPermission.yarn:
        return getPermissionLevel(yarn);
      // return (yarn == ProtectionPermissionType.write) ? true : false;
      case ProtectionPermission.moment:
        return getPermissionLevel(moment);
      case ProtectionPermission.product:
        return getPermissionLevel(product);
      case ProtectionPermission.services:
        return getPermissionLevel(service);
      case ProtectionPermission.inbox:
        return getPermissionLevel(message);
      case ProtectionPermission.blog:
        return getPermissionLevel(blog);
      case ProtectionPermission.invoice:
        return getPermissionLevel(invoice);
      case ProtectionPermission.contract:
        return getPermissionLevel(contract);
      case ProtectionPermission.channel:
        return getPermissionLevel(message);
      case ProtectionPermission.group:
        return getPermissionLevel(message);
      case ProtectionPermission.transaction:
        return getPermissionLevel(payment);
      case ProtectionPermission.sendMoney:
        return getPermissionLevel(payment);
      case ProtectionPermission.requestMoney:
        return getPermissionLevel(paymentRequest);
      case ProtectionPermission.paymentLinks:
        return getPermissionLevel(payment);
      case ProtectionPermission.wallet:
        return getPermissionLevel(payment);
      case ProtectionPermission.creditCard:
        return getPermissionLevel(payment);
      case ProtectionPermission.utility:
        return getPermissionLevel(payment);
      case ProtectionPermission.chat:
        return getPermissionLevel(message);
      case ProtectionPermission.order:
        return getPermissionLevel(order);
      case ProtectionPermission.superStore:
        return getPermissionLevel(product);
      case ProtectionPermission.servicesHub:
        return getPermissionLevel(service);
      case ProtectionPermission.send:
        return getPermissionLevel(payment);
      case ProtectionPermission.request:
        return getPermissionLevel(paymentRequest);
      case ProtectionPermission.profile:
        return getPermissionLevel(profile);
    }
    return null;
  }
}

class ShippingAddress {
  String? id;
  String? addressLineOne;
  String? addressLineTwo;
  String? city;
  UserState? userState;
  String? country;
  String? countryIsoCode;
  String? shippingNote;
  String? postCode;
  String? stateName;
  String? created_at;
  String? updated_at;
  String? email;
  bool is_residential = false;
  String? first_name;
  String? last_name;
  String? line_1;
  String? line_2;
  String? phone;
  String? zip;
  bool? is_default;
  String? name;
  double? latitude;
  double? longitude;

  ShippingAddress({
    this.id,
    this.addressLineOne,
    this.addressLineTwo,
    this.city,
    this.stateName,
    this.postCode,
    this.userState,
    this.country,
    this.shippingNote,
    this.countryIsoCode,
    this.created_at,
    this.updated_at,
    this.email,
    this.is_residential = false,
    this.first_name,
    this.last_name,
    this.line_1,
    this.line_2,
    this.phone,
    this.zip,
    this.is_default,
    this.name,
    this.latitude,
    this.longitude,
  });

  ShippingAddress.fromJson(var object) {
    id = object['id'] ?? "";
    addressLineOne = object['address_line_1'] ?? "";
    addressLineTwo = object['address_line_2'] ?? "";
    city = object['city'] ?? "";
    userState = object['state'] != null
        ? object['state'].runtimeType == String
            ? null
            : UserState.fromJson(object['state'])
        : null;
    country = object['country'] ?? "";
    countryIsoCode = object['country_iso_code'] ?? "NG";
    postCode = object['post_code'];
    stateName = object['state'];
    created_at = object['created_at'];
    updated_at = object['updated_at'];
    email = object['email'];
    is_residential = object['is_residential'];
    first_name = object['first_name'];
    last_name = object['last_name'];
    line_1 = object['line1'];
    line_2 = object['line2'];
    phone = object['phone'];
    zip = object['zip'];
    is_default = object['is_default'];
    id = object['id'];
    name = object["name"];
    latitude = object["latitude"]?.toDouble();
    longitude = object["longitude"]?.toDouble();

    // location: json["location"],
    // metadata: json["metadata"] == null
    // ? null
    //     : Metadata.fromJson(json["metadata"]),
    // providerId: json["provider_id"],
    // providerCreatedAt: json["provider_created_at"] == null
    // ? null
    //     : DateTime.parse(json["provider_created_at"]),
    // providerUpdatedAt: json["provider_updated_at"] == null
    // ? null
    //     : DateTime.parse(json["provider_updated_at"]),
    // anonymous: json["anonymous"],
    // isDefault: json["is_default"],
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': userState,
      'country': country,
      'shipping_note': shippingNote,
      'address_line_1': addressLineOne,
      'address_line_2': addressLineTwo,
      'country_iso_code': countryIsoCode,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  String toAddressString() {
    return "$line_1, $city, $stateName, $country";
  }

  String toFullAddress() {
    return "$line_1, $line_2, $city, $stateName, $country, $zip";
  }

  Map<String, dynamic> toAddUpdate() {
    return {
      'city': city,
      'state': stateName,
      'country': country,
      'line1': line_1,
      'line2': line_2,
      "is_residential": is_residential,
      "email": email,
      "phone": phone,
      "zip": zip,
      "first_name": first_name,
      "last_name": last_name,
      "name": name
    };
  }

  ShippingAddress copyWith({
    String? addressLineOne,
    dynamic id,
    String? addressLineTwo,
    String? city,
    String? country,
    String? postCode,
    String? stateName,
    String? email,
    bool? is_residential,
    String? first_name,
    String? last_name,
    String? line_1,
    String? line_2,
    String? phone,
    String? zip,
    bool? is_default,
    String? name,
    double? latitude,
    double? longitude,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      line_1: line_1 ?? this.line_1,
      line_2: line_2 ?? this.line_2,
      city: city ?? this.city,
      country: country ?? this.country,
      postCode: postCode ?? this.postCode,
      stateName: stateName ?? this.stateName,
      email: email ?? this.email,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      phone: phone ?? this.phone,
      zip: zip ?? this.zip,
      name: name ?? this.name,
      is_residential: is_residential ?? this.is_residential,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class CustomerProfile {
  String? fullName;
  String? userName;
  String? avatar = "";
  String? qrCode;
  String? nickName;
  String? type;
  String? wallpaper;
  String? conversationId;
  String uuid;
  String? bio;
  int? followers;
  int? following;
  String? chatWallpaper;
  String defaultCurrency;
  bool? isVerified;
  UserAbout? userAbout;
  UserStatus status;
  double rating;
  bool? isFollowing;
  String? dateJoined;
  ProfileMenu? profileMenu;
  Wallet? wallet;

  // Pass in as named parameter in constructor
  CustomerProfile(
      {this.following = 0,
      this.followers = 0,
      this.fullName = "",
      this.bio = "",
      this.wallpaper = "",
      this.chatWallpaper = "",
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
      this.dateJoined = '',
      this.isFollowing = false,
      this.status = UserStatus.UNKNOWN,
      this.rating = 0.0});

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    final CustomerProfile profile = CustomerProfile(
        fullName: json['full_name'] ?? json['name'] ?? "",
        userName: json['username'] ?? "",
        bio: json['bio'] ?? "",
        dateJoined: json['date_joined'] ?? "",
        isFollowing: json['is_following'] ?? false,
        chatWallpaper: json['chat_wallpaper'] ?? "",
        avatar: json['avatar'] ?? "",
        qrCode: json['qr_code'] ?? "",
        following: json['following'] ?? 0,
        followers: json['followers'] ?? 0,
        nickName: json['nickname'] ?? json['name'] ?? "",
        type: json['type'] ?? json['account_type'] ?? "user",
        conversationId: json['conversation_id'] ?? "",
        status: UserStatus.UNKNOWN,
        rating: json['rating'] ?? 0.0);
    if (json['profile'] != null) {
      profile.userAbout = UserAbout.fromJson(json['profile']);
    }
    if (json['type'] == 'User') {
      profile.wallpaper = json['wallpaper'];
    } else if (json['type'] != null && json['profile'] != null) {
      profile.wallpaper = profile.userAbout!.wallpaper;
    }

    if (json['default_currency'] != null) {
      profile.defaultCurrency = json['default_currency'] ?? "NGN";
    }
    if (json['is_verified'] != null) {
      profile.isVerified = json['is_verified'] ?? false;
    }
    if (json['uuid'] != null) {
      profile.uuid = json['uuid'] ?? "";
    }

    if (json['profile_menu'] != null) {
      profile.profileMenu = ProfileMenu.fromJson(json['profile_menu']);
    }
    if (json['wallet'] != null) {
      profile.wallet = Wallet.fromJson(json['wallet']);
    }

    return profile;
  }

  factory CustomerProfile.fromDBJson(Map<String, dynamic> json) {
    final CustomerProfile profile = CustomerProfile(
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
    final CustomerProfile profile = CustomerProfile(
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
    final CustomerProfile profile = CustomerProfile(
      fullName: participant.fullName,
      userName: participant.userName,
      avatar: participant.avatar,
      type: participant.type,
    );
    return profile;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // print('User type::: ${data['type']}');

    data['full_name'] = fullName;
    data['username'] = userName;
    data['nickname'] = nickName;
    data['avatar'] = avatar;
    data['qr_code'] = qrCode;
    data['type'] = type;
    data['bio'] = bio;
    if (data['type'] == "User") {
      data['wallpaper'] = wallpaper;
    } else if (data['type'] != null) {
      data['wallpaper'] = userAbout?.wallpaper;
    }
    data['conversation_id'] = conversationId;
    data['status'] = status.name;
    data['uuid'] = uuid;
    data['default_currency'] = defaultCurrency;
    data['is_verified'] = isVerified;
    // if (data['profile'] != null) {
    //   data['profile'] = this.userAbout!.toJson();
    // }
    // data['profile'] = this.userAbout!.toJson();
    if (profileMenu != null) {
      data['profile_menu'] = profileMenu!.toJson();
    }
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toJsonForDB() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['username'] = userName;
    data['avatar'] = avatar;
    data['nickname'] = nickName;
    data['qr_code'] = qrCode;
    data['type'] = type;
    data['conversation_id'] = conversationId;
    data['rating'] = rating;

    return data;
  }

  Map<String, dynamic> toJsonToSendInToChat() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['username'] = userName;
    data['avatar'] = avatar;
    data['qr_code'] = qrCode;
    data['type'] = type;
    return data;
  }

  String? displayName() {
    if (nickName != "" && nickName != null) {
      if (type != null &&
          type != "" &&
          type != "Business" &&
          type != "Developer") {
        return messageDecoderWithEmoji(nickName);
      }
    }

    if (fullName != null && fullName != "") {
      return messageDecoderWithEmoji(fullName);
    }
    return messageDecoderWithEmoji(userName);
  }
}

class ProfileMenu {
  String? id;
  bool? product;
  bool? service;
  bool? blog;
  bool? yarn;
  bool? moment;
  bool? channels;
  bool? reviews;
  bool? openingHours;
  List<String>? ordering;
  String? productLabel;
  String? serviceLabel;
  String? createdAt;
  String? updatedAt;

  ProfileMenu(
      {this.id,
      this.product,
      this.service,
      this.blog,
      this.yarn,
      this.moment,
      this.channels,
      this.reviews,
      this.openingHours,
      this.ordering,
      this.productLabel,
      this.serviceLabel,
      this.createdAt,
      this.updatedAt});

  ProfileMenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product = json['product'];
    service = json['service'];
    blog = json['blog'];
    yarn = json['yarn'];
    moment = json['moment'];
    channels = json['channels'];
    reviews = json['reviews'];
    openingHours = json['opening_hours'];
    ordering = json['ordering'].cast<String>();
    productLabel = json['product_label'];
    serviceLabel = json['service_label'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product'] = product;
    data['service'] = service;
    data['blog'] = blog;
    data['yarn'] = yarn;
    data['moment'] = moment;
    data['channels'] = channels;
    data['reviews'] = reviews;
    data['opening_hours'] = openingHours;
    data['ordering'] = ordering;
    data['product_label'] = productLabel;
    data['service_label'] = serviceLabel;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Wallet {
  String? accountNumber;
  FinancialInstitution? financialInstitution;
  AccountTier? accountTier;
  String? accountName;
  String? customerUsername;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? note;

  Wallet(
      {this.accountNumber,
      this.financialInstitution,
      this.accountTier,
      this.accountName,
      this.customerUsername,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.note});

  Wallet.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    financialInstitution = json['financial_institution'] != null
        ? FinancialInstitution.fromJson(json['financial_institution'])
        : null;
    accountTier = json['account_tier'] != null
        ? AccountTier.fromJson(json['account_tier'])
        : null;
    accountName = json['account_name'];
    customerUsername = json['customer_username'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_number'] = accountNumber;
    if (financialInstitution != null) {
      data['financial_institution'] = financialInstitution!.toJson();
    }
    if (accountTier != null) {
      data['account_tier'] = accountTier!.toJson();
    }
    data['account_name'] = accountName;
    data['customer_username'] = customerUsername;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['note'] = note;
    return data;
  }
}

// class FinancialInstitution {
// String? name;
// String? country;
// String? logo;
//
// FinancialInstitution({this.name, this.country, this.logo});
//
// FinancialInstitution.fromJson(Map<String, dynamic> json) {
// name = json['name'];
// country = json['country'];
// logo = json['logo'];
// }
//
// Map<String, dynamic> toJson() {
// final Map<String, dynamic> data = <String, dynamic>{};
// data['name'] = name;
// data['country'] = country;
// data['logo'] = logo;
// return data;
// }
// }

class AccountTier {
  String? tierType;
  String? dailyCumulativeTransactionLimit;
  String? cumulativeBalance;

  AccountTier(
      {this.tierType,
      this.dailyCumulativeTransactionLimit,
      this.cumulativeBalance});

  AccountTier.fromJson(Map<String, dynamic> json) {
    tierType = json['tier_type'];
    dailyCumulativeTransactionLimit =
        json['daily_cumulative_transaction_limit'];
    cumulativeBalance = json['cumulative_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tier_type'] = tierType;
    data['daily_cumulative_transaction_limit'] =
        dailyCumulativeTransactionLimit;
    data['cumulative_balance'] = cumulativeBalance;
    return data;
  }
}

class UserLocation {
  final double? latitude;
  final double? longitude;

  UserLocation({this.latitude, this.longitude});
}

class UserFollowers {
  String? userName;
  String? avatar;
  bool? isVerified;
  String? fullName;
  String? accountType;

  UserFollowers({
    this.userName,
    this.avatar,
    this.isVerified,
    this.fullName,
    this.accountType,
  });

  UserFollowers.fromJson(dynamic json) {
    userName = json['username'];
    avatar = json['avatar'];
    isVerified = json['is_verified'];
    fullName = json['full_name'];
    accountType = json['account_type'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = userName;
    map['avatar'] = avatar;
    map['is_verified'] = isVerified;
    map['full_name'] = fullName;
    map['account_type'] = accountType;
    return map;
  }
}
