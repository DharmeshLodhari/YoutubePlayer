import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../routes/route_constants.dart';

class ConnectionRequestList extends StatefulWidget {
  @override
  _ConnectionRequestListState createState() => _ConnectionRequestListState();
}

class _ConnectionRequestListState extends State<ConnectionRequestList> {
  final GlobalKey<ScaffoldState> _scaffoldContactRequestListKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState>
      _scaffoldMessengerContactRequestListKey =
      new GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List connectionRequestList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  ScrollController _scrollController = new ScrollController();

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

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        connectionRequestList = [];
        noItemInList = false;
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    // refresh the list when lifecycle called onResume method
    // _onRefreshOnResume();
    return ScaffoldMessenger(
      key: _scaffoldMessengerContactRequestListKey,
      child: Scaffold(
        key: _scaffoldContactRequestListKey,
        backgroundColor: lightGrey,
        body: _buildScaffoldBody(),
      ),
    );
  }

  Widget _buildScaffoldBody() {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: _buildFriendsList(),
    );
  }

  String noConnectionRequestMsg =
      "You have no friend request\nPull down to refresh";
  Widget _buildFriendsList() {
    return noItemInList
        ? NoItemInList(
            msg: noConnectionRequestMsg,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 4,
            ),
            //+1 for progressbar
            itemCount: connectionRequestList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == connectionRequestList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(
                    context, connectionRequestList[index], index);
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
        Map<String, dynamic>? result = await UserAuth()
            .listContactRequests(next, previous)
            .catchError((error) {
          debugPrint("ERROR:- $error");
          //  return;
        });
        if (result == null) return;
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];

        isLoading = false;
        connectionRequestList.addAll(tempList);
        Provider.of<ConnectionRequestListBloc>(context, listen: false)
            .setHasConnectionRequests = connectionRequestList.isNotEmpty;

        if (mounted) setState(() {});
      }
      if (connectionRequestList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && connectionRequestList.length > 6) {
        _scaffoldMessengerContactRequestListKey.currentState!
            .showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldMessengerContactRequestListKey.currentState!
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(Map data, int index) {
    CustomerProfile fromUser = CustomerProfile.fromJson(data["from_user"]);
    CustomerProfile toUser = CustomerProfile.fromJson(data["to_user"]);

    bool isRequestSent = fromUser.userName == userBloc.user.userName;
    return isRequestSent
        ? []
        : [
            SlideActionButton(
              backgroundColor: navyBlue,
              icon: SlydoAppIcon.send_connection_request,
              onTap: () {
                acceptFriendRequestAlert(
                    isRequestSent ? toUser : fromUser, index);
              },
              title: AppLocalization.of(context)!.accept,
              slideController: _slideController,
            ),
          ];
  }

  List<Widget> listActionSlideActions(Map data, int index) {
    CustomerProfile fromUser = CustomerProfile.fromJson(data["from_user"]);
    CustomerProfile toUser = CustomerProfile.fromJson(data["to_user"]);

    bool isRequestSent = fromUser.userName == userBloc.user.userName;

    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.cancel_connection_request,
        onTap: () {
          rejectRequestAlert(isRequestSent ? toUser : fromUser, index,
              isRequestSent: isRequestSent);
        },
        title: isRequestSent
            ? AppLocalization.of(context)!.cancel
            : AppLocalization.of(context)!.reject,
        slideController: _slideController,
      ),
    ];
  }

  void rejectRequestAlert(CustomerProfile user, int index,
      {required bool isRequestSent}) async {
    bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.reject,
      description: isRequestSent
          ? "Are you sure want to cancel the request?"
          : AppLocalization.of(context)!.areYouSureWantToRejectRequestFrom +
              " ${user.displayName()}",
      actionOneText: isRequestSent
          ? AppLocalization.of(context)!.yes
          : AppLocalization.of(context)!.reject,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await UserAuth().cancelOrRejectContactRequest(user);
      done = true;
      if (done) {
        _showSnackBar(
            context,
            isRequestSent
                ? "Request canceled successfully !!"
                : AppLocalization.of(context)!.requestFrom +
                    " ${user.displayName()} " +
                    AppLocalization.of(context)!.isRejectedSuccessfully);
        setState(() {
          connectionRequestList.removeAt(index);
          if (connectionRequestList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Future<void> acceptFriendRequestAlert(CustomerProfile user, int index) async {
    bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.true_icon,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: navyBlue,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: false,
      title: AppLocalization.of(context)!.accept,
      description: messageDecoderWithEmoji("Are you sure you want to add" +
          " ${user.displayName()} " +
          "as a friend?"),
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.accept,
    );
    if (result != null && result) {
      bool done = await UserAuth().acceptContactRequest(user);
      if (done) {
        _showSnackBar(
            context,
            "${user.displayName()} " +
                AppLocalization.of(context)!.isAddedToYourContactList);

        connectionRequestList.removeAt(index);

        RefreshBlocForConnectionDashboard refreshBloc =
            Provider.of<RefreshBlocForConnectionDashboard>(context,
                listen: false);

        if (mounted) {
          _onRefresh();
          refreshBloc.isRefresh = false;
        }

        if (connectionRequestList.length <= 9) {
          getList();
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Widget _getSlidableWithLists(BuildContext context, Map data, int index) {
    return Slidable(
      key: Key(data["id"].toString()),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(data),
      actions: listActionSlideActions(data, index),
      secondaryActions: listSecondaryActions(data, index),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.data);

  final Map data;

  late UserBloc userBloc;

  Map<String, dynamic>? cleanDisplayData(var data) {
    if (data["from_user"]["username"] == userBloc.user.userName) {
      return data["to_user"];
    } else {
      return data["from_user"];
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    CustomerProfile user = CustomerProfile.fromJson(cleanDisplayData(data)!);

    return GestureDetector(
      onTap: () {
        Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
            ? Slidable.of(context)?.open()
            : Slidable.of(context)?.close();
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": user.userName});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: UserTile(user: user),
      ),
    );
  }
}
