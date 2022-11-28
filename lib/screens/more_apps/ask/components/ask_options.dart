import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../../utils/util.dart';
import '../ask_auth.dart';
import '../ask_report_screen.dart';
import '../models/Topics/YarnTopic.dart';

class AskOptions extends StatefulWidget {

  YarnTopic? yarnTopic;
  AskOptions({this.yarnTopic});
  @override
  State<AskOptions> createState() => _AskOptionsState();
}

class _AskOptionsState extends State<AskOptions> {

  Future addUserVisibilityOption(String status) async {
    bool? data = await AskAuth().addStatusInPost(widget.yarnTopic!.id!, status);
    if (data != null) {
      if (data) {
        showToast(message: "Status Updated Successfully");
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (isMyYarnQuestion()) {
      return _buildMoreOptionForOwner();
    }
    return _buildMoreOptionForOther();
  }

  Widget _buildMoreOptionForOwner() {
    return Container(
      height: 240,
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'More options',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            color: HexColor("#EBEDFC"),
          ),
          SizedBox(
            height: 15,
          ),
          if (widget.yarnTopic!.isQuestion!)...[
            _buildTile(
                icon: Icons.verified_outlined,
                title: 'Accept Answer ',
                subTitle: 'Once you accept this answer, your bounty \nreward will be sent to this user.'
            ),
            SizedBox(
              height: 15,
            ),
            _buildTile(
                icon: SlydoAppIconNew.hide_commenting,
                iconSize: 18,
                width: 12,
                title: 'Turn off commenting',
                subTitle: 'Disable commenting on this post.'
            ),
            SizedBox(
              height: 15,
            ),
            _buildTile(
                icon: SlydoAppIconNew.delete_post,
                iconSize: 18,
                width: 12,
                title: 'Delete',
                subTitle: 'Delete this question'
            ),
          ] else ...[
            _buildTile(
                icon: SlydoAppIconNew.edit_post,
                iconSize: 18,
                width: 12,
                title: 'Edit',
                subTitle: 'Edit yarn'
            ),
            SizedBox(
              height: 15,
            ),
            _buildTile(
                icon: SlydoAppIconNew.hide_commenting,
                iconSize: 18,
                width: 12,
                title: 'Turn off commenting',
                subTitle: 'Disable commenting on this post.'
            ),
            SizedBox(
              height: 15,
            ),
            _buildTile(
                icon: SlydoAppIconNew.delete_post,
                iconSize: 18,
                width: 12,
                title: 'Delete',
                subTitle: 'Delete this yarn'
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoreOptionForOther() {
    return Container(
      height: 270,
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'More options',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            color: HexColor("#EBEDFC"),
          ),
          SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: SlydoAppIconNew.save_post,
              iconSize: 18,
              width: 12,
              title: 'Save yarn/question',
              subTitle: 'Add this to you saved items',
              onTap: () {
                addUserVisibilityOption("saved");
              },
          ),
          SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: SlydoAppIconNew.hide_post,
              iconSize: 18,
              width: 12,
              title: 'Hide yarn',
              subTitle: 'See fewer posts like this',
              onTap: () {
                addUserVisibilityOption("hidden");
              }
          ),
          SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: Icons.report_gmailerrorred_rounded,
              title: 'Not Interested',
              subTitle: 'Not interested in this yarn',
              onTap: () {
                addUserVisibilityOption("not-interested");
              }
          ),
          SizedBox(
            height: 15,
          ),
          _buildTile(
              icon: Icons.report_gmailerrorred_rounded,
              title: 'Report yarn',
              subTitle: 'I’m concerned about this post',
              onTap: () {
                Navigator.pop(context);
                NavigationUtil.push(context, screen: AddReportScreen(object: widget.yarnTopic!.toJson(), type: "yarn",));
              }
          ),
        ],
      ),
    );
  }

  Widget _buildTile({IconData? icon, double? iconSize, double? width, String? title, String? subTitle, GestureTapCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: iconSize ?? 24,
            ),
            SizedBox(
              width: width ?? 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subTitle!,
                  style: TextStyle(
                    color: HexColor("#75818F"),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool isMyYarnQuestion() {
    return getLoggedInUserName(context) == widget.yarnTopic!.author;
  }
}
