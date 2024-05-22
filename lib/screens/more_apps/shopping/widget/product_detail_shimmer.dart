import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.white,
          period: const Duration(seconds: 1),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: greyBackground,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 15,
                            decoration: BoxDecoration(
                                color: greyBackground,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 100,
                            height: 15,
                            decoration: BoxDecoration(
                                color: greyBackground,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  color: greySecondaryYarn,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 15,
                        decoration: BoxDecoration(
                            color: greyBackground,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 150,
                        height: 15,
                        decoration: BoxDecoration(
                            color: greyBackground,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  color: greySecondaryYarn,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 15,
                        decoration: BoxDecoration(
                            color: greyBackground,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 200,
                        height: 15,
                        decoration: BoxDecoration(
                            color: greyBackground,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  color: greySecondaryYarn,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.circle),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 15,
                            decoration: BoxDecoration(
                                color: greyBackground,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 100,
                            height: 15,
                            decoration: BoxDecoration(
                                color: greyBackground,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 0.5,
                  color: greySecondaryYarn,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 15,
                      decoration: BoxDecoration(
                          color: greyBackground,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisExtent: 150,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        maxCrossAxisExtent: 250,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
