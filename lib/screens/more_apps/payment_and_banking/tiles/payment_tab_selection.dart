import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class PaymentTabSelection extends StatefulWidget {
  final Function(int) onTap;
  final int currentIndex;
  String? tabOne;
  String? tabTwo;

  PaymentTabSelection(
      {required this.onTap,
      this.currentIndex = 0,
      this.tabOne,
      this.tabTwo,
      Key? key})
      : super(key: key);

  @override
  State<PaymentTabSelection> createState() => _PaymentTabSelectionState();
}

class _PaymentTabSelectionState extends State<PaymentTabSelection> {
  @override
  Widget build(BuildContext context) {
    return _buildMain();
  }

  Widget _buildMain() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
          color: greyBackground, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: buildTabItem(
                onTap: widget.onTap,
                tabIndex: 0,
                title: widget.tabOne!,
                currentIndex: widget.currentIndex),
          ),
          Expanded(
            child: buildTabItem(
                onTap: widget.onTap,
                tabIndex: 1,
                title: widget.tabTwo!,
                currentIndex: widget.currentIndex),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem({
    required int tabIndex,
    required String title,
    required Function(int) onTap,
    int? currentIndex,
  }) {
    return InkWell(
      onTap: () => onTap(tabIndex),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          shape: BoxShape.rectangle,
          color: currentIndex == tabIndex ? navyBlue : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: currentIndex == tabIndex ? white : yarnBlack,
              fontSize: 14,
              fontWeight:
                  currentIndex == tabIndex ? FontWeight.w700 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
