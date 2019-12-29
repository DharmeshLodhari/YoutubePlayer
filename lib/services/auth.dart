//import 'package:paybay/models/user.dart';
//
//
//class AuthService {
//
//  // This function creates a user object from named args passed in
//  User createUser( String uuid,  String url, String phoneNumber,
//      String fullName, String username,  String avatar, String qrCode){
//       User _user = User(uuid: uuid, url: url, phoneNumber: phoneNumber,
//           fullName: fullName, username: username, avatar: avatar,
//           qrCode: qrCode);
//       return _user;
//  }
//
//  // log user in if credentials are correct
//  Future authenticate(String phoneNumber, String password) async {
//    // make http connection here and
//    var url = 'http://example.com/whatsit/create';
//    var response = await http.post(url, body: {'phone_number': phoneNumber, 'password': password});
//    if (response.statusCode == 200) {
//      print("yes");
//
//    }
//    print('Response body: ${response.body}');
//
//    print(await http.read('http://example.com/foobar.txt'));
//
//
//
//
//
//
//
//
//    return null;//createUser(uuid, url, phoneNumber, fullName, username, avatar, qrCode)
//
//  }
//}
//
//
//
