import 'package:Slydo/constant.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../user_profile/models/user.dart';
import '../../user_profile/screens/user_profile_module_new/user_product_list.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({Key? key}) : super(key: key);

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
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
        AppLocalization.of(context)!.myProducts,
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
            "filter": "Products",
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
      const SizedBox(width: 10),
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            copyProductLink();
          },
          icon: SvgPicture.asset(
            "link_icon".toSVG(),
          )),
      const SizedBox(width: 10),
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            Navigator.pushNamed(context, Routes.ADD_PRODUCT,
                arguments: {"channelUsername": ""});
          },
          height: 15,
          width: 15,
          icon: PermissionProtectionWidget(
            permissionName: ProtectionPermission.product,
            isLockForRead: true,
            child: SvgPicture.asset(
              "add_payment".toSVG(),
              height: 12,
              width: 12,
            ),
          )),
      const SizedBox(width: 20),
    ];
  }

  Future<void> copyProductLink() async {
    await ShoppingAuthService().getProductLink().then((value) {
      Clipboard.setData(ClipboardData(
        text: "${value.url}",
      ));
      showToast(message: "Link Copied !");
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildProductsView(),
      ],
    );
  }

  Widget _buildProductsView() {
    return Expanded(
      child: UserProductList(
        user: customerProfile,
        isOwner: true,
      ),
    );
  }
}
