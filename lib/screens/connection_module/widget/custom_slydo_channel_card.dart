import 'dart:async';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/channel_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/state_notifier.dart';
import '../../../utils/colors.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../more_apps/messaging/message_auth.dart';

// ignore: must_be_immutable
class CustomSlydoChannelCard extends StatefulWidget {
  ChannelModel? channelModel;

  CustomSlydoChannelCard({required this.channelModel});

  @override
  _CustomSlydoChannelCardState createState() => _CustomSlydoChannelCardState();
}

class _CustomSlydoChannelCardState extends State<CustomSlydoChannelCard> {
  bool isTyping = false;

  MainSocketProvider? mainSocketProvider;
  StreamSubscription? streamSubscription;
  String? typingMessage = "";

  late UserBloc userBloc;
  bool isLoading = false;

  @override
  void dispose() {
    mainSocketProvider?.removeStreamSubscription(streamSubscription);
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    Widget avatarImage;

    Color borderColor = getUserTypeColorByType(type: 'user');

    avatarImage = GestureDetector(
      onTap: () {
        if (widget.channelModel!.isGroupConversation!) {
          Navigator.of(context).pushNamed("/photo-viewer",
              arguments: widget.channelModel?.banner ?? defaultImage);
        }
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.channelModel!.banner == "" ||
                    widget.channelModel!.banner == null
                ? defaultImage
                : widget.channelModel!.banner!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );

    Widget tile = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: Text(
            truncateString(
                str: widget.channelModel!.groupName!, lengthToTruncateAt: 25),
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: getSubtitle(context),
          leading: avatarImage,
          trailing: getTrailing(),
        ),
      ),
    );
    return tile;
  }

  Widget getSubtitle(BuildContext context) {
    return Text(
      '${getFormattedViewCount(
        noOfViews: widget.channelModel!.noOfMembers!,
        addViewText: false,
      )} member(s)',
      maxLines: 1,
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getTrailing() {
    return InkWell(
      onTap: widget.channelModel?.isMember == true
          ? () {
              showToast(message: 'You are already a member');
            }
          : () {
              if (mounted) setState(() => isLoading = true);
              MessageAuth()
                  .joinChannel(
                      channelId: widget.channelModel!.id!,
                      userName: userBloc.user.userName!)
                  .then((value) {
                if (mounted) setState(() => isLoading = false);

                if (value) {
                  showToast(message: "Joined group successfully");
                  widget.channelModel!.isMember = true;
                  if (mounted) setState(() {});
                }
              }).catchError((error) {
                if (mounted) setState(() => isLoading = false);
                if (error.toString().contains('is full')) {
                  showToast(message: error.toString());
                } else {
                  showToast(message: 'Something went wrong, please try again.');
                }

                debugPrint("ERROR: $error");
              });
            },
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularLoadingIndicator(color: naturalGreen),
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: naturalGreen.withOpacity(0.1),
              ),
              child: Text(
                widget.channelModel?.isMember == true ? 'Joined' : 'Join',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: naturalGreen),
              ),
            ),
    );
  }

  Widget getBadgeAndGroupLabel(int? count) {
    if (!widget.channelModel!.isGroupConversation!) {
      if (count == 0) {
        return Container(
          width: 0,
          height: 0,
        );
      } else {
        return getBadge(count!, padding: 12);
      }
    } else {
      if (count == 0) {
        return getGroupLabel();
      } else {
        return Column(
          crossAxisAlignment: checkUserIsAdmin() || checkUserIsOwner()
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
          children: [
            getBadge(count!,
                padding: checkUserIsAdmin() || checkUserIsOwner() ? 10 : 0),
            Expanded(
              child: SizedBox(
                height: 4,
              ),
            ),
            getGroupLabel(),
          ],
        );
      }
    }
  }

  Widget getGroupLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        checkUserIsAdmin() || checkUserIsOwner()
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: navyBlue.withOpacity(0.1),
                    ),
                    child: Icon(
                      checkUserIsOwner() ? Icons.group : Icons.person,
                      color: navyBlue,
                      size: 12,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                ],
              )
            : Container(),
        Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: naturalGreen.withOpacity(0.1),
          ),
          child: Text(
            "Group",
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: naturalGreen),
          ),
        ),
      ],
    );
  }

  bool checkUserIsAdmin() {
    if (widget.channelModel!.adminUsers!.contains(userBloc.user.userName))
      return true;
    return false;
  }

  bool checkUserIsOwner() {
    if (widget.channelModel!.owner!.contains(userBloc.user.userName!))
      return true;
    return false;
  }

  Widget getBadge(int count, {double padding = 0}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Badge(
        elevation: 0,
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: Text(
          getCountForMessage(count),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12),
        ),
        position: BadgePosition(end: 0, top: 0),
      ),
    );
  }

  String getCountForMessage(int count) {
    return count > 999 ? "999+" : "$count";
  }
}

