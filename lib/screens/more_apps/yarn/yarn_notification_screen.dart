import 'package:Slydo/screens/more_apps/yarn/widgets/notification_view.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import '../../../widget/no_item_in_list.dart';
import 'models/Topics/Notifications.dart';

class YarnNotification extends StatefulWidget {
  final Function(bool)? onDeleteNotification;

  YarnNotification({Key? key, this.onDeleteNotification}) : super(key: key);

  @override
  State<YarnNotification> createState() => _YarnNotificationState();
}

class _YarnNotificationState extends State<YarnNotification> {
  bool isLoading = false;
  String? next = "", previous = "";
  List<Notifications> notificationList = [];
  int count = 0;
  bool noList = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  void getAllNotification() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result =
            await YarnAuth().getAllNotification(
          next,
          previous ?? "",
        );

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];

        // debugPrint('tempList:::: ${tempList.runtimeType}');
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            notificationList.addAll(tempList);
          });
        }
      }
      if (notificationList.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    getAllNotification();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getAllNotification();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: yarnBlack,
        ),
        controller: refreshController,
        onRefresh: onRefresh,
        child: _buildListView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Notification",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      shadowColor: greySecondaryYarn,
    );
  }

  Widget _buildListView() {
    if (!noList) {
      return ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: notificationList.length + 1,
        itemBuilder: (context, index) {
          if (index == notificationList.length) {
            return buildShimmerLoadingIndicator(isLoading: isLoading);
          }
          return AskNotificationView(
            notification: notificationList[index],
            onDeleteNotification: (Notifications notifications) {
              final int index = notificationList
                  .indexWhere((element) => element.id == notifications.id);
              if (index != -1) {
                notificationList.removeAt(index);
                //send callback to refresh notification count
                widget.onDeleteNotification!(true);
                if (mounted) setState(() {});
              }
              // onRefresh();
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    }
    return NoItemInList(
      msg: AppLocalization.of(context)!.noResultFound,
    );
  }

  void onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        notificationList = [];
        if (mounted) setState(() {});

        getAllNotification();
        setState(() {
          refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          refreshController.refreshCompleted();
        });
      }
    });
  }
}
