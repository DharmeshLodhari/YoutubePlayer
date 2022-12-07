import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  CategoryChip({Key? key, this.onTap, this.title, this.categoryColor, this.selectedCategoryTextColor, this.borderColor}) : super(key: key);

  GestureTapCallback? onTap;
  Color? categoryColor;
  String? title;
  Color? selectedCategoryTextColor;
  Color? borderColor;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: categoryColor,
          border: Border.all(color: borderColor ?? Color(0xFF000000)),
        ),
        child: Text(
          title!,
          style: TextStyle(
              color:
              selectedCategoryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
