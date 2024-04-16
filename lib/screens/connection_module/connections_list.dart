import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile_for_connection.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/search_text_field.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../locator.dart';
import '../../../../../routes/route_constants.dart';

class ConnectionList extends StatefulWidget {
  @override
  _ConnectionListState createState() => _ConnectionListState();
}

class _ConnectionListState extends State<ConnectionList> {
  final GlobalKey<ScaffoldState> _scaffoldContactsListKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerContactsListKey =
      new GlobalKey<ScaffoldMessengerState>();
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List connectionsList = [];
  ScrollController _scrollController = new ScrollController();

  bool isLoading = false;
  bool noItemInList = false;
  bool isLoadingFromDB = false;

  late ConnectionListBloc _connectionListBloc;

  TextEditingController? searchChatConversation;
  bool isUserIsSearching = false;
  List<ChatConversation> searchedChatConnection = [];

  RefreshBlocForConnectionDashboard? _refreshBloc;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AppConfigurationModel? appConfigurationModel;

  @protected
  void initState() {
    getList();

    fetchConnectionListFromDbIfAvailable();

    setupSearchChatConnection();

    super.initState();

    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

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

  void setupSearchChatConnection() {
    searchChatConversation = TextEditingController();

    searchChatConversation!.addListener(() {
      if (searchChatConversation!.text.isNotEmpty) {
        isUserIsSearching = true;
        if (mounted) setState(() {});
        getSearchedChatConnections();
      } else {
        isUserIsSearching = false;
        if (mounted) setState(() {});
      }
    });
  }

  void getSearchedChatConnections() async {
    searchedChatConnection = await ConnectionListManager()
        .getSearchedConnectionsFromDB(
            searchedText: searchChatConversation!.text.trim());
    if (mounted) setState(() {});
  }

  void fetchConnectionListFromDbIfAvailable() async {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        myGlobals.scaffoldKey.currentContext!,
        listen: false);

    isLoading = true;
    if (mounted) setState(() {});

    int result = await connectionListBloc.getConnectionsCount();
    debugPrint("RESULT FROM CONNECTION LIST :- $result");
    if (result == 0) {
      isLoading = false;
      refreshList();
    } else {
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // refresh the list when lifecycle called onResume method
    _onRefreshOnResume();
    _connectionListBloc = Provider.of<ConnectionListBloc>(context);

    return ScaffoldMessenger(
      key: _scaffoldMessengerContactsListKey,
      child: Scaffold(
        key: _scaffoldContactsListKey,
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: [
              getSearchTextField(),
              isUserIsSearching
                  ? Expanded(child: getSearchedUserListUI())
                  : Expanded(
                      child: getRefreshIndicator(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getRefreshIndicator() {
    return StreamBuilder<bool?>(
        initialData: false,
        stream: ChatMessageSynchronizer().getChatMessageFetchingStream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              IgnorePointer(
                ignoring: snapshot.data!,
                child: SmartRefresher(
                  enablePullDown: true,
                  header: WaterDropHeader(
                    complete: Container(),
                    waterDropColor: navyBlue,
                    refresh: CircularLoadingIndicator(),
                  ),
                  controller: _refreshController,
                  onRefresh: refreshList,
                  child: _buildConnectionsList(),
                ),
              ),
              if (snapshot.data!) showFetchingMessageUI()
            ],
          );
        });
  }

  Widget showFetchingMessageUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18), color: navyBlue),
            child: JumpingText(
              'Syncing Messages ...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForConnectionDashboard>(context);
    _refreshBloc?.addListener(() async {
      if (_refreshBloc?.isRefresh ?? false) {
        await refreshList();
        _refreshBloc?.isRefresh = false;
      }
    });
  }

  Future<void> refreshList() async {
    await ConnectionSynchronizer().fetch(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  Widget getSearchedUserListUI() {
    return searchedChatConnection.isEmpty
        ? NoItemInList(
            msg: "No Result found",
            isResult: true,
          )
        : Container(
            child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
              vertical: 4,
            ),
            //+1 for progressbar
            itemCount: searchedChatConnection.length,
            itemBuilder: (BuildContext context, int index) {
              return _getSlidableWithLists(
                  context, searchedChatConnection[index], index);
            },
            controller: _scrollController,
          ));
  }

  Widget getSearchTextField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
      child: SearchTextField(
        hintText: "Search my contacts",
        hintStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        onSubmit: () {
          getSearchedChatConnections();
        },
        textEditingController: searchChatConversation,
      ),
    );
  }

  /// If appConfigurationModel.groupChatWorks is false (i.e, we want to disable the groupChat feature),
  /// remove groupChat conversations from the list of connections.
  int getConnectionListItemCount() {
    int itemCount = 0;
    if (appConfigurationModel?.enableGroupChat == false) {
      _connectionListBloc.connectionUsers
          .removeWhere((element) => element.isGroupConversation! == true);
      itemCount = _connectionListBloc.connectionUsers.length;
    } else {
      itemCount = _connectionListBloc.connectionUsers.length;
    }

    return itemCount;
  }

  String noContactMsg = "No contact found\nPull down to refresh";

