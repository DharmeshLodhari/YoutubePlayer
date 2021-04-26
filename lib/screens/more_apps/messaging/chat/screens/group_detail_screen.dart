import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversationModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';

class GroupDetailScreen extends StatefulWidget {
  final arguments;

  GroupDetailScreen({this.arguments});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldGroupDetailScreen =
      new GlobalKey<ScaffoldState>();

  SlidableController _slideController;

  GroupDetailModel groupDetail;
  bool isLoading = false;

  @protected
  void initState() {
    getGroupDetail();

    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  void getGroupDetail() {
    ChatConversationModel _chatConversationModel;

    _chatConversationModel = widget.arguments["chat_conversation"] ??
        ChatConversationModel(
          conversationId: "36bce4e8-427b-4f47-b292-a40c69b4e776",
          adminUsers: [],
          avatar:
              "https://slydo-assets.s3.amazonaws.com/media/image_cropper_1619181971304.jpg",
          blockedParticipants: [],
          mutedParticipants: [],
          fullName: "Test Group 3",
          isGroupConversation: true,
          participants: [
            "abiola.rasheed.2",
            "black",
            "brijesh.sakariya",
            "ola.abraham",
            "olabisi.abraham.1"
          ],
          type: "User",
          username: "Test Group 3",
        );

    groupDetail = convertChatConversationToGroupDetail(_chatConversationModel);

    isLoading = true;
    if (mounted) setState(() {});

    MessageAuth()
        .getGroupConversationDetail(groupDetail.conversationId)
        .then((value) {
      groupDetail = value;
      isLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("ERROR:- $error");
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  GroupDetailModel convertChatConversationToGroupDetail(
      ChatConversationModel chatConversationModel) {
    GroupDetailModel groupDetailModel = GroupDetailModel(
        fullName: chatConversationModel.fullName,
        username: chatConversationModel.username,
        type: chatConversationModel.type,
        mutedParticipants: chatConversationModel.mutedParticipants,
        blockedParticipants: chatConversationModel.blockedParticipants,
        avatar: chatConversationModel.avatar,
        conversationId: chatConversationModel.conversationId,
        isGroupConversation: chatConversationModel.isGroupConversation,
        adminUsers: chatConversationModel.adminUsers,
        participants: []);
    return groupDetailModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGroupDetailScreen,
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: getScaffoldBody(),
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
        groupDetail.fullName,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      actions: [
        editGroupBtn(),
        SizedBox(width: 8),
        addUserToGroupBtn(),
        SizedBox(
          width: 16,
        )
      ],
    );
  }

  Widget addUserToGroupBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.send_connection_request,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        addParticipantToGroup("brijesh.sakariya");
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget editGroupBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.edit,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        searchUserFromContactList(query: "abiola");
        // searchParticipantInGroup(query: "abiola");
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget getScaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : Container(
            child: Column(
              children: [
                Expanded(child: _buildConnectionsList()),
              ],
            ),
          );
  }

  Widget _buildConnectionsList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Members (${groupDetail.participants.length})",
              style: TextStyle(
                  color: darkGrey, fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Column(
              children: groupDetail.participants
                  .asMap()
                  .map((index, value) =>
                      MapEntry(index, getUserTile(index: index, user: value)))
                  .values
                  .toList()),

          SizedBox(
            height: 16,
          ),

          Divider(
            color: dividerColor,
            height: 0,
            thickness: 1.5,
          ),

          SizedBox(
            height: 16,
          ),

          getExitGroupTile(),

          // Expanded(
          //   child: ListView.builder(
          //     padding: EdgeInsets.symmetric(
          //       vertical: 4,
          //     ),
          //     //+1 for progressbar
          //     itemCount: groupDetail.participants.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return getUserTile(
          //           user: groupDetail.participants[index], index: index);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget getExitGroupTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Exit group",
            maxLines: 1,
            style: TextStyle(
              color: mateRed,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          leading: Icon(
            SlydoAppIcon.leave,
            color: mateRed,
          ),
          onTap: () {
            exitFromGroup();
          },
        ),
      ),
    );
  }

