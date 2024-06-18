import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../models/ask_categories_model.dart';
import '../yarn_auth.dart';

class CustomizeCategoryButton extends StatefulWidget {
  final YarnCategories? askCategory;
  UsersCategories? usersCategory;
  CustomizeCategoryButton({super.key, this.askCategory, this.usersCategory});

  @override
  State<CustomizeCategoryButton> createState() =>
      _CustomizeCategoryButtonState();
}

class _CustomizeCategoryButtonState extends State<CustomizeCategoryButton> {
  bool isAdd = false;
  bool isLoading = false;

  @override
  void initState() {
    userSelectedCategory();
    super.initState();
  }

  void userSelectedCategory() {
    setState(() {
      isAdd = false;
    });
    for (YarnCategories cat in widget.usersCategory!.categories ?? []) {
      if (cat.id == widget.askCategory!.id) {
        setState(() {
          isAdd = true;
        });
        break;
      }
    }
    debugPrint("IS ADD:- $isAdd");
  }

  Future<UsersCategories?> saveUserCategories(String categoryId) async {
    try {
      final Map<String, dynamic>? result =
          await YarnAuth().saveUsersSingleCategories(categoryId);
      if (result != null) {
        setState(() {
          widget.usersCategory = result['results'];
          userSelectedCategory();
          isLoading = false;
        });
        showToast(message: "Saved Successfully");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showToast(message: error.toString());
    }
    return widget.usersCategory!;
  }

  Future<UsersCategories?> deleteUserCategories(String categoryId) async {
    try {
      final Map<String, dynamic>? result =
          await YarnAuth().deleteUsersSingleCategories(categoryId);
      if (result != null) {
        widget.usersCategory = result['results'];
        userSelectedCategory();
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: "Removed Successfully");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showToast(message: error.toString());
    }
    return widget.usersCategory;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        if (isAdd) {
          await deleteUserCategories(widget.askCategory!.id!);
        } else {
          await saveUserCategories(widget.askCategory!.id!);
        }
      },
      child: !isLoading
          ? Container(
              height: 25,
              width: isAdd ? 77 : 58,
              decoration: BoxDecoration(
                  color: isAdd ? Colors.white : HexColor("#3F61DB"),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HexColor("#3F61DB"),
                  )),
              child: Center(
                child: Text(
                  isAdd ? "Remove" : "Add",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAdd ? HexColor("#3F61DB") : Colors.white,
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 25,
              width: 60,
              child: Center(
                  child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(navyBlue),
                  strokeWidth: 2.0,
                ),
              ))),
    );
  }
}
