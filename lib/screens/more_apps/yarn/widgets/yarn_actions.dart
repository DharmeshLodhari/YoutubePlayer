import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
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
  bool? minusComment;
  List<Yarn>? checkIfReyarned;

  YarnActions(
      {required this.yarn,
      this.onReYarnAdded,
      this.minusComment,
      this.checkIfReyarned});

  @override
  State<YarnActions> createState() => _YarnActionsState();
}

class _YarnActionsState extends State<YarnActions> {
  late YarnDashboardBloc yarnDashboardBloc;

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
        const SizedBox(
          width: 22,
        ),
        _buildShareButton(),
        const SizedBox(
          width: 45,
        ),
        _buildPayButton(),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  Widget _buildActionableList() {
    final List<Widget> finalActionList = [];

    finalActionList.addAll([
      Expanded(child: _buildCommentButton()),
      Expanded(child: _buildLikeButton()),
      Expanded(child: _buildDisLikeButton()),
      Expanded(child: _buildReYarnButton()),
    ]);

    return Row(
      children: finalActionList,
    );
  }

  Widget _buildCommentButton() {
    return InkWell(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: YarnDetailScreen(yarn: widget.yarn),
        );
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "yarn/yarn_comment".toSVG(),
            color: darkGreyYarn,
            height: 15,
            width: 15,
          ),
          const SizedBox(
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
      padding: const EdgeInsets.only(left: 5),
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
        final int count = getLikeCount();
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
      padding: const EdgeInsets.only(left: 10),
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
        final int count = getDisLikeCount();
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

  Widget _buildReYarnButton() {
    bool canReYarn = true;
    bool canReYarnTemp = true;
    final bool canReYarnMain = true;
    if (widget.yarn.reYarn != null) {
      canReYarn = false;
    }

    if (widget.checkIfReyarned != null) {
      for (var item in widget.checkIfReyarned!) {
        if (item.reYarn!.id == widget.yarn.id) {
          canReYarnTemp = false;
        }
      }
    }

    return InkWell(
      onTap: () {
        if (!canReYarnTemp) {
          showToast(message: "You cannot Reyarn.");
          return;
        }

        if (canReYarn) {
          if (widget.yarn.userReyarned) {
            showToast(message: "Reyarn added already");
          } else {
            NavigationUtil.push(context,
                screen: ShareAsAyarnScreen(
                    appTitle: "Reyarn",
                    enableText: true,
                    isShare: false,
                    askCategories: yarnDashboardBloc.yarnCategories,
                    shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
                    yarnTopic: widget.yarn,
                    callback: (params) async {
                      createReYarn(params);
                      showToast(message: "Reyarn successful");
                    }));
          }
        } else {
          showToast(message: "You cannot Reyarn.");
        }
      },
      child: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          SvgPicture.asset(
            "yarn/re_share".toSVG(),
            color: widget.yarn.userReyarned ? naturalGreen : darkGreyYarn,
            height: 15,
            width: 15,
          ),
          const SizedBox(
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
          const SizedBox(
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

              if (widget.yarn.userSupported == true) {
                showToast(message: 'You already supported this Yarn');
                return;
              }

              // if (getIt<AppConfigurationBloc>()
              //         .appConfigurationModel
              //         ?.enablePayment ==
              //     true) {
              Navigator.of(context).pushNamed(
                Routes.SEND_PAYMENT,
                arguments: <String, dynamic>{
                  'recipient': widget.yarn.author,
                  'isFromProfile': false,
                  'isFromChat': false,
                  'isFromYarn': true,
                  'isFromMoment': false,
                  'callback': onCallback,
                  'yarnId': widget.yarn.id != null ? widget.yarn.id! : '',
                  'defaultReferenceText':
                      'Payment from Yarn, Yard ID : ${widget.yarn.id != null ? widget.yarn.id! : ''} '
                },
              );
              // } else {
              //   showToast(message: 'Payment not available at the moment');
              // }
            }
          : () {
              if (!isPayMeEnable) return;
              showToast(message: 'You cannot pay yourself');
            },
      child: Column(
        children: [
          const SizedBox(
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

  // callback function with a bool parameter for success yarn payment
  void onCallback(bool value) {
    // Handle the callback value
    widget.yarn.userSupported = value;
    if (mounted) setState(() {});
  }

  String getCommentCount() {
    if (widget.yarn.numberOfComments != null &&
        widget.yarn.numberOfComments != 0) {
      if (widget.minusComment == true) {
        return (widget.yarn.numberOfComments! - 1).toString();
      } else {
        return widget.yarn.numberOfComments?.toString() ?? "";
      }
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
    final Map<String, dynamic>? data =
        await YarnAuth().addLike(widget.yarn.id!);
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
    final Map<String, dynamic>? data =
        await YarnAuth().addDisLike(widget.yarn.id!);
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

  Future createReYarn(Yarn yarn) async {
    yarn.reYarn = widget.yarn;

    final Yarn? data = await YarnAuth().addReYarn(yarn);
    setState(() {
      widget.yarn.userReyarned = !widget.yarn.userReyarned;
    });
    if (data != null) {
      showToast(message: "Reyarn added successfully");
      widget.yarn.numberOfReYarn = (widget.yarn.numberOfReYarn ?? 0) + 1;
      widget.onReYarnAdded!(data);
      if (mounted) setState(() {});
    }
  }

  Future<void> sendMomentToUserInChat({required Yarn yarnTopic}) async {
    final List<ChatConversation?> listOfRecipient =
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
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    final Map<String, dynamic> metaData = yarnTopic.toJson();

    final Map<String, dynamic> data = {
      "meta_data": jsonEncode(metaData),
      "check_id": const Uuid().v4(),
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
