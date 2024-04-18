class SecureUser {
  String? password;
  String? phoneNumber;
  String? company;
  bool? isStaffLogin = false;

  SecureUser(
      {this.password, this.phoneNumber, this.company, this.isStaffLogin});

  factory SecureUser.fromJson(Map<String, dynamic> json) {
    return SecureUser(
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      company: json['company'],
      isStaffLogin: json['isStaffLogin'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['password'] = this.password;
    data['phoneNumber'] = this.phoneNumber;
    data['company'] = this.company;
    data['isStaffLogin'] = this.isStaffLogin;
    return data;
  }
}
