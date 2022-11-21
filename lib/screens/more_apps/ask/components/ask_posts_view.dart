import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/components/viewer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/util.dart';
import '../models/Topics/YarnTopic.dart';

class AskPosts extends StatelessWidget {
  bool? openComments;
  Widget? commentsOnPosts;
  bool? showTag;
  Function? onOptionsAction;

  bool? isImages = false;
  YarnTopic? yarnTopic;
  Color? backGroundColor;

  AskPosts({
    this.openComments = false,
    this.commentsOnPosts,
    this.showTag = true,
    this.onOptionsAction,
    this.isImages,
    this.yarnTopic,
    this.backGroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color:
                backGroundColor == null ? HexColor("#FBFBFF") : backGroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildPostCard()),
    );
  }

  Widget _buildPostCard() {
    if (isImages!) {
      return _buildWithImagesPostCard();
    }
    return _buildWithOutImagesPostCard();
  }

  Widget _buildWithImagesPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
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
        _buildImagesRow(),
        SizedBox(
          height: 20,
        ),
        _buildTopActions(),
        SizedBox(
          height: 20,
        ),
        _buildCommentView(),
      ],
    );
  }

  Widget _buildWithOutImagesPostCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
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
        SizedBox(
          height: 20,
        ),
        _buildCommentView(),
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
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: yarnTopic!.authorAvatar!,
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
            userNameWithVerifiedIcon(
                name: yarnTopic!.authorName!, isVerified: false),
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
              '4 mins',
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
            children: yarnTopic!.tags!
                .map((e) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Color(0xFFEBEDFC),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      margin: EdgeInsets.only(right: 5),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 8,
                        ),
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
    );
  }

  Widget _buildImagesRow() {
    return Container(
      height: 175,
      child: Row(
        children: yarnTopic!.media!
            .map((mediaFile) => Expanded(
                  child: Container(
                    height: 175,
                    padding: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: mediaFile.file!,
                      fit: BoxFit.contain,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCommentView() {
    if (openComments! && commentsOnPosts != null) {
      return Column(
        children: [
          Divider(
            thickness: 1,
            color: HexColor("#BEC2F4"),
          ),
          commentsOnPosts!,
        ],
      );
    }
    return SizedBox();
  }
}
