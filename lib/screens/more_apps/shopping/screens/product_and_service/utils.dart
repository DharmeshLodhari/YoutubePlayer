import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    child: IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(
            color: greyDarkBackground,
          ),
        ),
        child: Row(
          children: [
            // Blue line on the left
            Container(
              width: 6.0,
              decoration: BoxDecoration(
                color: navyBlue, // Your custom navy blue color
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            SvgPicture.asset(
              'assets/images/misc_icon.svg',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'See what people are saying about this product',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: fontDarkGrey,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
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
            ),
            const SizedBox(width: 8.0),
            Container(
              width: 1.0,
              height: 60.0,
              color: greyDarkBackground,
            ),
            const SizedBox(width: 8.0),
            Icon(
              Icons.arrow_forward_ios,
              color: blackFont,
              size: 18.0,
            ),
            const SizedBox(width: 10.0),
          ],
        ),
      ),
    ),
  );
}
