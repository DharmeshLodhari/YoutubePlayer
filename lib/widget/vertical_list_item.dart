import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
