import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/screens/more_apps/messaging/tiles/message.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'message_auth.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final GlobalKey<ScaffoldState> _scaffoldMessageKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerMessageKey =
      new GlobalKey<ScaffoldMessengerState>();
  final _messageAuth = MessageAuth();
  SlidableController? slidableController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List messageList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  String? filterValue;
  late UserBloc userBloc;
  RefreshBlocForMessages? _refreshBloc;

  GlobalKey _key = LabeledGlobalKey("messageListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  @protected
  void initState() {
    this.getList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForMessages>(context);
    _refreshBloc!
      ..addListener(() {
        if (_refreshBloc!.isRefresh) {
          if (mounted) {
            _onRefresh();
            _refreshBloc!.isRefresh = false;
          }
        }
      });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        messageList = [];
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    filterValue = value;
    setState(() {});
    _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "Inbox", value: "all"),
        CustomizedPopUpMenuItem(
            title: AppLocalization.of(context)!.archived, value: "archived"),
        CustomizedPopUpMenuItem(
            title: AppLocalization.of(context)!.sent, value: "sent"),
        CustomizedPopUpMenuItem(
            title: AppLocalization.of(context)!.starred, value: "starred"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    // refresh the list when lifecycle called onResume method
    _onRefreshOnResume();

    return ScaffoldMessenger(
      key: _scaffoldMessengerMessageKey,
      child: Scaffold(
        key: _scaffoldMessageKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildMessageList()),
        floatingActionButton: FloatingActionButton(
          heroTag: "compose_message",
          backgroundColor: navyBlue,
          isExtended: false,
          child: const Icon(
            SlydoAppIcon.text_message,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              Routes.COMPOSE_MESSAGE,
            );
          },
        ),
      ),
    );
  }

  Widget appBar() {
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
      title: Row(
        children: [
          Text(
            '${getAppBarFilterTitle()} ',
            style: TextStyle(
                color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            AppLocalization.of(context)!.messages,
            style: TextStyle(
                color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(top: 16.0),
        //   child: Text(
        //     getAppBarFilterTitle(),
        //     style: TextStyle(
        //       color: blackFont,
        //       fontSize: 16,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        // ),
        // SizedBox(width: 16),
        popUpMenuButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  getAppBarFilterTitle() {
    switch (filterValue) {
      case 'all':
        return 'Inbox';
      case 'sent':
        return 'Sent';
      case 'archived':
        return 'Archived';
      case 'starred':
        return 'Starred';
      default:
        return 'Inbox';
    }
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.filter_alt_rounded,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noMessages,
          )
        : isLoading && messageList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                //+1 for progressbar
                itemCount: messageList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == messageList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                        context, messageList[index], index);
                  }
                },
                controller: _scrollController,
              );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? result = await _messageAuth
            .listMessages(next, previous, filter: filterValue);

        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isLoading = false;
            messageList.addAll(tempList);
          });
        }
      }
      if (messageList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && messageList.length > 6) {
        _scaffoldMessengerMessageKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldMessengerMessageKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listActionSlideActions(
      PartialMessage partialMessage, int index) {
    return [displayArchivedUnArchivedButton(partialMessage, index)];
  }

  Widget displayArchivedUnArchivedButton(
      PartialMessage partialMessage, int index) {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying archive icon by message's isArchivedByRecipient property and if it sender then
    // we are showing and modifying archive icon by message's isArchivedBySender property
    final bool isRecipient = userBloc.user.userName == partialMessage.recipient;

    final IconData actionIcon = isRecipient
        ? partialMessage.isArchivedByRecipient!
            ? SlydoAppIcon.unarchive
            : SlydoAppIcon.archive
        : partialMessage.isArchivedBySender!
            ? SlydoAppIcon.unarchive
            : SlydoAppIcon.archive;

    final String actionText = isRecipient
        ? partialMessage.isArchivedByRecipient!
            ? "Unarchive"
            : "Archive"
        : partialMessage.isArchivedBySender!
            ? "Unarchive"
            : "Archive";

    return SlideActionButton(
        backgroundColor: naturalGreen,
        icon: actionIcon,
        onTap: () async {
          final action = isRecipient
              ? partialMessage.isArchivedByRecipient!
                  ? "unarchive"
                  : "archive"
              : partialMessage.isArchivedBySender!
                  ? "unarchive"
                  : "archive";
          await _messageAuth.updateMessage(partialMessage.id!, action);
          setState(() {
            if (isRecipient) {
              partialMessage.isArchivedByRecipient =
                  partialMessage.isArchivedByRecipient! ? false : true;
            } else {
              partialMessage.isArchivedBySender =
                  partialMessage.isArchivedBySender! ? false : true;
            }
          });
        },
        title: actionText,
        slideController: slidableController);
  }

  void markArchivedUnArchivedMessage(PartialMessage partialMessage, int index) {
    setState(() {
      partialMessage.isArchivedByRecipient =
          partialMessage.isArchivedByRecipient! ? false : true;
    });
  }

  List<Widget> listSecondaryActions(PartialMessage partialMessage, int index) {
    return [displayDeleteButton(partialMessage, index)];
  }

  Widget displayDeleteButton(PartialMessage partialMessage, int index) {
    return SlideActionButton(
        backgroundColor: mateRed,
        icon: Icons.delete,
        onTap: () {
          deleteMessage(partialMessage, index);
        },
        title: AppLocalization.of(context)!.delete,
        slideController: slidableController);
  }

  void deleteMessage(PartialMessage partialMessage, int index) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.delete,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.delete,
      description: AppLocalization.of(context)!.areYouSureWantToDeleteThisMsg,
      actionOneText: AppLocalization.of(context)!.delete,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result == null) return;
    if (result) {
      // call delete message _auth method
      final bool done =
          await _messageAuth.deleteMessage(messageList[index].conversationID);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context)!.messageIsDeletedSuccessfully);
        setState(() {
          messageList.removeAt(index);
          if (messageList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, PartialMessage partialMessage, int index) {
    return Slidable(
      key: Key(partialMessage.id!),
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(partialMessage),
      actions: listActionSlideActions(partialMessage, index),
      secondaryActions: listSecondaryActions(partialMessage, index),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.partialMessage);

  final PartialMessage partialMessage;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pushNamed(Routes.DETAIL_MESSAGE,
            arguments: {'id': widget.partialMessage.id});
      },
      onDoubleTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": widget.partialMessage.sender});
      },
      onLongPress: () {
        setState(() {
          if (isExpanded) {
            isExpanded = false;
          } else {
            isExpanded = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: MessageTile(
            partialMessage: widget.partialMessage,
            expandedWidget: expandedWidget()),
      ),
    );
  }

  Widget expandedWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isExpanded ? 48 : 0,
      curve: Curves.fastOutSlowIn,
      child: isExpanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 1,
                  color: dividerColor,
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(child: sendMessageButton()),
                      Container(
                        width: 1,
                        color: dividerColor,
                        height: 48,
                      ),
                      Expanded(child: blockUserButton()),
                    ],
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget sendMessageButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: navyBlue.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.message,
                color: navyBlue,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.message,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.partialMessage.sender)
              .then((user) {
            setState(() {
              isExpanded = false;
            });
            Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
              'recipient': user.userName,
              'subject': "",
            });
          });
        },
      ),
    );
  }

  Widget blockUserButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.partialMessage.sender)
              .then((user) {
            UserAuth().blockUser(user).then((result) {
              setState(() {
                isExpanded = false;
              });
              if (result) {
                showToast(message: "${widget.partialMessage.sender} ");
              } else {
                showToast(message: AppLocalization.of(context)!.error);
              }
            });
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: mateRed.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.remove,
                color: mateRed,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.blockUser,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
