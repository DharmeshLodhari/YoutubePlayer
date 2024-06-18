import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedCheckBoxField extends StatefulWidget {
  String title;
  Function onTap;
  bool? isChecked;
  double? fontSize;
  int? maxLines;

  CustomizedCheckBoxField(
      {super.key,
      required this.title,
      required this.onTap,
      required this.isChecked,
      this.fontSize,
      this.maxLines})
     ;

  @override
  State<CustomizedCheckBoxField> createState() =>
      _CustomizedCheckBoxFieldState();
}

class _CustomizedCheckBoxFieldState extends State<CustomizedCheckBoxField> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap as void Function()?,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
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
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                  color: blackFont,
                  fontSize: widget.fontSize ?? 14.0,
                  fontWeight: FontWeight.w600),
              maxLines: widget.maxLines ?? 1,
              softWrap: widget.maxLines == 2 ? true : false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
