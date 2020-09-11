import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/tiles/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class ConnectionList extends StatefulWidget {
  @override
  _ConnectionListState createState() => _ConnectionListState();
}

class _ConnectionListState extends State<ConnectionList> {
  final GlobalKey<ScaffoldState> _scaffoldContactsListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  SlidableController _slideController;
  int count = 0;
  String next = "";
  String previous = "";
  List connectionsList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

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
        connectionsList = [];
        noItemInList = false;
        getList();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldContactsListKey,
      backgroundColor: lightGrey,
      body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildConnectionsList()),
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
                return _getSlidableWithLists(
                    context, connectionsList[index], index);
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
        Map<String, dynamic> result = await _auth.contacts(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
        List<CustomerProfile> convertedIntoUserList = List<CustomerProfile>();
        tempList.forEach((element) {
          CustomerProfile user = CustomerProfile();
          user.fullName = element["full_name"] ?? "";
          user.userName = element["username"] ?? "";
          user.avatar = element["avatar"] ?? "";
          user.qrCode = element["qr_code"] ?? "";
          convertedIntoUserList.add(user);
        });
        if (mounted) {
          setState(() {
            isLoading = false;
            connectionsList.addAll(convertedIntoUserList);
          });
        }
      }
      if (connectionsList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
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
      // IconSlideAction(
      //   caption: AppLocalization.of(context).block,
      //   color: Colors.grey[600],
      //   icon: Icons.block,
      //   onTap: () {
      //     blockUserAlert(user, index);
      //   },
      // ),
      SlideActionButton(
        backgroundColor: mateRad,
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
      // IconSlideAction(
      //   caption: AppLocalization.of(context).delete,
      //   color: Colors.red,
      //   icon: Icons.remove_circle,
      //   onTap: () {
      //     unFriendUserAlert(user, index);
      //   },
      // ),
      SlideActionButton(
        backgroundColor: mateRad,
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
      title: AppLocalization.of(context).block,
      description: AppLocalization.of(context).areYouSureWantToBlock +
          " ${user.fullName}",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.blockUser(user);
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
      title: AppLocalization.of(context).delete,
      description: AppLocalization.of(context).areYouSureWantToDelete +
          " ${user.fullName} " +
          "From Your Connection List",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.removeFromContactList(user);
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

  Widget _getSlidableWithLists(
      BuildContext context, CustomerProfile user, int index) {
    return Slidable(
      key: Key(user.userName),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(user),
      actions: listActionSlideActions(user, index),
      secondaryActions: listSecondaryActions(user, index),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.user);
  final CustomerProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile',
          arguments: {"searchedUser": user}),
      child: Container(
        color: lightGrey,
        child: UserTile(user: user),
      ),
    );
  }
}
