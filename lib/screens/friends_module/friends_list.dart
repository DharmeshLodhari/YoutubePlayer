//TODO: APP LOCALIZATION
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final GlobalKey<ScaffoldState> _scaffoldFriendsListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List friendsList = [];
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
          _scrollController.position.maxScrollExtent) {
        getList();
      }
    });
    slidableController = SlidableController(
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
        friendsList = [];
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
      key: _scaffoldFriendsListKey,
      backgroundColor: lightBlue(),
      body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: darkBlue(),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildFriendsList()),
    );
  }

  Widget _buildFriendsList() {
    return noItemInList
        ? NoItemInList(
            msg: "Currently You Have No Any Friends",
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 4,
            ),
            //+1 for progressbar
            itemCount: friendsList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == friendsList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(
                    context, friendsList[index], index);
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
            child: isLoading
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  )
                : Container()),
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
        Map<String, dynamic> result = await _auth.listFriends(next, previous);
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
            friendsList.addAll(convertedIntoUserList);
          });
        }
      }
      if (friendsList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && friendsList.length > 6) {
        _scaffoldFriendsListKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          getList();
        });
      }
    }
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldFriendsListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    return [
      IconSlideAction(
        caption: "Block",
        color: Colors.red,
        icon: Icons.block,
        onTap: () {
          blockUserAlert(user, index);
        },
      ),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    return [
      IconSlideAction(
        caption: "UnFriend",
        color: Colors.red,
        icon: Icons.remove_circle,
        onTap: () {
          unFriendUserAlert(user, index);
        },
      ),
    ];
  }

  void blockUserAlert(CustomerProfile user, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: "Block",
      description: "Are You Sure Want To Block ${user.fullName}",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.blockUser(user);
      done = true;
      if (done) {
        _showSnackBar(context, "${user.fullName} is Blocked Successfully");
        setState(() {
          friendsList.removeAt(index);
          if (friendsList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> unFriendUserAlert(CustomerProfile user, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: "UnFriend",
      description: "Are You Sure Want To Unfriend ${user.fullName}",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.unFriendUser(user);
      if (done) {
        _showSnackBar(
            context, "${user.fullName} is Removed From Your Friend List");
        setState(() {
          friendsList.removeAt(index);
          if (friendsList.length <= 9) {
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
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(user),
      actions: listActionSlideActions(user, index),
      secondaryActions: listSecondaryActions(user, index),
    );
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
        color: lightBlue(),
        child: CustomerTile(user: user),
      ),
    );
  }
}
