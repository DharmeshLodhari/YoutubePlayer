import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_group_action_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/user_tile_for_group_detail.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
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

  UserBloc userBloc;

  bool muteNotification = false;

  /// Socket
  MainSocketProvider mainSocketProvider;
  StreamSubscription streamSubscription;

  @protected
  void initState() {
    getGroupDetail();

    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider.socketStream.listen((event) {
      determineMessageType(event);
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  void determineMessageType(String message) async {
    Map<String, dynamic> messageData = jsonDecode(message);

    switch (messageData['type']) {
      case "group_conversation_admin_actions":
        if (messageData['meta_data']['conversation_id'] ==
            groupDetail.conversationId) {
          if (messageData['meta_data']['action'] == "delete_group") {
            Toast.show(
                "${messageData['meta_data']['author']} has deleted this group !!",
                context,
                textColor: Colors.white,
                backgroundColor: Colors.black,
                duration: Toast.LENGTH_LONG);
            Navigator.popUntil(
                context, ModalRoute.withName("/friends-dashboard"));
            return;
          } else if (messageData['meta_data']['action'] == "remove_user") {
            List users = messageData['meta_data']['users'];
            if (users.isEmpty) return;
            if (users.first == null || users.first == "") return;
            String user = users.first.toString();
            if (user == userBloc.user.userName) {
              Toast.show(
                  "${messageData['meta_data']['author']} has removed you from group !!",
                  context,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                  duration: Toast.LENGTH_LONG);
              Navigator.popUntil(
                  context, ModalRoute.withName("/friends-dashboard"));
              return;
            }
          }
        }
        UserBloc user = Provider.of<UserBloc>(
            MyGlobals().navigationKey.currentContext,
            listen: false);

        if (messageData['meta_data']['author'] != user.user.userName) {
          var result =
              ChatGroupActionManagerForLiveConversation(message: messageData)
                  .handleMessageAction(groupDetailModel: groupDetail);

          if (result != null) {
            if (result is GroupDetailModel) {
              groupDetail = result;
              if (mounted) setState(() {});
            }
          }

          break;
        }
    }
  }

  void getGroupDetail() {
    groupDetail = widget.arguments["groupDetail"];

    isLoading = true;
    if (mounted) setState(() {});

    debugPrint("groupDetail.conversationId:- ${groupDetail.conversationId}");
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    mainSocketProvider = Provider.of<MainSocketProvider>(context);

    initializeListener();
    return WillPopScope(
      onWillPop: () async {
        mainSocketProvider.removeStreamSubscription(streamSubscription);
        Navigator.of(context).pop(groupDetail);
        return false;
      },
      child: Scaffold(
        key: _scaffoldGroupDetailScreen,
        backgroundColor: Colors.white,
        appBar: getAppBar(),
        body: getScaffoldBody(),
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
          Navigator.of(context).pop(groupDetail);
        },
      ),leadingWidth: 40,
      title: Row(
        children: [
          getUserIcon(),
          SizedBox(
            width: 12,
          ),
          Text(
            groupDetail.fullName,
            style: TextStyle(
                color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.fade,
            softWrap: false,
            maxLines: 1,
          ),
        ],
      ),
      actions: getGroupActions(),
    );
  }

  Widget getUserIcon() {
    Color borderColor = getUserTypeColorByType(type: groupDetail.type);

    return Container(
      height: 36,
      width: 36,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed("/photo-viewer",
                arguments: groupDetail != null
                    ? groupDetail.avatar ??
                        "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                    : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png");
          },
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: groupDetail != null
                  ? groupDetail.avatar ??
                      "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                  : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getGroupActions() {
    if (groupDetail.adminUsers.contains(userBloc.user.userName)) {
      return [
        isLoading ? Container() : editGroupBtn(),
        SizedBox(width: 8),
        isLoading ? Container() : addUserToGroupBtn(),
        SizedBox(
          width: 16,
        )
      ];
    }
    return [];
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
        addParticipantToGroup();
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
      onTap: () async {
        var result = await Navigator.of(context).pushNamed(
            "/update-name-and-profile-for-group",
            arguments: {"groupDetail": groupDetail});

        if (result != null) {
          debugPrint("Result:- $result");
          groupDetail = result;
          if (mounted) setState(() {});
        }
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

  Widget getGroupDescription() {
    return groupDetail.description == ""
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                      color: darkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "${groupDetail.description}",
                  style: TextStyle(color: blackFont),
                ),
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
            height: 12,
          ),
          getGroupDescription(),
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members (${groupDetail.participants.length})",
                  style: TextStyle(
                      color: darkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: seeAllGroupMember,
                  child: Text(
                    "See all",
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
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
            thickness: 1,
          ),
          SizedBox(
            height: 16,
          ),
          getMuteNotificationTile(),
          SizedBox(
            height: 16,
          ),
          Divider(
            color: dividerColor,
            height: 0,
            thickness: 1,
          ),
          SizedBox(
            height: 16,
          ),
          userBloc.user.userName != groupDetail.owner
              ? getExitGroupTile()
              : getDeleteGroupTile(),
        ],
      ),
    );
  }

  void seeAllGroupMember() async {
    var result = await Navigator.of(context).pushNamed(
        "/search-member-in-group",
        arguments: {"groupDetail": groupDetail});

    if (result != null) {
      debugPrint("Result:- $result");
      groupDetail = result;

      if (mounted) setState(() {});
    }
  }

  Widget getMuteNotificationTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Mute notifications",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Container(
            width: 60,
            child: Switch(
              value: muteNotification,
              onChanged: (value) {
                muteNotification = value;
                setState(() {});
              },
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: navyBlueLight,
            ),
          ),
          onTap: () {
            if (muteNotification) {
              muteGroupNotification();
            }
          },
        ),
      ),
    );
  }

  Widget getDeleteGroupTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            "Delete group",
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
            SlydoAppIcon.delete,
            color: mateRed,
          ),
          onTap: () {
            deleteGroup();
          },
        ),
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

  Widget _getSlideLists(BuildContext context, CustomerProfile user, int index) {
    return Slidable(
      key: UniqueKey(),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.20,
      fastThreshold: 1,
      showAllActionsThreshold: 0.6,
      // movementDuration: Duration(milliseconds: 300),
      child: VerticalListItem(user, groupDetail),
      actions: listActionSlideActions(user, index),
      secondaryActions: listSecondaryActions(user, index),
    );
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    bool isOwner = false;
    bool isAdmin = false;
    bool isBlocked = false;
    bool isMuted = false;
    bool isCurrentUser = false;
    bool isCurrentUserIsAdmin = false;

    if (groupDetail.owner == user.userName) {
      isOwner = true;
    }
    if (groupDetail.adminUsers.contains(user.userName)) {
      isAdmin = true;
    }
    if (groupDetail.blockedParticipants.contains(user.userName)) {
      isBlocked = true;
    }
    if (groupDetail.mutedParticipants.contains(user.userName)) {
      isMuted = true;
    }
    if (user.userName == userBloc.user.userName) {
      isCurrentUser = true;
    }
    if (groupDetail.adminUsers.contains(userBloc.user.userName)) {
      isCurrentUserIsAdmin = true;
    }

    List<Widget> leftSwipeActions = [];

    if (isOwner || isCurrentUser) return leftSwipeActions;

    if (isCurrentUserIsAdmin) {
      leftSwipeActions.add(
        SlideActionButton(
            backgroundColor: mateRed,
            icon: SlydoAppIcon.remove,
            onTap: () {
              removeParticipantFromGroup(index);
            },
            title: "Remove",
            slideController: _slideController),
      );
    }

    if (!isBlocked && isCurrentUserIsAdmin) {
      leftSwipeActions.add(
        SlideActionButton(
            backgroundColor: lightGrey,
            icon: SlydoAppIcon.block,
            iconColor: blackFont,
            onTap: () {
              blockParticipantFromGroup(index);
            },
            title: "Block",
            slideController: _slideController),
      );
    }

    if (!isMuted && isCurrentUserIsAdmin) {
      leftSwipeActions.add(
        SlideActionButton(
            backgroundColor: lightGrey,
            icon: SlydoAppIcon.mute,
            iconColor: blackFont,
            onTap: () {
              muteParticipantFromGroup(index);
            },
            title: "Mute",
            slideController: _slideController),
      );
    }

    if (isAdmin && isCurrentUserIsAdmin) {
      leftSwipeActions.add(
        SlideActionButton(
            backgroundColor: lightGrey,
            icon: SlydoAppIcon.remove_admin,
            iconColor: blackFont,
            onTap: () {
              removeParticipantFromAdmin(index);
            },
            title: "Remove from admin",
            slideController: _slideController),
      );
    }

    return leftSwipeActions;
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    bool isOwner = false;
    bool isAdmin = false;
    bool isBlocked = false;
    bool isMuted = false;
    bool isCurrentUser = false;
    bool isCurrentUserIsAdmin = false;

    if (groupDetail.owner == user.userName) {
      isOwner = true;
    }
    if (groupDetail.adminUsers.contains(user.userName)) {
      isAdmin = true;
    }
    if (groupDetail.blockedParticipants.contains(user.userName)) {
      isBlocked = true;
    }
    if (groupDetail.mutedParticipants.contains(user.userName)) {
      isMuted = true;
    }
    if (user.userName == userBloc.user.userName) {
      isCurrentUser = true;
    }
    if (groupDetail.adminUsers.contains(userBloc.user.userName)) {
      isCurrentUserIsAdmin = true;
    }

    List<Widget> rightSwipeAction = [];

    if (isOwner || isCurrentUser) return rightSwipeAction;

    if (isMuted && isCurrentUserIsAdmin) {
      rightSwipeAction.add(SlideActionButton(
          backgroundColor: lightGrey,
          icon: SlydoAppIcon.unmute,
          iconColor: blackFont,
          onTap: () {
            unMuteParticipantFromGroup(index);
          },
          title: "Unmute",
          slideController: _slideController));
    }

    if (isBlocked && isCurrentUserIsAdmin) {
      rightSwipeAction.add(
        SlideActionButton(
            backgroundColor: lightGrey,
            icon: SlydoAppIcon.unblock,
            iconColor: blackFont,
            onTap: () {
              unBlockParticipantFromGroup(index);
            },
            title: "Unblock",
            slideController: _slideController),
      );
    }

    if (!isAdmin && isCurrentUserIsAdmin) {
      rightSwipeAction.add(
        SlideActionButton(
            backgroundColor: naturalGreen,
            icon: SlydoAppIcon.make_admin,
            onTap: () {
              makeParticipantAdmin(index);
            },
            title: "Make admin",
            slideController: _slideController),
      );
    }

    return rightSwipeAction;
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
        groupDetail.adminUsers.remove(participant.userName);
        if (mounted) setState(() {});
        Toast.show("${participant.userName} is removed from admin !!", context);
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
        groupDetail.adminUsers.add(participant.userName);
        if (mounted) setState(() {});
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
        groupDetail.mutedParticipants.add(participant.userName);
        if (mounted) setState(() {});
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
        groupDetail.mutedParticipants.remove(participant.userName);
        if (mounted) setState(() {});
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
        groupDetail.blockedParticipants.add(participant.userName);
        if (mounted) setState(() {});
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
        groupDetail.blockedParticipants.remove(participant.userName);
        if (mounted) setState(() {});
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
        if (mounted) setState(() {});
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void addParticipantToGroup() async {
    var selectedUsers = await Navigator.of(context).pushNamed(
        "/select-user-for-group",
        arguments: {"isForAddingUserInGroup": true});

    if (selectedUsers != null) {
      MessageAuth()
          .addParticipantToGroup(
              conversationId: groupDetail.conversationId, users: selectedUsers)
          .then((value) {
        if (value) {
          if (selectedUsers is List<CustomerProfile>) {
            List<Participant> usersAdded = [];

            selectedUsers.forEach((element) {
              usersAdded.add(Participant(
                  avatar: element.avatar,
                  fullName: element.fullName,
                  type: element.type,
                  userName: element.userName));
            });

            groupDetail.participants.addAll(usersAdded);
            Toast.show("Users are added in group !!", context);
            if (mounted) setState(() {});
          }
        }
      }).catchError((error) {
        debugPrint("ERROR:- $error");
      });
    }
  }

  void exitFromGroup() {
    MessageAuth()
        .exitFromGroup(conversationId: groupDetail.conversationId)
        .then((value) {
      if (value) {
        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: groupDetail.conversationId);

        Toast.show("You left the ${groupDetail.fullName}!!", context);
        Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void deleteGroup() {
    MessageAuth()
        .deleteGroup(conversationId: groupDetail.conversationId)
        .then((value) {
      if (value) {
        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: groupDetail.conversationId);
        Toast.show("You deleted the ${groupDetail.fullName}!!", context);
        Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }
}

void muteGroupNotification() {
  debugPrint("Mute Notification");
  //   MessageAuth()
  //       .exitFromGroup(conversationId: groupDetail.conversationId)
  //       .then((value) {
  //     if (value) {
  //       ConnectionListBloc connectionListBloc =
  //           Provider.of<ConnectionListBloc>(context, listen: false);
  //       connectionListBloc.deleteChatConversation(
  //           conversationId: groupDetail.conversationId);
  //       Toast.show("You deleted the ${groupDetail.fullName}!!", context);
  //       Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
  //     }
  //   }).catchError((error) {
  //     debugPrint("ERROR:- $error");
  //   });
  // }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.user, this.groupDetail);

  final CustomerProfile user;

  final GroupDetailModel groupDetail;

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
        child: UserTileForGroupDetail(
            user: widget.user, groupDetail: widget.groupDetail),
      ),
    );
  }
}
