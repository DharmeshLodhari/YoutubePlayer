import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile(
      {super.key, required this.packageDetailsModel, required this.index});

  final PackageDetailsModel packageDetailsModel;
  final int index;
  late ShippingProcessBloc shippingProcessBloc;
  late UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return GestureDetector(
      onTap: () {
        shippingProcessBloc.currentSelectedIndex = index;
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: shippingProcessBloc.currentSelectedIndex == index &&
                  shippingProcessBloc.isPaymentSuccessful == false
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: navyBlue,
                    width: 1,
                  ),
                )
              : decorateBox(),
          // decoration: decorateBox(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              _buildPackageDetail(context),
              const SizedBox(
                height: 5.0,
              ),
              if (shippingProcessBloc.isPaymentSuccessful == false)
                _buildShippingDetail(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageDetail(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
      trailing: Container(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (shippingProcessBloc
                    .packagesList[index].isShippingProcessCompleted ==
                true)
              Checkbox(
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                checkColor: Colors.white,
                activeColor: navyBlue,
                value: true,
                shape: const CircleBorder(),
                onChanged: (bool? value) {},
              ),
            Row(
              children: [
                Text(
                  "${worldCurrencies[userBloc.user.currency]}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: black,
                    fontFamily: "Inter",
                  ),
                ),
                Text(
                  moneyDisplayNormalizer(packageDetailsModel.totalPrice ?? 0),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: black,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetail(BuildContext context) {
    Widget child;

    if (shippingProcessBloc.packagesList[index].isShippingProcessCompleted ==
        false) {
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
                    "${worldCurrencies[shippingProcessBloc.packagesList[index].shippingOption?.currency]}${moneyDisplayNormalizer(shippingProcessBloc.packagesList[index].shippingOption?.price)}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                shippingProcessBloc.packagesList[index].getDeliveryTime() ?? "",
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
        shippingProcessBloc.isUseCartProcess(true);
        Navigator.of(context).pushNamed(Routes.DELIVERY_OPTION);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          const Padding(
            padding: EdgeInsets.only(right: 7.0),
            child: Icon(
              Icons.keyboard_arrow_right_outlined,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (packageDetailsModel.deliveryOption == null) {
      return Image.asset(
        "assets/images/package.png",
        width: 48,
      );
    }
    switch (packageDetailsModel.deliveryOption!) {
      case DeliveryOptions.shipping:
        return Image.asset(
          "assets/images/package.png",
          width: 48,
        );
      case DeliveryOptions.eatIn:
        return Image.asset(
          "assets/images/eatin_logo.png",
          fit: BoxFit.fill,
        );
      case DeliveryOptions.pickUp:
        return Image.asset(
          "assets/images/pickup_logo.png",
          fit: BoxFit.fill,
        );
    }
  }
}
