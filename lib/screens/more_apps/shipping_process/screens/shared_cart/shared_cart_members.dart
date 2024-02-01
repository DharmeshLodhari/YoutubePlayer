import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/vertical_list_item.dart';

class SharedCartMembers extends StatefulWidget {
  @override
  State<SharedCartMembers> createState() => _SharedCartMembersState();
}

class _SharedCartMembersState extends State<SharedCartMembers> {
  late SharedCartBloc sharedCartBloc;
  SlidableController? _slideController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        sharedCartBloc.getSharedCartModel().name ?? "",
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: [
        RoundedBackgroundIcon(
          height: 34,
          width: 34,
          icon: Icon(
            SlydoAppIcon.add,
            size: 16,
            color: blackFont,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
                arguments: {"create": "addMember"});
          },
          backgroundColor: iconBtnGrey,
          enableMargin: true,
        ),
        const SizedBox(
          width: 16,
        ),
      ],
      backgroundColor: white,
      elevation: 0.0,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: sharedCartBloc.getSharedCartModel().membersDetails?.length == 0 ||
              sharedCartBloc.getSharedCartModel().membersDetails == null
          ? NoItemInList(
              title: AppLocalization.of(context)!.noMembersYet,
              msg: AppLocalization.of(context)!.noMembersYet,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              //+1 for progressbar
              itemCount:
                  sharedCartBloc.getSharedCartModel().membersDetails?.length,
              itemBuilder: (BuildContext context, int index) {
                if (index ==
                    sharedCartBloc
                        .getSharedCartModel()
                        .membersDetails
                        ?.length) {
                  return buildLoadingIndicator(isLoading: isLoading);
                } else {
                  return _getSlidableWithLists(
                    context,
                    cartMemberTile(
                        members: sharedCartBloc
                            .getSharedCartModel()
                            .membersDetails?[index],
                        index: index),
                    sharedCartBloc.getSharedCartModel().membersDetails?[index],
                  );
                }
              },
            ),
    );
  }

  Widget cartMemberTile({required UserFollowers? members, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          leading: ClipOval(
            child: CachedNetworkImage(
              height: 45,
              width: 45,
              imageUrl:
                  members?.avatar == "" ? defaultImage : members?.avatar ?? "",
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              errorWidget: imageErrorWidget,
              filterQuality: FilterQuality.high,
            ),
          ),
          title: Text(
            members?.fullName ?? "",
            maxLines: 1,
            style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter"),
          ),
          subtitle: Text(
            '@${members?.userName}',
            maxLines: 1,
            style: TextStyle(
                color: darkGrey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter"),
          ),
        ),
      ),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget cartMemberTile, UserFollowers? member) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(cartMemberTile),
      secondaryActions: listActionSlideActions(member: member),
    );
  }

  List<Widget> listActionSlideActions({UserFollowers? member}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () async {
            deleteMember(member);
          },
          title: AppLocalization.of(context)!.remove,
          slideController: _slideController),
    ];
  }

  void deleteMember(UserFollowers? member) {
    Map<String, dynamic> data = {
      "members": [member?.userName]
    };
    SharedCartAuthService()
        .removeMemberFromSharedCart(
            sharedCartBloc.getSharedCartModel().id, data)
        .then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.memberDeletedSuccessfully);
        //remove the selected add-on from the list using it id
        // member.removeWhere((addOn) => addOn.id == member.id);
        if (mounted) setState(() {});
      } else {
        showToast(message: AppLocalization.of(context)!.memberIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }
}
