import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/single_store_card.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class SectionProducts extends StatefulWidget {
  final dynamic headers;

  const SectionProducts({super.key, this.headers, this.isLast = false});
  final bool isLast;

  @override
  State<SectionProducts> createState() => _SectionProductsState();
}

class _SectionProductsState extends State<SectionProducts> {
  List<Product> result = [];
  bool isLoading = false;
  bool dealsOfDayEmpty = false;
  String? todayDealNext = "";
  String? todayDealPrevious = "";
  bool todaysDealsEmpty = false;
  double todaysDealsSizeBox = 0;

  void getRowTitle(headers) async {
    isLoading = true;
    if (mounted) setState(() {});
    for (var item in headers['results']) {
      final Product product = ShoppingAuthService().createProduct(item);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.headers["name"],
                        style: TextStyle(
                          color: black,
                          fontSize: 14,
                          height: 1,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        )),
                    _buildViewMore(context)
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 0);
                    },
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: result.length + 1,
                    itemBuilder: (context, index) {
                      if (index == result.length) {
                        return buildLoadingIndicator(isLoading: isLoading);
                      } else {
                        return SuperStoreSingleCard(
                          product: result[index],
                          // next: headers['next_url']
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.isLast ? 56 : 16),
        ],
      );
    } else {
      return const SizedBox();
    }
    // return FutureBuilder(
    //     future: getRowTitle(widget.headers),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         List<Product> prod = snapshot.data as List<Product>;
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Container(
    //               color: Colors.white,
    //               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    //               child: Column(
    //                 children: [
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(widget.headers["name"],
    //                           style: TextStyle(
    //                             color: black,
    //                             fontSize: 14,
    //                             height: 1,
    //                             fontFamily: "Inter",
    //                             fontWeight: FontWeight.w600,
    //                           )),
    //                       _buildViewMore(context)
    //                     ],
    //                   ),
    //                   SizedBox(height: 11),
    //                   SizedBox(
    //                     height: 274,
    //                     child: ListView.separated(
    //                       separatorBuilder: (BuildContext context, int index) {
    //                         return SizedBox(width: 16);
    //                       },
    //                       shrinkWrap: true,
    //                       physics: const ScrollPhysics(),
    //                       scrollDirection: Axis.horizontal,
    //                       itemCount: prod.length,
    //                       itemBuilder: (context, index) {
    //                         return SuperStoreSingleCard(
    //                           product: prod[index],
    //                           // next: headers['next_url']
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             SizedBox(height: widget.isLast ? 56 : 16),
    //           ],
    //         );
    //       } else {
    //         return SizedBox();
    //       }
    //     });
  }

  Widget _buildViewMore(BuildContext context) {
    return InkWell(
      onTap: () {
        final String url = AppConfig.baseUrl + widget.headers["next_url"];
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
            "View more",
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: navyBlue,
            size: 12,
          ),
        ],
      ),
    );
  }
}
