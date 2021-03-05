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
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new AnimatedSize(
              vsync: this,
              duration: const Duration(milliseconds: 500),
              child: new ConstrainedBox(
                  constraints: widget.isExpanded
                      ? new BoxConstraints()
                      : new BoxConstraints(maxHeight: 50.0),
                  child: new Text(
                    widget.text,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ))),
          widget.isExpanded
              ? new ConstrainedBox(constraints: new BoxConstraints())
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
