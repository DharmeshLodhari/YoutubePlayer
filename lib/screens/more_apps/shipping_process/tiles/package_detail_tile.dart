import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile({super.key});

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected == true ? navyBlue : white,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.DELIVERY_OPTION);
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListTile(
                leading: _buildImage(),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Prineygladhair",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: black,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      "₦187,000.00",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: black,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  "Package 1 (1 item)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: black,
                    fontFamily: "Inter",
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              _buildShippingData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      "https://www.helium10.com/app/uploads/2020/04/vit-c.jpg",
      height: 48,
      width: 48,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      cacheHeight: 48,
      cacheWidth: 48,
      frameBuilder: imageFrameBuilder,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }

  Widget _buildShippingData() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Shipping: ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    "₦2,000.00",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "Estimated delivery time 2-5 days",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: darkGrey,
                  fontFamily: "Inter",
                ),
              ),
              //
            ],
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right_outlined,
        )
      ],
    );
  }
}