  Widget _buildConnectionsList() {
    try {
      return _connectionListBloc.connectionUsers.length == 0
          ? NoItemInList(msg: noContactMsg, isResult: true)
          : ListView.builder(
              shrinkWrap: true,
              // padding: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(bottom: 80.0),
              //+1 for progressbar
              itemCount: getConnectionListItemCount(),
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (BuildContext context, int index) {
                ChatConversation chatConversation =
                    _connectionListBloc.connectionUsers[index];

                if (appConfigurationModel?.enableGroupChat == false) {
                  if (chatConversation.isGroupConversation!) {
                    return SizedBox.shrink();
                  }
                }
                return _getSlidableWithLists(
                    context, _connectionListBloc.connectionUsers[index], index);
              },
              controller: _scrollController,
            );
    } catch (error) {
      debugPrint("ERROR building list =>:- $error");
      return _connectionListBloc.connectionUsers.length == 0
          ? NoItemInList(
              msg: noContactMsg,
              isResult: true,
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 4),
              //+1 for progressbar
              itemCount: _connectionListBloc.connectionUsers.length,
              // physics: const BouncingScrollPhysics(
              //     parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (BuildContext context, int index) {
                return _getSlidableWithLists(
                    context, _connectionListBloc.connectionUsers[index], index);
              },
              controller: _scrollController,
            );
    }
  }

  void getList() async {
    ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(context, listen: false);
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});
        Map<String, dynamic>? result =
            await UserAuth().contacts(next, previous);
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];

        List tempList = result['results'];

        debugPrint("List:- $tempList");

        List<ChatConversation> users = [];

        tempList.forEach(
            (element) => users.add(ChatConversation.fromJson(element)));

        // connectionsList.addAll(users);
        debugPrint("List Length users:- ${users.length}");

        connectionListBloc.setConnectionUsers(users: users);

        isLoading = false;
        if (mounted) setState(() {});

        // ConnectionListManager().saveConnectionsToDB(connections: users);

        // if (mounted) setState(() {});

        /// adding chat Users in database
        ChatUserManager().addUsers(users);
      }
      if (connectionListBloc.connectionUsers.isEmpty) {
        noItemInList = true;
        if (mounted) setState(() {});
      } else if (next == null &&
          connectionListBloc.connectionUsers.length > 6) {
        _scaffoldMessengerContactsListKey.currentState?.showSnackBar(SnackBar(
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
    _scaffoldMessengerContactsListKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(ChatConversation user, int index) {
    if (user.userName.toString().toLowerCase() == 'slydo') {
      return [];
    }

    if (user.isGroupConversation!) {
      return [];
    }
    CustomerProfile customerProfile =
        CustomerProfile.fromChatConversation(user);

    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.block,
        onTap: () {
          blockUserAlert(customerProfile);
        },
        title: AppLocalization.of(context)!.block,
        slideController: _slideController,
      ),
    ];
  }

  List<Widget> listActionSlideActions(
      ChatConversation chatConversation, int index) {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    if (chatConversation.userName.toString().toLowerCase() == 'slydo') {
      return [];
    }

    if (chatConversation.isGroupConversation!) {
      if (userBloc.user.userName == chatConversation.owner) {
        return [];
      }

      return [
        SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.leave,
          onTap: () {
            exitTheGroupAlert(chatConversation, index);
          },
          title: "Exit",
          slideController: _slideController,
        ),
      ];
    }

    CustomerProfile customerProfile =
        CustomerProfile.fromChatConversation(chatConversation);

    return [
      SlideActionButton(
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove_connection,
        onTap: () {
          removeFromConnectionUserAlert(customerProfile, index);
        },
        title: AppLocalization.of(context)!.remove,
        slideController: _slideController,
      ),
    ];
  }

  void blockUserAlert(CustomerProfile user) async {
    bool? result = await showDialogBox(
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
      title: AppLocalization.of(context)!.block,
      description: AppLocalization.of(context)!.areYouSureWantToBlock +
          " ${user.displayName()}",
      actionOneText: AppLocalization.of(context)!.block,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await UserAuth().blockUser(user);
      // done = true;
      if (done) {
        _showSnackBar(
            context,
            "${user.displayName()} " +
                AppLocalization.of(context)!.isBlockedSuccessfully);
        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: user.conversationId);

        if (connectionsList.length <= 9) {
          getList();
        }
        setState(() {});
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Future<void> exitTheGroupAlert(
      ChatConversation chatConversation, int index) async {
    bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.leave,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: "Exit",
      description: "Are you sure want to leave ${chatConversation.fullName} ?",
      actionOneText: "Exit",
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await MessageAuth()
          .exitFromGroup(conversationId: chatConversation.conversationId!);
      if (done) {
        _showSnackBar(context, "You left ${chatConversation.fullName}");

        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: chatConversation.conversationId);

        setState(() {});
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Future<void> removeFromConnectionUserAlert(
      CustomerProfile user, int index) async {
    bool? result = await showDialogBox(
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
      description: AppLocalization.of(context)!.areYouSureWantToDelete +
          " ${user.displayName()} " +
          "From Your friends List",
      actionOneText: AppLocalization.of(context)!.delete,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      bool done = await UserAuth().removeFromContactList(user);
      if (done) {
        _showSnackBar(
            context,
            "${user.displayName()} " +
                AppLocalization.of(context)!.isRemovedSuccessfully);

        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: user.conversationId);
        if (mounted) setState(() {});
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, ChatConversation user, int index) {
    return Slidable(
      key: Key(user.userName ?? ''),
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
    // _refreshController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.user);

  final ChatConversation user;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
        if (userBloc.user.staff != null) {
          showToast(message: AppLocalization.of(context)?.doNotPermission);
        } else {
          ChatUserManager().clearChatUserMessageCount(
              conversationId: widget.user.conversationId);

          await Navigator.pushNamed(context, Routes.CHAT_SCREEN,
              arguments: {"searchedUser": widget.user});
        }

        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: UserTileForConnection(user: widget.user),
      ),
    );
  }
}
