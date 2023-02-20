import 'dart:math';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/models/ask_categories_model.dart';
import 'package:flutter/cupertino.dart';

class YarnDashboardBloc extends ChangeNotifier {
  int? currentTabIndex = 0;
  String? categoryToAskOn = '';
  String? newlySelectedCategory = '';
  List<YarnCategories> _yarnCategories = [];
  List<YarnCategories> get yarnCategories => _yarnCategories;
  List<String> _selectedAskCategories = [];
  List<String> get selectedAskCategories => _selectedAskCategories;
  int get random => Random().nextInt(categoryColors.length - 1);
  UserYarnSettings get yarnSettings => _yarnSettings;
  UserYarnSettings _yarnSettings = UserYarnSettings();

  bool get adultContent => yarnSettings.allowAdultContent;
  bool get sensitiveContent => yarnSettings.allowSensitiveContent;
  bool get pushNotification => yarnSettings.allowNotification;

  var productService;
  List<Yarn> get createYarnTopicList => _createYarnTopicList;
  List<Yarn> get deleteYarnTopicList => _deleteYarnTopicList;
  List<Yarn> get reYarnTopicList => _reYarnTopicList;

  List<Yarn> _createYarnTopicList = [];
  List<Yarn> _deleteYarnTopicList = [];
  List<Yarn> _reYarnTopicList = [];

  void addCreateYarnTopicList(List<Yarn> yarn) {
    _createYarnTopicList.addAll(yarn);
    notifyListeners();
  }

  void addDeleteYarnTopicList(List<Yarn> yarn) {
    _deleteYarnTopicList.addAll(yarn);
    notifyListeners();
  }

  void addReYarnTopicList(List<Yarn> yarn) {
    _reYarnTopicList.addAll(yarn);
    notifyListeners();
  }

  void updateReYarnTopicList(List<Yarn> yarn) {
    _reYarnTopicList = [];
    _reYarnTopicList.addAll(yarn);

    notifyListeners();
  }

  void updateCreateYarnTopicList(List<Yarn> yarn) {
    _createYarnTopicList = [];
    _createYarnTopicList.addAll(yarn);

    notifyListeners();
  }

  set yarnCategories(List<YarnCategories> cat) {
    _yarnCategories = cat;
    notifyListeners();
  }

  void setAskCategories(List<YarnCategories> cat) {
    _yarnCategories = cat;
    notifyListeners();
  }

  void addCategories(List<YarnCategories> cat) {
    _yarnCategories.addAll(cat);
    notifyListeners();
  }

  set yarnSettings(UserYarnSettings userYarnSettings) {
    _yarnSettings = userYarnSettings;
    notifyListeners();
  }

  set adultContent(bool value) {
    yarnSettings.allowAdultContent = value;
    notifyListeners();
  }

  set sensitiveContent(bool value) {
    yarnSettings.allowSensitiveContent = value;
    notifyListeners();
  }

  set pushNotification(bool value) {
    yarnSettings.allowNotification = value;
    notifyListeners();
  }

  void onSelectedAskCategories(String c) {
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
}
