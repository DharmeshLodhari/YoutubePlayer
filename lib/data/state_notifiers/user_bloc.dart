import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_message_settings.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier {
  // This block notify the change in user status and pass it round the app.
  User _user = User(
      rider: null,
      uuid: null,
      url: null,
      phoneNumber: null,
      fullName: null,
      userName: null,
      avatar: null,
      qrCode: null,
      password: null,
      currency: null);

  ChatMessageSettings _chatMessageSettings = ChatMessageSettings();

  ChatMessageSettings get chatMessageSettings => _chatMessageSettings;

  set chatMessageSettings(ChatMessageSettings val) {
    _chatMessageSettings = val;
    notifyListeners();
  }

  bool get isStaffLogin => _isStaffLogin;
  bool _isStaffLogin = false;

  set isStaffLogin(bool isStaffLogin) {
    _isStaffLogin = isStaffLogin;
    notifyListeners();
  }

  // Getter
  User get user => _user;

  // Setter
  set user(User val) {
    _user = val;
    notifyListeners();
  }

  set userAbout(UserAbout? userAbout) {
    _user.userAbout = userAbout;
    notifyListeners();
  }

  set updateNickName(String nickName) {
    _user.nickName = nickName;
    notifyListeners();
  }

  void updateProfileAvatar(String? url) {
    _user.avatar = url;
    notifyListeners();
  }

  void updateRider(RiderModel rider) {
    _user.rider = rider;
    notifyListeners();
  }

  void removeProfileAvatar() {
    _user.avatar = defaultImage;
    notifyListeners();
  }

  void removeProfileCover() {
    _user.wallpaper = "";
    _user.userAbout!.wallpaper = "";
    notifyListeners();
  }

  UserAbout? get userAbout => _user.userAbout;
}
