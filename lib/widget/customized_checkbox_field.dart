import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedCheckBoxField extends StatefulWidget {
  String title;
  Function onTap;
  bool isChecked;

  CustomizedCheckBoxField(
      {@required this.title, @required this.onTap, @required this.isChecked});

  @override
  _CustomizedCheckBoxFieldState createState() =>
      _CustomizedCheckBoxFieldState();
}

class _CustomizedCheckBoxFieldState extends State<CustomizedCheckBoxField> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: new BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: new BorderRadius.circular(5),
                ),
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.transparent,
                  ),
                  child: Checkbox(
                    value: widget.isChecked,
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onChanged: (val) {
                      widget.onTap();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            widget.title,
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
      onTap: widget.onTap,
    );
  }
}
