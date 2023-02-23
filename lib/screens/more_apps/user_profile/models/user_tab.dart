import 'package:flutter/material.dart';

class UserTab {
  String? label;
  Widget? child;
  Future<List<dynamic>> Function()? apiCall;

  UserTab({this.label, this.child, this.apiCall});
}

class UserTabView {
  String? name;
  List<UserTab> tabs;

  UserTabView({this.name, required this.tabs});
}
