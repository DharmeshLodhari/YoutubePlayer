import 'package:flutter/material.dart';

import '../../../utils/util.dart';
import 'models/ask_categories_model.dart';
import 'widgets/customize_category.dart';
import 'yarn_auth.dart';

class AskSCustomizeScreen extends StatefulWidget {
  @override
  State<AskSCustomizeScreen> createState() => _AskSCustomizeScreenState();
}

class _AskSCustomizeScreenState extends State<AskSCustomizeScreen> {
  bool isAskCategoriesLoading = false;
  String? categoriesNext = "";
  String? categoriesPrevious = "";
  bool noCategoriesList = false;
  int? categoryCount = 0;
  List<AskCategories> askCategories = [];
  UsersCategories? usersCategory;
  bool isCategoryLoading = false;

  @override
  void initState() {
    getAskCategoriesList();
    getUserCategories();
    super.initState();
  }

  Future<UsersCategories?> getUserCategories() async {
    Map<String, dynamic>? result = await YarnAuth().getUsersCategories();
    setState(() {
      usersCategory = result!['results'];
    });
    return usersCategory!;
  }

  void getAskCategoriesList() async {
    if (!isAskCategoriesLoading) {
      if (categoriesNext != null && !isAskCategoriesLoading) {
        isAskCategoriesLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await YarnAuth()
            .getAllCategories(categoriesNext, categoriesPrevious!);

        if (result == null) {
          noCategoriesList = true;

          isAskCategoriesLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        categoryCount = result['count'];
        categoriesNext = result['next'];
        categoriesPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noCategoriesList = false;
            isAskCategoriesLoading = false;
            askCategories.addAll(tempList);
          });
        }
      }
      if (askCategories.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Customize your interest',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: blackFont,
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
            size: 26,
          ),
        ));
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: usersCategory != null
          ? _buildCategoryList()
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(navyBlue),
              ),
            ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      color: white,
      child: Column(
        children: askCategories.map((category) {
          return CustomizeCategory(
            askCategory: category,
            usersCategory: usersCategory,
          );
        }).toList(),
      ),
    );
  }
}
