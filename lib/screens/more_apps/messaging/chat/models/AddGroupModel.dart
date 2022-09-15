import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class AddGroupModel {
  bool? makePublic;
  String? groupName;
  double? channelFee;
  String? groupProfilePhoto;
  String? groupDescription;
  List<CustomerProfile>? users;
  int? maxAllowedMembers;
  int? ageRestriction;

  AddGroupModel(
      {this.ageRestriction = 18,
      this.makePublic = false,
      this.channelFee = 0,
      this.maxAllowedMembers,
      this.groupName,
      this.groupProfilePhoto,
      this.users,
      this.groupDescription});
}
