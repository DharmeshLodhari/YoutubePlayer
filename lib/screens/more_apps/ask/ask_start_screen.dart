import 'dart:convert';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../data/state_notifier.dart';
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
  // List<AskCategories> askCategoriesList = [];
  // List<AskCategories> selectedAskCategoriesList = [];
  final GlobalKey<ScaffoldMessengerState> _askCategoriesScaffoldMessengerKey = new GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;
  DatabaseHelper _db = DatabaseHelper();

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
          //askCategoriesList.addAll(tempList);
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

  Future<void> saveUsersCategories(String body) async {
    Map<String, dynamic>? result = await AskAuth().saveUsersCategories(body);
    UsersCategories usersCategories = result!['results'] as UsersCategories;
    UserCategoriesStructure userCategoriesStructure = UserCategoriesStructure(userId: userBloc.user.uuid, userSelectedCategory: jsonEncode(usersCategories.categories));
    _db.saveUserSelectedYarnCategories(userCategoriesStructure);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Consumer<AskViewModel>(
      builder: (context, model, child) {
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
                _buildCategoryList(model),
                SizedBox(
                  height: 65,
                ),
                _buildSaveButton(model),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTitleAndDescription({String? title, double? fontSize, FontWeight? fontWeight}) {
    return Text(
      title!,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildCategoryList(AskViewModel model) {
    if (!isAskCategoriesLoading) {
      return Wrap(
        runSpacing: 30,
        spacing: 15,
        children: model.askCategories
            .map(
                (e) {
                  // int random = Random().nextInt(model.categoryColors.length-1);
                  return CategoryChip(
                    onTap: () {
                      model.onSelectedAskCategories(e.id!);
                    },
                    title: e.name!,
                    selectedCategoryBorderColor: model.selectedAskCategories.contains(e.id) ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.1),
                    categoryColor: HexColor(e.color!).withOpacity(0.1),
                    selectedCategoryTextColor: HexColor(e.color!),
                  );
                }).toList(),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildSaveButton(AskViewModel model) {
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
            "${model.selectedAskCategories.length} out of 3 selected",
            onPressed: () async {
              if (model.selectedAskCategories.isEmpty) {
                showToast(message: "Please select minimum 3 categories");
              } else {
                if (model.selectedAskCategories.length < 3) {
                  showToast(message: "Please select more then 3 categories");
                } else {
                  await saveUsersCategories(jsonEncode({"categories": model.selectedAskCategories}));
                  NavigationUtil.push(
                    context,
                    screen: AskHomeScreen(askCategories: model.askCategories),
                  ).then((value) => Navigator.of(context).pop());
                }
              }

              // NavigationUtil.push(
              //   context,
              //   screen: AskHomeScreen(askCategories: model.askCategories),
              // );

            },
          ),
        ),
      ],
    );
  }
}
