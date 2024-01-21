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

class CircularLoadingIndicator extends StatefulWidget {
  Color? color;

  CircularLoadingIndicator({this.color});

  @override
  State<CircularLoadingIndicator> createState() =>
      _CircularLoadingIndicatorState();
}

class _CircularLoadingIndicatorState extends State<CircularLoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    if (widget.color == null) {
      widget.color = navyBlue;
    }

    return CircularProgressIndicator(
      strokeWidth: 2.5,
      valueColor: AlwaysStoppedAnimation(widget.color),
      backgroundColor: Colors.transparent,
    );
  }
}

class CircularLoadingIndicatorWithPercentage extends StatefulWidget {
  final double? value;
  final Color? color;

  CircularLoadingIndicatorWithPercentage({this.value, this.color});

  @override
  _CircularLoadingIndicatorWithPercentageState createState() =>
      _CircularLoadingIndicatorWithPercentageState();
}

class _CircularLoadingIndicatorWithPercentageState
    extends State<CircularLoadingIndicatorWithPercentage> {
  Color? color;

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
