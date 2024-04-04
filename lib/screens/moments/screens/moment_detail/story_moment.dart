import 'dart:async';
import 'dart:convert';

import 'package:Slydo/screens/moments/screens/moment_detail/render_moment_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/loading_indicator.dart';
import '../../../../widget/read_more_widget.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../../more_apps/messaging/chat/models/ChatConversation.dart';
import '../../../more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import '../../../more_apps/user_profile/models/user.dart';
import '../../../more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../more_apps/yarn/yarn_report_screen.dart';
import '../../../post_detail_page.dart';
import '../../models/moments_model.dart';
import '../../moments_bloc.dart';
import '../../utils.dart';
import '../../widgets/attachment_widget.dart';
import '../../widgets/custom_moment_detail_button.dart';
import '../create_moment_screen.dart';
import '../moments_service.dart';
import 'custom_story_view.dart' as custom;
import 'custom_story_view.dart';
import 'moment_comment_list.dart';

class StoryMomentScreen extends StatefulWidget {
  final StoryController? controller;
  final List<custom.Shiddo>? storyItems;
  final MomentsModel? currentMoment;

  StoryMomentScreen(
      {Key? key,
      required this.controller,
      required this.storyItems,
      required this.currentMoment})
      : super(key: key);

  @override
  State<StoryMomentScreen> createState() => _StoryMomentScreenState();
}

class _StoryMomentScreenState extends State<StoryMomentScreen> {
  bool _isLiked = false;

  bool _isDisLiked = false;
  MomentsBloc? momentsBloc;
  int index = 0;

  MomentsModel? currentMoment;
  final GlobalKey<RenderMomentState> _renderMomentStateKey =
      GlobalKey<RenderMomentState>();

  void toggleMediaPlayingState() {
    _renderMomentStateKey.currentState?.toggleMediaPlayingState();
  }

  Future<bool> addLikeToMoment() async {
    MomentsModel data =
        await MomentsService().likeMoment(currentMoment?.id ?? "");
    if (data != null) {
      setState(() {
        currentMoment!.likes = data.likes;
        currentMoment!.dislikes = data.dislikes;
      });
      return true;
    }
    return false;
  }

  Future<bool> addDisLikeToMoment() async {
    MomentsModel data =
        await MomentsService().dislikeMoment(currentMoment?.id ?? "");

    if (data != null) {
      setState(() {
        currentMoment!.dislikes = data.dislikes;
        currentMoment!.likes = data.likes;
      });
      return true;
    }
    return false;
  }

  int getLikeCount() {
    if (currentMoment!.likes != null && currentMoment!.likes != 0) {
      return currentMoment!.likes ?? 0;
    }
    return 0;
  }

