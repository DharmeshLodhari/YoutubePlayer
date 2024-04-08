//The dashes at the top of the moment's page (similar to Whatsapp's)
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class MomentDashView extends StatefulWidget {
  final int currentPageViewIndex;
  final int lengthOfMoment;
  final AnimationController controller;
  final PageController pageController;
  final double value;

  MomentDashView(
      {Key? key,
      required this.currentPageViewIndex,
      required this.lengthOfMoment,
      required this.controller,
      required this.value,
      required this.pageController})
      : super(key: key);

  @override
  _MomentDashViewState createState() => _MomentDashViewState();
}

class _MomentDashViewState extends State<MomentDashView>
    with TickerProviderStateMixin {
  late AnimationController controller;
  Timer? timer;
  double widthFactor = 0;
  PageController? _pageController;
  double? v;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    _pageController = widget.pageController;
    v = widget.value;
    if (widget.value == 1.0) {
      controller = widget.controller;
    } else {
      controller.lowerBound;
    }

    super.initState();
  }

  // @override
  // void dispose() {
  //   widget.videoPlayerControllers![0].dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    v = widget.value;

    if (widget.value == 1.0) {
      controller = widget.controller;
    }
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

      if (controller.value == 1.0) {
        _pageController?.nextPage(
            duration: const Duration(milliseconds: 50), curve: Curves.easeIn);
        controller.reset();
        if (currentIndex == lengthOfMoment) {
          break;
        }
      }
    }

    return widgets;
  }
}
