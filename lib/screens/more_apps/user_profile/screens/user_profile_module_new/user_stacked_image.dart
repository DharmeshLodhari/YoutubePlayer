import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/util.dart';

class StackedWidgets extends StatelessWidget {
  final List<Widget> items;
  final TextDirection direction;
  final double size;
  final double xShift;

  const StackedWidgets({
    Key? key,
    required this.items,
    this.direction = TextDirection.ltr,
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
    })
        .values
        .toList();

    return Stack(
      children: direction == TextDirection.ltr
          ? allItems.reversed.toList()
          : allItems,
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
        child: CachedNetworkImage(
          imageUrl: urlImage,
          fit: BoxFit.cover,
          errorWidget: imageErrorWidget,
        ),
      ),
    ),
  );
}
