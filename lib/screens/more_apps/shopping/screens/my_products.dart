import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
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
            Navigator.of(context).pushNamed(Routes.USER_PRODUCT_AND_SERVICE_SEARCH,
                arguments: {"searchedUser": customerProfile, "filter": "Products", "hidePreIcon": true});
          },
          height: 15,
          width: 15,
          icon: SvgPicture.asset(
            "yarn/search".toSVG(),
            height: 12,
            width: 12,
          )),
      SizedBox(width: 20),
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            Navigator.pushNamed(context, Routes.ADD_PRODUCT, arguments: {"channelUsername": ""});
          },
          height: 15,
          width: 15,
          icon: SvgPicture.asset(
            "add_payment".toSVG(),
            height: 12,
            width: 12,
          )),
      SizedBox(width: 20),

    ];
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


