import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class CategoryChip extends StatelessWidget {
  CategoryChip({
    Key? key,
    this.onTap,
    this.title,
    this.categoryColor,
    this.selectedCategoryTextColor,
    this.borderColor,
    this.isIconShow = false
  }) : super(key: key);

  final GestureTapCallback? onTap;
  final Color? categoryColor;
  final String? title;
  final Color? selectedCategoryTextColor;
  final Color? borderColor;
  final bool? isIconShow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: categoryColor,
              border:
              Border.all(color: borderColor ?? Color(0xFFFFFFFF), width: 0.5),
            ),
            child: Text(
              title ?? "",
              style: TextStyle(
                  color: selectedCategoryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if(isIconShow ?? false)...[
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    color: HexColor("#3F61DB"),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: HexColor("#FFFFFF"),
                        width: 2
                    )
                ),
                child: Center(
                  child: Icon(
                    Icons.check_outlined,
                    size: 10,
                    color: HexColor("#FFFFFF"),
                  ),
                ),
              ),
            ),
          ]
        ],
      )
    );
  }
}