  Widget getUserTile({Participant user, int index}) {
    CustomerProfile customerProfile = CustomerProfile(
        fullName: user.fullName,
        avatar: user.avatar,
        userName: user.userName,
        type: user.type);

    return _getSlideLists(context, customerProfile, index);
  }

  void createGroup() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    //   MessageAuth().createGroupChat(group: groupModel).then((value) {
    //     Navigator.pop(context);
    //     if (value) {
    //       Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
    //     }
    //   }).catchError((error) {
    //     debugPrint("ERROR While creating Group :- $error");
    //     Toast.show("$error", context,
    //         duration: Toast.LENGTH_LONG,
    //         textColor: Colors.white,
    //         backgroundColor: blackFont);
    //   });
    // }
  }

  Widget _getSlideLists(BuildContext context, CustomerProfile user, int index) {
    return Slidable(
      key: UniqueKey(),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.20,
      child: VerticalListItem(user),
      actions: listActionSlideActions(user, index),
      secondaryActions: listSecondaryActions(user, index),
    );
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            removeParticipantFromGroup(index);
          },
          title: "Remove",
          slideController: _slideController),
      SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.block,
          iconColor: blackFont,
          onTap: () {
            blockParticipantFromGroup(index);
          },
          title: "Block",
          slideController: _slideController),
      SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.mute,
          iconColor: blackFont,
          onTap: () {
            muteParticipantFromGroup(index);
          },
          title: "Mute",
          slideController: _slideController),
      SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.remove_admin,
          iconColor: blackFont,
          onTap: () {
            removeParticipantFromAdmin(index);
          },
          title: "Remove from admin",
          slideController: _slideController),
    ];
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    return [
      SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.unmute,
          iconColor: blackFont,
          onTap: () {
            unMuteParticipantFromGroup(index);
          },
          title: "Unmute",
          slideController: _slideController),
      SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.unblock,
          iconColor: blackFont,
          onTap: () {
            unBlockParticipantFromGroup(index);
          },
          title: "Unblock",
          slideController: _slideController),
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.make_admin,
          onTap: () {
            makeParticipantAdmin(index);
          },
          title: "Make admin",
          slideController: _slideController),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void removeParticipantFromAdmin(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .removeParticipantFromAdmin(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("Removed from admin successfully !!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void makeParticipantAdmin(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .makeParticipantAdmin(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is now admin !!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void muteParticipantFromGroup(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .muteParticipantFromGroup(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is muted!!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void unMuteParticipantFromGroup(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .unMuteParticipantFromGroup(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is unmuted!!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void blockParticipantFromGroup(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .blockParticipantFromGroup(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is blocked!!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void unBlockParticipantFromGroup(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .unBlockParticipantFromGroup(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is unblocked!!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void removeParticipantFromGroup(int index) {
    Participant participant = groupDetail.participants[index];
    MessageAuth()
        .removeParticipantFromGroup(
            conversationId: groupDetail.conversationId,
            userName: participant.userName)
        .then((value) {
      if (value) {
        Toast.show("${participant.userName} is removed!!", context);
        groupDetail.participants.removeAt(index);
        setState(() {});
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void addParticipantToGroup(String userName) {
    MessageAuth()
        .addParticipantToGroup(
            conversationId: groupDetail.conversationId, userName: userName)
        .then((value) {
      if (value) {
        Toast.show("userName is added in group !!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void exitFromGroup() {
    MessageAuth()
        .exitFromGroup(conversationId: groupDetail.conversationId)
        .then((value) {
      if (value) {
        Toast.show("You left the ${groupDetail.fullName}!!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void searchParticipantInGroup({String query}) {
    MessageAuth()
        .searchParticipantInGroup(
            conversationId: groupDetail.conversationId, query: query)
        .then((value) {
      if (value) {
        Toast.show("olabisi.abraham.1 is added in group !!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void searchUserFromContactList({String query}) {
    MessageAuth().searchUserInContact(query: query).then((value) {
      if (value) {
        Toast.show("olabisi.abraham.1 is added in group !!", context);
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.user);

  final CustomerProfile user;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
            ? Slidable.of(context)?.open()
            : Slidable.of(context)?.close();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: UserTile(user: widget.user),
      ),
    );
  }
}
