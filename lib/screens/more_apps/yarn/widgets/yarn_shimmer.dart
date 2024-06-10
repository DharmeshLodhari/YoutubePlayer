import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class YarnShimmer extends StatelessWidget {
  const YarnShimmer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.white,
      period: const Duration(seconds: 2),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            height: 280,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: greyBackground,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
            thickness: 0.5,
            color: greySecondaryYarn,
          );
        },
      ),
    );
  }
}
