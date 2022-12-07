import 'dart:math';

import 'package:Slydo/screens/more_apps/yarn/models/ask_categories_model.dart';
import 'package:flutter/cupertino.dart';

class YarnDashboardBloc extends ChangeNotifier {
  int? currentTabIndex = 0;
  String? categoryToAskOn = '';
  String? newlySelectedCategory = '';
  List<AskCategories> _yarnCategories = [];
  List<AskCategories> get askCategories => _yarnCategories;
  List<String> _selectedAskCategories = [];
  List<String> get selectedAskCategories => _selectedAskCategories;
  int get random => Random().nextInt(categoryColors.length - 1);

  set askCategories(List<AskCategories> cat) {
    _yarnCategories = cat;
    notifyListeners();
  }

  void setAskCategories(List<AskCategories> cat) {
    _yarnCategories = cat;
    notifyListeners();
  }

  void onSelectedAskCategories(String c) {
    print("SELECTED CATEGORIES:- $c");
    if (_selectedAskCategories.contains(c)) {
      _selectedAskCategories.remove(c);
      notifyListeners();
    } else {
      _selectedAskCategories.add(c);
      notifyListeners();
    }
  }

  List<String> categoryList = [
    'Health',
    'Politics',
    'Technology',
    'Fashion',
    'Education',
    'Sport',
    'Travels',
    'Movies',
    'Food',
    'Finance',
    'Art & Culture',
    'Relationship',
    'Religion'
  ];

  List<Color> categoryColors = [
    Color(0xFFF07097),
    Color(0xFF030F36),
    Color(0xFF8829C1),
    Color(0xFF8B008B),
    Color(0xFF3F61DB),
    Color(0xFFB22727),
    Color(0xFFFFCC00),
    Color(0xFF8B008B),
    Color(0xFFFFA500),
    Color(0xFF46CE7C),
    Color(0xFF964B00),
    Color(0xFFF35B46),
    Color(0xFF243A73),
  ];

  List<String> selectedCategoryList = [];

  List<String> userTags = [];

  void init() {
    currentTabIndex = 0;
    _selectedAskCategories = [];
    userTags = [];
    notifyListeners();
  }

  void updateCategoryToAskOn({String? c}) {
    categoryToAskOn = c;
    notifyListeners();
  }

  void onSelectCategory({String? c}) {
    if (selectedCategoryList.contains(c)) {
      selectedCategoryList.remove(c);
      notifyListeners();
    } else {
      if (selectedCategoryList.length < 3) {
        selectedCategoryList.add(c!);
        notifyListeners();
      }
    }
  }

  void updateNewlySelected(String v) {
    newlySelectedCategory = v;
    notifyListeners();
  }

  void updateCurrentAskTapOnHome({int? i}) {
    currentTabIndex = i;
    notifyListeners();
  }

  void joinACategory() {}

  void setInTag() {}
}
