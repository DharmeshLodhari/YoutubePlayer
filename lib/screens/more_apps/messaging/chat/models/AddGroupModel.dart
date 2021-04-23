import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class AddGroupModel {
  String groupName;
  String groupProfilePhoto;
  List<CustomerProfile> users;

  AddGroupModel({this.groupName, this.groupProfilePhoto, this.users});
}
