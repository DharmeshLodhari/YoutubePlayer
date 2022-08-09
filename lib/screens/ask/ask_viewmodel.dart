import 'package:flutter/cupertino.dart';

class AskViewModel extends ChangeNotifier {

  List<String> categoryList = ['Health',
    'Politics', 'Technology',
    'Fashion', 'Education',
    'Sport', 'Travels',
    'Food', 'Finance',
    'Art & Culture', 'Relationship',
    'Religion'];

  List<String> selectedCategoryList = [];

  void initialiseVM(){

  }

  void onSelectCategory() {

  }

}