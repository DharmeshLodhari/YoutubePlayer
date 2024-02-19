import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  SharedCartModel cartDetails = SharedCartModel();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCartDetails();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  Future<void> getCartDetails() async {
    if (!isLoading) {
      if (mounted) {
        isLoading = true;
        setState(() {});
      }

      await SharedCartAuthService()
          .getCartDetails(sharedCartBloc.getSharedCartModel().id)
          .then((value) {
        cartDetails = value;
        if (mounted) {
          isLoading = false;
          setState(() {});
        }
      }).catchError((error) {
        if (mounted) {
          isLoading = false;
          setState(() {});
        }
        debugPrint(error.toString());
        debugPrint("Product check variant::: ${error.toString()}");
        // showToast(message: error.toString());
      });
    }
  }

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
        cartDetails.name ?? "",
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
                arguments: {
                  "create": "addMember"
                }).whenComplete(() => getCartDetails());
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
    ;
  }

  Widget _buildCartMembers() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : cartDetails.members?.length == 0 || cartDetails.members == null
            ? NoItemInList(
                title: AppLocalization.of(context)!.noMembersYet,
                msg: AppLocalization.of(context)!.noMembersYet,
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                //+1 for progressbar
                itemCount: cartDetails.members?.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cartDetails.members?.length) {
                    return buildLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                      context,
                      cartMemberTile(
                          members: cartDetails.members?[index], index: index),
                      cartDetails.members?[index],
                    );
                  }
                },
              );
  }

  Widget cartMemberTile({required SharedCartMemberModel? members, int? index}) {
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

  Widget _getSlidableWithLists(BuildContext context, Widget cartMemberTile,
      SharedCartMemberModel? member) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(cartMemberTile),
      secondaryActions: listActionSlideActions(member: member),
    );
  }

  List<Widget> listActionSlideActions({SharedCartMemberModel? member}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () async {
            await deleteMember(member);
          },
          title: AppLocalization.of(context)!.remove,
          slideController: _slideController),
    ];
  }

  Future<void> deleteMember(SharedCartMemberModel? member) async {
    Map<String, dynamic> data = {
      "members": [member?.userName]
    };
    await SharedCartAuthService()
        .removeMemberFromSharedCart(cartDetails.id, data)
        .then((value) {
      if (value == true) {
        showToast(
            message: AppLocalization.of(context)!.memberDeletedSuccessfully);
        _onRefresh();
      } else {
        showToast(message: AppLocalization.of(context)!.memberIsNotDeleted);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getCartDetails();
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
