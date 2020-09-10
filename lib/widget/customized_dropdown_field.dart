import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedDropDownField extends StatelessWidget {
  Widget child;
  String title;
  CustomizedDropDownField({@required this.child, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(alignedDropdown: true, child: child),
          ),
        ),
      ],
    );
  }
}
