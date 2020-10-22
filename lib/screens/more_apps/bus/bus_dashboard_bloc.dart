import 'package:flutter/material.dart';

/// BUS

class BusDashboardBloc extends ChangeNotifier {
  static int _index = 0;
  PageController _pageController = PageController(initialPage: _index);

  int get index => _index;

  PageController get pageController => _pageController;

  set index(int value) {
    _index = value;
    _pageController.animateToPage(_index,
        duration: Duration(milliseconds: 300), curve: Curves.linear);
    notifyListeners();
  }
}
