import 'package:flutter/material.dart';

class CustomPagination extends StatelessWidget {
  const CustomPagination(
      {required this.child, required this.onScrollEnd, Key? key})
      : super(key: key);
  final Widget child;
  final Function() onScrollEnd;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrices = notification.metrics;
        if (metrices.pixels == metrices.maxScrollExtent) {
          onScrollEnd();
        }
        return true;
      },
      child: child,
    );
  }
}
