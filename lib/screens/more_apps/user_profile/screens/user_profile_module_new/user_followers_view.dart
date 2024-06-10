import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../user_auth.dart';

class UserFollowersView extends StatefulWidget {
  final String? userName;
  UserFollowersView({super.key, this.userName});

  @override
  State<UserFollowersView> createState() => _UserFollowersViewState();
}

class _UserFollowersViewState extends State<UserFollowersView> {
  bool isLoading = false;
  String? next = "", previous = "";
  List<UserFollowers> userFollowers = [];
  int count = 0;
  bool noList = false;

  void getUserFollowersList(String userName) async {
    debugPrint("NEXT URL1:- $next");
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic> result =
            await UserAuth().fetchCustomerFollowers(userName);

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
        // yarnTopicList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            userFollowers.addAll(tempList);
          });
        }
        debugPrint("User Followers::: $userFollowers");
      }
    }
    if (userFollowers.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    } else if (next == null && userFollowers.length > 6) {
      // _askCategoriesScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      //   content:
      //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //   duration: Duration(milliseconds: 500),
      // ));
    }
  }

  @override
  void initState() {
    getUserFollowersList(widget.userName ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return followersWidget(userImages: userFollowers);
  }
}
