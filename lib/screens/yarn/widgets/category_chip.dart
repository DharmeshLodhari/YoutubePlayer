import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class CategoryChip extends StatefulWidget {
  const CategoryChip({
    super.key,
    this.onTap,
    this.title,
    this.categoryColor,
    this.selectedCategoryTextColor,
    this.borderColor,
    this.isIconShow = false,
    this.selected = false,
  });

  final GestureTapCallback? onTap;
  final Color? categoryColor;
  final String? title;
  final Color? selectedCategoryTextColor;
  final Color? borderColor;
  final bool? isIconShow;
  final bool selected;

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  Color? chipColor;
  String? chipTitle;

  @override
  void initState() {
    super.initState();
    chipColor = widget.categoryColor;
    chipTitle = widget.title;
  }

  @override
  void didUpdateWidget(CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      setState(() {
        // Change the color when selected
        chipColor = widget.selected ? darkGreyYarn : widget.categoryColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: chipColor,
              border: Border.all(
                color: widget.borderColor ?? const Color(0xFFFFFFFF),
                width: 0.5,
              ),
            ),
            child: Text(
              chipTitle ?? "",
              style: TextStyle(
                color: widget.selectedCategoryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.isIconShow ?? false) ...[
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  color: HexColor("#3F61DB"),
                  shape: BoxShape.circle,
                  border: Border.all(color: HexColor("#FFFFFF"), width: 2),
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
          ],
        ],
      ),
    );
  }
}
