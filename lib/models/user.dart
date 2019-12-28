
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
