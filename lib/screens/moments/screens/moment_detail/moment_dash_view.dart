//The dashes at the top of the moment's page (similar to Whatsapp's)
import 'dart:async';

import 'package:flutter/material.dart';

class MomentDashView extends StatefulWidget {
  final int currentPageViewIndex;
  final int lengthOfMoment;

  const MomentDashView(
      {Key? key,
      required this.currentPageViewIndex,
      required this.lengthOfMoment})
      : super(key: key);

  @override
  _MomentDashViewState createState() => _MomentDashViewState();
}

class _MomentDashViewState extends State<MomentDashView> {
  Timer? timer;
  double widthFactor = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (widthFactor.toInt() >= 1) {
        timer.cancel();
      }
      widthFactor += 0.1;

      if (mounted) setState(() {});
      debugPrint('WIDTH FACTOR -> ${widthFactor.toInt()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: dashes(widget.lengthOfMoment, widget.currentPageViewIndex),
      ),
    );
  }

  List<Widget> dashes(int lengthOfMoment, int currentIndex) {
    debugPrint('DASHES ---> ');
    List<Widget> widgets = [];
    for (int i = 0; i < lengthOfMoment; i++) {
      Widget widget = Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 0),
              ),
            ],
            color: currentIndex >= i
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      widgets.add(widget);
    }
    return widgets;
  }
}
