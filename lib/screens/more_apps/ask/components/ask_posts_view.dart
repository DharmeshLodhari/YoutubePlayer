import 'package:Slydo/screens/more_apps/ask/components/topic_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/util.dart';

class AskPosts extends StatelessWidget {
  bool? openComments;
  Widget? commentsOnPosts;
  bool? showTag;
  Function? onOptionsAction;

  bool? isImages = false;
  List<String>? tags = [];
  String? authorName;
  String? authorAvatar;
  String? title;
  String? body;
  List<String>? images;

  AskPosts({
    this.openComments = false,
    this.commentsOnPosts,
    this.showTag = true,
    this.onOptionsAction,
    this.isImages,
    this.tags,
    this.authorName,
    this.authorAvatar,
    this.title,
    this.body,
    this.images
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: HexColor("#FBFBFF"),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildPostCard()
      ),
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
        _buildPostTitle(),
        SizedBox(
          height: 10,
        ),
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        SizedBox(
          height: 15,
        ),
        _buildImagesRow(),
        SizedBox(height: 20,),
        _buildTopActions(),
        SizedBox(
          height: 20,
        ),
        if (openComments! && commentsOnPosts != null) ...[
          Divider(
            thickness: 1,
            color: blackFont.withOpacity(0.3),
          ),
          commentsOnPosts!,
        ]
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
        _buildPostTitle(),
        SizedBox(
          height: 10,
        ),
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
        if (openComments! && commentsOnPosts != null) ...[
          Divider(
            thickness: 1,
            color: blackFont.withOpacity(0.3),
          ),
          commentsOnPosts!,
        ]
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
                  imageUrl: authorAvatar!,
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
                userNameWithVerifiedIcon(name: authorName!, isVerified: false),
                SizedBox(width: 5,),
                Icon(
                  Icons.verified,
                  color: HexColor("#3F61DB"),
                  size: 12,
                ),
                SizedBox(width: 5,),
                Text(
                  '4 mins',
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
        ),
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
      title!,
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
      body!,
      maxLines: 30,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTagsAndViewerRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: tags!.map((e) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Color(0xFFEBEDFC),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: EdgeInsets.only(right: 5),
              child: Text(
                e,
                style: TextStyle(
                  fontSize: 8,
                ),
              ),
            )).toList(),
          ),
        ),
        Container(
          height: 22,
          width: 22,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF06164B)
          ),
          child: Text(
            "+11",
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopActions() {
    return TopicActions(
      totalDislikes: '30',
      totalLikes: '323',
      totalReply: '23',
    );
  }

  Widget _buildImagesRow() {
    return Container(
      height: 175,
      child: Row(
        children: images!.map((e) => Expanded(
          child: Container(
            height: 175,
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CachedNetworkImage(
              imageUrl: e,
              fit: BoxFit.contain,
              errorWidget: imageErrorWidget,
            ),
          ),
        )).toList(),
      ),
    );
  }

}
