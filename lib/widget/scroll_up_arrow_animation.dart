import 'package:flutter/material.dart';

class ScrollArrowIndicator extends StatefulWidget {
  const ScrollArrowIndicator({super.key});

  @override
  _ScrollArrowIndicatorState createState() => _ScrollArrowIndicatorState();
}

class _ScrollArrowIndicatorState extends State<ScrollArrowIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5), // Move the arrow up
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Image.asset(
        'assets/images/home/arrow_up.png',
        height: 150,
        width: 50,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
