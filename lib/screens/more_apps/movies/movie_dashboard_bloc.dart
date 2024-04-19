import 'package:flutter/material.dart';

/// MOVIE

class MovieDashboardBloc extends ChangeNotifier {
  static int _index = 0;
  final PageController _pageController = PageController(initialPage: _index);

  int get index => _index;

  PageController get pageController => _pageController;

  set index(int value) {
    _index = value;
    _pageController.animateToPage(_index,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
    notifyListeners();
  }
}
