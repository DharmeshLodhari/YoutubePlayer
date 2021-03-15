class SecureUser {
  String password;
  String phoneNumber;

  SecureUser({this.password, this.phoneNumber});

  factory SecureUser.fromJson(Map<String, dynamic> json) {
    return SecureUser(
      password: json['password'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['password'] = this.password;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
