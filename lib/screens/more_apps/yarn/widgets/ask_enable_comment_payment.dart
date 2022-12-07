import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/colors.dart';

class AskEnableCommentAndPayment extends StatefulWidget {

  final String? title, image;
  final Widget? icon;
  final Color? baseColor;
  final Color? highLightColor;
  final Function(bool?) onTap;

  AskEnableCommentAndPayment({Key? key, this.title, this.image, this.icon, this.baseColor, this.highLightColor, required this.onTap}) : super(key: key);

  @override
  State<AskEnableCommentAndPayment> createState() => _AskEnableCommentAndPaymentState();
}

class _AskEnableCommentAndPaymentState extends State<AskEnableCommentAndPayment> {

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
            color: isSelected ? widget.highLightColor : widget.baseColor,
            border: Border.all(color: isSelected ? widget.highLightColor ?? Color(0xFFFFFFFF) : widget.baseColor ?? Color(0xFFFFFFFF)),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            Text(
              widget.title ?? '',
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? widget.highLightColor : widget.baseColor
              ),
            ),
            SizedBox(width: 4,),
            SvgPicture.asset(
              "${widget.image}".toSVG(),
              height: 20,
              width: 20,
              color: isSelected ? widget.highLightColor : widget.baseColor,
            ),
            SizedBox(width: 4,),
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? widget.highLightColor ?? Color(0xFFFFFFFF) : widget.baseColor ?? Color(0xFFFFFFFF), width: isSelected ? 2 : 1),
                color: isSelected ? widget.highLightColor : HexColor("#FFFFFF"),
              ),
              child: isSelected ? Icon(Icons.check_outlined, color: widget.highLightColor,size: 8,) : null,
            ),
          ],
        ),
      ),
    );
  }
}
