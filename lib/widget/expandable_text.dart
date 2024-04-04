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
    return Stack(clipBehavior: Clip.none, children: <Widget>[
      AnimatedSize(
        // vsync: this,
        duration: const Duration(milliseconds: 500),
        child: ConstrainedBox(
          constraints: widget.isExpanded
              ? const BoxConstraints()
              // ignore: prefer_const_constructors
              : BoxConstraints(maxHeight: 50.0),
          child: Text(
            widget.text,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
      if (widget.isExpanded)
        ConstrainedBox(constraints: const BoxConstraints())
      else
        Positioned(
          bottom: -10,
          right: 2,
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.all(1),
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
