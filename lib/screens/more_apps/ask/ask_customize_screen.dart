import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/colors.dart';
import 'ask_auth.dart';
import 'ask_viewmodel.dart';
import 'components/customize_category.dart';
import 'models/ask_categories_model.dart';

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

  @override
  void initState() {
    getAskCategoriesList();
    getUserCategories();
    super.initState();
  }

  Future<UsersCategories?> getUserCategories() async {
    Map<String, dynamic>? result = await AskAuth().getUsersCategories();
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

        Map<String, dynamic>? result = await AskAuth()
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
          noCategoriesList = false;
          isAskCategoriesLoading = false;
          context.read<AskViewModel>().setAskCategories(tempList);
          askCategories.addAll(tempList);
        }
      }
      if (Provider.of<AskViewModel>(context, listen: false).askCategories.isEmpty) {
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
    return Consumer<AskViewModel>(builder: (context, model, child) {
      return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Categories',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: blackFont,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
              size: 26,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ...List.generate(
                  model.askCategories.length,
                  (i) {
                    return Column(
                      children: [
                        CustomizeCategory(
                          askCategory: model.askCategories[i],
                          isAdd: isAddCategory(),
                          onTap: () {},
                        ),
                        Divider(
                          color: HexColor("#EBEDFC"),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  bool? isAddCategory() {
    bool isAdded = false;
    print("USER CATEGORY:- $usersCategory");
    for (var cate in askCategories) {
      if (usersCategory != null) {
        if (usersCategory!.categories!.contains(cate)) {
          isAdded = true;
        }
        isAdded = false;
      }
      isAdded = false;
    }
    return isAdded;
  }

  Widget buildCategoryList(
      {String? e, Function? onAddCategory, AskViewModel? model}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: blackFont,
            ),
          ),
          Expanded(
              child: SizedBox(
            width: 10,
          )),
          Container(
            decoration: BoxDecoration(
              color: blackFont.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                model!.selectedCategoryList.contains(e) ? 'Remove' : 'Add',
                style: TextStyle(
                  color: blackFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60,
          )
        ],
      ),
    );
  }
}
