import 'dart:developer';
import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/add_group_model.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/group_detail_model.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/user_tile_for_group_detail.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

class UpdateGroupNameAndProfile extends StatefulWidget {
  final arguments;

  UpdateGroupNameAndProfile({this.arguments});

  @override
  _UpdateGroupNameAndProfileState createState() =>
      _UpdateGroupNameAndProfileState();
}

class _UpdateGroupNameAndProfileState extends State<UpdateGroupNameAndProfile> {
  final GlobalKey<ScaffoldState> _scaffoldUpdateGroupNameAndProfileKey =
      new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formFieldKey = new GlobalKey<FormState>();

  List<CustomerProfile> selectedConnectionList = [];

  TextEditingController? groupNameController;
  TextEditingController? groupDescriptionController;

  GroupDetailModel? groupDetail;

  late AddGroupModel groupModel;

  AppConfigurationModel? appConfigurationModel;

  String selectedAge = '18+';
  bool ageRestriction = false;
  bool? makeGroupPaid = false;
  bool? makeChannelPublic = false;
  bool? limitGroupMembers = false;
  final TextEditingController _channelFeeCtrl = TextEditingController();
  final TextEditingController _maxNoOfUsersCtrl =
      TextEditingController(text: '255');
  bool isAvatar = false;
  bool? isBanner = false;

  @protected
  void initState() {
    groupNameController = TextEditingController();
    groupDescriptionController = TextEditingController();

    getGroupDetail();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    groupNameController!.text =
        messageDecoderWithEmoji(groupDetail!.fullName!)!;
    groupDescriptionController!.text = groupDetail!.description!;
    if (groupDetail?.ageRestriction != null) {
      ageRestriction = true;
      selectedAge = "${groupDetail!.ageRestriction}+";
    }

    makeChannelPublic = groupDetail?.isPublicGroup ?? false;
    if (groupDetail?.groupSubscriptionFees != null) {
      makeGroupPaid = true;
      _channelFeeCtrl.text =
          groupDetail?.groupSubscriptionFees?.toString() ?? "0";
    }
    if (groupDetail?.maxAllowedUser != null) {
      limitGroupMembers = true;
      _maxNoOfUsersCtrl.text = groupDetail?.maxAllowedUser?.toString() ?? "";
    }

    super.initState();
  }

  void getGroupDetail() {
    groupDetail = widget.arguments["groupDetail"];
    groupModel =
        AddGroupModel(groupConversationId: groupDetail!.conversationId);
    fetchConnectionList();
  }

