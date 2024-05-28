import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryOrderTile extends StatefulWidget {
  DeliveryModel? jobListing;
  DeliveryOrderTile({required this.jobListing, super.key});

  @override
  State<DeliveryOrderTile> createState() => _DeliveryOrderTileState();
}

class _DeliveryOrderTileState extends State<DeliveryOrderTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildOrderId(),
          _buildLogoAndDeliveryAndAmount(),
          _buildItemsAndKg(),
          const SizedBox(height: 10.0),
          _buildIconAndAddressAndPickup(),
        ],
      ),
    );
  }

  Widget _buildOrderId() {
    return Text(
      'Ride #${widget.jobListing?.orderId.toString() ?? ""}',
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildLogoAndDeliveryAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLogo(),
            _buildVerticalDivider(),
            _buildDelivery(),
          ],
        ),
        Row(
          children: [
            _buildEst(),
            _buildCurrency(),
            _buildAmount(),
          ],
        )
      ],
    );
  }

  Widget _buildLogo() {
    return Image.network(
      widget.jobListing?.merchantAvatar ?? "",
      height: 24,
      width: 24,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
      cacheHeight: 24,
      cacheWidth: 24,
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

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      child: VerticalDivider(
        color: greySecondaryYarn,
        thickness: 1,
        indent: 10,
        endIndent: 10,
        width: 20,
      ),
    );
  }

  Widget _buildDelivery() {
    return Text(
      widget.jobListing?.merchantFullName ?? "",
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildEst() {
    return Text(
      "Est ",
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildCurrency() {
    return Text(
      worldCurrencies[widget.jobListing?.currency] ?? "NGN",
      style: TextStyle(
        color: yarnBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildAmount() {
    return Text(
      moneyDisplayNormalizer(widget.jobListing?.riderPayment),
      style: TextStyle(
        color: yarnBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildItemsAndKg() {
    return Text(
      "${widget.jobListing?.totalNoOfItems} Items (${widget.jobListing?.totalWeight}Kg)",
      style: TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildIconAndAddressAndPickup() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconImage(),
        const SizedBox(width: 7.0),
        Expanded(child: _buildMainAddressColumn())
      ],
    );
  }

  Widget _buildIconImage() {
    return SvgPicture.asset(
      'assets/images/rider/ic_route.svg',
      height: 65,
    );
  }

  Widget _buildMainAddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.jobListing?.pickupAddress?.addressLineOne}, ${widget.jobListing?.pickupAddress?.addressLineTwo}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
            'Pickup by ${widget.jobListing?.convertDateFormat(widget.jobListing?.expectedPickupTime.toString() ?? "")}',
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            )),
        const SizedBox(height: 20),
        Text(
          '${widget.jobListing?.deliveryAddress?.addressLineOne}, ${widget.jobListing?.deliveryAddress?.addressLineTwo}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deliver by ${widget.jobListing?.convertDateFormat(widget.jobListing?.expectedDeliveryTime.toString() ?? "")}',
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
