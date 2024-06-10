//The dashes at the top of the moment's page (similar to Whatsapp's)
import 'dart:async';

import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class MomentDashView extends StatefulWidget {
  final int currentPageViewIndex;
  final int lengthOfMoment;
  final AnimationController controller;
  final PageController pageController;
  final double value;

  const MomentDashView(
      {Key? key,
      required this.currentPageViewIndex,
      required this.lengthOfMoment,
      required this.controller,
      required this.value,
      required this.pageController})
      : super(key: key);

  @override
  State<MomentDashView> createState() => _MomentDashViewState();
}

class _MomentDashViewState extends State<MomentDashView>
    with TickerProviderStateMixin {
  late AnimationController controller;
  Timer? timer;
  double widthFactor = 0;
  late PageController _pageController;

  @override
  void initState() {
    _pageController = widget.pageController;
    controller = widget.controller;

    controller.addListener(controllerListener);

    super.initState();
  }

  void controllerListener() {
    if (controller.isCompleted) {
      if (widget.currentPageViewIndex == widget.lengthOfMoment - 1) {
        if (mounted) Navigator.pop(context);
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 50), curve: Curves.easeIn);
        controller.reset();
      }
    }
  }

  @override
  void dispose() {
    controller.addListener(controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: dashes(widget.lengthOfMoment, widget.currentPageViewIndex),
      ),
    );
  }

  ///Colors.blue[900]

  List<Widget> dashes(int lengthOfMoment, int currentIndex) {
    // debugPrint('DASHES ---> ');
    final List<Widget> widgets = [];
    for (int i = 0; i < lengthOfMoment; i++) {
      final Widget widget = Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: LinearProgressIndicator(
            value: currentIndex >= i ? controller.value : controller.lowerBound,
            semanticsLabel: 'Linear progress indicator',
            backgroundColor: currentIndex > i ? navyBlue : white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
          ),
        ),
      );
      widgets.add(widget);
    }

    return widgets;
  }
}
