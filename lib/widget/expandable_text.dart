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
    return Stack(overflow: Overflow.visible, children: <Widget>[
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
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      widget.isExpanded
          ? ConstrainedBox(constraints: BoxConstraints())
          : Positioned(
              bottom: -10,
              right: 2,
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(50)),
                  padding: EdgeInsets.all(1),
                  child: GestureDetector(
                      onTap: () => setState(() => widget.isExpanded = true),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: navyBlue,
                      )),
                ),
              ),
            )
    ]);
  }
}
