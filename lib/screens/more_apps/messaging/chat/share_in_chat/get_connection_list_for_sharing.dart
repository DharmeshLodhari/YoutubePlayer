import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class GetUserConnectionList extends StatefulWidget {
  @override
  _GetUserConnectionListState createState() => _GetUserConnectionListState();
}

class _GetUserConnectionListState extends State<GetUserConnectionList> {
  final GlobalKey<ScaffoldState> _scaffoldContactsListKey =
      new GlobalKey<ScaffoldState>();
  SlidableController _slideController;
  int count = 0;
  String next = "";
  String previous = "";
  List connectionsList = [];
  ScrollController _scrollController = new ScrollController();

  bool isLoading = false;
  bool noItemInList = false;

  RefreshBlocForConnectionDashboard _refreshBloc;

  @protected
  void initState() {
    this.getList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldContactsListKey,
      backgroundColor: lightGrey,
      body: _buildConnectionsList(),
    );
  }

  Widget _buildConnectionsList() {
    return noItemInList
        ? NoItemInList(
            msg: "You Have No Connections",
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 4,
            ),
            //+1 for progressbar
            itemCount: connectionsList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == connectionsList.length) {
                return _buildIndicator();
              } else {
                return ShareToUserTile(
                  user: connectionsList[index],
                );
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

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic> result = await UserAuth().contacts(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];

        List tempList = result['results'];
        List<CustomerProfile> users = List<CustomerProfile>();

        tempList
            .forEach((element) => users.add(CustomerProfile.fromJson(element)));

        isLoading = false;
        connectionsList.addAll(users);

        if (mounted) setState(() {});

        /// adding chat Users in database
        ChatUserManager().addUsers(users);
      }
      if (connectionsList.isEmpty) {
        noItemInList = true;
        if (mounted) setState(() {});
      } else if (next == null && connectionsList.length > 6) {
        _scaffoldContactsListKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldContactsListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.block,
        onTap: () {
          blockUserAlert(user, index);
        },
        title: AppLocalization.of(context).block,
        slideController: _slideController,
      ),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove_connection,
        onTap: () {
          removeFromConnectionUserAlert(user, index);
        },
        title: AppLocalization.of(context).remove,
        slideController: _slideController,
      ),
    ];
  }

  void blockUserAlert(CustomerProfile user, int index) async {
    bool result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.block,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context).block,
      description: AppLocalization.of(context).areYouSureWantToBlock +
          " ${user.fullName}",
      actionOne: AppLocalization.of(context).block,
      actionTwo: AppLocalization.of(context).cancel,
    );
    if (result) {
      bool done = await UserAuth().blockUser(user);
      done = true;
      if (done) {
        _showSnackBar(
            context,
            "${user.fullName} " +
                AppLocalization.of(context).isBlockedSuccessfully);
        setState(() {
          connectionsList.removeAt(index);
          if (connectionsList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> removeFromConnectionUserAlert(
      CustomerProfile user, int index) async {
    bool result = await showDialogBox(
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
      title: AppLocalization.of(context).delete,
      description: AppLocalization.of(context).areYouSureWantToDelete +
          " ${user.fullName} " +
          "From Your Connection List",
      actionOne: AppLocalization.of(context).delete,
      actionTwo: AppLocalization.of(context).cancel,
    );
    if (result) {
      bool done = await UserAuth().removeFromContactList(user);
      if (done) {
        _showSnackBar(
            context,
            "${user.fullName} " +
                AppLocalization.of(context).isRemovedSuccessfully);
        setState(() {
          connectionsList.removeAt(index);
          if (connectionsList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ShareToUserTile extends StatefulWidget {
  CustomerProfile user;

  ShareToUserTile({this.user});

  @override
  _ShareToUserTileState createState() => _ShareToUserTileState();
}

class _ShareToUserTileState extends State<ShareToUserTile> {
  bool isSelected = false;
  Widget avatarImage;

  Color borderColor;

  ShareMessageToChatBloc _shareMessageToChatBloc;

  @override
  void initState() {
    borderColor = getUserTypeColor(user: widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _shareMessageToChatBloc = Provider.of<ShareMessageToChatBloc>(context);
    return getTile();
  }

  Widget getAvatar() {
    return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.user.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : widget.user.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ));
  }

  Widget getTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: GestureDetector(
        onTap: () {
          isSelected = !isSelected;
          if (isSelected) {
            _shareMessageToChatBloc.addRecipient(customerProfile: widget.user);
          } else {
            _shareMessageToChatBloc.removeRecipient(
                customerProfile: widget.user);
          }

          setState(() {});
        },
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            dense: true,
            title: getTitle(),
            subtitle: getSubtitle(),
            leading: getAvatar(),
            trailing: getTrailing(),
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      widget.user.fullName,
      maxLines: 1,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getSubtitle() {
    return Text(
      widget.user.userName,
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
    return Container(
      child: Icon(
        isSelected
            ? Icons.radio_button_checked_outlined
            : Icons.radio_button_off_outlined,
        color: isSelected ? navyBlue : dividerColor,
      ),
    );
  }
}
