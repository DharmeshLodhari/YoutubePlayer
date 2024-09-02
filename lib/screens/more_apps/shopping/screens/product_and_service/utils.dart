import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

Widget getProductOrServiceSocialMedia(
    BuildContext context, String modelName, String id) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, Routes.PRODUCT_AND_SERVICE_SOCIAL_MEDIA,
          arguments: {
            "modelName": modelName,
            "id": id,
          });
    },
    child: Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: greySecondaryYarn,
        ),
      ),
      child: Row(
        children: [
          // Blue line on the left
          Container(
            width: 5.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: navyBlue, // Your custom navy blue color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Icon on the left
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.check_circle,
                color: navyBlue,
                size: 15.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'See what people are saying about this product',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: blackFont,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Product Moment & Yarn Showcase',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: fontLightGrey,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8.0),
          const Divider(
            height: 50,
            color: Colors.black,
          ),
          const SizedBox(width: 8.0),
          // Arrow Icon on the right
          Icon(
            Icons.arrow_forward_ios,
            color: blackFont,
            size: 18.0,
          ),
        ],
      ),
    ),
  );
}
