import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/AddGroupModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SetNameAndProfileOfGroup extends StatefulWidget {
  final arguments;

  SetNameAndProfileOfGroup({this.arguments});

  @override
  _SetNameAndProfileOfGroupState createState() =>
      _SetNameAndProfileOfGroupState();
}

class _SetNameAndProfileOfGroupState extends State<SetNameAndProfileOfGroup> {
  final GlobalKey<ScaffoldState> _scaffoldSetNameAndProfileKey =
      new GlobalKey<ScaffoldState>();

  List<CustomerProfile> selectedConnectionList = [];

  TextEditingController? groupNameController;
  TextEditingController? groupDescriptionController;

  AddGroupModel groupModel = AddGroupModel();

  @protected
  void initState() {
    groupNameController = TextEditingController();
    groupDescriptionController = TextEditingController();

    fetchConnectionList();

    super.initState();
  }

  void fetchConnectionList() async {
    selectedConnectionList = widget.arguments["users"] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldSetNameAndProfileKey,
      backgroundColor: Colors.white,
      appBar: getAppBar() as PreferredSizeWidget?,
      body: getScaffoldBody(),
      floatingActionButton: getFloatingActionBtn(),
    );
  }

  Widget? getFloatingActionBtn() {
    return groupNameController!.text.isEmpty
        ? null
        : FloatingActionButton(
            backgroundColor: navyBlue,
            onPressed: createGroup,
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
        "New Group",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }

  Widget getScaffoldBody() {
    return Container(
      child: Column(
        children: [
          getGroupNameAndProfile(),
          getGroupDescription(),
          Expanded(child: _buildConnectionsList()),
        ],
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
                child: TextField(
              controller: groupNameController,
              cursorColor: blackFont,
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w700, fontSize: 16),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: "Type group name here",
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: darkGrey),
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
        child: groupModel.groupProfilePhoto == null
            ? Container(
                height: 64,
                width: 64,
                color: chatBackgroundColor,
                child: Icon(
                  SlydoAppIcon.add_image,
                  color: darkGrey,
                  size: 18,
                ),
              )
            : Container(
                height: 64,
                width: 64,
                child: Image.file(
                  File(groupModel.groupProfilePhoto!),
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
        String? croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return;
        }

        groupModel.groupProfilePhoto = croppedImage;
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

  Widget getUserTile({CustomerProfile? user}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: UserTile(user: user),
    );
  }

  void createGroup() async {
    groupModel.users = selectedConnectionList;
    groupModel.groupName = groupNameController!.text.trim();
    groupModel.groupDescription = groupDescriptionController!.text.trim();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    await MessageAuth().createGroupChat(group: groupModel).then((value) async {
      Navigator.pop(context);
      ChatUserModel chatUserModel = ChatUserModel.fromChatConversation(value);
      ChatUserManager().addUser(conversationId: chatUserModel.conversationId);
      if (mounted) setState(() {});

      ConnectionListBloc connectionListBloc =
          Provider.of<ConnectionListBloc>(context, listen: false);
      connectionListBloc.addConnectionUser(chatConversation: value);

      Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
    }).catchError((error) {
      debugPrint("ERROR While creating Group :- $error");
      showToast(message: "$error");
    });
  }
}
