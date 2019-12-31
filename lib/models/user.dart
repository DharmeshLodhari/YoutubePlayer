
class User {
  String uuid;
  String url;
  String phoneNumber;
  String fullName;
  String userName;
  String avatar;
  String qrCode;
  String password;

  // Pass in as named parameter in constructor
  User({this.uuid, this.url, this.phoneNumber, this.fullName, this.userName,
    this.avatar, this.qrCode, this.password});

  bool isAuthenticated(){
    //  We should check here if instance has username then user is not Anonymous
    return userName != null ? true: false;
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

  // Pass in as named parameter in constructor
  Payee({this.uuid, this.url, this.fullName, this.userName, this.avatar,
    this.qrCode,});

}
