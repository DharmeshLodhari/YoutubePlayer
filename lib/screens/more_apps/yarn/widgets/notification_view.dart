import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/util.dart';
import '../models/Topics/Notifications.dart';
import '../utils/utils.dart';

class AskNotificationView extends StatelessWidget {
  Notifications? notification;
  Function(Notifications)? onDeleteNotification;

  AskNotificationView({Key? key, this.notification, this.onDeleteNotification})
      : super(key: key);

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
        if (notification!.body != null) ...[
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
                  Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                    "searchedUserName": notification!.authorUserName
                  });
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
                    if (notification!.type == "mention") ...[
                      RichTextForTitle(
                        description: notification!.title ?? "",
                      ),
                    ] else if (notification!.type == "like") ...[
                      RichTextForTitle(
                        description: notification!.title ?? "",
                      ),
                    ] else ...[
                      userNameWithVerifiedIcon(
                        name: "@${notification!.authorUserName}",
                        isVerified: false,
                        verifiedIconSize: 16,
                        textStyle: TextStyle(
                          color: yarnBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        verifiedIconColor: verifyGreen,
                      ),
                    ]
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                showDeleteNotificationDialog(context, notification!.id);
              },
              child: Icon(
                Icons.cancel,
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
      description: notification!.body ?? '',
    );
  }

  showDeleteNotificationDialog(BuildContext context, String? notificationId) {
    showDialogBox(
        context: context,
        actionOneTextColor: white,
        actionOneBgColor: mateRed,
        actionTwoTextColor: blackFont,
        actionTwoBgColor: greyBorderColor,
        title: 'Delete',
        actionTwoText: AppLocalization.of(context)!.cancel,
        actionOneText: AppLocalization.of(context)!.delete,
        description: 'Are you sure you want to delete this Notification?',
        roundedBackgroundIcon: RoundedBackgroundIcon(
          enableMargin: false,
          width: 90,
          height: 90,
          image: Icon(SlydoAppIcon.delete, color: mateRed),
        ),
        leftButtonOnPressed: () {
          // Navigator.pop(context);
          return deleteNotification(notificationId);
        },
        rightButtonOnPressed: () {
          debugPrint('Cancel clicked');
          // return Navigator.pop(context);
        });
  }

  deleteNotification(String? notificationId) async {
    bool? data = await YarnAuth().deleteNotification(notification!.id);
    if (data != null && data) {
      showToast(message: "Notification deleted successfully");

      if (notification != null) {
        onDeleteNotification!(notification!);
      }
    }
  }
}
