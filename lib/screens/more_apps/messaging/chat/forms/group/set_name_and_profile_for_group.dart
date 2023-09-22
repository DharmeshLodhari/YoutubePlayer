import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/AddGroupModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../locator.dart';
import '../../../../../../services/app_config_bloc.dart';

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

  final TextEditingController _channelFeeCtrl = TextEditingController();
  final TextEditingController _maxNoOfUsersCtrl =
      TextEditingController(text: '255');

  String selectedAge = '18+';
  bool ageRestriction = false;
  bool? makeGroupPaid = false;
  bool? makeChannelPublic = false;
  bool? createPaidChannel = false;
  bool? limitGroupMembers = false;
  AppConfigurationModel? appConfigurationModel;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String createTitle = "";

  @protected
  void initState() {
    groupNameController = TextEditingController();
    groupDescriptionController = TextEditingController();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    createTitle = widget.arguments != null
        && widget.arguments["create"] == "group" ? "New Group"
        : "New Paid Channel";

    // appConfigurationModel?.enablePaidGroupChat = true;

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
      body: SingleChildScrollView(child: getScaffoldBody()),
      floatingActionButton: getFloatingActionBtn(),
    );
  }

  Widget? getFloatingActionBtn() {
    return groupNameController!.text.isEmpty
        ? null
        : FloatingActionButton(
            backgroundColor: navyBlue,
            onPressed: () => createGroup(onCallBack: () {
              NavigationUtil.pop(context);
            }),
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
        createTitle.isNotEmpty ? createTitle : "New Channel",
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            getGroupNameAndProfile(),
            getGroupDescription(),
            Container(
                height: (160 * selectedConnectionList.length).toDouble(),
                child: _buildConnectionsList()),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  getMakePublicField(),
                  SizedBox(height: 10),
                  getPaidGroupChatField(),
                  getLimitGroupMembersField(),
                  getAgeRestrictionField(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getMakePublicField() {
    return Row(
      children: [
        Expanded(
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
          value: makeChannelPublic!,
        ),
        SizedBox(
          width: 10,
        )
      ],
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

  Widget getPaidGroupChatField() {
    return widget.arguments != null
        && widget.arguments["create"] == "group" ? SizedBox.shrink()
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
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
            SizedBox(width: 10),
          ],
        ),
        if (makeGroupPaid!) ...[
          SizedBox(
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
                double userAmount = double.parse(val.replaceAll(',', ''));
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
        SizedBox(height: 10),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Text(
        //         'Create paid group chat',
        //         style:
        //             TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        //       ),
        //     ),
        //     Switch(
        //       onChanged: (bool value) {
        //         setState(() {
        //           makeGroupPaid = value;
        //         });
        //       },
        //       value: makeGroupPaid!,
        //     ),
        //     SizedBox(
        //       width: 10,
        //     )
        //   ],
        // ),
        // if (makeGroupPaid!) ...[
        //   SizedBox(
        //     height: 10,
        //   ),
        //   CustomizedTextFormField(
        //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        //     keyboardType: TextInputType.phone,
        //     controller: _maxNoOfUsersCtrl,
        //     isAmountField: true,
        //     labelText: AppLocalization.of(context)!.amount,
        //     onChanged: (value) {},
        //     validator: (val) {
        //       try {
        //         double userAmount = double.parse(val.replaceAll(',', ''));
        //         if (userAmount > amountLimit) {
        //           return 'You cannot fund more than $amountLimit';
        //         }
        //       } catch (e) {
        //         return AppLocalization.of(context)!.invalidAmount;
        //       }
        //       return null;
        //     },
        //   ),
        // ],
        // SizedBox(height: 10),
      ],
    );

    return appConfigurationModel?.enablePayment == true &&
            appConfigurationModel?.enablePaidGroupChat == true
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
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
                  SizedBox(width: 10),
                ],
              ),
              if (makeGroupPaid!) ...[
                SizedBox(
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
                      double userAmount = double.parse(val.replaceAll(',', ''));
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
              SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text(
              //         'Create paid group chat',
              //         style:
              //             TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              //       ),
              //     ),
              //     Switch(
              //       onChanged: (bool value) {
              //         setState(() {
              //           makeGroupPaid = value;
              //         });
              //       },
              //       value: makeGroupPaid!,
              //     ),
              //     SizedBox(
              //       width: 10,
              //     )
              //   ],
              // ),
              // if (makeGroupPaid!) ...[
              //   SizedBox(
              //     height: 10,
              //   ),
              //   CustomizedTextFormField(
              //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //     keyboardType: TextInputType.phone,
              //     controller: _maxNoOfUsersCtrl,
              //     isAmountField: true,
              //     labelText: AppLocalization.of(context)!.amount,
              //     onChanged: (value) {},
              //     validator: (val) {
              //       try {
              //         double userAmount = double.parse(val.replaceAll(',', ''));
              //         if (userAmount > amountLimit) {
              //           return 'You cannot fund more than $amountLimit';
              //         }
              //       } catch (e) {
              //         return AppLocalization.of(context)!.invalidAmount;
              //       }
              //       return null;
              //     },
              //   ),
              // ],
              // SizedBox(height: 10),
            ],
          )
        : SizedBox.shrink();
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
                    'Limit channel members',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
              value: limitGroupMembers!,
            ),
            SizedBox(width: 10)
          ],
        ),
        if (limitGroupMembers!) ...[
          SizedBox(height: 10),
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
        SizedBox(height: 30),
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
                  Text(
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
              value: ageRestriction,
            ),
            SizedBox(width: 10)
          ],
        ),
        if (ageRestriction) ...[
          SizedBox(height: 10),
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
              hint: Text('Select an age'),
              underline: SizedBox.shrink(),
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
        SizedBox(height: 30),
      ],
    );
  }

  void createGroup({Function? onCallBack}) async {
    if (limitGroupMembers!) {
      if (int.parse(_maxNoOfUsersCtrl.text) > 255) {
        showToast(message: 'Max number of users is 255');
        return;
      } else if (int.parse(_maxNoOfUsersCtrl.text) < 3) {
        showToast(
            message: 'You can not create channels with less than 3 members');
        return;
      }
    }

    groupModel.users = selectedConnectionList;
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

    groupModel.name = groupNameController!.text.trim();
    groupModel.ageRestriction = int.parse(selectedAge.split('+')[0]);
    groupModel.description = groupDescriptionController!.text.trim();

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

      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      // if (onCallBack != null) onCallBack();
    }).catchError((error) {
      debugPrint("ERROR While creating Group :- $error");
      showToast(message: "$error");
    });
  }
}
