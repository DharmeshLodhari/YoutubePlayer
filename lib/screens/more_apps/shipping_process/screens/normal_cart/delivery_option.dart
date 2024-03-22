import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryOption extends StatefulWidget {
  DeliveryOption({
    Key? key,
  }) : super(key: key);

  @override
  State<DeliveryOption> createState() => _DeliveryOptionState();
}

class _DeliveryOptionState extends State<DeliveryOption> {
  List<String?> deliveryOption = ["Shipping", "Eatin", "Pickup"];

  late ShippingProcessBloc shippingProcessBloc;
  TextEditingController userNoteController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (shippingProcessBloc.getPackageDetailModel().hasShippingAvailable() ==
          false) {
        deliveryOption.removeAt(0);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          shippingProcessBloc.clearBuyNowData();
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
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
        'Delivery Option',
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
          shippingProcessBloc.clearBuyNowData();
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dropDownPickItemWidget(
                      label: 'Delivery Option',
                      selectedItem: shippingProcessBloc
                          .getPackageDetailModel()
                          .getDeliveryOption(),
                      onTap: () => pickDeliveryOptions(),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (shippingProcessBloc
                            .getPackageDetailModel()
                            .deliveryOption !=
                        null)
                      shippingProcessBloc.getPackageDetailModel().requireNote()
                          ? _buildNote()
                          : _buildDeliveryAddressAndOptions(),
                    if (shippingProcessBloc
                            .getPackageDetailModel()
                            .shippingOption !=
                        null)
                      _buildShippingOptionSelected(),
                  ],
                ),
              ),
            ),
          ),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressAndOptions() {
    return Column(
      children: [
        _buildDeliveryAddress(),
        const SizedBox(
          height: 16,
        ),
        if (shippingProcessBloc.getPackageDetailModel().shippingOption == null)
          _buildShippingOption(),
      ],
    );
  }

  Widget ShippingOptionalWid(
      {required String title, required String subTitle}) {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              subTitle,
              style: TextStyle(
                color: darkGrey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right_outlined,
            color: black,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Text(
          'Note',
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        SizedBox(height: 5),
        _buildNoteTextField(),
      ],
    );
  }

  pickDeliveryOptions() async {
    String? pickedDeliveryOption = await showPickItemDialog<String>(
      context: context,
      items: deliveryOption,
      selectedItem:
          shippingProcessBloc.getPackageDetailModel().getDeliveryOption(),
    );
    if (pickedDeliveryOption != null) {
      shippingProcessBloc.updateDeliveryOption(pickedDeliveryOption);
    }
  }

  Widget _buildDeliveryAddress() {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          Routes.DISPATCH_ADDRESS,
          arguments: {
            "isForSelection": true,
            "shippingAddress":
                shippingProcessBloc.getPackageDetailModel().deliveryAddress,
            "onShippingAddressChange": (address) {
              shippingProcessBloc.getPackageDetailModel().deliveryAddress =
                  address;
              setState(() {});
            }
          },
        );
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: TextStyle(
              color: darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                      null
                  ? shippingProcessBloc
                          .getPackageDetailModel()
                          .deliveryAddress
                          ?.toAddressString() ??
                      ""
                  : "Select delivery address",
              style: TextStyle(
                color: black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_right_outlined,
              color: black,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Shipping Option",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () async {
            if (shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                null) {
              shippingProcessBloc.updateShippingOptionType(ShippingTypes.slydo);
              await Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION);
            } else {
              showToast(message: "Please select delivery address.");
            }
          },
          child: ShippingOptionalWid(
            title: "Ship with Slydo",
            subTitle: "Use slydo dispatch rider to get your orders.",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () async {
            if (shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                null) {
              shippingProcessBloc
                  .updateShippingOptionType(ShippingTypes.merchant);
              await Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION);
            } else {
              showToast(message: "Please select delivery address.");
            }
          },
          child: ShippingOptionalWid(
            title: "Merchant Option",
            subTitle: "Use merchant rider to get your orders delivered",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        GestureDetector(
          onTap: () async {
            if (shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                null) {
              shippingProcessBloc
                  .updateShippingOptionType(ShippingTypes.courier);
              await Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION);
            } else {
              showToast(message: "Please select delivery address.");
            }
          },
          child: ShippingOptionalWid(
            title: "Ship with Courier",
            subTitle: "Use courier service to get your order delivered to you.",
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    bool isEnable = false;
    if (shippingProcessBloc.getPackageDetailModel().deliveryOption ==
            DeliveryOptions.eatIn ||
        shippingProcessBloc.getPackageDetailModel().deliveryOption ==
            DeliveryOptions.pickUp) {
      isEnable = true;
    } else {
      if (shippingProcessBloc.getPackageDetailModel().deliveryOption ==
              DeliveryOptions.shipping &&
          (shippingProcessBloc.getPackageDetailModel().shippingOption != null &&
              shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                  null)) {
        isEnable = true;
      }
    }

    if (isEnable) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CurvedButton(
          onPressed: () {
            shippingProcessBloc
                .getPackageDetailModel()
                .updateShippingNote(userNoteController.text.trim());
            shippingProcessBloc.updateShippingProcessCompleted(true);
            shippingProcessBloc.isUseCart == true
                ? Navigator.of(context).pop()
                : Navigator.of(context).pushNamed(Routes.CONFIRM_ORDER,
                    arguments: {'isSharedCart': false, 'sharedCartId': ''});
          },
          backgroundColor: navyBlue,
          textColor: white,
          text: 'Done',
        ),
      );
    }
    return Container();
  }

  Widget _buildShippingOptionSelected() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select Shipping Option",
              style: TextStyle(
                color: darkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            TextButton(
              onPressed: () {
                shippingProcessBloc.updateShippingOption(null);
              },
              child: Text(
                "Reset Option",
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        _buildShipping(),
        const SizedBox(
          height: 16,
        ),
        _buildInsurePackage(),
        const SizedBox(
          height: 16,
        ),
        _buildShippingNotes(),
      ],
    );
  }

  Widget _buildInsurePackage() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "Insure Package",
        style: TextStyle(
          color: navyBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
      trailing: CupertinoSwitch(
          value: shippingProcessBloc.getPackageDetailModel().getInSurePackage(),
          onChanged: (value) {
            shippingProcessBloc.getPackageDetailModel().insurePackage = value;
          },
          activeColor: const Color(0xff3F61DB) // Color when switch is ON
          ),
    );
  }

  Widget _buildShipping() {
    Widget logo;
    String? logoImage =
        shippingProcessBloc.getPackageDetailModel().getShippingLogo() ?? "";
    if ((logoImage.contains('http')) ||
        shippingProcessBloc.getPackageDetailModel().shippingType ==
            ShippingTypes.courier) {
      logo = Image.network(
        logoImage,
        width: 40,
        height: 40,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        cacheHeight: 40,
        cacheWidth: 40,
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
    } else {
      logo = Image.asset(
        logoImage,
        width: 40,
        height: 40,
        fit: BoxFit.fill,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          minVerticalPadding: 0,
          minLeadingWidth: 10,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity(horizontal: 0, vertical: 0),
          leading: logo,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shippingProcessBloc.getPackageDetailModel().shippingType ==
                        ShippingTypes.slydo
                    ? 'Slydo'
                    : shippingProcessBloc
                            .getPackageDetailModel()
                            .shippingOption
                            ?.name ??
                        "",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              Checkbox(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                checkColor: Colors.white,
                activeColor: navyBlue,
                value: true,
                shape: const CircleBorder(),
                onChanged: (bool? value) {},
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shippingProcessBloc.getPackageDetailModel().getDeliveryTime() ??
                    "",
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Text(
                "${worldCurrencies[shippingProcessBloc.getPackageDetailModel().shippingOption?.currency]}${moneyDisplayNormalizer(shippingProcessBloc.getPackageDetailModel().shippingOption?.price)}",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                "${shippingProcessBloc.getPackageDetailModel().merchantAddress?.toAddressString()} -➜ ${shippingProcessBloc.getPackageDetailModel().deliveryAddress?.toAddressString()}",
                style: TextStyle(
                  color: black,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
            ),
            SizedBox(width: 5.0),
            _buildTrackingTag(),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: greyBorderColor,
      ),
      child: Text(
        shippingProcessBloc.getPackageDetailModel().getDeliveryTag() ?? "",
        style: TextStyle(
          color: darkGrey,
          fontSize: 8,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildShippingNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Note",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        _buildNoteTextField(),
      ],
    );
  }

  Widget _buildNoteTextField() {
    return TextField(
      controller: userNoteController,
      maxLines: 5,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Border color
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: greyBorderColor, // Change the focus color here
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: white, // Background color
      ),
    );
  }
}