// class CustomSlydoChannelCard extends StatefulWidget {
//   final ChatConversation chatConversation;
//   const CustomSlydoChannelCard({Key? key, required this.chatConversation})
//       : super(key: key);
//
//   @override
//   _CustomSlydoChannelCardState createState() =>
//       _CustomSlydoChannelCardState();
// }
//
// class _CustomSlydoChannelCardState extends State<CustomSlydoChannelCard> {
//   SlidableController? _slideController;
//   // int? count = 0;
//   // String? next = "";
//   // String? previous = "";
//   // List connectionsList = [];
//
//   bool isLoading = false;
//   bool noItemInList = false;
//   bool isLoadingFromDB = false;
//
//   TextEditingController? searchChatConversation;
//   bool isUserIsSearching = false;
//   List<ChatConversation> searchedChatConnection = [];
//
//   AppConfigurationModel? appConfigurationModel;
//
//   @override
//   Widget build(BuildContext context) {
//     return _getSlidableWithLists(
//       context,
//       widget.chatConversation,
//     );
//   }
//
//   // void getList() async {
//   //   ConnectionListBloc connectionListBloc =
//   //       Provider.of<ConnectionListBloc>(context, listen: false);
//   //   if (!isLoading) {
//   //     if (next != null && !isLoading) {
//   //       isLoading = true;
//   //       if (mounted) setState(() {});
//   //       Map<String, dynamic>? result =
//   //           await UserAuth().contacts(next, previous);
//   //       if (result == null) {
//   //         isLoading = false;
//   //         return;
//   //       }
//   //       count = result['count'];
//   //       next = result['next'];
//   //       previous = result['previous'];
//   //
//   //       List tempList = result['results'];
//   //
//   //       debugPrint("List:- $tempList");
//   //
//   //       List<ChatConversation> users = [];
//   //
//   //       tempList.forEach(
//   //           (element) => users.add(ChatConversation.fromJson(element)));
//   //
//   //       debugPrint('CONNECTION USERS 0 --> ${users[0].isVerified}');
//   //
//   //       // connectionsList.addAll(users);
//   //
//   //       connectionListBloc.setConnectionUsers(users: users);
//   //
//   //       isLoading = false;
//   //       if (mounted) setState(() {});
//   //
//   //       // ConnectionListManager().saveConnectionsToDB(connections: users);
//   //
//   //       // if (mounted) setState(() {});
//   //
//   //       /// adding chat Users in database
//   //       ChatUserManager().addUsers(users);
//   //     }
//   //     if (connectionListBloc.connectionUsers.isEmpty) {
//   //       noItemInList = true;
//   //       if (mounted) setState(() {});
//   //     } else if (next == null &&
//   //         connectionListBloc.connectionUsers.length > 6) {
//   //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //         content:
//   //             Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
//   //         duration: Duration(milliseconds: 500),
//   //       ));
//   //     }
//   //   }
//   // }
//
//   Widget _getSlidableWithLists(
//       BuildContext context, ChatConversation chatConversation) {
//     return Slidable(
//       key: Key(chatConversation.userName!),
//       controller: _slideController,
//       direction: Axis.horizontal,
//       actionPane: SlidableBehindActionPane(),
//       actionExtentRatio: 0.25,
//       child: VerticalListItem(chatConversation),
//       actions: listActionSlideActions(chatConversation),
//       secondaryActions: listSecondaryActions(chatConversation),
//     );
//   }
//
//   List<Widget> listActionSlideActions(ChatConversation chatConversation) {
//     UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
//
//     if (chatConversation.userName!.toLowerCase() == 'slydo') {
//       return [];
//     }
//
//     if (chatConversation.isGroupConversation!) {
//       if (userBloc.user.userName == chatConversation.owner) {
//         return [];
//       }
//
//       return [
//         SlideActionButton(
//           backgroundColor: mateRed,
//           icon: SlydoAppIcon.leave,
//           onTap: () {
//             exitTheGroupAlert(chatConversation);
//           },
//           title: "Exit",
//           slideController: _slideController,
//         ),
//       ];
//     }
//
//     CustomerProfile customerProfile =
//         CustomerProfile.fromChatConversation(chatConversation);
//
//     return [
//       SlideActionButton(
//         backgroundColor: mateRed,
//         icon: SlydoAppIcon.remove_connection,
//         onTap: () {
//           removeFromConnectionUserAlert(customerProfile);
//         },
//         title: AppLocalization.of(context)!.remove,
//         slideController: _slideController,
//       ),
//     ];
//   }
//
//   List<Widget> listSecondaryActions(ChatConversation chatConversation) {
//     if (chatConversation.userName!.toLowerCase() == 'slydo') {
//       return [];
//     }
//
//     if (chatConversation.isGroupConversation!) {
//       return [];
//     }
//     CustomerProfile customerProfile =
//         CustomerProfile.fromChatConversation(chatConversation);
//
//     return [
//       SlideActionButton(
//         backgroundColor: mateRed,
//         icon: SlydoAppIcon.block,
//         onTap: () {
//           blockUserAlert(customerProfile);
//         },
//         title: AppLocalization.of(context)!.block,
//         slideController: _slideController,
//       ),
//     ];
//   }
//
//   void blockUserAlert(CustomerProfile user) async {
//     bool? result = await showDialogBox(
//       context: context,
//       roundedBackgroundIcon: RoundedBackgroundIcon(
//         backgroundColor: mateRed.withOpacity(0.08),
//         borderRadius: 20,
//         width: 48,
//         height: 48,
//         icon: Icon(
//           SlydoAppIcon.block,
//           color: mateRed,
//           size: 16,
//         ),
//         enableMargin: false,
//       ),
//       actionOneBgColor: mateRed,
//       actionOneTextColor: Colors.white,
//       actionTwoBgColor: greyBorderColor,
//       actionTwoTextColor: blackFont,
//       title: AppLocalization.of(context)!.block,
//       description: AppLocalization.of(context)!.areYouSureWantToBlock +
//           " ${user.displayName()}",
//       actionOneText: AppLocalization.of(context)!.block,
//       actionTwoText: AppLocalization.of(context)!.cancel,
//     );
//     if (result != null && result) {
//       bool done = await UserAuth().blockUser(user);
//       // done = true;
//       if (done) {
//         _showSnackBar(
//             context,
//             "${user.displayName()} " +
//                 AppLocalization.of(context)!.isBlockedSuccessfully);
//         ConnectionListBloc connectionListBloc =
//             Provider.of<ConnectionListBloc>(context, listen: false);
//         connectionListBloc.deleteChatConversation(
//             conversationId: user.conversationId);
//
//         // if (connectionsList.length <= 9) {
//         //   getList();
//         // }
//         setState(() {});
//       } else {
//         _showSnackBar(context, AppLocalization.of(context)!.error);
//       }
//     }
//   }
//
//   Future<void> exitTheGroupAlert(ChatConversation chatConversation) async {
//     bool? result = await showDialogBox(
//       context: context,
//       roundedBackgroundIcon: RoundedBackgroundIcon(
//         backgroundColor: mateRed.withOpacity(0.08),
//         borderRadius: 20,
//         width: 48,
//         height: 48,
//         icon: Icon(
//           SlydoAppIcon.leave,
//           color: mateRed,
//           size: 16,
//         ),
//         enableMargin: false,
//       ),
//       actionOneBgColor: mateRed,
//       actionOneTextColor: Colors.white,
//       actionTwoBgColor: greyBorderColor,
//       actionTwoTextColor: blackFont,
//       title: "Exit",
//       description: "Are you sure want to leave ${chatConversation.fullName} ?",
//       actionOneText: "Exit",
//       actionTwoText: AppLocalization.of(context)!.cancel,
//     );
//     if (result != null && result) {
//       bool done = await MessageAuth()
//           .exitFromGroup(conversationId: chatConversation.conversationId!);
//       if (done) {
//         _showSnackBar(context, "You left ${chatConversation.fullName}");
//
//         ConnectionListBloc connectionListBloc =
//             Provider.of<ConnectionListBloc>(context, listen: false);
//         connectionListBloc.deleteChatConversation(
//             conversationId: chatConversation.conversationId);
//
//         setState(() {});
//       } else {
//         _showSnackBar(context, AppLocalization.of(context)!.error);
//       }
//     }
//   }
//
//   Future<void> removeFromConnectionUserAlert(CustomerProfile user) async {
//     bool? result = await showDialogBox(
//       context: context,
//       roundedBackgroundIcon: RoundedBackgroundIcon(
//         backgroundColor: mateRed.withOpacity(0.08),
//         borderRadius: 20,
//         width: 48,
//         height: 48,
//         icon: Icon(
//           SlydoAppIcon.delete,
//           color: mateRed,
//           size: 16,
//         ),
//         enableMargin: false,
//       ),
//       actionOneBgColor: mateRed,
//       actionOneTextColor: Colors.white,
//       actionTwoBgColor: greyBorderColor,
//       actionTwoTextColor: blackFont,
//       title: AppLocalization.of(context)!.delete,
//       description: AppLocalization.of(context)!.areYouSureWantToDelete +
//           " ${user.displayName()} " +
//           "From Your Connection List",
//       actionOneText: AppLocalization.of(context)!.delete,
//       actionTwoText: AppLocalization.of(context)!.cancel,
//     );
//     if (result != null && result) {
//       bool done = await UserAuth().removeFromContactList(user);
//       if (done) {
//         _showSnackBar(
//             context,
//             "${user.displayName()} " +
//                 AppLocalization.of(context)!.isRemovedSuccessfully);
//
//         ConnectionListBloc connectionListBloc =
//             Provider.of<ConnectionListBloc>(context, listen: false);
//         connectionListBloc.deleteChatConversation(
//             conversationId: user.conversationId);
//         if (mounted) setState(() {});
//       } else {
//         _showSnackBar(context, AppLocalization.of(context)!.error);
//       }
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String text) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }
// }
