import 'package:Slydo/data/state_notifier.dart';
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
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class ConnectionRequestList extends StatefulWidget {
  @override
  _ConnectionRequestListState createState() => _ConnectionRequestListState();
}

class _ConnectionRequestListState extends State<ConnectionRequestList> {
  final GlobalKey<ScaffoldState> _scaffoldContactRequestListKey =
      new GlobalKey<ScaffoldState>();
  UserBloc userBloc;
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List connectionRequestList = [];
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
        connectionRequestList = [];
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
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      key: _scaffoldContactRequestListKey,
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
            msg: "You Have No Connection Request",
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

  Map<String, dynamic> cleanDisplayData(var data) {
    if (data["from_user"]["username"] == userBloc.user.userName) {
      return data["to_user"];
    } else {
      return data["from_user"];
    }
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic> result =
            await _auth.listContactRequests(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
        List<CustomerProfile> convertedIntoUserList = List<CustomerProfile>();
        tempList.forEach((element) {
          var data = cleanDisplayData(element);
          debugPrint(data.toString());
          CustomerProfile user = CustomerProfile();
          user.fullName = data["full_name"] ?? "";
          user.userName = data["username"] ?? "";
          user.avatar = data["avatar"] ?? "";
          user.qrCode = data["qr_code"] ?? "";
          convertedIntoUserList.add(user);
        });
        if (mounted) {
          setState(() {
            isLoading = false;
            connectionRequestList.addAll(convertedIntoUserList);
          });
        }
      }
      if (connectionRequestList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && connectionRequestList.length > 6) {
        _scaffoldContactRequestListKey.currentState.showSnackBar(SnackBar(
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
    _scaffoldContactRequestListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    String caption = AppLocalization.of(context).reject;

    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () async {
            rejectRequestAlert(user, index);
          }),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    return [
      IconSlideAction(
        caption: AppLocalization.of(context).accept,
        color: Colors.green,
        icon: Icons.group_add,
        onTap: () {
          acceptFriendRequestAlert(user, index);
        },
      ),
    ];
  }

  void rejectRequestAlert(CustomerProfile user, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: AppLocalization.of(context).reject,
      description:
          AppLocalization.of(context).areYouSureWantToRejectRequestFrom +
              " ${user.fullName}",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.rejectContactRequest(user);
      done = true;
      if (done) {
        _showSnackBar(
            context,
            AppLocalization.of(context).requestFrom +
                " ${user.fullName} " +
                AppLocalization.of(context).isRejectedSuccessfully);
        setState(() {
          connectionRequestList.removeAt(index);
          if (connectionRequestList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> acceptFriendRequestAlert(CustomerProfile user, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: AppLocalization.of(context).accept,
      description: AppLocalization.of(context).areYouSureWantToAdd +
          " ${user.fullName} " +
          "In Your Connections",
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).no,
      type: AlertType.warning,
    );
    if (result) {
      bool done = await _auth.acceptContactRequest(user);
      if (done) {
        _showSnackBar(
            context,
            "${user.fullName} " +
                AppLocalization.of(context).isAddedToYourContactList);
        setState(() {
          connectionRequestList.removeAt(index);
          if (connectionRequestList.length <= 9) {
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
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: lightBlue(),
        child: UserTile(user: user),
      ),
    );
  }
}
