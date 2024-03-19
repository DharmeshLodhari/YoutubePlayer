import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/auth/rider_delivery_auth.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryOrderTile extends StatefulWidget {
  DeliveryModel jobListing;
  DeliveryOrderTile({required this.jobListing, super.key});

  @override
  State<DeliveryOrderTile> createState() => _DeliveryOrderTileState();
}

class _DeliveryOrderTileState extends State<DeliveryOrderTile> {
  bool isRejectAPILoading = false;
  bool isAcceptAPILoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: greyBorderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoAndDeliveryAndAmount(),
                _buildItemsAndKg(),
                SizedBox(height: 10.0),
                _buildIconAndAddressAndPickup(),
                SizedBox(height: 10.0),
                _buildButtonCancelAndPickup(),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.0),
      ],
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
            _buildAmount(),
          ],
        )
      ],
    );
  }

  Widget _buildLogo() {
    return Image.network(
      widget.jobListing.merchantAvatar ?? "",
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
      widget.jobListing.merchantFullName ?? "",
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

  Widget _buildAmount() {
    return Text(
      widget.jobListing.currency ?? "",
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
      "${widget.jobListing.totalNoOfItems} Items (${widget.jobListing.totalWeight}Kg)",
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
        SizedBox(width: 7.0),
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
          '${widget.jobListing.pickupAddress?.addressLineOne}, ${widget.jobListing.pickupAddress?.addressLineTwo}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontSize: 12,
            fontFamily: "Inter",
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 3),
        Text(widget.jobListing.expectedPickupTime.toString(),
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
            )),
        SizedBox(height: 20),
        Text(
          '${widget.jobListing.deliveryAddress?.addressLineOne}, ${widget.jobListing.deliveryAddress?.addressLineTwo}',
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
              widget.jobListing.expectedDeliveryTime.toString(),
              style: TextStyle(
                color: navyBlue,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            Padding(
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

  Widget _buildButtonCancelAndPickup() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: isRejectAPILoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      isRejectAPILoading = true;
                      if (mounted) setState(() {});
                      rejectJob();
                      showToast(
                          message: AppLocalization.of(context)!
                              .jobRemovedFromListing);

                      isRejectAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: redBtn,
              textColor: white,
              text: 'Reject',
              fontSize: 15,
              isLoading: isRejectAPILoading,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: CurvedButton(
              onPressed: isAcceptAPILoading
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAcceptAPILoading = true;
                      if (mounted) setState(() {});
                      await acceptJob();

                      isAcceptAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: white,
              text: 'Accept(4:49)',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> rejectJob() async {
    await RiderDeliveryAuthService()
        .rejectOffer(widget.jobListing.id)
        .then((value) {
      showToast(message: AppLocalization.of(context)!.jobRemovedFromListing);
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> acceptJob() async {
    await RiderDeliveryAuthService()
        .acceptOffer(widget.jobListing.id)
        .then((value) {
      if (value == true) {
        showToast(message: AppLocalization.of(context)!.jobAcceptedFromListing);
        Navigator.of(context).pushNamed(Routes.RIDER_JOB_DETAILS, arguments: {
          'showDetails': false,
          'deliveryDetail': widget.jobListing,
        });
      } else {
        showToast(message: 'Offer already accepted by a dispatcher');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }
}
