import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile_for_connection.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import '../../user_auth.dart';

class ConnectionList extends StatefulWidget {
  @override
  _ConnectionListState createState() => _ConnectionListState();
}

class _ConnectionListState extends State<ConnectionList> {
  final GlobalKey<ScaffoldState> _scaffoldContactsListKey =
      new GlobalKey<ScaffoldState>();
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

  RefreshBlocForConnectionDashboard _refreshBloc;
  ConnectionListBloc _connectionListBloc;

  @protected
  void initState() {
    fetchConnectionListFromDbIfAvailable();

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

  void fetchConnectionListFromDbIfAvailable() async {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        myGlobals.scaffoldKey.currentContext,
        listen: false);

    isLoading = true;
    if (mounted) setState(() {});

    int result = await connectionListBloc.getConnectionsCount();
    debugPrint("RESULT FROM CONNECTION LIST :- $result");
    if (result == 0) {
      isLoading = false;

      this.getList();
    }

    isLoading = false;
    if (mounted) setState(() {});
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
    // refresh the list when lifecycle called onResume method
    // _onRefreshOnResume();

    _connectionListBloc = Provider.of<ConnectionListBloc>(context);

    return Scaffold(
      key: _scaffoldContactsListKey,
      backgroundColor: lightGrey,
      // floatingActionButton: getFloatingActionBtn(),
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

  Widget getFloatingActionBtn() {
    bool isGroupUser = false;

    List<String> groupUsers = [
      "brijesh.sakariya",
      "abiola.rasheed.2",
      "olabisi.abraham.1",
      "black"
    ];
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    groupUsers.forEach((element) {
      if (element == userBloc.user.userName) {
        isGroupUser = true;
      }
    });

    return !isGroupUser
        ? null
        : FloatingActionButton(
            backgroundColor: navyBlue,
            child: Icon(Icons.add),
            onPressed: () {
              CustomerProfile user = CustomerProfile();
              _connectionListBloc.addTestConversationForGroup(user: user);
            },
          );
  }

  Widget _buildConnectionsList() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : FutureBuilder(
            future: Future.value(_connectionListBloc.connectionUsers),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  debugPrint("ConnectionState.none");
                  return Center(
                    child: CircularLoadingIndicator(),
                  );
                  break;
                case ConnectionState.waiting:
                  return Center(
                    child: CircularLoadingIndicator(),
                  );
                  break;
                case ConnectionState.active:
                  debugPrint("ConnectionState.active");
                  return Center(
                    child: CircularLoadingIndicator(),
                  );
                  break;
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return NoItemInList(
                        msg: "No connection found !!",
                        isResult: true,
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      //+1 for progressbar
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _getSlidableWithLists(
                            context, snapshot.data[index], index);
                      },
                      controller: _scrollController,
                    );
                  } else if (snapshot.hasError) {
                    debugPrint("ERROR:- ${snapshot.error}");
                    return Container();
                  }
                  debugPrint("ERROR While Loading Data 1");
                  return Container();
                  break;

                default:
                  debugPrint("ERROR While Loading Data 2");
                  return Container();
              }
            });
  }

  // Widget _buildConnectionsList() {
  //   return noItemInList
  //       ? NoItemInList(
  //           msg: "You Have No Connections",
  //         )
  //       : ListView.builder(
  //           padding: EdgeInsets.symmetric(
  //             vertical: 4,
  //           ),
  //           //+1 for progressbar
  //           itemCount: connectionsList.length + 1,
  //           itemBuilder: (BuildContext context, int index) {
  //             if (index == connectionsList.length) {
  //               return _buildIndicator();
  //             } else {
  //               return _getSlidableWithLists(
  //                   context, connectionsList[index], index);
  //             }
  //           },
  //           controller: _scrollController,
  //         );
  // }

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
    ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(context, listen: false);
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

        // debugPrint("List:- $tempList");

        List<CustomerProfile> users = List<CustomerProfile>();

        tempList
            .forEach((element) => users.add(CustomerProfile.fromJson(element)));

        isLoading = false;
        if (mounted) setState(() {});
        // connectionsList.addAll(users);

        connectionListBloc.setConnectionUsers(users: users);

        // ConnectionListManager().saveConnectionsToDB(connections: users);

        if (mounted) setState(() {});

        /// adding chat Users in database
        ChatUserManager().addUsers(users);
      }
      if (connectionListBloc.connectionUsers.isEmpty) {
        noItemInList = true;
        if (mounted) setState(() {});
      } else if (next == null &&
          connectionListBloc.connectionUsers.length > 6) {
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
      onTap: () async {
        ChatUserManager().clearChatUserMessageCount(
            conversationId: widget.user.conversationId);

        await Navigator.pushNamed(context, '/chat-screen',
            arguments: {"searchedUser": widget.user});
        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: UserTileForConnection(user: widget.user),
      ),
    );
  }
}
