import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/UpdateGroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/user_tile_for_group_detail.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

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

  TextEditingController groupNameController;
  TextEditingController groupDescriptionController;

  GroupDetailModel groupDetail;

  UpdateGroupDetailModel groupModel;

  @protected
  void initState() {
    groupNameController = TextEditingController();
    groupDescriptionController = TextEditingController();

    getGroupDetail();

    groupNameController.text = groupDetail.fullName;
    groupDescriptionController.text = groupDetail.description;

    super.initState();
  }

  void getGroupDetail() {
    groupDetail = widget.arguments["groupDetail"];
    groupModel =
        UpdateGroupDetailModel(groupConversationId: groupDetail.conversationId);
    fetchConnectionList();
  }

  void fetchConnectionList() async {
    selectedConnectionList = groupDetail.participants
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
      appBar: getAppBar(),
      body: getScaffoldBody(),
      floatingActionButton: getFloatingActionBtn(),
    );
  }

  Widget getFloatingActionBtn() {
    return FloatingActionButton(
      backgroundColor: navyBlue,
      onPressed: updateGroup,
      child: Icon(
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
        "Edit Group",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }

  Widget getScaffoldBody() {
    return Form(
      key: _formFieldKey,
      child: Container(
        child: Column(
          children: [
            getGroupNameAndProfile(),
            getGroupDescription(),
            Expanded(child: _buildConnectionsList()),
          ],
        ),
      ),
    );
  }

  Widget getGroupDescription() {
    return Container(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
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
        padding: EdgeInsets.only(right: 16, left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                getGroupProfile()
              ],
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: TextFormField(
              controller: groupNameController,
              cursorColor: blackFont,
              validator: (value) {
                if (value.isNotEmpty) return null;
                return "Please Enter group name";
              },
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w700, fontSize: 16),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: "Type group name here",
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
        pickGroupProfile();
      },
      child: ClipOval(
        child: groupModel.avatar == null
            ? Container(
                height: 64,
                width: 64,
                color: chatBackgroundColor,
                child: CachedNetworkImage(
                  imageUrl: groupDetail.avatar == null ||
                          groupDetail.avatar == ""
                      ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                      : groupDetail.avatar,
                  fit: BoxFit.fill,
                ),
              )
            : Container(
                height: 64,
                width: 64,
                child: Image.file(
                  File(groupModel.avatar),
                  fit: BoxFit.fill,
                ),
              ),
      ),
    );
  }

  void pickGroupProfile() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context).selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context).camera,
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
          await ImagePicker().getImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        /// for cropping the image
        String croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        groupModel.avatar = croppedImage;
        if (mounted) setState(() {});
      }
    }
  }

  Widget _buildConnectionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Members (${selectedConnectionList.length})",
            style: TextStyle(
                color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 4,
            ),
            //+1 for progressbar
            itemCount: selectedConnectionList.length,
            itemBuilder: (BuildContext context, int index) {
              return getUserTile(user: selectedConnectionList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget getUserTile({CustomerProfile user}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: UserTileForGroupDetail(
        user: user,
        groupDetail: groupDetail,
      ),
    );
  }

  void updateGroup() {
    if (_formFieldKey.currentState.validate()) {
      groupModel.name = groupNameController.text.trim();
      groupModel.description = groupDescriptionController.text.trim();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularLoadingIndicator(),
              ));

      MessageAuth().updateGroupChat(group: groupModel).then((value) {
        Navigator.pop(context);
        if (value != null) {
          Toast.show(
            "Group detail updated successfully !!",
            context,
            duration: Toast.LENGTH_LONG,
            textColor: Colors.white,
          );
          debugPrint("Group detail updated successfully !!");
          Map<String, dynamic> data = value;

          groupDetail.avatar = data["banner"];
          groupDetail.fullName = data["group_name"];
          groupDetail.username = data["group_name"];
          groupDetail.description = data["description"];

          Navigator.pop(context, groupDetail);
        }
      }).catchError((error) {
        debugPrint("ERROR While Updating Group :- $error");
        Toast.show(
          "$error",
          context,
          duration: Toast.LENGTH_LONG,
          textColor: Colors.white,
        );
      });
    }
  }
}
