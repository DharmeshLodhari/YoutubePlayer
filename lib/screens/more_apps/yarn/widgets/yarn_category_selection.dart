import 'package:Slydo/screens/more_apps/yarn/widgets/category_chip.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_by_category_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YarnCategorySelection extends StatefulWidget {
  const YarnCategorySelection({super.key});

  @override
  State<YarnCategorySelection> createState() => _YarnCategorySelectionState();
}

class _YarnCategorySelectionState extends State<YarnCategorySelection> {
  bool isLoading = false;
  String? next = "";
  String? previous = "";
  bool noCategoriesList = false;
  int? count = 0;

  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    getAskCategoriesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    return _buildMain();
  }

  Widget _buildMain() {
    if (yarnDashboardBloc.yarnCategories.isEmpty) {
      return Container();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
          ),
          CategoryChip(
            onTap: () {},
            title: 'All',
            categoryColor: darkGreyYarn,
            selectedCategoryTextColor: HexColor("#000000"),
            borderColor: greySecondaryYarn,
          ),
          ...List.generate(
            yarnDashboardBloc.yarnCategories.length,
            (i) {
              return Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  CategoryChip(
                    onTap: () {
                      NavigationUtil.push(
                        context,
                        screen: YarnCategoryScreen(
                          askCategories: yarnDashboardBloc.yarnCategories[i],
                        ),
                      );
                    },
                    title: yarnDashboardBloc.yarnCategories[i].name,
                    categoryColor:
                        yarnDashboardBloc.yarnCategories[i].name == 'All'
                            ? greySecondaryYarn
                            : greyBackground,
                    selectedCategoryTextColor: HexColor("#000000"),
                    borderColor: greySecondaryYarn,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void getAskCategoriesList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result =
            await YarnAuth().getAllCategories(next, previous!);

        if (result == null) {
          noCategoriesList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          noCategoriesList = false;
          isLoading = false;

          // debugPrint('tempList::: ${tempList.runtimeType}');

          yarnDashboardBloc.addCategories(tempList);
        }
      }
      if (yarnDashboardBloc.yarnCategories.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
          });
        }
      }
    }
  }
}
