
class User {
  final String uuid;
  String url = '';
  String phoneNumber = '';
  String fullName = '';
  String userName = '';
  String avatar = '';
  String qrCode = '';

  // Pass in as named parameter in constructor
  User({this.uuid, this.url, this.phoneNumber, this.fullName, this.userName, this.avatar, this.qrCode,});

  bool isAuthenticated(){
    //  We should check here if instance has username then user is not Anonymous
    return userName != null ? true: false;
  }
}




class Payee {
  //a person to whom money is paid or is to be paid, especially the person to whom a cheque is made payable.
  final String uuid;
  String url = '';
  String fullName = '';
  String userName = '';
  String avatar = '';
  String qrCode = '';

  // Pass in as named parameter in constructor
  Payee({this.uuid, this.url, this.fullName, this.userName, this.avatar, this.qrCode,});

}
