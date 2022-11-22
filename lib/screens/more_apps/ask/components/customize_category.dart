import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

import '../models/ask_categories_model.dart';

class CustomizeCategory extends StatelessWidget {

  AskCategories? askCategory;
  bool? isAdd = false;
  GestureTapCallback? onTap;

  CustomizeCategory({Key? key, this.askCategory, this.isAdd, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("IS ADDED CATEGORY- $isAdd");
    return ListTile(
      visualDensity: VisualDensity(vertical: -3, horizontal: 0),
      title: Text(
        askCategory!.name!,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: InkWell(
        onTap: onTap,
        child: Container(
          height: 25,
          width: 60,
          decoration: BoxDecoration(
            color: isAdd! ? Colors.white : HexColor("#3F61DB"),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HexColor("#3F61DB"),)
          ),
          child: Center(
            child: Text(
              isAdd! ? "Remove" : "Add",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAdd! ? HexColor("#3F61DB") : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
