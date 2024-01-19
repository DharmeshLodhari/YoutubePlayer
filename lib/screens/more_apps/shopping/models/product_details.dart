/// id : "5e67fca0-143d-4c86-a969-4a6163f2f159"
/// url : "/api/v1/products/add-by-token/5e67fca0-143d-4c86-a969-4a6163f2f159/create-product/"
/// expiry_date : "2024-01-17 19:38:12.016863+00:00"
/// merchant : "blackstriker"
/// meta_data : {"uuid":"b9f89ac0-4166-46c3-80ce-a5667485fef2","avatar":"http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg","qr_code":"http://cdn.slydo.co.global.prod.fastly.net/media/customer/qr-code/bd0f11db-1214-45f1-9a2c-ee482200ddd0.png","nickname":"Black Striker Enterprise","username":"blackstriker","full_name":"Black Striker Enterprise","account_type":"Developer","phone_number":"+919998333150","default_currency":"NGN"}
/// created_at : "2024-01-17T14:38:12.016863+01:00"

class ProductDetails {
  ProductDetails({
    this.id,
    this.url,
    this.expiryDate,
    this.merchant,
    this.metaData,
    this.createdAt,
  });

  ProductDetails.fromJson(dynamic json) {
    id = json['id'];
    url = json['url'];
    expiryDate = json['expiry_date'];
    merchant = json['merchant'];
    metaData =
        json['meta_data'] != null ? MetaData.fromJson(json['meta_data']) : null;
    createdAt = json['created_at'];
  }
  String? id;
  String? url;
  String? expiryDate;
  String? merchant;
  MetaData? metaData;
  String? createdAt;
  ProductDetails copyWith({
    String? id,
    String? url,
    String? expiryDate,
    String? merchant,
    MetaData? metaData,
    String? createdAt,
  }) =>
      ProductDetails(
        id: id ?? this.id,
        url: url ?? this.url,
        expiryDate: expiryDate ?? this.expiryDate,
        merchant: merchant ?? this.merchant,
        metaData: metaData ?? this.metaData,
        createdAt: createdAt ?? this.createdAt,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['url'] = url;
    map['expiry_date'] = expiryDate;
    map['merchant'] = merchant;
    if (metaData != null) {
      map['meta_data'] = metaData?.toJson();
    }
    map['created_at'] = createdAt;
    return map;
  }
}

/// uuid : "b9f89ac0-4166-46c3-80ce-a5667485fef2"
/// avatar : "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg"
/// qr_code : "http://cdn.slydo.co.global.prod.fastly.net/media/customer/qr-code/bd0f11db-1214-45f1-9a2c-ee482200ddd0.png"
/// nickname : "Black Striker Enterprise"
/// username : "blackstriker"
/// full_name : "Black Striker Enterprise"
/// account_type : "Developer"
/// phone_number : "+919998333150"
/// default_currency : "NGN"

class MetaData {
  MetaData({
    this.uuid,
    this.avatar,
    this.qrCode,
    this.nickname,
    this.username,
    this.fullName,
    this.accountType,
    this.phoneNumber,
    this.defaultCurrency,
  });

  MetaData.fromJson(dynamic json) {
    uuid = json['uuid'];
    avatar = json['avatar'];
    qrCode = json['qr_code'];
    nickname = json['nickname'];
    username = json['username'];
    fullName = json['full_name'];
    accountType = json['account_type'];
    phoneNumber = json['phone_number'];
    defaultCurrency = json['default_currency'];
  }
  String? uuid;
  String? avatar;
  String? qrCode;
  String? nickname;
  String? username;
  String? fullName;
  String? accountType;
  String? phoneNumber;
  String? defaultCurrency;
  MetaData copyWith({
    String? uuid,
    String? avatar,
    String? qrCode,
    String? nickname,
    String? username,
    String? fullName,
    String? accountType,
    String? phoneNumber,
    String? defaultCurrency,
  }) =>
      MetaData(
        uuid: uuid ?? this.uuid,
        avatar: avatar ?? this.avatar,
        qrCode: qrCode ?? this.qrCode,
        nickname: nickname ?? this.nickname,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        accountType: accountType ?? this.accountType,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uuid'] = uuid;
    map['avatar'] = avatar;
    map['qr_code'] = qrCode;
    map['nickname'] = nickname;
    map['username'] = username;
    map['full_name'] = fullName;
    map['account_type'] = accountType;
    map['phone_number'] = phoneNumber;
    map['default_currency'] = defaultCurrency;
    return map;
  }
}
