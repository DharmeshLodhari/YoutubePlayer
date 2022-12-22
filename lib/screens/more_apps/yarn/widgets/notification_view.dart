import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/Notifications.dart';
import '../utils/utils.dart';

class AskNotificationView extends StatelessWidget {
  Notifications? notification;
  AskNotificationView({Key? key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: _buildMain(context: context));
  }

  Widget _buildMain({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(context: context),
        SizedBox(
          height: 10,
        ),
        if (notification!.body != null)...[
          _buildPostDescription(),
          SizedBox(
            height: 10,
          ),
        ],
      ],
    );
  }

  Widget _buildUserInfoRow({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserAvatar(context: context),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {"searchedUserName": notification!.authorUserName});
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          messageDecoderWithEmoji(
                              notification!.authorName ?? "") ??
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
                            '${getGetYarnQuestionDateTime(notification!.createdAt!)}',
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 12, color: yarnBlack),
                          ),
                        )
                      ],
                    ),
                    if (notification!.type == "mention")...[
                      RichTextForTitle(
                        description: notification!.title ?? "",
                      ),
                    ] else if (notification!.type == "like")...[
                      RichTextForTitle(
                        description: notification!.title ?? "",
                      ),
                    ] else...[
                      userNameWithVerifiedIcon(
                        name: "@${notification!.authorUserName}",
                        isVerified: false,
                        verifiedIconSize: 16,
                        textStyle: TextStyle(
                          color: yarnBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        verifiedIconColor: verifyBlue,
                      ),
                    ]
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Icon(
                Icons.more_horiz_rounded,
                color: darkGreyYarn,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar({required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: notification!.authorAvatar ?? "");
      },
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: notification!.authorAvatar ?? "",
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildPostDescription() {
    return RichTextForTitle(
      description: messageDecoderWithEmoji(notification!.body ?? '') ?? '',
    );
  }
}
