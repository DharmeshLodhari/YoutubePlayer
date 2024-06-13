import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BlockedList extends StatefulWidget {
  const BlockedList({super.key});

  @override
  State<BlockedList> createState() => _BlockedListState();
}

class _BlockedListState extends State<BlockedList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldBlockListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldBlockMessengerListKey =
      GlobalKey<ScaffoldMessengerState>();

  int? count = 0;
  String? next = "";
  String? previous = "";
  List blockList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  @override
  void initState() {
    getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    super.initState();
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      count = 0;
      next = "";
      previous = "";
      blockList = [];
      noItemInList = false;
      getList();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    // refresh the list when lifecycle called onResume method
    // _onRefreshOnResume();

    return ScaffoldMessenger(
      key: _scaffoldBlockMessengerListKey,
      child: Scaffold(
        key: _scaffoldBlockListKey,
        backgroundColor: lightGrey,
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Column(
              children: [
                Expanded(child: _buildFriendsList()),
                const SizedBox(height: 80),
              ],
            )),
      ),
    );
  }

  String noBlockedListMsg = "No Blocked Users\nPull down to refresh";
  Widget _buildFriendsList() {
    return noItemInList
        ? NoItemInList(
            msg: noBlockedListMsg,
          )
        : isLoading && blockList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 4, right: 4, bottom: 80.0),
                  //+1 for progressbar
                  itemCount: blockList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == blockList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return _getSlidableWithLists(
                          context, blockList[index], index);
                    }
                  },
                  controller: _scrollController,
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
        final Map<String, dynamic>? result =
            await UserAuth().listBlockUsers(next, previous).catchError((error) {
          debugPrint("ERROR:- $error");
          //  return;
        });
        if (result == null) return;

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final List tempList = result['results'];

        final List<CustomerProfile> users = [];

        for (var element in tempList) {
          users.add(CustomerProfile.fromJson(element));
        }

        isLoading = false;
        blockList.addAll(users);

        if (mounted) setState(() {});
      }
      if (blockList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && blockList.length > 6) {
        _scaffoldBlockMessengerListKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldBlockMessengerListKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(CustomerProfile user, int index) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        backgroundColor: naturalGreen,
        icon: SlydoAppIcon.unblock,
        onPressed: (context) {
          unBlockUserAlert(user, index);
        },
        label: AppLocalization.of(context)!.unblock,
      ),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user, int index) {
    return [];
  }

  void unBlockUserAlert(CustomerProfile user, int index) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: naturalGreen.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.unblock,
          color: naturalGreen,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: false,
      title: AppLocalization.of(context)!.unblock,
      description:
          "${AppLocalization.of(context)!.areYouSureWantToUnblock} ${user.displayName()}",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.accept,
    );
    if (result != null && result) {
      bool done = await UserAuth().unBlockUser(user);
      done = true;
      if (done) {
        _showSnackBar(context,
            "${user.displayName()} ${AppLocalization.of(context)!.isUnblockedSuccessfully}");
        setState(() {
          blockList.removeAt(index);
          if (blockList.length <= 9) {
            getList();
          }
        });
      }
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, CustomerProfile user, int index) {
    return Slidable(
      key: Key(user.userName!),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(user, index),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(user, index),
      ),
      child: VerticalListItem(user),
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
  const VerticalListItem(this.user, {super.key});

  final CustomerProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final slidableController = Slidable.of(context);
        if (slidableController != null) {
          if (slidableController.actionPaneType == ActionPaneType.none) {
            slidableController.openEndActionPane();
          } else {
            slidableController.close();
          }
        }
        // Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
        //     ? Slidable.of(context)?.open()
        //     : Slidable.of(context)?.close();
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": user.userName});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: UserTile(user: user),
      ),
    );
  }
}
