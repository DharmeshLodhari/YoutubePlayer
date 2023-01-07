import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import "package:uuid/uuid.dart";

import '../models/share_as_yarn_model.dart';
import '../share_as_a_yarn_screen.dart';
import '../yarn_dashboard_bloc.dart';

class YarnActions extends StatefulWidget {
  final Yarn yarn;
  final Function(Yarn)? onReYarnAdded;
  YarnActions({required this.yarn, this.onReYarnAdded});

  @override
  State<YarnActions> createState() => _YarnActionsState();
}

class _YarnActionsState extends State<YarnActions> {
  late YarnDashboardBloc yarnDashboardBloc;

  // CustomerProfile? searchedUser;

  int retweetCount = 1;
  @override
  void initState() {
    // retweetCount = Random().nextInt(200);
    // searchedUser = CustomerProfile();

    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildActionableList()),
        SizedBox(
          width: 22,
        ),
        _buildShareButton(),
        SizedBox(
          width: 45,
        ),
        _buildPayButton(),
        SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget _buildActionableList() {
    List<Widget> finalActionList = [];

    if (enableCommenting()) {
      finalActionList.add(Expanded(child: _buildCommentButton()));
    }

    finalActionList.addAll([
      Expanded(child: _buildLikeButton()),
      Expanded(child: _buildDisLikeButton()),
      Expanded(child: _buildRetweetButton()),
    ]);

    if (finalActionList.length == 3) {
      finalActionList.add(Expanded(child: Container()));
    }

    return Row(
      children: finalActionList,
    );
  }

