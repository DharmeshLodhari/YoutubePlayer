import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/country_picker_dialog.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryOption extends StatefulWidget {
  const DeliveryOption({
    super.key,
  });

  @override
  State<DeliveryOption> createState() => _DeliveryOptionState();
}

class _DeliveryOptionState extends State<DeliveryOption> {
  List<String?> deliveryOption = ["Shipping", "In Store/Eat In", "Pickup"];

  late ShippingProcessBloc shippingProcessBloc;
  late Country _selectedDialogCountry;
  TextEditingController userNoteController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  DateTime? selectedDateTime;
  String? dateText;
  bool isTimeAvailable = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (shippingProcessBloc.getPackageDetailModel().hasShippingAvailable() ==
          false) {
        deliveryOption.removeAt(0);
      }
    });
    _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
    selectedDateTime = DateTime.now();
    dateText = formatDate(selectedDateTime ?? DateTime.now());
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
          backgroundColor: lightGrey,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
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
                          ? _buildPickupAndEatInSelected()
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

  Widget _buildPickupAndEatInSelected() {
    return Column(
      children: [
        // _buildTableNo(),
        if (shippingProcessBloc.getPackageDetailModel().requireTableNo())
          CustomizedCheckBoxField(
            onTap: () {
              isTimeAvailable = !isTimeAvailable;
              setState(() {
                if (isTimeAvailable) {
                  selectedDateTime = DateTime.now();
                  dateText = formatDate(selectedDateTime ?? DateTime.now());
                } else {
                  selectedDateTime = null;
                  dateText = "";
                }
              });
            },
            isChecked: isTimeAvailable,
            title: "Schedule",
          ),
        if (isTimeAvailable ||
            shippingProcessBloc.getPackageDetailModel().requireTableNo() ==
                false)
          _buildEatInOptions()
        else
          const SizedBox(),
        _buildNote(),
      ],
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

  Widget shippingOptionalWid(
      {required BoxFit fit,
      required String icon,
      required String title,
      required String subTitle}) {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          leading: Image.asset(
            icon,
            height: 30,
            width: 35,
            fit: fit,
            frameBuilder: imageFrameBuilder,
          ),
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
        const SizedBox(
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
        const SizedBox(height: 5),
        _buildNoteTextField(),
      ],
    );
  }

  Future<void> pickDeliveryOptions() async {
    final String? pickedDeliveryOption = await showPickItemDialog<String>(
      context: context,
      items: deliveryOption,
      selectedItem:
          shippingProcessBloc.getPackageDetailModel().getDeliveryOption(),
    );
    if (pickedDeliveryOption != null) {
      shippingProcessBloc.updateDeliveryOption(pickedDeliveryOption,
          pickUpSelectCallBack: () {
        selectedDateTime = DateTime.now();
        dateText = formatDate(selectedDateTime ?? DateTime.now());
      });
    }
  }

  Future<void> dateOption() async {
    final String? pickedDeliveryOption = await showPickItemDialog<String>(
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
        if (shippingProcessBloc.getPackageDetailModel().hasSlydoDispatch ??
            false)
          GestureDetector(
            onTap: () async {
              if (shippingProcessBloc.getPackageDetailModel().deliveryAddress !=
                  null) {
                shippingProcessBloc
                    .updateShippingOptionType(ShippingTypes.slydo);
                await Navigator.of(context).pushNamed(Routes.SHIPPING_OPTION);
              } else {
                showToast(message: "Please select delivery address.");
              }
            },
            child: shippingOptionalWid(
              icon: "assets/images/app_logo_navyBlue.png",
              fit: BoxFit.fitHeight,
              title: "Ship with Slydo",
              subTitle: "Use slydo dispatch rider to get your orders.",
            ),
          ),
        if (shippingProcessBloc.getPackageDetailModel().hasMerchantDispatch ??
            false) ...[
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
            child: shippingOptionalWid(
              icon: "assets/images/bike_icon.png",
              fit: BoxFit.fitHeight,
              title: "Merchant Option",
              subTitle: "Use merchant rider to get your orders delivered",
            ),
          ),
        ],
        if (shippingProcessBloc.getPackageDetailModel().hasCourierDispatch ??
            false) ...[
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
            child: shippingOptionalWid(
              icon: "assets/images/bike_icon.png",
              fit: BoxFit.fill,
              title: "Ship with Courier",
              subTitle:
                  "Use courier service to get your order delivered to you.",
            ),
          ),
        ],
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
            shippingProcessBloc.getPackageDetailModel().updateDateTime(
                shippingProcessBloc.getPackageDetailModel().getDeliveryOption(),
                selectedDateTime);
            shippingProcessBloc.updateShippingProcessCompleted(true);
            shippingProcessBloc.isUseCart == true
                ? Navigator.of(context).pop()
                : Navigator.of(context).pushNamed(Routes.CONFIRM_ORDER,
                    arguments: {'isSharedCart': false, 'sharedCartId': ''});
          },
          backgroundColor: navyBlue,
          textColor: white,
          text: 'Continue',
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
    final String logoImage =
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
          visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
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
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
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
              // Text(
              //   "${worldCurrencies[shippingProcessBloc.getPackageDetailModel().shippingOption?.currency]}${moneyDisplayNormalizer(shippingProcessBloc.getPackageDetailModel().shippingOption?.price)}",
              //   style: TextStyle(
              //     color: blackFont,
              //     fontSize: 14,
              //     fontWeight: FontWeight.w700,
              //     fontFamily: "Inter",
              //   ),
              // ),
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
            const SizedBox(width: 5.0),
            _buildTrackingTag(),
          ],
        ),
      ],
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

  Widget _buildPhoneNumberWidget(
      {required String? selectedItem, required Function onTap, String? label}) {
    return phoneNumberField();
  }

  Widget phoneNumberField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: getCountryDropdown()),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 5,
          child: CustomizedTextFormField(
            labelColor: darkGrey,
            keyboardType: TextInputType.phone,
            hintText: "3387710700",
            controller: phoneNumberController,
            validator: (val) {
              if (val.isNotEmpty && val.length >= 9) {
                return null;
              }
              return AppLocalization.of(context)!.invalidPhoneNumber;
            },
          ),
        ),
      ],
    );
  }

  Widget getCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Phone number",
          style: TextStyle(
            color: darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          color: whiteBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            onTap: () {
              _openCountryPickerDialog(isForLogin: true);
            },
            title: _buildDialogItem(_selectedDialogCountry),
          ),
        ),
      ],
    );
  }

  void _openCountryPickerDialog({bool isForLogin = false}) => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: navyBlue),
          child: CountryPickerDialog(
            isForLogin: isForLogin,
            titlePadding: const EdgeInsets.all(8.0),
            searchCursorColor: navyBlue,
            searchInputDecoration: InputDecoration(
              hintText: AppLocalization.of(context)!.search,
              hintStyle: TextStyle(
                fontSize: 16,
                color: darkGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            isSearchable: true,
            title: Text(
              AppLocalization.of(context)?.selectYourPhoneCode ?? "",
              style: TextStyle(
                fontSize: 14,
                color: blackFont,
                fontWeight: FontWeight.w400,
              ),
            ),
            onValuePicked: (country) =>
                setState(() => _selectedDialogCountry = country),
            itemBuilder: _buildDialogItemWithName,
          ),
        ),
      );
  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 4.0),
        CountryPickerUtils.getDefaultFlagImage(country),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            "+${country.phoneCode}",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          color: blackFont,
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildDialogItemWithName(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        const SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            "(${country.name})",
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEatInOptions() {
    return Column(
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            _buildDate(),
            const SizedBox(height: 16),
            _buildTime(),
            const SizedBox(height: 16),
            _buildPhoneNumberWidget(
              label: 'Phone number',
              selectedItem: shippingProcessBloc
                  .getPackageDetailModel()
                  .getDeliveryOption(),
              onTap: () => dateOption(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildDate() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        ).then((value) {
          if (value != null) {
            setState(() {
              selectedDateTime = DateTime(value.year, value.month, value.day,
                  selectedDateTime?.hour ?? 0, selectedDateTime?.minute ?? 0);
              dateText = formatDate(selectedDateTime!);
            });
          }
        }).catchError((error) {
          print('Error: $error'); // Debug print
        });
      },
      child: CustomizedDropDownField(
        title: "Date",
        child: ListTile(
          dense: true,
          title: Text(
            dateText ?? "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            SlydoAppIcon.date,
            size: 16,
            color: black,
          ),
        ),
      ),
    );
  }

  Widget _buildTime() {
    return GestureDetector(
      onTap: () {
        showTimePicker(
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true, // Forces 24-hour format
              ),
              child: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary:
                        navyBlue, // Sets the color for the time picker clock
                    onSurface:
                        Colors.black, // Sets the color for the time numbers
                  ),
                ),
                child: child!,
              ),
            );
          },
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((time) {
          if (time != null) {
            setState(() {
              if (selectedDateTime != null) {
                selectedDateTime = DateTime(
                  selectedDateTime!.year,
                  selectedDateTime!.month,
                  selectedDateTime!.day,
                  time.hour,
                  time.minute,
                );
              } else {
                selectedDateTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  time.hour,
                  time.minute,
                );
              }
            });
            print("======>$selectedDateTime");
          }
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Time",
        child: ListTile(
          dense: true,
          title: Text(
            (selectedDateTime) != null && !isMidnight(selectedDateTime!)
                ? formatTime24hrs(
                    selectedDateTime?.add(const Duration(hours: 1)))
                : "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(
            Icons.access_time,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTableNo() {
    return Column(
      children: [
        _buildTableNoTextField(),
        const SizedBox(height: 15),
        CustomizedCheckBoxField(
          onTap: () {
            isTimeAvailable = !isTimeAvailable;
            setState(() {});
          },
          isChecked: isTimeAvailable,
          title: "Schedule",
        ),
      ],
    );
  }

  Widget _buildTableNoTextField() {
    return CustomizedTextFormField(
      labelText: "Table No(Optional)",
      // initialValue: discountModel.value?.toString(),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        if (int.tryParse(val) == null) {
          return "Invalid value";
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        // discountModel.value = int.tryParse(val);
      },
    );
  }
}
