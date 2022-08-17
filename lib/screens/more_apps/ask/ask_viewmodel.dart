import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class AskViewModel extends ChangeNotifier {

  int? currentAskTapOnHome = 0;
  String? categoryToAskOn = '';
  String? newlySelectedCategory = '';

  void init(){
    currentAskTapOnHome = 0;
    selectedCategoryList = [];

    categoryList.forEach((element) {
      categoryColors.add(Color((math.Random().nextDouble() * 0xFFFFFF).toInt()));
    });

    notifyListeners();
  }

  List<String> categoryList = ['Health',
    'Politics', 'Technology',
    'Fashion', 'Education',
    'Sport', 'Travels',
    'Food', 'Finance',
    'Art & Culture', 'Relationship',
    'Religion'];

  List<Color> categoryColors = [];

  List<String> selectedCategoryList = [

  ];

  void updateCategoryToAskOn({String? c}){
    categoryToAskOn = c;
    notifyListeners();
  }

  void onSelectCategory({String? c}) {
    if(selectedCategoryList.contains(c)) {
      selectedCategoryList.remove(c);
      notifyListeners();
    } else {
      if(selectedCategoryList.length < 3) {
        selectedCategoryList.add(c!);
        notifyListeners();
      }
    }
  }

  void updateNewlySelected(String v){
    newlySelectedCategory = v;
    notifyListeners();
  }

  void updateCurrentAskTapOnHome({int? i}){
    currentAskTapOnHome = i;
    notifyListeners();
  }

}