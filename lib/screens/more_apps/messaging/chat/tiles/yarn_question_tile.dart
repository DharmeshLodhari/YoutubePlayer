import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/util.dart';

class YarnQuestionTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  YarnQuestionTileForChat(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<YarnQuestionTileForChat> createState() => _YarnQuestionTileForChatState();
}

class _YarnQuestionTileForChatState extends State<YarnQuestionTileForChat> {
  late UserBloc userBloc;
  late YarnQuestionForChatModel yarnQuestionForChatModel;
  // VideoPlayerController? _mainVideoController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    yarnQuestionForChatModel =
        YarnQuestionForChatModel.fromJson(jsonDecode(widget.message!['meta_data']));

    // if (momentForChatModel.video != null) {
    //   isLoading = true;
    //   if (mounted) setState(() {});
    //   _mainVideoController = VideoPlayerController.network(
    //     momentForChatModel.video!,
    //     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    //   )..initialize().then((_) {
    //       isLoading = false;
    //       if (mounted) setState(() {});
    //     });
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // _mainVideoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    bool isSend = widget.message!["author"] == userBloc.user.userName;

    return GestureDetector(
      onTap: () async {
        // isLoading = true;
        // if (mounted) setState(() {});
        //
        // await MomentsService()
        //     .getSingleMoment(momentId: yarnQuestionForChatModel.id!)
        //     .then((momentsModelList) {
        //   isLoading = false;
        //   if (mounted) setState(() {});
        //
        //   NavigationUtil.push(
        //     context,
        //     screen: MomentsDetailsScreen(
        //       indexOfMoment: 0,
        //       momentsModelList: [momentsModelList],
        //     ),
        //   );
        // }).catchError((e) {
        //   isLoading = false;
        //   if (mounted) setState(() {});
        //   showToast(message: 'ERROR -> $e');
        // });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.35,
                  minWidth: MediaQuery.of(context).size.width / 1.35,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: widget.chatConversation!.isGroupConversation!
                      ? isSend
                      ? Colors.transparent
                      : Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.chatConversation!.isGroupConversation!
                        ? isSend
                        ? 0
                        : 8
                        : 0,
                    vertical: widget.chatConversation!.isGroupConversation!
                        ? isSend
                        ? 0
                        : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.chatConversation!.isGroupConversation!
                        ? widget.message!['author'] != userBloc.user.userName
                        ? Column(
                      children: [
                        Text(
                          widget.message!['author_full_name'] ??
                              widget.message!['author'],
                          style: TextStyle(
                              color: isSend ? Colors.white : navyBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                      ],
                    )
                        : Container(
                      height: 0,
                      width: 0,
                    )
                        : Container(
                      height: 0,
                      width: 0,
                    ),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          decoration: decorateBox(color: Colors.white),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildPostCard(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isSend
                  ? Container(
                width: 20,
                child: isSend
                    ? Center(
                  child: getMessageTick(message: widget.message!),
                )
                    : Container(),
              )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 2,
          ),
          Row(
            mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                width: 20,
              ),
              Text(
                formatTime(widget.message!['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                width: 20,
              )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    // if (yarnQuestionForChatModel.image != null) {
    //   return _buildWithImagesPostCard();
    // }
    return _buildWithOutImagesPostCard();
  }

  // Widget _buildWithImagesPostCard() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildUserInfoRow(),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       _buildPostTitle(),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       _buildPostDescription(),
  //       // SizedBox(
  //       //   height: 10,
  //       // ),
  //       // _buildImagesRow(),
  //       // SizedBox(height: 20,),
  //     ],
  //   );
  // }

  Widget _buildWithOutImagesPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        _buildPostTitle(),
        SizedBox(
          height: 10,
        ),
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                  shape: BoxShape.circle
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: yarnQuestionForChatModel.authorAvatar!,
                  fit: BoxFit.cover,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        Expanded(
            child: Row(
              children: [
                userNameWithVerifiedIcon(name: yarnQuestionForChatModel.authorUsername!, isVerified: false),
                SizedBox(width: 5,),
                Icon(
                  Icons.verified,
                  color: HexColor("#3F61DB"),
                  size: 12,
                ),
                SizedBox(width: 5,),
                Text(
                  '',
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  Widget _buildPostTitle() {
    return Text(
      yarnQuestionForChatModel.title!,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: TextStyle(
        color: blackFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPostDescription() {
    return Text(
      yarnQuestionForChatModel.description ?? "",
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Widget _buildImagesRow() {
  //   return Container(
  //     height: 175,
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(10),
  //       child: CachedNetworkImage(
  //         imageUrl: yarnQuestionForChatModel.image!.first.file!,
  //         fit: BoxFit.contain,
  //         errorWidget: imageErrorWidget,
  //       ),
  //     ),
  //   );
  // }
}

class YarnQuestionForChatModel {
  String? id;
  String? title;
  String? authorAvatar;
  String? authorUsername;
  String? description;

  YarnQuestionForChatModel({
    required this.id,
    required this.title,
    required this.authorAvatar,
    required this.authorUsername,
    required this.description,
  });

  factory YarnQuestionForChatModel.fromJson(Map<String, dynamic> json) {
    return YarnQuestionForChatModel(
      id: json['id'],
      title: json['title'],
      authorAvatar: json['author_avatar'],
      authorUsername: json['author_username'],
      description: json['description']
    );
  }
}
