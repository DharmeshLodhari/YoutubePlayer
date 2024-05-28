import 'dart:io';

import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PackageDetails extends StatefulWidget {
  const PackageDetails({Key? key}) : super(key: key);

  @override
  State<PackageDetails> createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          floatingActionButton: floatingActionBar(),
          body: _buildBody(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Prineygladhair',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDeliveryBy(),
              const SizedBox(
                height: 10,
              ),
              _buildNote(),
              const SizedBox(
                height: 10,
              ),
              _buildItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryBy() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery By",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ListTile(
              minVerticalPadding: 0,
              minLeadingWidth: 10,
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
              leading: SvgPicture.asset(
                "assets/images/slydo.svg",
                width: 40,
                height: 40,
                color: navyBlue,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SLYDO",
                    style: TextStyle(
                      color: blackFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estimated delivery time 2-5 days",
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                  const Text(
                    "₦3,000.00",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "No 4, ilewole street, Ogba -➜ No 5, Adetutu street,ikeja, lagos",
                    style: TextStyle(
                      color: black,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
                _buildTrackingTag(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: greyBorderColor,
      ),
      child: Text(
        'Live Feed',
        style: TextStyle(
          color: darkGrey,
          fontSize: 8,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Note",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            const Icon(Icons.edit),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          'I will like it to be well packed and beautiful., I will like it to be well packed and beautiful., I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.,I will like it to be well packed and beautiful.',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Items",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {},
              child: _buildItemList(),
            );
          },
        )
      ],
    );
  }

  Widget _buildItemList() {
    return Container(
      color: Colors.white,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: getLeading(),
                  title: getTitle(),
                  subtitle: getSubtitle(context),
                  onTap: () {
                    // Navigator.pushNamed(context, Routes.PRODUCT,
                    //     arguments: {"product": widget.item});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        height: 48,
        width: 48,
        // imageUrl: widget.variant != null && widget.image!.isNotEmpty ? widget.image! : widget.item?.cover ?? defaultImage,
        imageUrl: "https://www.helium10.com/app/uploads/2020/04/vit-c.jpg",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.contain,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        // placeholder: (context, url) => widget.item?.cover == null
        //     ? Icon(Icons.widgets)
        //     : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          appendStringDot("Piano Bone straight wig ", 10),
          maxLines: 1,
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 2,
        ),
        getColorSizeName(context),
        const SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getSubTotalPriceWidget(),
            getAddRemoveItems(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtotal",
              style: TextStyle(
                fontSize: 12,
                color: darkGrey,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            getTotalPriceWidget(),
          ],
        ),
        // getTotalPriceWidget(),
      ],
    );
  }

  Widget getColorSizeName(BuildContext context) {
    return const Text(
      "Brown mix, 16”",
      style: TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getSubTotalPriceWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "₦",
          style: TextStyle(
              color: black,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        Text(
          "185,000.00",
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getAddRemoveItems() {
    return Container(
      width: 110,
      color: Colors.transparent,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RoundedBackgroundIcon(
              backgroundColor: iconBtnGrey,
              icon: Icon(
                SlydoAppIcon.minus,
                color: blackFont,
                size: 2,
              ),
              // onTap: widget.variant == null ? widget.onDecreaseQty : () => widget.onDecreaseVariantQty!(variantId),
              // onTap: widget.variant == null
              //     ? widget.onDecreaseQty
              //     : (widget.addOn != null
              //     ? widget.onDecreaseQty
              //     : () => widget.onDecreaseVariantQty!(variantId)),
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              // widget.variant != null
              //     ? variantQuantity.toString()
              //     : widget.qty.toString(),
              "0",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontFamily: "Inter",
              ),
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            RoundedBackgroundIcon(
              backgroundColor: iconBtnGrey,
              icon: Icon(
                SlydoAppIcon.plus,
                color: blackFont,
                size: 14, // Adjust the size as needed
              ),
              // onTap: widget.variant == null ? widget.onIncreaseQty : () => widget.onIncreaseVariantQty!(variantId),
              // onTap: widget.variant == null
              //     ? widget.onIncreaseQty
              //     : (widget.addOn != null
              //     ? widget.onIncreaseQty
              //     : () => widget.onIncreaseVariantQty!(variantId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTotalPriceWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "₦",
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          "185,000.00",
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Total: ',
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                const Text(
                  '₦',
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '187,200.00',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            MaterialButton(
              height: 40,
              color: navyBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const SizedBox(
                width: 66,
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
