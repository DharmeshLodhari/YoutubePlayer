import 'package:Slydo/constant.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../user_profile/models/user.dart';
import '../../user_profile/screens/user_profile_module_new/user_service_list.dart';

class MyServices extends StatefulWidget {
  const MyServices({Key? key}) : super(key: key);

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  late UserBloc userBloc;
  late CustomerProfile customerProfile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    customerProfile = CustomerProfile(
      fullName: userBloc.user.fullName,
      userName: userBloc.user.userName,
      avatar: userBloc.user.avatar,
      bio: userBloc.user.bio,
      dateJoined: '',
      followers: 0,
      isVerified: userBloc.user.isVerified,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        AppLocalization.of(context)!.myServices,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      actions: _buildAppBarActions(),
      elevation: 0.5,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      RoundedBackgroundIcon(
        backgroundColor: Colors.transparent,
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.USER_PRODUCT_AND_SERVICE_SEARCH, arguments: {
            "searchedUser": customerProfile,
            "filter": "Services",
            "hidePreIcon": true
          });
        },
        height: 15,
        width: 15,
        icon: SvgPicture.asset(
          "yarn/search".toSVG(),
          height: 12,
          width: 12,
        ),
      ),
      const SizedBox(width: 30),
      RoundedBackgroundIcon(
        backgroundColor: Colors.transparent,
        onTap: () {
          final PermissionType? hasPermission =
              userBloc.user.hasWritePermission(ProtectionPermission.services);
          if (hasPermission == PermissionType.WRITE) {
            Navigator.pushNamed(context, Routes.ADD_SERVICE);
          } else {
            showSnackbar(context,
                message: AppLocalization.of(context)?.doNotPermission ?? "");
          }
        },
        height: 15,
        width: 15,
        icon: SvgPicture.asset(
          "add_payment".toSVG(),
          height: 12,
          width: 12,
        ),
      ),
      const SizedBox(width: 20),
    ];
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildServicesView(),
      ],
    );
  }

  Widget _buildServicesView() {
    return Expanded(
      child: UserServiceList(
        user: customerProfile,
        isOwner: true,
      ),
    );
  }
}
