import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class VerticalListItem extends StatelessWidget {
  const VerticalListItem(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final slidableController = Slidable.of(context);
        if (slidableController != null) {
          if (slidableController.actionPaneType == ActionPaneType.none) {
            slidableController.openEndActionPane();
          } else {
            slidableController.close();
          }
        }
        // Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
        //     ? Slidable.of(context)?.open()
        //     : Slidable.of(context)?.close(),
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