  void fetchConnectionList() async {
    selectedConnectionList = groupDetail!.participants
        .map((element) => CustomerProfile(
            userName: element.userName,
            avatar: element.avatar,
            type: element.type,
            fullName: element.fullName))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldUpdateGroupNameAndProfileKey,
      backgroundColor: Colors.white,
      appBar: getAppBar() as PreferredSizeWidget?,
      body: getScaffoldBody(),
      floatingActionButton: getFloatingActionBtn(),
    );
  }

  Widget getFloatingActionBtn() {
    return FloatingActionButton(
      backgroundColor: navyBlue,
      onPressed: updateGroup,
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 28,
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        groupDetail!.conversationType == "channel"
            ? "Edit Channel"
            : "Edit Group",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }

  Widget getScaffoldBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formFieldKey,
        child: Container(
          child: Column(
            children: [
              getProfileCover(),
              getGroupNameAndProfile(),
              getGroupDescription(),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    getMakePublicField(),
                    const SizedBox(height: 10),
                    getPaidGroupChatField(),
                    getLimitGroupMembersField(),
                    getAgeRestrictionField(),
                  ],
                ),
              ),
              _buildConnectionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getProfileCover() {
    return GestureDetector(
        onTap: () {
          pickWallpaper();
        },
        child: Container(height: 150, child: getProfileWallpaper()));
  }

  Widget getProfileWallpaper() {
    return isBanner == true
        ? Container(
            child: Image.file(
              File(groupModel.groupProfilePhoto!),
              fit: BoxFit.fill,
            ),
          )
        : CachedNetworkImage(
            imageUrl: groupDetail!.banner == null || groupDetail!.banner == ""
                ? defaultWallPaper
                : groupDetail!.banner!,
            fit: BoxFit.fill,
            errorWidget: imageErrorWidget,
          );
  }

  void pickWallpaper() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context)!.selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context)!.camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        final String? croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        groupModel.groupProfilePhoto = croppedImage;
        isBanner = true;
        if (mounted) setState(() {});
      }
    }
  }

  Widget getMakePublicField() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Make public',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        Switch(
          onChanged: (bool value) {
            setState(() {
              makeChannelPublic = value;
            });
          },
          activeColor: navyBlue,
          value: makeChannelPublic!,
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget getPaidGroupChatField() {
    return appConfigurationModel?.enablePayment == true &&
            appConfigurationModel?.enablePaidGroupChat == true
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create paid group chat',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Switch(
                    onChanged: (bool value) {
                      setState(() {
                        makeGroupPaid = value;
                      });
                    },
                    value: makeGroupPaid!,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              if (makeGroupPaid!) ...[
                const SizedBox(
                  height: 10,
                ),
                CustomizedTextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  controller: _channelFeeCtrl,
                  isAmountField: true,
                  labelText: AppLocalization.of(context)!.amount,
                  onChanged: (value) {},
                  validator: (val) {
                    try {
                      final double userAmount =
                          double.parse(val.replaceAll(',', ''));
                      // if (userAmount > amountLimit) {
                      //   return 'You cannot fund more than $amountLimit';
                      // }
                    } catch (e) {
                      return AppLocalization.of(context)!.invalidAmount;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create paid group chat',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Switch(
                    onChanged: (bool value) {
                      setState(() {
                        makeGroupPaid = value;
                      });
                    },
                    value: makeGroupPaid!,
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
              if (makeGroupPaid!) ...[
                const SizedBox(
                  height: 10,
                ),
                CustomizedTextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  controller: _maxNoOfUsersCtrl,
                  isAmountField: true,
                  labelText: AppLocalization.of(context)!.amount,
                  onChanged: (value) {},
                  validator: (val) {
                    try {
                      final double userAmount =
                          double.parse(val.replaceAll(',', ''));
                      if (userAmount > amountLimit) {
                        return 'You cannot fund more than $amountLimit';
                      }
                    } catch (e) {
                      return AppLocalization.of(context)!.invalidAmount;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget getLimitGroupMembersField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupDetail!.conversationType == "channel"
                        ? 'Limit channel members'
                        : 'Limit group members',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'By default, number of allowed members is 255',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              onChanged: (bool value) {
                setState(() {
                  limitGroupMembers = value;
                });
              },
              activeColor: navyBlue,
              value: limitGroupMembers!,
            ),
            const SizedBox(width: 10)
          ],
        ),
        if (limitGroupMembers!) ...[
          const SizedBox(height: 10),
          CustomizedTextFormField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            controller: _maxNoOfUsersCtrl,
            isAmountField: false,
            labelText: 'Max. number of users',
            onChanged: (value) {},
            validator: (val) {
              if (int.parse(val) < 3) {
                return "You can not create channels with less than 3 members";
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }

  Widget getAgeRestrictionField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Age restriction',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Set age of members that can join the group.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              onChanged: (bool value) {
                setState(() {
                  ageRestriction = value;
                });
              },
              activeColor: navyBlue,
              value: ageRestriction,
            ),
            const SizedBox(width: 10)
          ],
        ),
        if (ageRestriction) ...[
          const SizedBox(height: 10),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton2(
              isExpanded: true,
              value: selectedAge,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              hint: const Text('Select an age'),
              underline: const SizedBox.shrink(),
              items: ['13+', '15+', '18+', '21+'].map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedAge = value!;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget getGroupDescription() {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: CustomizedTextFormField(
        maxLines: 4,
        labelText: "Description",
        textCapitalization: TextCapitalization.sentences,
        controller: groupDescriptionController,
      ),
    );
  }

  Widget getGroupNameAndProfile() {
    return Container(
      child: Container(
        height: 80,
        padding: const EdgeInsets.only(right: 16, left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                getGroupProfile()
              ],
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: TextFormField(
              controller: groupNameController,
              cursorColor: blackFont,
              validator: (value) {
                if (value!.isNotEmpty) return null;
                return groupDetail!.conversationType == "channel"
                    ? "Please Enter channel name"
                    : "Please Enter group name";
              },
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w700, fontSize: 16),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: groupDetail!.conversationType == "channel"
                      ? "Type channel name here"
                      : "Type group name here",
                  helperStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: darkGrey),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: dividerColor))),
            ))
          ],
        ),
      ),
    );
  }

  Widget getGroupProfile() {
    return GestureDetector(
      onTap: () {
        pickGroupAvatar();
      },
      child: ClipOval(
          child: isAvatar == true
              ? Container(
                  height: 64,
                  width: 64,
                  child: Image.file(
                    File(groupModel.avatar!),
                    fit: BoxFit.fill,
                  ),
                )
              : groupModel.avatar != null || groupDetail!.avatar != ""
                  ? Container(
                      height: 64,
                      width: 64,
                      color: chatBackgroundColor,
                      child: CachedNetworkImage(
                        imageUrl: groupDetail!.avatar == null ||
                                groupDetail!.avatar == ""
                            ? defaultImage
                            : groupDetail!.avatar!,
                        fit: BoxFit.fill,
                        errorWidget: imageErrorWidget,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        pickGroupAvatar();
                      },
                      child: CircleAvatar(
                        backgroundColor: navyBlue,
                        radius: 30,
                        child: Text(
                          getInitials(groupDetail!.fullName!).toUpperCase(),
                          style: TextStyle(
                              color: white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    )),
    );
  }

  void pickGroupAvatar() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context)!.selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context)!.camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        final String? croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        groupModel.avatar = croppedImage;
        isAvatar = true;
        if (mounted) setState(() {});
      }
    }
  }

  Widget _buildConnectionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Members (${selectedConnectionList.length})",
            style: TextStyle(
                color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Column(
          children: selectedConnectionList.map((e) {
            return getUserTile(user: e);
          }).toList(),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget getUserTile({CustomerProfile? user}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: UserTileForGroupDetail(
        user: user,
        groupDetail: groupDetail,
      ),
    );
  }

  void updateGroup() {
    if (limitGroupMembers!) {
      if (int.parse(_maxNoOfUsersCtrl.text) > 255) {
        showToast(message: 'Max number of users is 255');
        return;
      } else if (int.parse(_maxNoOfUsersCtrl.text) < 3) {
        showToast(
            message: groupDetail!.conversationType == "channel"
                ? 'You can not create channel with less than 3 members'
                : 'You can not create group with less than 3 members');
        return;
      }
    }

    if (_formFieldKey.currentState!.validate()) {
      groupModel.name = groupNameController!.text.trim();
      groupModel.ageRestriction = int.parse(selectedAge.split('+')[0]);
      groupModel.description = groupDescriptionController!.text.trim();
      if (makeGroupPaid == true &&
          _channelFeeCtrl.text.replaceAll(' ', '').isNotEmpty) {
        groupModel.channelFee =
            double.parse(_channelFeeCtrl.text.replaceAll(',', ''));
      }

      groupModel.maxAllowedMembers =
          _maxNoOfUsersCtrl.text.replaceAll(' ', '').isEmpty
              ? 255
              : int.parse(_maxNoOfUsersCtrl.text);
      groupModel.makePublic = makeChannelPublic;
      if (makeGroupPaid == true &&
          _channelFeeCtrl.text.replaceAll(' ', '').isNotEmpty) {
        groupModel.channelFee =
            double.parse(_channelFeeCtrl.text.replaceAll(',', ''));
      }

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ));

      MessageAuth().updateGroupChat(group: groupModel).then((value) {
        Navigator.pop(context);
        if (value != null) {
          showToast(message: "Group detail updated successfully !!");

          log("Group detail updated successfully !! $value");
          final Map<String, dynamic> data = value;

          groupDetail!.avatar = data["avatar"];
          groupDetail!.banner = data["banner"];
          groupDetail!.fullName = data["group_name"];
          groupDetail!.username = data["group_name"];
          groupDetail!.description = data["description"];
          groupDetail!.isPublicGroup = data["is_public_group"];
          groupDetail!.groupSubscriptionCurrency =
              data["group_subscription_currency"];
          groupDetail!.ageRestriction = data["age_restriction"];
          groupDetail!.groupSubscriptionFees = data["group_subscription_fee"];
          groupDetail!.maxAllowedUser = data["group_max_allowed_users"];

          //   {group_name: SLYDO Team,
          //       description: The African Super App Builders,
          // banner: http://cdn.slydo.co.global.prod.fastly.net/media/image_cropper_1662539342752.jpg,
          // owner: gbemiglad,
          // group_subscription_currency: NGN,
          // is_public_group: true,
          // age_restriction: 21,
          // group_subscription_fee: 0,
          // group_max_allowed_users: 25}

          Navigator.pop(context, groupDetail);
        }
      }).catchError((error) {
        debugPrint("ERROR While Updating Group :- $error");
        showToast(message: "$error");
      });
    }
  }
}
