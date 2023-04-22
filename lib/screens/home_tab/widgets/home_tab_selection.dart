import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeTabSelection extends StatefulWidget {
  final Function(int) onTap;
  final int currentIndex;

  const HomeTabSelection({required this.onTap, this.currentIndex = 0, Key? key})
      : super(key: key);
  @override
  State<HomeTabSelection> createState() => _HomeTabSelectionState();
}

class _HomeTabSelectionState extends State<HomeTabSelection> {
  @override
  Widget build(BuildContext context) {
    return _buildMain();
  }

  Widget _buildMain() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: buildTabItem(
                onTap: widget.onTap,
                tabIndex: 0,
                title: 'QR Code',
                currentIndex: widget.currentIndex),
          ),
          Expanded(
            child: buildTabItem(
                onTap: widget.onTap,
                tabIndex: 1,
                title: 'Explore',
                currentIndex: widget.currentIndex),
          ),
          Expanded(child: Container()),
          Expanded(child: Container()),
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
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle,
          color: currentIndex == tabIndex ? navyBlue : greyBackground,
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