  Widget _buildCommentButton() {
    return InkWell(
      onTap: enableCommenting()
          ? () {
              NavigationUtil.push(
                context,
                screen: YarnDetailScreen(yarn: widget.yarn),
              );
            }
          : null,
      child: Row(
        children: [
          SvgPicture.asset(
            "yarn/yarn_comment".toSVG(),
            color: darkGreyYarn,
            height: 15,
            width: 15,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            getCommentCount(),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: darkGreyYarn),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return LikeButton(
      mainAxisAlignment: MainAxisAlignment.start,
      padding: EdgeInsets.only(left: 5),
      size: 15,
      circleColor: CircleColor(start: red, end: red),
      bubblesColor: BubblesColor(
        dotPrimaryColor: red,
        dotSecondaryColor: red,
      ),
      onTap: (isLike) {
        return addLikeToYarnAndQuestion();
      },
      likeBuilder: (bool isLiked) {
        return SvgPicture.asset(
          widget.yarn.userUpvoted
              ? "yarn/likeAfter".toSVG()
              : "yarn/likeBefore".toSVG(),
          color: widget.yarn.userUpvoted ? red : darkGreyYarn,
          height: 13,
          width: 13,
        );
      },
      likeCount: getLikeCount(),
      countBuilder: (_, __, ___) {
        int count = getLikeCount();
        return Text(
          count == 0 ? '' : count.toString(),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: widget.yarn.userUpvoted ? red : darkGreyYarn),
        );
      },
    );
  }

  Widget _buildDisLikeButton() {
    return LikeButton(
      padding: EdgeInsets.only(left: 10),
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      size: 15,
      circleColor: CircleColor(start: starYellow, end: starYellow),
      bubblesColor: BubblesColor(
        dotPrimaryColor: starYellow,
        dotSecondaryColor: starYellow,
      ),
      onTap: (isLike) {
        return addDisLikeToYarnAndQuestion();
      },
      likeBuilder: (bool isLiked) {
        return SvgPicture.asset(
          widget.yarn.userDownVoted
              ? "yarn/unlikeAfter".toSVG()
              : "yarn/unlikeBefore".toSVG(),
          color: widget.yarn.userDownVoted ? starYellow : darkGreyYarn,
          height: 13,
          width: 13,
        );
      },
      likeCount: getDisLikeCount(),
      countBuilder: (_, __, ___) {
        int count = getDisLikeCount();
        return Text(
          count == 0 ? '' : count.toString(),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: widget.yarn.userDownVoted ? starYellow : darkGreyYarn),
        );
      },
    );
  }

  Widget _buildRetweetButton() {
    return InkWell(
      onTap: getLoggedInUserName(context) != widget.yarn.author
          ? () {
              if (widget.yarn.userReyarned) {
                showToast(message: "Re yarn added successfully");
              } else {
                addReYarn();
              }
            }
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          SvgPicture.asset(
            "yarn/re_share".toSVG(),
            color: widget.yarn.userReyarned ? naturalGreen : darkGreyYarn,
            height: 15,
            width: 15,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            getReYarnCount(),
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: widget.yarn.userReyarned ? naturalGreen : darkGreyYarn),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
      onTap: () {
        androidBottomSheet(
          context: context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bottomSheetItem(
                  title: 'Share in chat',
                  iconData: Icons.send_outlined,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await sendMomentToUserInChat(yarnTopic: widget.yarn);
                  }),
            ],
          ),
        );
      },
      // child: SvgPicture.asset("ask/share".toSVG()),
      child: Column(
        children: [
          SvgPicture.asset(
            "yarn/share".toSVG(),
            color: darkGreyYarn,
            height: 17,
            width: 17,
          ),
          SizedBox(
            height: 2,
          )
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    bool isPayMeEnable = false;
    if (widget.yarn.enablePayMe ?? false) {
      isPayMeEnable = true;
    }

    return InkWell(
      onTap: getLoggedInUserName(context) != widget.yarn.author
          ? () {
              if (!isPayMeEnable) return;

              if (getIt<AppConfigurationBloc>()
                      .appConfigurationModel
                      ?.enablePayment ==
                  true) {
                Navigator.of(context).pushNamed(
                  Routes.SEND_PAYMENT,
                  arguments: <String, dynamic>{
                    'recipient': widget.yarn.author,
                    'isFromProfile': false,
                    'isFromChat': false,
                    'defaultReferenceText': 'Payment from  "${truncateString(
                      str: widget.yarn.title!,
                      lengthToTruncateAt: 8,
                    )}\" yarn'
                  },
                );
              } else {
                showToast(message: 'Payment not available at the moment');
              }
            }
          : () {
              if (!isPayMeEnable) return;
              showToast(message: 'You cannot pay yourself');
            },
      child: Column(
        children: [
          SizedBox(
            height: 2,
          ),
          SvgPicture.asset(
            "yarn/send_money".toSVG(),
            color: !isPayMeEnable
                ? Colors.transparent
                : widget.yarn.userSupported
                    ? deepBlue
                    : null,
            height: 15,
            width: 15,
          ),
        ],
      ),
    );
  }

  String getCommentCount() {
    if (widget.yarn.numberOfComments != null &&
        widget.yarn.numberOfComments != 0) {
      return widget.yarn.numberOfComments?.toString() ?? "";
    }
    return "";
  }

  int getLikeCount() {
    if (widget.yarn.voteCount != null && widget.yarn.voteCount != 0) {
      return widget.yarn.voteCount ?? 0;
    }
    return 0;
  }

  int getDisLikeCount() {
    if (widget.yarn.downVoteCount != null &&
        widget.yarn.downVoteCount != 0 &&
        widget.yarn.userDownVoted == true) {
      return widget.yarn.downVoteCount ?? 0;
    }
    return 0;
  }

  String getReYarnCount() {
    if (widget.yarn.numberOfReYarn != null && widget.yarn.numberOfReYarn != 0) {
      return widget.yarn.numberOfReYarn?.toString() ?? "";
    }
    return "";
  }

  bool enableCommenting() {
    if (widget.yarn.enableCommenting != null &&
        (widget.yarn.enableCommenting ?? false)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await YarnAuth().addLike(widget.yarn.id!);
    setState(() {
      widget.yarn.userUpvoted = !widget.yarn.userUpvoted;
      widget.yarn.userDownVoted = false;
    });
    if (data != null) {
      setState(() {
        widget.yarn.voteCount = data['vote_count'];
        widget.yarn.downVoteCount = data['down_vote_count'];
      });
      return true;
    }
    return false;
  }

  Future<bool> addDisLikeToYarnAndQuestion() async {
    Map<String, dynamic>? data = await YarnAuth().addDisLike(widget.yarn.id!);
    setState(() {
      widget.yarn.userDownVoted = !widget.yarn.userDownVoted;
      widget.yarn.userUpvoted = false;
    });
    if (data != null) {
      setState(() {
        widget.yarn.voteCount = data['vote_count'];
        widget.yarn.downVoteCount = data['down_vote_count'];
      });
      return true;
    }
    return false;
  }

  Future reYarn(Yarn yarn) async {
    Map<String, dynamic> yarnMap = yarn.toAddMap();
    yarnMap['reyarn'] = widget.yarn.id;
    // print('object  yarn here');
    // Map<String, dynamic> body = {"reyarn": widget.yarn.id};
    // debugPrint("BODY DATA:- $body");

    // logger.d('this is the yarn map data $yarnMap');

    Yarn? data = await YarnAuth().addReYarn(yarnMap);
    setState(() {
      widget.yarn.userReyarned = !widget.yarn.userReyarned;
    });
    if (data != null) {
      showToast(message: "Re yarn added successfully");
      widget.yarn.numberOfReYarn = (widget.yarn.numberOfReYarn ?? 0) + 1;
      widget.onReYarnAdded!(data);
      if (mounted) setState(() {});
    }
  }

  addReYarn() {
    if (widget.yarn.userReyarned) {
      showToast(message: "Re yarn added successfully");
    } else {
      showModalBottomSheet<void>(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: GestureDetector(
                          onTap: () async {
                            await NavigationUtil.push(context,
                                screen: ShareAsAyarnScreen(
                                    appTitle: "Reyarn",
                                    enableText: true,
                                    askCategories:
                                        yarnDashboardBloc.yarnCategories,
                                    shareAsYarnModel:
                                        ShareAsYarnModel.shareAsYarnModel,
                                    callback: (params) async {
                                      reYarn(params);
                                      showToast(
                                          message:
                                              "Share in Yarn successfully created");
                                    }));
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "yarn/re_share".toSVG(),
                                color: blackFont,
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Reyarn',
                                style: TextStyle(
                                    color: blackFont,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Divider(
                        color: darkGrey,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: GestureDetector(
                          onTap: () async {
                            await NavigationUtil.push(context,
                                screen: ShareAsAyarnScreen(
                                    appTitle: "Quote Yarn",
                                    askCategories:
                                        yarnDashboardBloc.yarnCategories,
                                    shareAsYarnModel:
                                        ShareAsYarnModel.shareAsYarnModel,
                                    callback: (params) async {
                                      reYarn(params);
                                      showToast(
                                          message:
                                              "Share in Yarn successfully created");
                                    }));
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/pen-feather.png',
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Quote Yarn',
                                style: TextStyle(
                                    color: blackFont,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: darkGreyYarn.withOpacity(.3))),
                          child: Center(
                              child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          )),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ));
          });
    }
  }

  Future<void> sendMomentToUserInChat({required Yarn yarnTopic}) async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addMomentPostToChat(recipientUser: recipient!, yarnTopic: yarnTopic);
    });
  }

  Future<void> addMomentPostToChat({
    required ChatConversation recipientUser,
    required Yarn yarnTopic,
    String? url,
  }) async {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    Map<String, dynamic> metaData = yarnTopic.toJson();
    // {
    //   "id": yarnTopic.id,
    //   "author_avatar": yarnTopic.authorAvatar,
    //   "author_name": messageDecoderWithEmoji(yarnTopic.authorName),
    //   "author_username": yarnTopic.author,
    //   "title": messageDecoderWithEmoji(yarnTopic.title),
    //   "description": yarnTopic.body,
    //   "tags": yarnTopic.tags,
    //   "image": yarnTopic.media,
    //   "is_question": yarnTopic.isQuestion,
    //   "author_is_verified": yarnTopic.authorIsVerified,
    // };

    // switch (yarnTopic.mediaType) {
    //   case "image":
    //     metaData.addAll({"image": momentsModel.media});
    //     break;
    //   case "video":
    //     metaData.addAll({"image": momentsModel.mediaPoster});
    //     break;
    // }

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'yarn',
      "kind": "yarn",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(
        message: yarnTopic.isQuestion ? 'Question Shared' : 'Yarn Shared');
  }
}
