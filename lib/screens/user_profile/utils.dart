import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.white,
    highlightColor: greyBorderColor,
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return CustomBoxShadow(
          child: Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: CustomBoxShadow(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.zero,
                shadowColor: boxShadowTwo,
                color: lightGrey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 10,
                                width: 50,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                height: 8,
                                width: 50,
                                color: Colors.blueGrey,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 10,
                          width: 50,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
