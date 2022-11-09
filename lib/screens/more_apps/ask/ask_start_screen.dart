import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import '../../../widget/curved_btn.dart';
import 'ask_auth.dart';
import 'ask_home_screen.dart';
import 'ask_viewmodel.dart';
import 'models/ask_categories_model.dart';
import 'components/category_chip.dart';

class AskStartScreen extends StatefulWidget {
  @override
  State<AskStartScreen> createState() => _AskStartScreenState();
}

class _AskStartScreenState extends State<AskStartScreen> {

  bool isAskCategoriesLoading = false;
  String? categoriesNext = "";
  String? categoriesPrevious = "";
  bool noCategoriesList = false;
  int? categoryCount = 0;
  List<AskCategories> askCategoriesList = [];
  List<AskCategories> selectedAskCategoriesList = [];
  final GlobalKey<ScaffoldMessengerState> _askCategoriesScaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();


  @override
  void initState() {
    Future.microtask(() => context.read<AskViewModel>().init());
    getAskCategoriesList();
    super.initState();
  }

  void getAskCategoriesList() async {
    if (!isAskCategoriesLoading) {
      if (categoriesNext != null && !isAskCategoriesLoading) {
        isAskCategoriesLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllCategories(categoriesNext, categoriesPrevious!, otherDeals: true);

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
            askCategoriesList.addAll(tempList);
          });
        }
      }
      if (askCategoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
          });
        }
      } else if (categoriesNext == null && askCategoriesList.length > 6) {
        _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
          Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AskViewModel>(builder: (context, model, child) {
      return ScaffoldMessenger(
        key: _askCategoriesScaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
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
          body: ListView(
            padding: EdgeInsets.only(left: 26, right: 26, bottom: 20),
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                'What topic are you interested in?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Select 3 or more categories to continue. We’ll use this to recommend topics you may like.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 65,
              ),
              !isAskCategoriesLoading ? Wrap(
                runSpacing: 30,
                spacing: 15,
                children: askCategoriesList
                    .map(
                      (e) => CategoryChip(
                        onTap: () {
                          onCategorySelected(e);
                        },
                        title: e.name!,
                        selectedCategoryBorderColor: selectedAskCategoriesList.contains(e) ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.1),
                        categoryColor: Color(0xFFF07097).withOpacity(0.1),
                        selectedCategoryTextColor: selectedAskCategoriesList.contains(e)
                            ? navyBlue
                            : blackFont.withOpacity(0.9),
                      )).toList(),
              ) : Center(child: CircularProgressIndicator(),),
              SizedBox(
                height: 85,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 60),
                    child: CurvedButton(
                      height: 50,
                      textColor: Colors.white,
                      backgroundColor: navyBlue,
                      text:
                          "${selectedAskCategoriesList.length} out of 3 selected",
                      onPressed: () async {
                        NavigationUtil.push(
                          context,
                          screen: AskHomeScreen(askCategories: askCategoriesList),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  void onCategorySelected(AskCategories category) {
    if (selectedAskCategoriesList.contains(category)) {
      selectedAskCategoriesList.remove(category);
      setState(() {});
    } else {
      if (selectedAskCategoriesList.length < 3) {
        selectedAskCategoriesList.add(category);
        setState(() {});
      }
    }
  }
}
