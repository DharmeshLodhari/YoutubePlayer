import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../models/ask_categories_model.dart';
import 'customize_category_button.dart';

class CustomizeCategory extends StatelessWidget {
  YarnCategories? askCategory;
  UsersCategories? usersCategory;
  bool? isAdd = false;
  GestureTapCallback? onTap;
  CustomizeCategory(
      {super.key,
      this.askCategory,
      this.isAdd,
      this.onTap,
      this.usersCategory});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: 0, horizontal: 0),
          title: Text(
            askCategory!.name!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: CustomizeCategoryButton(
            askCategory: askCategory,
            usersCategory: usersCategory,
          ),
        ),
      ),
    );
  }
}
