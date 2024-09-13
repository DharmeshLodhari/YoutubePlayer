import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/shop_list_screen.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_pagination.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListCategoryProduct extends StatefulWidget {
  final String? nextUrl;
  final String categoryName;

  const ListCategoryProduct({
    required this.nextUrl,
    required this.categoryName,
    super.key,
  });

  @override
  State<ListCategoryProduct> createState() => _ListCategoryProductState();
}

class _ListCategoryProductState extends State<ListCategoryProduct> {
  String? nextUrl = "";
  String? productPrevious = "";
  bool productEmpty = false;
  int? productCount = 0;
  dynamic categoryId;
  List<Product> productList = [];
  bool isProductLoading = false;
  final ScrollController _productScrollController = ScrollController();

  @override
  void initState() {
    loadUrl();
    getProducts();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProducts();
      }
    });
    super.initState();
  }

  void loadUrl() {
    if (widget.nextUrl != null && widget.nextUrl != "") {
      nextUrl = widget.nextUrl;
    }
  }

  void getProducts() async {
    // if (nextUrl != null) {
    //   Map<String, dynamic>? result = await ShoppingAuthService()
    //       .listOfProduct(nextUrl, "", "", false, otherDeals: false);
    //
    //   var tempList = result!['results'];
    //
    //   nextUrl = result['next'];
    //   productCount = result['count'];
    //
    //   productList.addAll(tempList);
    // }
    // return productList;
    if (!isProductLoading) {
      if (nextUrl != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(nextUrl, productPrevious, "", false,
                otherDeals: false);

        if (result == null) {
          productEmpty = true;
          isProductLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        nextUrl = result['next'];
        productCount = result['count'];
        productPrevious = result['previous'];
        final tempList = result['results'];

        productEmpty = false;
        isProductLoading = false;
        productList.addAll(tempList);

        if (mounted) setState(() {});
      }
      if (productList.isEmpty) {
        if (mounted) {
          setState(() {
            productEmpty = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isProductLoading && productList.isEmpty) {
      return buildShimmer();
    }

    if (productList.isEmpty) {
      return _buildNoItem();
    } else {
      return CustomPagination(
          onScrollEnd: () async {
            getProducts();
            setState(() {});
          },
          child: ListView(children: [superStoreProducts()]));
    }
  }

  Widget superStoreProducts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productList.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Found $productCount ${widget.categoryName}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: blackFont,
                  ),
                ),
              ),
            ),
          CustomScrollView(
            physics: const ScrollPhysics(),
            controller: _productScrollController,
            shrinkWrap: true,
            slivers: <Widget>[
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(
                    child: SuperStoreSingleCard(
                      product: productList[i],
                    ),
                  ),
                  childCount: productList.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 8,
                  mainAxisExtent: 280,
                  crossAxisSpacing: 8,
                  maxCrossAxisExtent: 300,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    buildJumpingLoadingIndicator(isLoading: isProductLoading),
              ),
            ],
          ),
          // GridView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          //     mainAxisSpacing: 22,
          //     mainAxisExtent: 274,
          //     crossAxisSpacing: 15,
          //     maxCrossAxisExtent: 200,
          //   ),
          //   itemCount: productList.length,
          //   itemBuilder: (context, index) {
          //     return SuperStoreSingleCard(
          //       product: productList[index],
          //     );
          //   },
          // ),
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
