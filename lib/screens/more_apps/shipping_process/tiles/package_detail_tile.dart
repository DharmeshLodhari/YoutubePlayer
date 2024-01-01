import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile(
      {super.key, required this.packageDetailsModel, required this.index});

  final PackageDetailsModel packageDetailsModel;
  final int index;
  late ShippingProcessBloc shippingProcessBloc;

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: shippingProcessBloc.currentSelectedIndex == index
              ? navyBlue
              : white,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          shippingProcessBloc.currentSelectedIndex = index;
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildPackageDetail(context),
              SizedBox(
                height: 5.0,
              ),
              _buildShippingDetail(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageDetail(BuildContext context) {
    return ListTile(
      leading: _buildImage(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            packageDetailsModel.merchant ?? "",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: black,
              fontFamily: "Inter",
            ),
          ),
          Text(
            "₦${packageDetailsModel.totalPrice}",
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
        "Package 1 (${packageDetailsModel.totalItems} item)",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: black,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildShippingDetail(BuildContext context) {
    Widget child;

    if (packageDetailsModel.deliveryOption == null) {
      child = Text(
        "Select delivery option",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: navyBlue,
          fontFamily: "Inter",
        ),
      );
    } else {
      switch (packageDetailsModel.deliveryOption!) {
        case DeliveryOptions.shipping:
          child = Column(
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
          );
          break;
        case DeliveryOptions.eatIn:
          child = Text(
            "Eatin",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: blackFont,
              fontFamily: "Inter",
            ),
          );
          break;
        case DeliveryOptions.pickUp:
          child = Text(
            "PickUp",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: blackFont,
              fontFamily: "Inter",
            ),
          );
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        shippingProcessBloc.currentSelectedIndex = index;
        Navigator.of(context).pushNamed(Routes.DELIVERY_OPTION);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          Icon(
            Icons.keyboard_arrow_right_outlined,
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      "assets/images/package.png",
      fit: BoxFit.fill,
    );
  }
}
