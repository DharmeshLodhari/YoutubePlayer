import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/components/viewer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../ask_comment_detail_screen.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/YarnTopic.dart';
import 'ask_comment_view.dart';

class AskPosts extends StatelessWidget {
  bool? openComments;
  List<CommentDetails>? commentDetailsList = [];
  bool? showTag;
  Function? onOptionsAction;

  bool? isImages = false;
  YarnTopic? yarnTopic;
  Color? backGroundColor;

  AskPosts({
    this.openComments = false,
    this.commentDetailsList,
    this.showTag = true,
    this.onOptionsAction,
    this.isImages,
    this.yarnTopic,
    this.backGroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
        decoration: BoxDecoration(
          color: HexColor("#FBFBFF"),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildPostCard(context: context));
  }

  Widget _buildPostCard({required BuildContext context}) {
    if (isImages!) {
      return _buildWithImagesPostCard(context: context);
    }
    return _buildWithOutImagesPostCard(context: context);
  }

  Widget _buildWithImagesPostCard({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(context: context),
        SizedBox(
          height: 10,
        ),
        if (yarnTopic!.isQuestion!) ...[
          _buildPostTitle(),
          SizedBox(height: 10),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        SizedBox(
          height: 15,
        ),
        _buildImagesRow(context: context),
        SizedBox(
          height: 20,
        ),
        _buildTopActions(),
        _buildCommentView(context: context),
      ],
    );
  }

  Widget _buildWithOutImagesPostCard({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(context: context),
        SizedBox(
          height: 10,
        ),
        if (yarnTopic!.isQuestion!) ...[
          _buildPostTitle(),
          SizedBox(height: 10),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        SizedBox(
          height: 15,
        ),
        _buildTopActions(),
        _buildCommentView(context: context),
      ],
    );
  }

  Widget _buildUserInfoRow({required BuildContext context}) {
    return Row(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                    arguments: yarnTopic!.authorAvatar!);
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: yarnTopic!.authorAvatar!,
                    fit: BoxFit.cover,
                    errorWidget: imageErrorWidget,
                  ),
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
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.USER_PROFILE,
                    arguments: {
                      "searchedUserName": yarnTopic!.author
                    });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userNameWithVerifiedIcon(
                      name: yarnTopic!.authorName!, isVerified: false),
                  Text(
                    "@${yarnTopic!.author!}",
                    style: TextStyle(
                      fontSize: 10,
                      color: HexColor("#3F61DB")
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.verified,
              color: HexColor("#3F61DB"),
              size: 12,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '',
              style: TextStyle(
                color: blackFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )),
        InkWell(
          onTap: () => onOptionsAction!(),
          child: Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF4B545A),
          ),
        )
      ],
    );
  }

  Widget _buildPostTitle() {
    return Text(
      yarnTopic!.title!,
      maxLines: 30,
      style: TextStyle(
        color: blackFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPostDescription() {
    return Text(
      yarnTopic!.body!,
      maxLines: 30,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTagsAndViewerRow() {
    List<String> selectedImages = [];
    if (yarnTopic!.viewersAvatars != null) {
      for (ViewersAvatars avatars in yarnTopic!.viewersAvatars!) {
        selectedImages.add(avatars.avatar!);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            runSpacing: 5,
            spacing: 2,
            children: yarnTopic!.tags!
                .map((e) => Text(
                  "#$e",
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor("#3F61DB"),
                  ),
                ))
                .toList(),
          ),
        ),
        SizedBox(
            width: 70, child: ViewerArranger(selectedImages: selectedImages)),
      ],
    );
  }

  Widget _buildTopActions() {
    return TopicActions(
      yarnTopic: yarnTopic!,
      commentCount: yarnTopic!.numberOfComments != null ? yarnTopic!.numberOfComments! : 0,
    );
  }

  Widget _buildImagesRow({required BuildContext context}) {
    if (yarnTopic!.media!.length == 1) {
      return _buildSingleImage(context: context);
    } else if (yarnTopic!.media!.length == 2) {
      return _buildTwoImageRow(context: context);
    } else if (yarnTopic!.media!.length == 3) {
      return _buildThreeImageRow(context: context);
    } else if (yarnTopic!.media!.length >= 4) {
      return _buildFourImageRow(context: context);
    }
    return SizedBox();
  }

  Widget _buildSingleImage({required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: yarnTopic!.media!.first.file!,);
      },
      child: Container(
        width: double.infinity,
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: yarnTopic!.media!.first.file!,
              fit: BoxFit.cover,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImageRow({required BuildContext context}) {
    return Container(
      height: 175,
      child: Row(
        children: yarnTopic!.media!
            .map((mediaFile) => Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                  arguments: mediaFile.file!);
            },
            child: Container(
              height: (MediaQuery.of(context).size.width - 40) / 2,
              width: (MediaQuery.of(context).size.width - 40) / 2,
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: yarnTopic!.media![0].file!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
          ),
        ),)
            .toList(),
      ),
    );
  }

  Widget _buildThreeImageRow({required BuildContext context}) {
    return Container(
      height: 175,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                  arguments: yarnTopic!.media![0].file!);
              },
              child: Container(
                height: (MediaQuery.of(context).size.width - 40) / 2,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: yarnTopic!.media![0].file!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                    arguments: yarnTopic!.media![1].file!);
              },
              child: Container(
                height: (MediaQuery.of(context).size.width - 40) / 2,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: yarnTopic!.media![1].file!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                    arguments: yarnTopic!.media![2].file!);
              },
              child: Container(
                height: (MediaQuery.of(context).size.width - 40) / 2,
                width: (MediaQuery.of(context).size.width - 40) / 2,
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: yarnTopic!.media![2].file!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImageRow({required BuildContext context}) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: yarnTopic!.media![0].file!);
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 40) / 2,
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: yarnTopic!.media![0].file!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: yarnTopic!.media![1].file!);
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 40) / 2,
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: yarnTopic!.media![1].file!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8,),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: yarnTopic!.media![2].file!);
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 40) / 2,
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: yarnTopic!.media![2].file!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: yarnTopic!.media![3].file!);
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width - 40) / 2,
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: yarnTopic!.media![3].file!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentView({required BuildContext context}) {
    if (openComments! && commentDetailsList!.isNotEmpty && commentDetailsList != null) {
      return Column(
        children: [
          Divider(
            thickness: 1,
            color: HexColor("#BEC2F4"),
          ),
          Column(
            children: commentDetailsList!
                .map((e) => InkWell(
              onTap: () {
                NavigationUtil.push(
                  context,
                  screen: AskCommentDetailScreen(yarnTopic: yarnTopic, commentDetail: e,),
                );
              },
              child: AskCommentView(
                yarnTopic: yarnTopic,
                commentDetail: e,
                openReply: false,
              ),
            )).toList(),
          ),
        ],
      );
    }
    return SizedBox();
  }
}
