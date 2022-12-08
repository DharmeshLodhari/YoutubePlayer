import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/colors.dart';

class AskEnableCommentAndPayment extends StatefulWidget {
  final String? title, image;
  final Widget? icon;
  // Text Color
  final Color? baseTextColor, highLightTextColor;
  // Border Color
  final Color? baseBorderColor, highLightBorderColor;
  // BackGround Color
  final Color? baseBGColor, highLightBGColor;
  final Function(bool?) onTap;

  AskEnableCommentAndPayment(
      {Key? key,
      this.title,
      this.image,
      this.icon,
      this.baseTextColor,
      this.highLightTextColor,
      this.baseBorderColor,
      this.highLightBorderColor,
      this.baseBGColor,
      this.highLightBGColor,
      required this.onTap})
      : super(key: key);

  @override
  State<AskEnableCommentAndPayment> createState() =>
      _AskEnableCommentAndPaymentState();
}

class _AskEnableCommentAndPaymentState
    extends State<AskEnableCommentAndPayment> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isSelected) {
          isSelected = false;
        } else {
          isSelected = true;
        }
        widget.onTap(isSelected);
        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: isSelected ? widget.highLightBGColor : widget.baseBGColor,
            border: Border.all(
                color: isSelected
                    ? widget.highLightBorderColor ?? Color(0xFFFFFFFF)
                    : widget.baseBorderColor ?? Color(0xFFFFFFFF)),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Text(
              widget.title ?? '',
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? widget.highLightTextColor
                      : widget.baseTextColor),
            ),
            SizedBox(
              width: 4,
            ),
            SvgPicture.asset(
              "${widget.image}".toSVG(),
              height: 20,
              width: 20,
              color:
                  isSelected ? widget.highLightTextColor : widget.baseTextColor,
            ),
            SizedBox(
              width: 4,
            ),
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected
                        ? widget.highLightTextColor ?? Color(0xFFFFFFFF)
                        : widget.baseTextColor ?? Color(0xFFFFFFFF),
                    width: isSelected ? 2 : 1),
                color:
                    isSelected ? widget.highLightBGColor : HexColor("#FFFFFF"),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_outlined,
                      color: widget.highLightTextColor,
                      size: 8,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
