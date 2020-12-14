class User {
  String type;
  String avatar;
  String currency;
  String fullName;
  bool isVerified;
  String password;
  String phoneNumber;
  String qrCode;
  String url;
  String userName;
  String uuid;

  User(
      {this.type,
      this.avatar,
      this.currency,
      this.fullName,
      this.isVerified,
      this.password,
      this.phoneNumber,
      this.qrCode,
      this.url,
      this.userName,
      this.uuid});

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
}
