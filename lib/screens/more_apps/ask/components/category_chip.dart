import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  CategoryChip({Key? key, this.onTap, this.title, this.categoryColor, this.selectedCategoryBorderColor, this.selectedCategoryTextColor}) : super(key: key);

  GestureTapCallback? onTap;
  Color? selectedCategoryBorderColor;
  Color? categoryColor;
  String? title;
  Color? selectedCategoryTextColor;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: categoryColor,
          border: Border.all(
              color: selectedCategoryBorderColor!),
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
