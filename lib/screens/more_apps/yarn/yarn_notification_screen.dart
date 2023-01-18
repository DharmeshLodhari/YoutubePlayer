import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/notification_view.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/material.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/colors.dart';
import '../../../widget/noItemInList.dart';
import 'models/Topics/Notifications.dart';

class YarnNotification extends StatefulWidget {
  const YarnNotification({Key? key}) : super(key: key);

  @override
  State<YarnNotification> createState() => _YarnNotificationState();
}

class _YarnNotificationState extends State<YarnNotification> {
  bool isLoading = false;
  String? next = "", previous = "";
  List<Notifications> notificationList = [];
  int count = 0;
  bool noList = false;

  void getAllNotification() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth().getAllNotification(
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
        var tempList = result['results'];

        // print('tempList:::: ${tempList.runtimeType}');
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            notificationList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $notificationList");
      }
      if (notificationList.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  @override
  void initState() {
    getAllNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
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
      elevation: 0,
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
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Divider(),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: notificationList.length + 1,
            itemBuilder: (context, index) {
              if (index == notificationList.length) {
                return _buildLoadingIndicator();
              }
              return InkWell(
                  onTap: () {
                    // NavigationUtil.push(context,
                    //     screen: YarnDetailScreen(
                    //         yarnId: notificationList[index].yarn,
                    //         yarn: yarnTopicList![index]));
                    print('Notify:: ${notificationList.runtimeType}');
                    print('Notify:: ${notificationList[index].id}');
                    // print('Notify:: ${yarnTopicList}');
                  },
                  child: _buildListView(notificationList[index]));
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          ),
        )
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isLoading ? 1.0 : 00,
      child: isLoading ? YarnShimmer() : Container(),
    );
  }

  Widget _buildListView(Notifications notification) {
    if (noList) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.noResultFound,
      );
    }
    return AskNotificationView(
      notification: notification,
    );
  }
}
