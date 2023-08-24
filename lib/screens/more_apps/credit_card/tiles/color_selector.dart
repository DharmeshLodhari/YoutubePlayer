import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<Color> colors;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ColorSelector({Key? key,
    required this.colors,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.asMap().entries.map((entry) {
        final index = entry.key;
        final color = entry.value;

        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            width: 20,
            height: 20,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: currentIndex == index ? Colors.transparent : Colors.white,
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
