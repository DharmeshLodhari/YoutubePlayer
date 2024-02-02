import 'package:Slydo/screens/more_apps/rider_delivery/comman/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressPickupAndDelivery extends StatelessWidget {
  AddressPickupAndDelivery(
      {this.PickupAddressText, this.DeliveryByAddressText, this.TextColor});
  final String? PickupAddressText;
  final String? DeliveryByAddressText;
  final Color? TextColor;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconImage(),
        SizedBox(width: 5),
        _buildMainAddressColumn()
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      assetIconDot,
      height: 65,
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PickupAddressText ?? "",
          style: TextStyle(
              fontWeight: FontWeight.w500, color: TextColor, fontSize: 17),
        ),
        SizedBox(height: 25),
        Text(
          DeliveryByAddressText ?? "",
          style: TextStyle(
              fontWeight: FontWeight.w500, color: TextColor, fontSize: 17),
        ),
      ],
    );
  }
}