  int getDislikeCount() {
    if (currentMoment!.dislikes != null && currentMoment!.dislikes != 0) {
      return currentMoment!.dislikes ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    currentMoment = widget.currentMoment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    momentsBloc = Provider.of<MomentsBloc>(context, listen: false);

    return Scaffold(
      body: Stack(children: [
        StoryViewShiddo(
          indicatorForegroundColor: navyBlue,
          storyItems: widget.storyItems!,
          controller: widget.controller!,
          onStoryShow: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (value.shown == false) {
                currentMoment = value.momentsModel;
              }
              setState(() {});
            });
          },
          onComplete: () {
            Navigator.pop(context);
          },
          onVerticalSwipeComplete: (p0) {
            if (p0 == Direction.down) {
              widget.controller!.pause();
              Navigator.pop(context);
            }
          },
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          end: 15.0,
          bottom: MediaQuery.of(context).size.height * 0.13,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                isMyMoment()
                    ? CustomMomentDetailButton(
                        iconEnabled: true,
                        iconData: Icons.more_horiz_outlined,
                        text: '',
                        onPressed: () {
                          androidBottomSheet(
                            context: context,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                momentVisibilityOption(currentMoment!),
                                momentPermanentOption(currentMoment!),
                                enablePayment(currentMoment!),
                                momentCommentingOption(currentMoment!),
                                momentLikeOption(currentMoment!),
                                bottomSheetItem(
                                    title: 'Share in chat',
                                    iconData: Icons.send_outlined,
                                    onTap: () async {
                                      await sendMomentToUserInChat(
                                          momentsModel: currentMoment!);
                                    }),
                                bottomSheetItem(
                                  title: 'Delete',
                                  iconData: Icons.delete,
                                  onTap: () {
                                    Navigator.pop(context);

                                    showDialogBox(
                                      context: context,
                                      actionOneTextColor: white,
                                      actionOneBgColor: mateRed,
                                      actionTwoTextColor: blackFont,
                                      actionTwoBgColor: greyBorderColor,
                                      title:
                                          AppLocalization.of(context)!.delete,
                                      actionTwoText:
                                          AppLocalization.of(context)!.cancel,
                                      actionOneText:
                                          AppLocalization.of(context)!.delete,
                                      description:
                                          'Are you sure you want to delete this moment?',
                                      roundedBackgroundIcon:
                                          RoundedBackgroundIcon(
                                        enableMargin: false,
                                        width: 90,
                                        height: 90,
                                        image: Image.asset(
                                            'assets/images/delete_dialog_icon.png'),
                                      ),
                                      leftButtonOnPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (dialogLoadingContext) =>
                                                LoadingIndicator());
                                        MomentsService()
                                            .deleteMoment(
                                                currentMoment!.id!, "")
                                            .then(
                                          (value) {
                                            Navigator.pop(
                                                context); // Dismiss loading indicator
                                            Navigator.pop(context);
                                            showToast(
                                                message: 'Moment deleted');
                                          },
                                        ).catchError((e) {
                                          Navigator.pop(context);
                                          showToast(message: e.toString());
                                        });
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                _buildShareMomentOption(),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0.0, 0),
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                        // borderRadius: BorderRadius.circular(40),
                      ),
                      child: LikeButton(
                        mainAxisAlignment: MainAxisAlignment.start,
                        padding: const EdgeInsets.only(left: 5),
                        size: 20,
                        circleColor: CircleColor(start: white, end: white),
                        bubblesColor: BubblesColor(
                          dotPrimaryColor: white,
                          dotSecondaryColor: white,
                        ),
                        onTap: likeEnabled()
                            ? (isLike) {
                                _isLiked = true;
                                _isDisLiked = false;
                                setState(() {});
                                return addLikeToMoment();
                              }
                            : null,
                        likeBuilder: (bool isLiked) {
                          return SvgPicture.asset(
                            _isLiked == true
                                ? "yarn/likeAfter".toSVG()
                                : "yarn/likeBefore".toSVG(),
                            color: white,
                            height: 25,
                            width: 25,
                          );
                        },
                        likeCount: getLikeCount(),
                        countBuilder: (_, __, ___) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      likeEnabled()
                          ? int.parse(currentMoment!.likes.toString()) < 1
                              ? ''
                              : getFormattedViewCount(
                                  noOfViews: currentMoment!.likes!,
                                  addViewText: false)
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0.0, 0),
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                        // borderRadius: BorderRadius.circular(40),
                      ),
                      child: LikeButton(
                        padding: const EdgeInsets.only(left: 5),
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        size: 20,
                        circleColor: CircleColor(start: white, end: white),
                        bubblesColor: BubblesColor(
                          dotPrimaryColor: white,
                          dotSecondaryColor: white,
                        ),
                        onTap: likeEnabled()
                            ? (likes) {
                                _isDisLiked = true;
                                _isLiked = false;
                                setState(() {});

                                return addDisLikeToMoment();
                              }
                            : null,
                        // : null,
                        likeBuilder: (bool isLiked) {
                          return SvgPicture.asset(
                            _isDisLiked == false
                                ? "yarn/unlikeBefore".toSVG()
                                : "yarn/unlikeAfter".toSVG(),
                            color: white,
                            height: 20,
                            width: 17,
                          );
                        },
                        likeCount: getDislikeCount(),
                        countBuilder: (_, __, ___) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      likeEnabled()
                          ? int.parse(currentMoment!.dislikes.toString()) < 1
                              ? ''
                              : getFormattedViewCount(
                                  noOfViews: currentMoment!.dislikes!,
                                  addViewText: false,
                                )
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                CustomMomentDetailButton(
                  iconEnabled: commentingEnabled(),
                  svgImage: 'yarn/yarn_comment',
                  isSvgIcon: true,
                  text: currentMoment?.displayComment ?? '',
                  onPressed: commentingEnabled()
                      ? () {
                          widget.controller!.pause();
                          commentSheet(context, currentMoment!.id!,
                              currentMoment!.ownerName!,
                              index: index - 1, currentMoment: currentMoment);
                        }
                      : null,
                ),
                CustomMomentDetailButton(
                  iconEnabled: true,
                  iconData: Icons.visibility_rounded,
                  text: getFormattedViewCount(
                    noOfViews: currentMoment!.views,
                    addViewText: false,
                  ),
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 12.0,
          bottom: 20.0,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        String? image = '';
                        if (currentMoment!.avatar == "" ||
                            currentMoment!.avatar ==
                                "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
                          image = getInitials(currentMoment!.ownerName!)
                              .toUpperCase();
                        } else {
                          image = currentMoment!.avatar;
                        }

                        Navigator.of(context)
                            .pushNamed(Routes.PHOTO_VIEWER, arguments: image);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: MomentsUtils().getUserProfilePic(
                            currentMoment!.avatar!, currentMoment!.ownerName!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.USER_PROFILE,
                                arguments: {
                                  "searchedUserName": currentMoment!.owner,
                                },
                              );
                            },
                            child: Text(
                              messageDecoderWithEmoji(
                                  currentMoment!.ownerName!)!,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: blackFont,
                                    offset: const Offset(0.0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${MomentsUtils().getGetMomentDetailDateTime(currentMoment!.createdAt!)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              getPrivateOrPublicIcon(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: currentMoment!.text != null
                      ? ReadMoreText(
                          messageDecoderWithEmoji(currentMoment!.text)!,
                          trimLines: 2,
                          colorClickableText: Colors.pink,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'more',
                          trimExpandedText: 'less',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: blackFont,
                                offset: const Offset(0.0, 0),
                              ),
                            ],
                          ),
                          moreStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                          lessStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (currentMoment!.tags!.isEmpty) ...[
                  SizedBox(
                    width: 300,
                    child: getTags(),
                  ),
                ],
                const SizedBox(height: 9),
                Row(
                  children: [
                    getPayMeBtn(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: getWhichAttachmentWidgetToShow(
                        currentMoment!.attachment!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: CircleAvatar(
                  backgroundColor: navyBlue,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        toggleMediaPlayingState();
                        await NavigationUtil.push(context,
                            screen: CreateMediaMomentScreen());
                        toggleMediaPlayingState();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: navyBlue,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildShareMomentOption() {
    if (isMyMoment()) {
      return const SizedBox.shrink();
    }

    return CustomMomentDetailButton(
        iconEnabled: true,
        iconData: Icons.more_horiz_outlined,
        text: "",
        onPressed: () async {
          androidBottomSheet(
            context: context,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                bottomSheetItem(
                    title: 'Share in chat',
                    iconData: Icons.send_outlined,
                    onTap: () async {
                      await sendMomentToUserInChat(
                          momentsModel: currentMoment!);
                    }),
                bottomSheetItem(
                  title: 'Report Moment',
                  iconData: Icons.report_gmailerrorred_rounded,
                  onTap: () async {
                    Navigator.pop(context);

                    toggleMediaPlayingState();

                    await NavigationUtil.push(context,
                        screen: AddReportScreen(
                          object: currentMoment!.toJson(),
                          type: "moment",
                          isCommentMoment: true,
                        ));

                    toggleMediaPlayingState();
                  },
                ),
                bottomSheetItem(
                  title: 'Block Account',
                  iconData: Icons.block,
                  onTap: () async {
                    toggleMediaPlayingState();
                    var user = CustomerProfile();
                    user.userName = currentMoment!.owner;
                    user.fullName = currentMoment!.ownerName;
                    user.type = "";
                    user.nickName = "";

                    Future<bool?> check = blockUserAlert(context, user);
                    if (check == true) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> sendMomentToUserInChat(
      {required MomentsModel momentsModel}) async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(
          recipientUser: recipient!, momentsModel: momentsModel);
    });
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required MomentsModel momentsModel,
    String? url,
  }) async {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    Map<String, dynamic> metaData = {
      "id": momentsModel.id,
      "title": messageDecoderWithEmoji(momentsModel.text),
      "author_avatar": momentsModel.avatar,
      "author_username": messageDecoderWithEmoji(momentsModel.ownerName),
    };

    switch (momentsModel.mediaType) {
      case "image":
        metaData.addAll({"image": momentsModel.media});
        break;
      case "video":
        metaData.addAll({"image": momentsModel.mediaPoster});
        break;
    }

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": const Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'moment',
      "kind": "moment",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(message: 'Moment Shared');
  }

  Widget momentVisibilityOption(MomentsModel momentModel) {
    String title = "Make ";
    bool isPublic = false;
    IconData icon;
    if (momentModel.isPublic ?? false) {
      title += "Private";
      icon = Icons.shield;
      isPublic = false;
    } else {
      title += "Public";
      icon = Icons.public;
      isPublic = true;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!, data: {"is_public": isPublic}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget enablePayment(MomentsModel momentModel) {
    String title;
    bool isEnabledPayment = false;

    if (momentModel.payMe == false) {
      title = "Enable Payment";
      isEnabledPayment = true;
    } else {
      title = "Disable Payment";
      isEnabledPayment = false;
    }

    return bottomSheetItem(
        title: title,
        icon: Image.asset(
          'assets/images/slydo_icon_white.png',
          color: blackFont,
        ),
        onTap: () {
          Navigator.pop(context);
          MomentsService().updateMoment(
              momentId: momentModel.id!,
              data: {"enable_payme": isEnabledPayment}).then(
            (value) {
              momentModel = value;
              if (mounted) setState(() {});
              Navigator.pop(context); // Dismiss loading indicator
              showToast(
                  message: isEnabledPayment
                      ? 'Payment enabled !!'
                      : 'Payment disabled !!');
            },
          ).catchError((e) {
            Navigator.pop(context);
            showToast(message: e.toString());
          });
        });
  }

  Widget momentPermanentOption(MomentsModel momentModel) {
    bool isPermanent = false;
    String title;
    debugPrint("MOMENT MODEL IS PERMANENT:- ${momentModel.isPermanent}");
    debugPrint("MOMENT IS PERMANENT:- ${momentModel.isPermanent}");
    if (momentModel.isPermanent ?? false) {
      isPermanent = momentModel.isPermanent!;
    }

    if (isPermanent) {
      title = "For Moment Alone";
    } else {
      title = "Make Permanent";
    }

    return bottomSheetItem(
      title: title,
      iconData: CupertinoIcons.infinite,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"is_permanent": !isPermanent}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget momentCommentingOption(MomentsModel momentModel) {
    bool isCommentingEnable = false;
    String title;
    if (momentModel.enableCommenting) {
      isCommentingEnable = momentModel.enableCommenting;
    }

    IconData icon;
    if (isCommentingEnable) {
      title = "Turn off Commenting";
      icon = Icons.comments_disabled;
    } else {
      title = "Turn on Commenting";
      icon = Icons.comment;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);
        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"enable_commenting": !isCommentingEnable}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  Widget momentLikeOption(MomentsModel momentModel) {
    bool isLikeEnabled = false;
    String title;
    if (momentModel.enableLikes ?? false) {
      isLikeEnabled = momentModel.enableLikes!;
    }

    IconData icon;
    if (isLikeEnabled) {
      title = "Disable Likes";
      icon = Icons.thumb_up_alt;
    } else {
      title = "Enable Likes";
      icon = Icons.thumb_up_alt;
    }

    return bottomSheetItem(
      title: title,
      iconData: icon,
      onTap: () {
        Navigator.pop(context);

        MomentsService().updateMoment(
            momentId: momentModel.id!,
            data: {"enable_like": !isLikeEnabled}).then(
          (value) {
            momentModel = value;
            if (mounted) setState(() {});
            Navigator.pop(context); // Dismiss loading indicator
            showToast(message: 'Moment updated !!');
          },
        ).catchError((e) {
          Navigator.pop(context);
          showToast(message: e.toString());
        });
      },
    );
  }

  String getCommentCount(int index) {
    String commentCount = '';

    try {
      if (momentsBloc!.numberOfComments[index] >= 1) {
        commentCount = getFormattedViewCount(
          noOfViews: momentsBloc!.numberOfComments[index],
          addViewText: false,
        );
      }
    } catch (error) {
      commentCount = '';
    }

    return commentCount;
  }

  Widget getPrivateOrPublicIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: currentMoment!.isPublic == true
          ? const Icon(
              Icons.public_outlined,
              color: Colors.white,
              size: 16,
            )
          : const Icon(
              Icons.security_outlined,
              color: Colors.white,
              size: 16,
            ),
    );
  }

  Widget getTags() {
    List<String> formattedTagList = [];

    if (currentMoment!.tags != null) {
      currentMoment!.tags!.join(', ');

      currentMoment!.tags!.forEach((tag) {
        formattedTagList.add('#$tag ');
      });

      return ReadMoreText(
        formattedTagList.join(' '),
        trimLines: 2,
        colorClickableText: Colors.pink,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'more',
        trimExpandedText: 'less',
        style: const TextStyle(color: Colors.white70),
        moreStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        lessStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget getWhichAttachmentWidgetToShow(Map<String, dynamic> attachment) {
    if (attachment.containsKey('url')) {
      return attachmentWidget(
        onTap: () {
          _launchUrl(attachment['url'].toString().split('-')[0]);
        },
        iconData: Icons.link,
        title: attachment['url'].toString().split('-')[1],
      );
    }

    if (attachment.containsKey('product')) {
      return attachmentWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.PRODUCT,
              // arguments: {"productId": 'ce8d6464-8c7f-47db-a381-a163a258713a'},
              arguments: {"productId": attachment['product']},
            );
          },
          iconData: Icons.shopping_cart_rounded,
          title: 'Product');
    }

    if (attachment.containsKey('service')) {
      return attachmentWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.SERVICE_DETAIL,
              // arguments: {"serviceId": '08083ad8-04d9-4878-8b18-e820f7c680af'},
              arguments: {"serviceId": attachment['service']},
            );
          },
          iconData: Icons.handyman_rounded,
          title: 'Service');
    }

    if (attachment.containsKey('blog')) {
      return attachmentWidget(
        onTap: () {
          NavigationUtil.push(
            context,
            screen: PostDetailPage(
              // postId: '303d5c1b-5539-4b63-a448-c0d3e9687d61',
              postId: attachment['blog'],
              postType: PostType.blog,
            ),
          );
        },
        iconData: Icons.receipt_long_rounded,
        title: 'Blog',
      );
    } else {
      return Container();
    }
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  bool isMyMoment() {
    return getLoggedInUserName(context) == currentMoment!.owner;
  }

  bool likeEnabled() {
    return currentMoment!.enableLikes != null && currentMoment!.enableLikes!;
  }

  bool commentingEnabled() {
    return currentMoment!.enableCommenting != null &&
        currentMoment!.enableCommenting;
  }

  Widget getPayMeBtn() {
    return currentMoment!.payMe!
        ? InkWell(
            onTap: getLoggedInUserName(context) != currentMoment!.owner
                ? () async {
                    if (currentMoment!.userSupported == true) {
                      showToast(
                          message: 'You have already supported this moment');
                      return;
                    }

                    Navigator.of(context).pushNamed(
                      Routes.SEND_PAYMENT,
                      arguments: <String, dynamic>{
                        'recipient': currentMoment!.owner,
                        'isFromProfile': false,
                        'isFromChat': false,
                        'isFromMoment': true,
                        'isFromYarn': false,
                        'callback': onCallback,
                        'momentId':
                            currentMoment!.id != null ? currentMoment!.id! : '',
                        'defaultReferenceText':
                            'Payment from Moment, Moment ID : ${currentMoment!.id != null ? currentMoment!.id! : ''}'
                      },
                    );
                  }
                : () {
                    showToast(message: 'You cannot pay yourself');
                  },
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: 20,
              shadowColor: Colors.black.withOpacity(0.7),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: checkColor(),
                    borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/slydo_icon_white.png',
                      width: 30,
                      height: 20,
                      color: currentMoment!.payMeButtonColor?.toLowerCase() ==
                              '#ffffff'
                          ? navyBlue
                          : Colors.white,
                    ),
                    Text(
                      messageDecoderWithEmoji(
                          currentMoment!.payMeLabel ?? 'Pay Me')!,
                      style: TextStyle(
                        color: currentMoment!.payMeButtonColor?.toLowerCase() ==
                                '#ffffff'
                            ? navyBlue
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Color checkColor() {
    if (currentMoment!.payMeButtonColor != null) {
      if (currentMoment!.userSupported == true) {
        return HexColor('#808080');
      } else {
        return HexColor('#${currentMoment!.payMeButtonColor}');
      }
    } else {
      return HexColor('#3F61DB');
    }
  }

  // callback function with a bool parameter for success moment payment
  void onCallback(bool value) {
    // Handle the callback value
    currentMoment!.userSupported = value;
    if (mounted) setState(() {});
  }

  void commentSheet(
      BuildContext context, String momentID, String usernameMoment,
      {required int index, MomentsModel? currentMoment}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        borderSide: BorderSide.none,
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CommentListWidget(
          momentID: momentID,
          index: index,
          username: currentMoment!.ownerName!,
          moment: currentMoment,
          callbackUpdateCommentCount: (value, count) {
            if (value) {
              currentMoment.numberOfComments = count;

              // momentsBloc!.numberOfComments[index] =
              //     momentsBloc!.numberOfComments[index] + 1;
              if (mounted) setState(() {});
            } else {
              // momentsBloc!.numberOfComments[index] = count == 1
              //     ? momentsBloc!.numberOfComments[index] - 1
              //     : momentsBloc!.numberOfComments[index] - count;
              count == 1
                  ? currentMoment.numberOfComments - 1
                  : currentMoment.numberOfComments - count;

              if (mounted) setState(() {});
            }
          },
        ),
      ),
    ).then((value) {
      widget.controller!.play();
    });
  }
}
