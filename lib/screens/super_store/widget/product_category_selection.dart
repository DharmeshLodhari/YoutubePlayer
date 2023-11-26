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

import '../shop_category_screen.dart';

class ProductCategorySelection extends StatefulWidget {
  final Function(String, dynamic ,bool)? callback;
  final String? next_url;
  final String? categoryName;

   ProductCategorySelection({Key? key, this.callback, this.next_url, this.categoryName}) : super(key: key);

  @override
  State<ProductCategorySelection> createState() => _ProductCategorySelectionState();
}

class _ProductCategorySelectionState extends State<ProductCategorySelection> {
  bool isLoading = false;
  String? next = "";
  String? previous = "";
  bool noCategoriesList = false;
  int? count = 0;
  String selectedCategory = 'All';

  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    
    getProductCategoriesList();
    if(widget.categoryName!.isNotEmpty){
      setState(() {
        selectedCategory = widget.categoryName!;
      });
    }
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
      child: Container(
        child: Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            ...List.generate(
              yarnDashboardBloc.productCategories.length,
              (i) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    CategoryChip(
                      onTap: () {
                          // Call the callback function and pass the values
                          widget.callback!(yarnDashboardBloc.productCategories[i].name, yarnDashboardBloc.productCategories[i].id, true);
                          selectedCategory = yarnDashboardBloc.productCategories[i].name;
                          if(mounted)setState(() {});
      
                      },
                      title: yarnDashboardBloc.productCategories[i].name,
                      categoryColor:
                      selectedCategory == yarnDashboardBloc.productCategories[i].name
                              ? darkGreyYarn
                              : greyBackground,
                      selectedCategoryTextColor: HexColor("#000000"),
                      borderColor: greySecondaryYarn,
                      selected:  selectedCategory == yarnDashboardBloc.productCategories[i].name,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void getProductCategoriesList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result =
            await YarnAuth().getProductCategories(widget.next_url, previous!);
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
