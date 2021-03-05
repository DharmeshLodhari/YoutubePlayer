import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExpandableText extends StatefulWidget {
  ExpandableText(this.text);

  final String text;
  bool isExpanded = false;

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          AnimatedSize(
            vsync: this,
            duration: const Duration(milliseconds: 500),
            child: ConstrainedBox(
              constraints: widget.isExpanded
                  ? BoxConstraints()
                  : BoxConstraints(maxHeight: 50.0),
              child: Text(
                widget.text,
                softWrap: true,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          widget.isExpanded
              ? ConstrainedBox(constraints: BoxConstraints())
              : Container(
                  color: Colors.transparent,
                  child: GestureDetector(
                      onTap: () => setState(() => widget.isExpanded = true),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: navyBlue,
                      )),
                )
        ]);
  }
}

// Text(
// 'Show more',
// style: TextStyle(
// fontSize: 10.0.sp,
// color: navyBlue,
// fontWeight: FontWeight.w500),
// ),
