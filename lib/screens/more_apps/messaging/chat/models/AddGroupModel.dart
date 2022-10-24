import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class AddGroupModel {
  bool? makePublic;
  String? name;
  double? channelFee;
  String? groupProfilePhoto;
  String? description;
  List<CustomerProfile>? users;
  int? maxAllowedMembers;
  int? ageRestriction;
  String? groupConversationId;
  String? avatar;

  AddGroupModel(
      {this.groupConversationId,
      this.ageRestriction = 18,
      this.makePublic = false,
      this.channelFee = 0,
      this.maxAllowedMembers,
      this.name,
      this.groupProfilePhoto,
      this.users,
      this.description,
        this.avatar,
      });
}
