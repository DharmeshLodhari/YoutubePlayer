import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/channel_profile_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/default_user_profile_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/custom_profile_model.dart';
import 'profile_template/business_profile_screen.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  final dynamic arguments;

  UserProfileScreen({required this.arguments});

  @override
  _UserProfileScreenState createState() =>
      _UserProfileScreenState(arguments: arguments);
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> arguments;
  late UserBloc userBloc;

  bool isLoading = true;

  _UserProfileScreenState({required this.arguments});

  int currentIndex = 1;
  BehaviorSubject<int> selectedIndexStream = BehaviorSubject<int>();
  CustomerProfile? searchedUser;
  String? searchedUserName;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  double? top;

  late CustomerProfileBloc customerProfileBloc;
  CustomProfileModel customProfileModel = CustomProfileModel();
  Map<String, dynamic>? result = {};

  bool appBarStatus = true;

  bool isInRequestList = false;
  Map<String, dynamic> channelDetail = {};
  CustomerProfile? user;

  @override
  void initState() {
    initializeVariables();

    super.initState();
  }

  void initializeVariables() async {
    await getSearchedUser();
    currentIndex = arguments['index'] ?? 0;
    debugPrint('CURRENT INDEX -> $currentIndex');
    selectedIndexStream.sink.add(currentIndex);
    if (mounted) setState(() {});
  }

  Future<void> getSearchedUser({bool load = true}) async {
    searchedUserName = arguments['searchedUserName'].toString();

    if (load) {
      isLoading = true;
      if (mounted) setState(() {});
    }

    if (arguments['channel'] != null) {
      Map<String, dynamic>? data;

      try {
        data =
            await MessageAuth().getSingleChannel(channelId: searchedUserName);

        if (data == null) {
          Navigator.pop(context);
          showToast(message: 'Something went wrong');
          return;
        } else if (data != null && data.isNotEmpty) {
          channelDetail.addAll(data['results']);
        } else {
          showToast(message: 'Something went wrong');
        }
      } catch (e) {
        Navigator.pop(context);
        showToast(message: 'Channel not found');
      }

      isLoading = false;
      if (mounted) setState(() {});

      return;
    }

    try {
      user = await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    } catch (e) {
      Navigator.pop(context);
      showToast(message: 'User not found');
    }

    searchedUser = user;

    checkCurrentUserIsInRequestList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void checkCurrentUserIsInRequestList() async {
    final UserBloc _userBloc = Provider.of<UserBloc>(context, listen: false);
    debugPrint("is In Request List -");

    if (_userBloc.user.userName != searchedUser?.userName) {
      UserAuth().checkInRequest(searchedUser?.userName).then((value) {
        if (mounted) {
          setState(() {
            debugPrint("is In Request List : $isInRequestList");

            if (value == true) {
              isInRequestList = true;
            } else {
              isInRequestList = false;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    if (isLoading) {
      return Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (userBloc.user.userName == searchedUser?.userName) {
      isOwner = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return await Future.value(true);
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(body: checkView()),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          searchedUser = null;
          Navigator.pop(context);
        },
      ),
      title: isLoading
          ? const SizedBox.shrink()
          : userNameWithVerifiedIcon(
              name: searchedUser!.displayName()!,
              isVerified: searchedUser!.isVerified),
    );
  }

  Widget checkView() {
    if (arguments['channel'] != null) {
      final String name = channelDetail['owner']['full_name'];

      final CustomerProfile profile = CustomerProfile(
        fullName: name,
        userName: channelDetail['group_name'] ?? '',
        nickName: channelDetail['username'] ?? '',
        avatar: channelDetail['owner']['avatar'],
        bio: channelDetail['description'],
        dateJoined: channelDetail['created_at'],
        followers: channelDetail['no_of_members'],
        isVerified: channelDetail['owner']['is_verified'],
      );
      if (mounted) setState(() {});

      return ChannelProfileScreen(
        searchedUser: profile,
        channelDetail: channelDetail,
        searchedUserName: channelDetail['username'] ?? '',
        isOwner: isOwner,
        isLoading: isLoading,
      );
    } else if (searchedUser != null &&
        searchedUser!.type!.toLowerCase() == 'user') {
      return DefaultUserProfileScreen(
        searchedUser: searchedUser,
        searchedUserName: searchedUserName,
        isOwner: isOwner,
        isLoading: isLoading,
      );
    } else if (searchedUser != null) {
      return BusinessProfileScreen(
        searchedUser: searchedUser,
        searchedUserName: searchedUserName,
        isOwner: isOwner,
        isLoading: isLoading,
      );
    } else {
      return Container();
    }
  }
}
