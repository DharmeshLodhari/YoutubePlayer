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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: categoryColor,
          border: Border.all(
              color: selectedCategoryBorderColor!),
        ),
        height: 40,
        width: 120,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              title!,
              style: TextStyle(
                  color:
                  selectedCategoryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
