import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/viewer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/YarnTopic.dart';
import '../widgets/yarn_media_renderer.dart';

class ReYarnTile extends StatefulWidget {
  final GestureTapCallback? onOptionsAction;

  final Yarn yarn;
  final Color? backGroundColor;

  ReYarnTile({
    required this.yarn,
    this.onOptionsAction,
    this.backGroundColor,
  });

  @override
  State<ReYarnTile> createState() => _ReYarnTileState();
}

class _ReYarnTileState extends State<ReYarnTile> {
  /// variables for yarn tile render TYPE
  bool isMediaPresent = false;

  @override
  void initState() {
    if ((widget.yarn.media.isNotEmpty)) {
      isMediaPresent = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greySecondaryYarn)
      ),
      child: _buildMain(),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(),
        SizedBox(
          height: 10,
        ),
        if (widget.yarn.isQuestion) ...[
          _buildPostTitle(),
          SizedBox(height: 8),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        if (isMediaPresent) ...[
          _buildImagesRow(),
        ],
        // _buildTopActions(),
      ],
    );
  }

  Widget _buildUserInfoRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4,
        ),
        // if (widget.yarn.category != null)...[
        //   _buildCategoryTypeChip(),
        //   SizedBox(
        //     height: 8,
        //   ),
        // ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {"searchedUserName": widget.yarn.author});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          messageDecoderWithEmoji(
                              widget.yarn.authorName ?? "") ??
                              "",
                          style: TextStyle(fontSize: 12, color: yarnBlack),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        ClipOval(
                          child: Container(
                            height: 4,
                            width: 4,
                            color: yarnBlack,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            '${getGetYarnQuestionDateTime(widget.yarn.createdAt!)}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 12, color: yarnBlack),
                          ),
                        )
                      ],
                    ),
                    userNameWithVerifiedIcon(
                      name: "@${widget.yarn.author!}",
                      isVerified: widget.yarn.authorIsVerified ?? false,
                      verifiedIconSize: 16,
                      textStyle: TextStyle(
                        color: yarnBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      verifiedIconColor: verifyBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: widget.yarn.authorAvatar!);
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.yarn.authorAvatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  // Widget _buildCategoryTypeChip() {
  //   if (widget.yarn.category != null) {
  //     return Container(
  //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20),
  //         color: yarnBlack,
  //       ),
  //       child: Text(
  //         widget.yarn.category!.name ?? "",
  //         style:
  //         TextStyle(color: white, fontSize: 9, fontWeight: FontWeight.w600),
  //       ),
  //     );
  //   } else {
  //     return SizedBox();
  //   }
  // }

  Widget _buildPostTitle() {
    return RichTextForTitle(
      description: messageDecoderWithEmoji(widget.yarn.title ?? '') ?? '',
    );
  }

  Widget _buildPostDescription() {
    return RichTextForTitle(
      description: messageDecoderWithEmoji(widget.yarn.body ?? '') ?? '',
    );
  }

  Widget _buildTagsAndViewerRow() {
    List<String> selectedImages = [];
    if (widget.yarn.viewersAvatars != null) {
      for (ViewersAvatars avatars in widget.yarn.viewersAvatars!) {
        selectedImages.add(avatars.avatar!);
      }
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                runSpacing: 5,
                spacing: 2,
                children: widget.yarn.tags!
                    .map((e) => Text(
                  "#$e",
                  style: TextStyle(
                      fontSize: 12,
                      color: navyBlue,
                      fontWeight: FontWeight.w500),
                ))
                    .toList(),
              ),
            ),
            SizedBox(
              width: 70,
              child: ViewerArranger(selectedImages: selectedImages),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // Widget _buildTopActions() {
  //   return YarnActions(
  //     yarn: widget.yarn,
  //   );
  // }

  Widget _buildImagesRow() {
    return YarnMediaRender(
      yarnTopic: widget.yarn,
    );
  }
}
