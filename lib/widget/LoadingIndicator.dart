import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            height: 2,
            width: double.infinity,
            margin: EdgeInsets.all(5),
            child: LinearProgressIndicator(
              // strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2.5,
      valueColor: AlwaysStoppedAnimation(navyBlue),
      backgroundColor: Colors.transparent,
    );
  }
}

class CircularLoadingIndicatorWithPercentage extends StatefulWidget {
  double value;
  Color color;

  CircularLoadingIndicatorWithPercentage({this.value, this.color});

  @override
  _CircularLoadingIndicatorWithPercentageState createState() =>
      _CircularLoadingIndicatorWithPercentageState();
}

class _CircularLoadingIndicatorWithPercentageState
    extends State<CircularLoadingIndicatorWithPercentage> {
  Color color;

  @override
  void initState() {
    if (widget.color == null) {
      color = navyBlue;
    } else {
      color = widget.color;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2.5,
      valueColor: AlwaysStoppedAnimation(color),
      backgroundColor: Colors.transparent,
      value: widget.value,
    );
  }
}
