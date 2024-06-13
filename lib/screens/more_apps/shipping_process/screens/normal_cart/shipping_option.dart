import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ShippingOption extends StatefulWidget {
  const ShippingOption({super.key});

  @override
  State<ShippingOption> createState() => _ShippingOptionState();
}

class _ShippingOptionState extends State<ShippingOption> {
  bool isLoading = false;
  List<ShippingOptionModel> shippingList = [];

  ShippingOptionModel? shippingOptionModel;

  late ShippingProcessBloc shippingProcessBloc;
  late CustomerProfileBloc customerProfileBloc;
  String cartId = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        await getCartId();
        final ShippingProcessBloc shippingProcessBloc =
            Provider.of<ShippingProcessBloc>(context, listen: false);

        getShippingEstimation(shippingProcessBloc.getPackageDetailModel());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
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
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Shipping Option',
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
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: shippingList.isNotEmpty || shippingList.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        itemCount: shippingList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return _buildShippingItem(index);
                        },
                      ),
                    ),
                  ),
                  if (shippingOptionModel != null)
                    CurvedButton(
                      onPressed: () {
                        if (shippingOptionModel != null) {
                          shippingProcessBloc
                              .updateShippingOption(shippingOptionModel!);
                        }
                        Navigator.of(context).pop();
                      },
                      backgroundColor: navyBlue,
                      textColor: white,
                      text: 'Save',
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/no_moment_lottie.json'),
                    const SizedBox(height: 20),
                    const Text('No shippable items at the moment'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShippingItem(int index) {
    Widget logo;
    final String? logoImage =
        shippingProcessBloc.getPackageDetailModel().getShippingLogo();
    if ((logoImage?.contains('http') ?? false) ||
        shippingProcessBloc.getPackageDetailModel().shippingType ==
            ShippingTypes.courier) {
      logo = Image.network(
        shippingList[index].carrierLogo ?? "",
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
        logoImage!,
        width: 40,
        height: 40,
        fit: BoxFit.fill,
      );
    }
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      shadowColor: boxShadowTwo,
      color: white,
      child: Container(
        decoration: decorateBox(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
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
                      shippingProcessBloc
                                  .getPackageDetailModel()
                                  .shippingType ==
                              ShippingTypes.slydo
                          ? 'Slydo'
                          : shippingList[index].name ?? "",
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Radio<ShippingOptionModel>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: shippingList[index],
                      groupValue: shippingOptionModel,
                      onChanged: (value) {
                        shippingOptionModel = value;
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shippingProcessBloc
                              .getPackageDetailModel()
                              .getDeliveryTime() ??
                          "",
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      "${worldCurrencies[shippingList[index].currency]}${moneyDisplayNormalizer(shippingList[index].price)}",
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
                  const SizedBox(width: 5.0),
                  _buildTrackingTag(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: greyTagColor,
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

  Future<void> getShippingEstimation(
      PackageDetailsModel packageDetailModel) async {
    if (!isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      await ShippingProcessAuthService()
          .getShippingEstimation(packageDetailModel, cartId)
          .then(
        (value) {
          for (var element in value) {
            shippingList.add(element);
          }
          isLoading = false;
          if (mounted) setState(() {});
        },
      ).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: error.toString());
      });
    }
  }

  Future<void> getCartId() async {
    if (mounted) setState(() {});

    cartId = await ShippingProcessAuthService().getCartId();
  }
}
