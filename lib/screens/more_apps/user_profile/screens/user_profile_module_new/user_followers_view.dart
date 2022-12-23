import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../user_auth.dart';

class UserFollowersView extends StatefulWidget {
  String? userName;
  UserFollowersView({Key? key, this.userName}) : super(key: key);

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

        Map<String, dynamic>? result =
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
        var tempList = result['results'];
        // yarnTopicList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            userFollowers.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $userFollowers");
      }
    }
    if (userFollowers.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    } else if (next == null && userFollowers.length > 6) {
      // _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
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
    return _buildMain(userImages: userFollowers);
  }

  Widget _buildMain({List<UserFollowers>? userImages}) {
    int count = userImages!.length;
    if (count == 0) {
      return SizedBox();
    } else if (4 > count) {
      return _buildStackedImages(images: userImages);
    } else if (4 <= count) {
      return _buildMultiViwer(userImages: userImages);
    } else {
      return SizedBox();
    }
  }

  Widget _buildMultiViwer({List<UserFollowers>? userImages}) {
    final double size = 32;
    final double xShift = 10;
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: StackedWidgets(
        size: size,
        xShift: xShift,
        items: [
          ...List.generate(
              4, (index) => buildImage(userImages![index].avatar ?? "")),
          if (userImages != null && userImages.length != 4) _buildText(),
        ],
      ),
    );
  }

  Widget _buildText() {
    int count = userFollowers.length - 4;
    return Container(
      height: 32,
      width: 32,
      padding: EdgeInsets.all(2),
      child: ClipOval(
        child: Container(
          color: Colors.black,
          child: Center(
              child: Text(
            "+$count",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildStackedImages({
    List<UserFollowers>? images,
  }) {
    if (images!.length != 0) {
      final double size = 32;
      final double xShift = 10;
      final items =
          images.map((image) => buildImage(image.avatar ?? "")).toList();

      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: StackedWidgets(
          items: items,
          size: size,
          xShift: xShift,
        ),
      );
    }
    return SizedBox();
  }
}
