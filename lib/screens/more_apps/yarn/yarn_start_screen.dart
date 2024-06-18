import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/ask_categories_model.dart';
import 'widgets/category_chip.dart';
import 'yarn_auth.dart';
import 'yarn_dashboard.dart';
import 'yarn_dashboard_bloc.dart';

class AskStartScreen extends StatefulWidget {
  const AskStartScreen({super.key});

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
  final GlobalKey<ScaffoldMessengerState> _askCategoriesScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;
  final DatabaseHelper _db = DatabaseHelper();

  List<Color> categoryColors = [
    const Color(0xFFF07097),
    const Color(0xFF030F36),
    const Color(0xFF8829C1),
    const Color(0xFF8B008B),
    const Color(0xFF3F61DB),
    const Color(0xFFB22727),
    const Color(0xFFFFCC00),
    const Color(0xFF8B008B),
    const Color(0xFFFFA500),
    const Color(0xFF46CE7C),
    const Color(0xFF964B00),
    const Color(0xFFF35B46),
    const Color(0xFF243A73),
  ];

  @override
  void initState() {
    Future.microtask(() => context.read<YarnDashboardBloc>().init());
    getAskCategoriesList();
    super.initState();
  }

  void getAskCategoriesList() async {
    if (!isAskCategoriesLoading) {
      if (categoriesNext != null && !isAskCategoriesLoading) {
        isAskCategoriesLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await YarnAuth()
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
        final tempList = result['results'];
        if (mounted) {
          noCategoriesList = false;
          isAskCategoriesLoading = false;
          context.read<YarnDashboardBloc>().setAskCategories(tempList);
          //askCategoriesList.addAll(tempList);
        }
      }
      if (Provider.of<YarnDashboardBloc>(context, listen: false)
          .yarnCategories
          .isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  Future<void> saveUsersCategories(String body) async {
    final Map<String, dynamic>? result =
        await YarnAuth().saveUsersCategories(body);
    final UsersCategories usersCategories =
        result!['results'] as UsersCategories;
    final UserCategoriesStructure userCategoriesStructure =
        UserCategoriesStructure(
            userId: userBloc.user.uuid,
            userSelectedCategory: jsonEncode(usersCategories.categories));
    _db.saveUserSelectedYarnCategories(userCategoriesStructure);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Consumer<YarnDashboardBloc>(builder: (context, model, child) {
      return ScaffoldMessenger(
        key: _askCategoriesScaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            shape: Border(bottom: BorderSide(color: HexColor("#D9D9D9"))),
            elevation: 0,
            title: Text(
              "Yarn",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HexColor("#030F36"),
              ),
            ),
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: HexColor("#292929"),
                size: 26,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 26, right: 26, bottom: 20),
            children: [
              const SizedBox(
                height: 15,
              ),
              _buildTitleAndDescription(
                  title: 'What are you interested?',
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              const SizedBox(
                height: 15,
              ),
              _buildTitleAndDescription(
                  title:
                      'Select 3 or more interest to continue. We’ll use this to recommend topics you may like.',
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
              const SizedBox(
                height: 30,
              ),
              _buildCategoryList(model),
              const SizedBox(
                height: 65,
              ),
              _buildSaveButton(model),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTitleAndDescription(
      {String? title, double? fontSize, FontWeight? fontWeight}) {
    return Text(
      title!,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildCategoryList(YarnDashboardBloc model) {
    if (!isAskCategoriesLoading) {
      return Wrap(
        runSpacing: 30,
        spacing: 15,
        children: model.yarnCategories.map((e) {
          // int random = Random().nextInt(model.categoryColors.length-1);
          return CategoryChip(
            onTap: () {
              model.onSelectedAskCategories(e.id!);
            },
            title: e.name!,
            categoryColor: model.selectedAskCategories.contains(e.id!)
                ? HexColor("#D9DFF8")
                : HexColor("#CCCCCC"),
            selectedCategoryTextColor:
                model.selectedAskCategories.contains(e.id!)
                    ? HexColor("#3F61DB")
                    : HexColor("#000000"),
            borderColor: model.selectedAskCategories.contains(e.id!)
                ? HexColor("#D9DFF8")
                : HexColor("#CCCCCC"),
            isIconShow: model.selectedAskCategories.contains(e.id!),
          );
        }).toList(),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSaveButton(YarnDashboardBloc model) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 60),
          child: CurvedButton(
            height: 50,
            textColor: Colors.white,
            backgroundColor: navyBlue,
            borderRadius: 50,
            text: "${model.selectedAskCategories.length} out of 3 selected",
            onPressed: () async {
              if (model.selectedAskCategories.isEmpty) {
                showToast(message: "Please select minimum 3 categories");
              } else {
                if (model.selectedAskCategories.length < 3) {
                  showToast(message: "Please select more then 3 categories");
                } else {
                  await saveUsersCategories(
                      jsonEncode({"categories": model.selectedAskCategories}));
                  NavigationUtil.push(
                    context,
                    screen: const YarnDashboard(),
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
