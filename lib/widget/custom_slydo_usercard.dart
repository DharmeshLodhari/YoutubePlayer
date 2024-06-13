import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import '../screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../screens/more_apps/user_profile/user_auth.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/util.dart';
import 'dialog.dart';
import 'loading_indicator.dart';

class CustomSlydoUserCard extends StatefulWidget {
  final CustomerProfile user;
  const CustomSlydoUserCard({super.key, required this.user});

  @override
  State<CustomSlydoUserCard> createState() => _CustomSlydoUserCardState();
}

class _CustomSlydoUserCardState extends State<CustomSlydoUserCard>
    with SingleTickerProviderStateMixin {
  late UserBloc userBloc;
  List<String> userConnectionNames = [];
  AppConfigurationModel? appConfigurationModel;
  // late final SlidableController _slideController = SlidableController(this);

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    // _slideController = SlidableController(
    //   onSlideAnimationChanged: handleSlideAnimationChanged,
    //   onSlideIsOpenChanged: handleSlideIsOpenChanged,
    // );
    getUserConnectionNames();
  }

  void getUserConnectionNames() async {
    userConnectionNames = await ConnectionListManager().listConnectionsFromDB();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return getSlidableWithCard(context);
  }

  Widget userCard() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": widget.user.userName});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: decorateBox(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    dense: true,
                    title: userNameWithVerifiedIcon(
                      name: widget.user.fullName!,
                      isVerified: widget.user.isVerified,
                    ),
                    subtitle: Text(
                      '@${widget.user.userName!}',
                      maxLines: 1,
                      style: TextStyle(color: darkGrey, fontSize: 12),
                    ),
                    leading: getUserLeading(widget.user),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUserLeading(CustomerProfile user) {
    final Color borderColor = getUserTypeColor(user: user);

    if (user.avatar == "" ||
        user.avatar ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(user.fullName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar == "" ? defaultImage : user.avatar!,
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

  Widget getSlidableWithCard(BuildContext context) {
    return Slidable(
      // controller: _slideController,
      //  direction: Axis.horizontal,
      // actionPane: const SlidableBehindActionPane(),
      // actionExtentRatio: 0.25,
      // actions: widget.user.userName.toString().toLowerCase() == "slydo"
      //     ? []
      //     : listActionSlideActions(),
      // secondaryActions: widget.user.userName.toString().toLowerCase() == "slydo"
      //     ? []
      //     : listSecondaryActions(),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: widget.user.userName.toString().toLowerCase() == "slydo"
            ? 0.0001
            : 0.25,
        children: listActionSlideActions(),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: widget.user.userName.toString().toLowerCase() == "slydo"
            ? 0.0001
            : 0.25,
        children: listSecondaryActions(),
      ),
      child: userCard(),
    );
  }

  List<Widget> listActionSlideActions() {
    final bool isNotCurrentUser =
        widget.user.userName != userBloc.user.userName;
    return [
      if (isNotCurrentUser)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          icon: Icons.payments_rounded,
          onPressed: (context) async {
            if (appConfigurationModel?.enablePayment == true) {
              Navigator.of(context).pushNamed(
                Routes.REQUEST_PAYMENT,
                arguments: {
                  'isFromProfile': false,
                  'isRequest': true,
                  'recipient': widget.user.userName,
                },
              );
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          },
          label: AppLocalization.of(context)!.request,
          backgroundColor: navyBlue,
          // slideController: _slideController,
        ),
      if (isNotCurrentUser)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          icon: Icons.payments_rounded,
          onPressed: (context) async {
            if (appConfigurationModel?.enablePayment == true) {
              Navigator.of(context).pushNamed(Routes.SEND_PAYMENT, arguments: {
                'isFromProfile': false,
                'recipient': widget.user.userName,
              });
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          },
          label: AppLocalization.of(context)!.send,
          backgroundColor: naturalGreen,
          // slideController: slidableController,
        ),
    ];
  }

  List<Widget> listSecondaryActions() {
    return [
      if (!userConnectionNames.contains(widget.user.userName) &&
          widget.user.userName != userBloc.user.userName)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          icon: SlydoAppIcon.add,
          onPressed: (context) async {
            connectUserAlert(widget.user);
          },
          label: 'Connect',
          backgroundColor: naturalGreen,
          // slideController: _slideController,
        ),
      if (userBloc.user.userName != widget.user.userName)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          icon: SlydoAppIcon.block,
          onPressed: (context) async {
            blockUserAlert(widget.user);
          },
          label: 'Block',
          backgroundColor: mateRed,
          // slideController: _slideController,
        ),
    ];
  }

  void blockUserAlert(CustomerProfile user) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.block,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.block,
      description:
          "${AppLocalization.of(context)!.areYouSureWantToBlock} ${user.displayName()}",
      actionOneText: AppLocalization.of(context)!.block,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      final bool done = await UserAuth().blockUser(user);
      if (done) {
        showSnackbar(context,
            message:
                "${user.displayName()} ${AppLocalization.of(context)!.isBlockedSuccessfully}");

        final ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: user.conversationId);

        setState(() {});
      } else {
        showSnackbar(context, message: AppLocalization.of(context)!.error);
      }
    }
  }

  void connectUserAlert(CustomerProfile user) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.add,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      title: AppLocalization.of(context)!.connect,
      description:
          "Are you sure you want to add ${user.displayName()} to your list of connections",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.connect,
      rightButtonOnPressed: () {
        showDialog(
            context: context,
            builder: (dialogLoadingContext) => LoadingIndicator());

        UserAuth().makeContactRequest(user).then((value) {
          Navigator.pop(context);
          if (value) {
            showToast(message: "Connection Request Sent !!");
          } else {
            showToast(message: "Request Not Sent.. ");
          }
        });
      },
    );
  }
}
