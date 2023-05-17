import 'package:Slydo/screens/more_apps/yarn/models/ask_categories_model.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_by_category_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/category_chip.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_list_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCategorySelection extends StatefulWidget {
  const ProductCategorySelection({Key? key}) : super(key: key);

  @override
  State<ProductCategorySelection> createState() => _ProductCategorySelectionState();
}

class _ProductCategorySelectionState extends State<ProductCategorySelection> {
  bool isLoading = false;
  String? next = "";
  String? previous = "";
  bool noCategoriesList = false;
  int? count = 0;

  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    getProductCategoriesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    return _buildMain();
  }

  Widget _buildMain() {
    if (yarnDashboardBloc.productCategories.isEmpty) {
      return Container();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
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
            yarnDashboardBloc.productCategories.length,
            (i) {
              return Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  CategoryChip(
                    onTap: () {
                      // NavigationUtil.push(
                      //   context,
                      //   screen: YarnCategoryScreen(
                      //     askCategories: yarnDashboardBloc.productCategories[i],
                      //   ),
                      // );
                    },
                    title: yarnDashboardBloc.productCategories[i].name,
                    categoryColor:
                        yarnDashboardBloc.productCategories[i].name == 'All'
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

  void getProductCategoriesList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result =
            await YarnAuth().getProductCategories(next, previous!);

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
        var tempList = result['results'];
        if (mounted) {
          noCategoriesList = false;
          isLoading = false;

          // debugPrint('tempList::: ${tempList.runtimeType}');

          yarnDashboardBloc.addProductCategories(tempList);
        }
      }
      if (yarnDashboardBloc.productCategories.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoriesList = true;
          });
        }
      }
    }
  }
}
