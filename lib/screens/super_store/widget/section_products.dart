import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/single_store_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/material.dart';


class SectionProducts extends StatelessWidget {
  final dynamic headers;
  const SectionProducts({Key? key, this.headers})  : super(key: key);


getRowTitle(headers) async {
    List<Product> result = [];
    for (var item in headers['results']) {
      Product product = await ShoppingAuthService().createProduct(item);
      result.add(product);
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRowTitle(headers),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Product> prod = snapshot.data as List<Product>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(headers["name"],
                        style: TextStyle(
                          color: black,
                          fontSize: 14,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        )),
                    InkWell(
                      onTap: () {
                        String url = AppConfig.baseUrl + headers["next_url"];
                        NavigationUtil.push(context,
                            screen:
                                SuperStoreIndustry(next: url, appTitle: headers["name"]));
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
                              height: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: navyBlue,
                            size: 12,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 11),
                SizedBox(
                  height: 274,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 16);
                    },
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: prod.length,
                    itemBuilder: (context, index) {
                      return SuperStoreSingleCard(
                        product: prod[index],
                        // next: headers['next_url']
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
            );
          } else {
            return SizedBox();
          }
        });
  }
}