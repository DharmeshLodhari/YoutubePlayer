import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class OtherBankTabSelection extends StatefulWidget {
  final Function(int) onTap;
  final int currentIndex;

  const OtherBankTabSelection({
    required this.onTap,
    this.currentIndex = 0,
    super.key,
  });

  @override
  State<OtherBankTabSelection> createState() => _OtherBankTabSelectionState();
}

class _OtherBankTabSelectionState extends State<OtherBankTabSelection> {
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.currentIndex;
  }

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
              title: 'New Beneficiary',
              underlineWidth: 2.0,
            ),
          ),
          Expanded(
            child: buildTabItem(
              onTap: widget.onTap,
              tabIndex: 1,
              title: 'Beneficiary',
              underlineWidth: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem({
    required int tabIndex,
    required String title,
    required Function(int) onTap,
    required double underlineWidth,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedTabIndex = tabIndex;
        });
        onTap(tabIndex);
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              title,
              style: TextStyle(
                color: selectedTabIndex == tabIndex ? navyBlue : yarnBlack,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: underlineWidth,
              width: 120,
              color:
                  selectedTabIndex == tabIndex ? navyBlue : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
