import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../widget/vertical_list_item.dart';

class SharedCartMembers extends StatefulWidget {
  const SharedCartMembers({super.key});

  @override
  State<SharedCartMembers> createState() => _SharedCartMembersState();
}

class _SharedCartMembersState extends State<SharedCartMembers>
    with SingleTickerProviderStateMixin {
  late SharedCartBloc sharedCartBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // SharedCartModel cartDetails = SharedCartModel();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool isMemberChange = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   isLoading = true;
    //   if (mounted) setState(() {});
    //   sharedCartBloc.refreshCartDetail();
    //   cartDetails = sharedCartBloc.getSharedCartModel();
    //   isLoading = false;
    //   if (mounted) setState(() {});
    // });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          Navigator.of(context).pop(isMemberChange);
          return;
        }
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: lightGrey,
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
          Navigator.of(context).pop(isMemberChange);
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
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
                Routes.SELECT_USER_FOR_GROUP,
                arguments: {"create": "addMember"});
            if (result != null && result is bool && result == true) {
              isMemberChange = result;
              setState(() {
                _onRefresh();
              });
            }
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
    return ScaffoldMessenger(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildCartMembers(),
          ),
        ),
      ),
    );
  }

  Widget _buildCartMembers() {
    final SharedCartModel cartDetails = sharedCartBloc.getSharedCartModel();
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : cartDetails.members?.length == 0 || cartDetails.members == null
            ? NoItemInList(
                title: AppLocalization.of(context)!.noMembersYet,
                msg: AppLocalization.of(context)!.noMembersYet,
              )
            : SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  itemCount: cartDetails.members?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _getSlidableWithLists(
                      context,
                      cartMemberTile(
                          member: cartDetails.members?[index], index: index),
                      cartDetails.members?[index],
                    );
                  },
                ),
              );
  }

  Widget cartMemberTile({required SharedCartMemberModel? member, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          leading: getUserLeading(member),
          title: Text(
            member?.fullName ?? "",
            maxLines: 1,
            style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter"),
          ),
          subtitle: Text(
            '@${member?.userName}',
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

  Widget getUserLeading(SharedCartMemberModel? member) {
    if (member?.avatar == "" ||
        member?.avatar ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 22,
        child: Text(
          getInitials(member?.fullName ?? "").toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return SizedBox(
        height: 45,
        width: 45,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:
                member?.avatar == "" ? defaultImage : member?.avatar! ?? "",
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
            height: double.infinity,
            filterQuality: FilterQuality.high,
            placeholder: (context, _) => CachedNetworkImage(
              imageUrl: defaultImage,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }
  }

  Widget _getSlidableWithLists(BuildContext context, Widget cartMemberTile,
      SharedCartMemberModel? member) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(member: member),
      ),
      child: VerticalListItem(cartMemberTile),
    );
  }

  List<Widget> listActionSlideActions({SharedCartMemberModel? member}) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove,
        onPressed: (context) async {
          await deleteMember(member);
        },
        label: AppLocalization.of(context)!.remove,
      ),
    ];
  }

  Future<void> deleteMember(SharedCartMemberModel? member) async {
    final Map<String, dynamic> data = {
      "members": [member?.userName]
    };
    await SharedCartAuthService()
        .removeMemberFromSharedCart(
            sharedCartBloc.getSharedCartModel().id, data)
        .then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.memberDeletedSuccessfully);
        isMemberChange = true;
        setState(() {
          _onRefresh();
        });
      } else {
        showToast(message: AppLocalization.of(context)!.memberIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) async {
      final connectionResult = value;
      if (connectionResult.contains(ConnectivityResult.wifi) ||
          connectionResult.contains(ConnectivityResult.ethernet) ||
          connectionResult.contains(ConnectivityResult.mobile)) {
        if (mounted) setState(() {});
        await sharedCartBloc.refreshCartDetail(
            sharedCartBloc.getSharedCartModel().id,
            isUpdate: true);
        setState(() {
          // Call the callback function with the updated list
          //to pass the list back to edit product page
          // widget.onListRefreshed!(productVariantList);
          _refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }
}
