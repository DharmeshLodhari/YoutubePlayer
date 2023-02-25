import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user_tab.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/default_user_profile_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'profile_template/default_business_profile_screen.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  final arguments;

  UserProfileScreen({required this.arguments});

  @override
  _UserProfileScreenState createState() =>
      _UserProfileScreenState(arguments: arguments);
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  var arguments;
  late UserBloc userBloc;

  bool isLoading = true;

  _UserProfileScreenState({this.arguments});

  int currentIndex = 1;
  BehaviorSubject<int> selectedIndexStream = BehaviorSubject<int>();
  CustomerProfile? searchedUser;
  String? searchedUserName;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  double? top;

  late CustomerProfileBloc customerProfileBloc;

  bool appBarStatus = true;

  bool isInRequestList = false;

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
    late CustomerProfile user;
    searchedUserName = arguments['searchedUserName'].toString();

    if (load) {
      isLoading = true;
      if (mounted) setState(() {});
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
    UserBloc _userBloc = Provider.of<UserBloc>(context, listen: false);
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
          ? SizedBox.shrink()
          : userNameWithVerifiedIcon(
              name: searchedUser!.displayName()!,
              isVerified: searchedUser!.isVerified),
    );
  }

  Widget checkView() {
    if (searchedUser!.type!.toLowerCase() == 'user') {
      return DefaultUserProfileScreen(
        searchedUser: searchedUser,
        searchedUserName: searchedUserName,
        isOwner: isOwner,
        isLoading: isLoading,
      );
    } else {
      return DefaultBusinessProfileScreen(
        searchedUser: searchedUser,
        searchedUserName: searchedUserName,
        isOwner: isOwner,
        isLoading: isLoading,
      );
    }
  }
}
