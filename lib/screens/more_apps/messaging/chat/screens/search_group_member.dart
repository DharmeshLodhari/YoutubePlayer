import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_group_action_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/user_tile_for_group_detail.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/search_text_field.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../message_auth.dart';

// ignore: must_be_immutable
class SearchGroupMember extends StatefulWidget {
  var arguments;

  SearchGroupMember({this.arguments});

  @override
  _SearchGroupMemberState createState() => _SearchGroupMemberState();
}

class _SearchGroupMemberState extends State<SearchGroupMember> {
  final GlobalKey<ScaffoldState> _scaffoldSearchGroupMemberKey =
      new GlobalKey<ScaffoldState>();

  int? count = 0;
  String? next = "";
  String? previous = "";
  List<Participant> groupMember = [];
  ScrollController _scrollController = new ScrollController();

  TextEditingController? searchUserController;

  bool isLoading = false;
  bool isSearchIsEmpty = false;
  bool noItemInList = false;

  GroupDetailModel? groupDetail;

  SlidableController? _slideController;
  late UserBloc userBloc;

  /// Socket
  late MainSocketProvider mainSocketProvider;
  StreamSubscription? streamSubscription;

  @protected
  void initState() {
    searchUserController = TextEditingController();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    groupDetail = widget.arguments["groupDetail"];

    this.getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    searchUserController!.addListener(() {
      if (searchUserController!.text.length >= 5) {
        setState(() {
          count = 0;
          next = "";
          previous = "";
          groupMember.clear();
          noItemInList = false;
          getList();
        });
      }
      if (groupMember.isNotEmpty || searchUserController!.text.length != 0) {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = true;
          });
        }
      }
    });

    super.initState();
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider.socketStream!.listen((event) {
      determineMessageType(event);
    });
  }

  void determineMessageType(String message) async {
    Map<String, dynamic> messageData = jsonDecode(message);

    switch (messageData['type']) {
      case "group_conversation_admin_actions":
        UserBloc user = Provider.of<UserBloc>(
            MyGlobals().navigationKey.currentContext!,
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
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    mainSocketProvider = Provider.of<MainSocketProvider>(context);

    initializeListener();
    return WillPopScope(
      onWillPop: () async {
        mainSocketProvider.removeStreamSubscription(streamSubscription);
        Navigator.pop(context, groupDetail);
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldSearchGroupMemberKey,
        backgroundColor: Colors.white,
        appBar: getAppBar() as PreferredSizeWidget?,
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
          Navigator.pop(context, groupDetail);
        },
      ),
      title: getSearchTextField(),
    );
  }

  Widget getSearchTextField() {
    return Container(
      padding: EdgeInsets.only(right: 16),
      child: SearchTextField(
        hintText: "Search...",
        onSubmit: () {
          debugPrint("Searched Text:- ${searchUserController!.text}");
        },
        textEditingController: searchUserController,
      ),
    );
  }

  Widget getScaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(child: _buildConnectionsList()),
        ],
      ),
    );
  }

  Widget _buildConnectionsList() {
    return isSearchIsEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context)!.noResultFound,
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                ),
                //+1 for progressbar
                itemCount: groupMember.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == groupMember.length) {
                    return _buildIndicator();
                  } else {
                    return getUserTile(index: index, user: groupMember[index]);
                  }
                },
                controller: _scrollController,
              );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  Future<void> getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result = await MessageAuth()
            .searchParticipantInGroup(next, previous,
                query: searchUserController!.text.trim(),
                conversationId: groupDetail!.conversationId);

        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];

        List tempList = result['results'];

        List<Participant> users = [];

        tempList.forEach((element) => users.add(Participant.fromJson(element)));

        isLoading = false;
        if (mounted) setState(() {});

        groupMember.addAll(users);
        if (mounted) setState(() {});
      }
      if (groupMember.isEmpty) {
        noItemInList = true;
        if (mounted) setState(() {});
      } else if (next == null && groupMember.length > 6) {
        _scaffoldSearchGroupMemberKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  Widget getUserTile({required Participant user, int? index}) {
    CustomerProfile customerProfile = CustomerProfile(
        fullName: user.fullName,
        avatar: user.avatar,
        userName: user.userName,
        type: user.type);

    return _getSlideLists(context, customerProfile, index);
    // return Container(
    //   padding: EdgeInsets.symmetric(vertical: 2),
    //   child: UserTile(user: user),
    // );
  }

  Widget _getSlideLists(
      BuildContext context, CustomerProfile user, int? index) {
    return Slidable(
      key: UniqueKey(),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.20,
      fastThreshold: 1,
      showAllActionsThreshold: 0.6,
      child: VerticalListItem(user, groupDetail),
      actions: listActionSlideActions(user, index),
      secondaryActions: listSecondaryActions(user, index),
    );
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int? index) {
    bool isOwner = false;
    bool isAdmin = false;
    bool isBlocked = false;
    bool isMuted = false;
    bool isCurrentUser = false;
    bool isCurrentUserIsAdmin = false;

    if (groupDetail!.owner == user.userName) {
      isOwner = true;
    }
    if (groupDetail!.adminUsers.contains(user.userName)) {
      isAdmin = true;
    }
    if (groupDetail!.blockedParticipants.contains(user.userName)) {
      isBlocked = true;
    }
    if (groupDetail!.mutedParticipants.contains(user.userName)) {
      isMuted = true;
    }
    if (user.userName == userBloc.user.userName) {
      isCurrentUser = true;
    }
    if (groupDetail!.adminUsers.contains(userBloc.user.userName)) {
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
              removeParticipantFromGroup(index!);
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
              blockParticipantFromGroup(index!);
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
              muteParticipantFromGroup(index!);
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
              removeParticipantFromAdmin(index!);
            },
            title: "Remove from admin",
            slideController: _slideController),
      );
    }

    return leftSwipeActions;
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int? index) {
    bool isOwner = false;
    bool isAdmin = false;
    bool isBlocked = false;
    bool isMuted = false;
    bool isCurrentUser = false;
    bool isCurrentUserIsAdmin = false;

    if (groupDetail!.owner == user.userName) {
      isOwner = true;
    }
    if (groupDetail!.adminUsers.contains(user.userName)) {
      isAdmin = true;
    }
    if (groupDetail!.blockedParticipants.contains(user.userName)) {
      isBlocked = true;
    }
    if (groupDetail!.mutedParticipants.contains(user.userName)) {
      isMuted = true;
    }
    if (user.userName == userBloc.user.userName) {
      isCurrentUser = true;
    }
    if (groupDetail!.adminUsers.contains(userBloc.user.userName)) {
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
            unMuteParticipantFromGroup(index!);
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
              unBlockParticipantFromGroup(index!);
            },
            title: "Unblock",
            slideController: _slideController),
      );
    }

    if (!isAdmin) {
      rightSwipeAction.add(
        SlideActionButton(
            backgroundColor: naturalGreen,
            icon: SlydoAppIcon.make_admin,
            onTap: () {
              makeParticipantAdmin(index!);
            },
            title: "Make admin",
            slideController: _slideController),
      );
    }

    return rightSwipeAction;
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  void removeParticipantFromAdmin(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .removeParticipantFromAdmin(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.adminUsers.remove(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is removed from admin !!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void makeParticipantAdmin(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .makeParticipantAdmin(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.adminUsers.add(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is now admin !!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void muteParticipantFromGroup(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .muteParticipantFromGroup(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.mutedParticipants.add(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is muted!!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void unMuteParticipantFromGroup(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .unMuteParticipantFromGroup(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.mutedParticipants.remove(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is unmuted!!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void blockParticipantFromGroup(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .blockParticipantFromGroup(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.blockedParticipants.add(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is blocked!!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void unBlockParticipantFromGroup(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .unBlockParticipantFromGroup(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        groupDetail!.blockedParticipants.remove(participant.userName);
        if (mounted) setState(() {});
        showToast(message: "${participant.userName} is unblocked!!");
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }

  void removeParticipantFromGroup(int index) {
    Participant participant = groupDetail!.participants[index];
    MessageAuth()
        .removeParticipantFromGroup(
            conversationId: groupDetail!.conversationId!,
            userName: participant.userName)
        .then((value) {
      if (value) {
        showToast(message: "${participant.userName} is removed!!");
        groupDetail!.participants.removeAt(index);
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
              conversationId: groupDetail!.conversationId!,
              users: selectedUsers as List<CustomerProfile>)
          .then((value) {
        if (value) {
          if (selectedUsers is List<CustomerProfile>) {
            List<Participant> usersAdded = [];

            selectedUsers.forEach((element) {
              usersAdded.add(Participant(
                  avatar: element.avatar,
                  fullName: element.displayName(),
                  type: element.type,
                  userName: element.userName));
            });

            groupDetail!.participants.addAll(usersAdded);
            showToast(message: "Users are added in group !!");
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
        .exitFromGroup(conversationId: groupDetail!.conversationId!)
        .then((value) {
      if (value) {
        showToast(message: "You left the ${groupDetail!.fullName}!!");
        Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
      }
    }).catchError((error) {
      debugPrint("ERROR:- $error");
    });
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.user, this.groupDetail);

  final CustomerProfile user;
  final GroupDetailModel? groupDetail;

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
          user: widget.user,
          groupDetail: widget.groupDetail,
        ),
      ),
    );
  }
}
