import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

import '../models/ask_categories_model.dart';
import 'customize_category_button.dart';

class CustomizeCategory extends StatelessWidget {
  AskCategories? askCategory;
  UsersCategories? usersCategory;
  bool? isAdd = false;
  GestureTapCallback? onTap;
  CustomizeCategory({this.askCategory, this.isAdd, this.onTap, this.usersCategory});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity(vertical: -3, horizontal: 0),
      title: Text(
        askCategory!.name!,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: CustomizeCategoryButton(
        askCategory: askCategory,
        usersCategory: usersCategory,
      ),
    );
  }
}
