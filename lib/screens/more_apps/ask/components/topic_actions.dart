import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class TopicActions extends StatelessWidget {
  String? totalReply;
  String? totalDislikes;
  String? totalLikes;

  TopicActions({this.totalReply, this.totalDislikes, this.totalLikes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset("ask/reply".toSVG()),
            SizedBox(
              width: 8,
            ),
            Text(
              totalReply!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/like".toSVG()),
            SizedBox(
              width: 8,
            ),
            Text(
              totalLikes!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/dislike".toSVG()),
            SizedBox(
              width: 8,
            ),
            Text(
              totalDislikes!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset("ask/share".toSVG()),
          ],
        ),
      ],
    );
  }
}
