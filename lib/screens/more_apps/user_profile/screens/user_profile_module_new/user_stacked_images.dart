import 'package:flutter/material.dart';

class StackedWidgets extends StatelessWidget {
  final List<Widget> items;
  final double size;
  final double xShift;

  const StackedWidgets({
    Key? key,
    required this.items,
    this.size = 100,
    this.xShift = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allItems = items
        .asMap()
        .map((index, item) {
      final left = size - xShift;

      final value = Container(
        width: size,
        height: size,
        child: item,
        margin: EdgeInsets.only(left: left * index),
      );

      return MapEntry(index, value);
    }).values.toList();

    return Stack(
      children: allItems,
    );
  }
}


Widget buildImage(String urlImage) {
  final double borderSize = 2;

  return ClipOval(
    child: Container(
      padding: EdgeInsets.all(borderSize),
      color: Colors.white,
      child: ClipOval(
        child: Image.network(
          urlImage,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}