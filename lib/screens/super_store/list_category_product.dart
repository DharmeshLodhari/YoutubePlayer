import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/shop_list_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/custom_pagination.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListCategoryProduct extends StatefulWidget {
  final String nextUrl;
  final String categoryName;

  const ListCategoryProduct({
    required this.nextUrl,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  State<ListCategoryProduct> createState() => _ListCategoryProductState();
}

class _ListCategoryProductState extends State<ListCategoryProduct> {
  String? nextUrl = "";
  int? productCount = 0;
  dynamic categoryId = null;
  List<Product> productList = [];
  bool isProductLoading = false;

  @override
  void initState() {
    nextUrl = widget.nextUrl;
    fetchFirstList();
    super.initState();
  }

  Future<void> fetchFirstList() async {
    isProductLoading = true;
    setState(() {});
    await getProducts();
    isProductLoading = false;
    setState(() {});
  }

  Future<List<Product>> getProducts() async {
    if (nextUrl != null) {
      final Map<String, dynamic>? result = await ShoppingAuthService()
          .listOfProduct(nextUrl, "", "", false, otherDeals: false);

      final tempList = result!['results'];

      nextUrl = result['next'];
      productCount = result['count'];

      productList.addAll(tempList);
    }
    return productList;
  }

  @override
  Widget build(BuildContext context) {
    if (isProductLoading) {
      return buildShimmer();
    }

    if (productList.isEmpty) {
      return _buildNoItem();
    }

    return CustomPagination(
        onScrollEnd: () async {
          await getProducts();
          setState(() {});
        },
        child: ListView(children: [superStoreProducts()]));
  }

  Widget superStoreProducts() {
    if (productList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productList.isEmpty)
            const SizedBox.shrink()
          else
            const SizedBox(height: 16),
          if (productList.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Found ${productCount} ${widget.categoryName}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: blackFont,
                  ),
                ),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing: 22,
              mainAxisExtent: 274,
              crossAxisSpacing: 15,
              maxCrossAxisExtent: 200,
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return SuperStoreSingleCard(
                product: productList[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoItem() {
    return Center(
      child: NoItemInList(
        msg: AppLocalization.of(context)!.noResultFound,
      ),
    );
  }

  Widget buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: greyBorderColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisSpacing: 14,
          mainAxisExtent: 180,
          crossAxisSpacing: 15,
          maxCrossAxisExtent: 200,
        ),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
