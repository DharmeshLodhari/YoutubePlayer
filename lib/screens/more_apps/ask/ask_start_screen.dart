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
            _buildTitleAndDescription(
                title: 'What topic are you interested in?',
                fontSize: 18,
                fontWeight: FontWeight.w700
            ),
            SizedBox(
              height: 15,
            ),
            _buildTitleAndDescription(
                title: 'Select 3 or more categories to continue. We’ll use this to recommend topics you may like.',
                fontSize: 14,
                fontWeight: FontWeight.w400
            ),
            SizedBox(
              height: 30,
            ),
            _buildCategoryList(),
            SizedBox(
              height: 65,
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription({String? title, double? fontSize, FontWeight? fontWeight}) {
    return Text(
      title!,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildCategoryList() {
    if (!isAskCategoriesLoading) {
      return Wrap(
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
              categoryColor: askCategoriesList.indexOf(e) <= categoryColors.length-1 ? categoryColors[askCategoriesList.indexOf(e)].withOpacity(0.1) : categoryColors[0].withOpacity(0.1),
              selectedCategoryTextColor: askCategoriesList.indexOf(e) <= categoryColors.length-1 ? categoryColors[askCategoriesList.indexOf(e)] : categoryColors[0],
            )).toList(),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildSaveButton() {
    return Row(
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
                screen: AskHomeScreen(askCategories: askCategoriesList, selectedCategories: selectedAskCategoriesList,),
              );
            },
          ),
        ),
      ],
    );
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
