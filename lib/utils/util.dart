import 'package:flutter/material.dart';

export 'colors.dart';

Widget imageFrameBuilder(BuildContext context, Widget child, int frame,
    bool wasSynchronouslyLoaded) {
  if (wasSynchronouslyLoaded) {
    return child;
  }
  return AnimatedOpacity(
    child: child,
    opacity: frame == null ? 0 : 1,
    duration: Duration(seconds: 1),
    curve: Curves.easeOut,
  );
}
