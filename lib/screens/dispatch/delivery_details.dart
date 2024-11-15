import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryDetails extends StatefulWidget {
  const DeliveryDetails({super.key});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar() as PreferredSizeWidget?,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Delivery Details',
        style: TextStyle(
          fontSize: 16,
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSelection(),
            const SizedBox(
              height: 10,
            ),
            _buildProductMeasurement(),
            const SizedBox(
              height: 10,
            ),
            _buildUploadPackageImage(),
            const SizedBox(
              height: 15,
            ),
            _buildRecipientName(),
            const SizedBox(
              height: 10,
            ),
            _buildMobileTextFiled(),
            const SizedBox(
              height: 10,
            ),
            _buildAddressDetail(),
            const SizedBox(
              height: 10,
            ),
            _buildItemDescription(),
            const SizedBox(
              height: 10,
            ),
            _buildPinConfirmation(),
            const SizedBox(
              height: 20,
            ),
            _buildConfirmDetailsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
            color: greySecondaryYarn), // replace with navyBlue if defined
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Section
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SvgPicture.asset(
              'assets/images/rider/ic_route.svg',
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          // Address List Section (Static items)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick Up',
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '24 Bashir Musa Road, Agege',
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontSize: 14,
                  ),
                ),
                Divider(color: Colors.grey[300], thickness: 1),
                Text(
                  'Destination',
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '20, Pedro Street, Alausa, Ikeja',
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMeasurement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Package Measurement',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Image.asset(
              "assets/images/thermometer_icon.png",
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Weight",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: darkGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Height",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: darkGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Width",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: darkGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadPackageImage() {
    return GestureDetector(
      onTap: () {
        // Handle image upload action
      },
      child: SvgPicture.asset(
        'assets/images/upload_package_Image.svg',
        height: 80,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildMobileTextFiled() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Image.asset("assets/images/phone_icon.png"),
              labelText: '+234',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          flex: 5,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Recipient Number',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            // Handle contacts button action
          },
          child: Text('Contacts', style: TextStyle(color: navyBlue)),
        ),
      ],
    );
  }

  Widget _buildAddressDetail() {
    return const Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Building Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Unit/Floor',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient Details',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        CustomizedTextFormField(
          labelText: 'Recipient Name',
          validator: (val) {
            if (val.isNotEmpty) {
              return null;
            }
            return AppLocalization.of(context)!.pleaseEnterRecipientName;
          },
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildItemDescription() {
    return CustomizedTextFormField(
      labelText: 'Delivery Note',
      hintText: 'Call me when you arrive.',
      maxLines: 3,
      onChanged: (value) {},
    );
  }

  Widget _buildPinConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pin Confirmation',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activate to confirm delivery with a 6-digit PIN.',
              style: TextStyle(
                color: lightBlackFont,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: true,
              onChanged: (bool? value) {
                // Handle checkbox change
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmDetailsButton() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.PAYMENT_OPTION);
      },
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Confirm Details  (Pay ₦1,000)",
    );
  }
}
