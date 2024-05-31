import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/explore_single_product_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class ExploreProducts extends StatefulWidget {
  final dynamic headers;

  const ExploreProducts({Key? key, this.headers, this.isLast = false})
      : super(key: key);
  final bool isLast;

  @override
  State<ExploreProducts> createState() => _ExploreProductsState();
}

class _ExploreProductsState extends State<ExploreProducts> {
  List<Product> result = [];
  bool isLoading = false;

  getRowTitle(headers) async {
    isLoading = true;
    if (mounted) setState(() {});
    for (var item in headers['results']) {
      Product product = await ShoppingAuthService().createProduct(item);
      result.add(product);
    }
    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    getRowTitle(widget.headers);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (result != null && result.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.headers["name"],
                  style: TextStyle(
                    color: black,
                    fontSize: 16,
                    height: 1,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                  )),
              _buildViewMore(context)
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: result.length >= 3 ? 3 : result.length,
            itemBuilder: (context, index) {
              if (index == result.length) {
                return buildLoadingIndicator(isLoading: isLoading);
              } else {
                return ExploreSingleProduct(
                  product: result[index],
                  // next: headers['next_url']
                );
              }
            },
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildViewMore(BuildContext context) {
    return InkWell(
      onTap: () {
        String url = AppConfig.baseUrl + widget.headers["next_url"];
        NavigationUtil.push(context,
            screen: SuperStoreIndustry(
                next: url,
                appTitle: widget.headers["name"],
                searchQuery: {"tags": widget.headers["id"]}));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "View all",
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
          // SizedBox(width: 8),
          // Icon(
          //   Icons.arrow_forward_ios_sharp,
          //   color: navyBlue,
          //   size: 12,
          // ),
        ],
      ),
    );
  }
}
