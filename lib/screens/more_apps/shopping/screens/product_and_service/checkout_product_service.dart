import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/user_address_product_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../../utils/slydo_app_icon_icons.dart';
import '../../../../../utils/util.dart';
import '../../../../../widget/curved_btn.dart';
import '../../../../../widget/dialog.dart';
import '../../../../../widget/loading_indicator.dart';
import '../../models/store.dart';
import '../../shopping_auth.dart';
import '../checkout_screen.dart';

class CheckoutProductService extends StatefulWidget {
  const CheckoutProductService({Key? key}) : super(key: key);

  @override
  State<CheckoutProductService> createState() => _CheckoutProductServiceState();
}

class _CheckoutProductServiceState extends State<CheckoutProductService> {
  String? deliveryOption;
  String? merchantFullName;
  String? merchantUsername;
  String? type;
  late BasketBloc basketBloc;
  List<String> merchantFullNames = [];
  String? selectedShippingOptionName;
  bool shippingOptionsLoading = false;
  ShippingOptionsModel? shippingOption;
  late CheckoutScreenBloc checkoutScreenBloc;
  List<ShippingOptionsModel> shippingOptions = [];
  Map<String, int?> userSelectedShippingOption = {};
  List<String> deliveryOptions = ['Pickup', 'Shipping/Delivery'];
  Map<dynamic, dynamic>? result = {};
  Product? product;
  Service? service;

  @override
  void initState() {
    super.initState();

    BasketBloc basketBloc = Provider.of<BasketBloc>(context, listen: false);
    basketBloc.orderTotalProductService = 0;
    basketBloc.totalShippingCost = 0;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    checkoutScreenBloc = Provider.of<CheckoutScreenBloc>(context);

    for (var item in basketBloc.productOrService) {
      // debugPrint('Fola product::: ${item}');

      result = item['results'];
      type = item['type'];

      merchantFullName = type == 'product'
          ? result!['seller_fullname']
          : result!['provider_fullname'];

      merchantUsername =
          type == 'product' ? result!['seller'] : result!['provider'];

      if (mounted) setState(() {});
    }
    return Scaffold(
      appBar: appBar(),
      body: _scaffoldBody(),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          basketBloc.productOrService.clear();
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Checkout',
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  _scaffoldBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping/Delivery Options',
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 14),
            dropDownPickItemWidget(
              label: 'Merchant',
              selectedItem: merchantFullName,
              onTap: () {},
            ),
            SizedBox(height: 18),
            Visibility(
              visible: merchantFullName != null,
              child: dropDownPickItemWidget(
                label: 'Shipping/Delivery',
                selectedItem: deliveryOption,
                onTap: () => pickDeliveryOptions(),
              ),
            ),
            SizedBox(height: 18),
            shippingOptionsLoading
                ? Center(child: CircularLoadingIndicator())
                : Visibility(
                    visible: shippingOptions.isNotEmpty,
                    child: dropDownPickItemWidget(
                      label: 'Shipping Options',
                      onTap: () => pickShippingOptions(),
                      selectedItem: selectedShippingOptionName,
                    ),
                  ),
            SizedBox(height: 18),
            Divider(thickness: 0.3, color: blackFont),
            Visibility(
              visible: merchantFullName != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 18,
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  priceRow(
                    title: 'Subtotal',
                    amount: moneyDisplayNormalizer(
                      getSubTotalPrice(),
                    ),
                  ),
                  priceRow(
                      title: 'Shipping Fee',
                      amount: deliveryOption == 'Pickup'
                          ? '0.00'
                          : shippingOption != null
                              ? moneyDisplayNormalizer(shippingOption!.price)
                              : '0.00'),
                  Divider(thickness: 0.3, color: blackFont),
                  priceRow(
                    title: 'Order total',
                    amount: moneyDisplayNormalizer(getOrderTotalPrice()),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            renderCurvedButton(),
          ],
        ),
      ),
    );
  }

  int getOrderTotalPrice() {
    int? totalPrice;

    Map<dynamic, dynamic>? variant = getVariantAsMap();

    if (deliveryOption == 'Pickup') {
      totalPrice = variant!['id'].isNotEmpty
          ? int.parse(variant['current_price'].toString())
          : int.tryParse(result!['price'])!;
    } else if (shippingOption != null) {
      totalPrice = variant!['id'].isNotEmpty
          ? int.parse(variant['current_price'].toString()) +
              shippingOption!.price
          : int.tryParse(result!['price'])! + shippingOption!.price;
    } else {
      totalPrice = variant!['id'].isNotEmpty
          ? int.parse(variant['current_price'].toString())
          : int.tryParse(result!['price'])!;
    }
    return totalPrice;
  }

  Map? getVariantAsMap() {
    Map<dynamic, dynamic>? variant = {};

    for (var product in basketBloc.productOrService) {
      // Access the 'key' in the outer map
      if (product.containsKey('results')) {
        var results = product['variant'];
        variant = results;
      }
    }
    return variant;
  }

  Map? getAddOnAsMap() {
    Map<dynamic, dynamic>? variant = {};

    for (var product in basketBloc.productOrService) {
      // Access the 'key' in the outer map
      if (product.containsKey('results')) {
        var results = product['add_ons'];
        variant = results;
      }
    }
    return variant;
  }

  getSubTotalPrice() {
    Map<dynamic, dynamic>? variant = getVariantAsMap();
    Map<dynamic, dynamic>? addOn = getAddOnAsMap();

    if (variant!['id'] != null && variant['id'].isNotEmpty) {
      return int.parse(variant['current_price'].toString());
    } else if (addOn!.isNotEmpty) {
      return int.parse(addOn['current_price'].toString());
    } else {
      return int.tryParse(result!['price']);
    }
  }

  Widget priceRow(
      {required String title,
      required String amount,
      TextStyle? amountTextStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                worldCurrencies['NGN']!,
                style: TextStyle(
                    color: blackFont,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              Text(
                amount,
                style: amountTextStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget renderCurvedButton() {
    if (basketBloc.merchantNameMapCopy.isEmpty) {
      return getCurvedButton();
    }
    if (deliveryOption == 'Shipping/Delivery') {
      if (!shippingOptionsLoading && shippingOptions.isEmpty) {
        return getCurvedButton();
      } else if (shippingOption != null) {
        return getCurvedButton();
      }
      return SizedBox.shrink();
    } else {
      if (merchantFullName != null &&
          deliveryOption != null &&
          deliveryOption != '') {
        return getCurvedButton();
      }
    }

    return SizedBox.shrink();
  }

  Widget getCurvedButton() {
    return CurvedButton(
      text: 'Next',
      onPressed: onNextClicked,
    );
  }

  onNextClicked() {
    if (shippingOption == null) {
      userSelectedShippingOption[merchantUsername!] = null;
    }

    basketBloc.orderTotalProductService += getOrderTotalPrice();
    basketBloc.totalShippingCost +=
        shippingOption != null ? shippingOption!.price : 0;

    basketBloc.userSelectedShippingOption = userSelectedShippingOption;
    NavigationUtil.pushReplacement(context,
        screen: UserAddressProductService(fromCheckoutScreen: true));
  }

  resetData() {
    deliveryOption = null;
    merchantFullName = null;
    shippingOptions.clear();
    selectedShippingOptionName = '';
    if (mounted) setState(() {});
  }

  pickDeliveryOptions() async {
    String? pickedDeliveryOption = await showPickItemDialog<String>(
      context: context,
      items: deliveryOptions,
      selectedItem: deliveryOption,
    );
    if (pickedDeliveryOption != null) {
      deliveryOption = pickedDeliveryOption;

      if (mounted) setState(() {});
      if (deliveryOption == 'Shipping/Delivery') {
        shippingOptionsLoading = true;
        if (mounted) setState(() {});

        ShoppingAuthService()
            .getShippingOptions(merchantName: merchantUsername!)
            .then(
          (value) {
            shippingOptionsLoading = false;
            if (mounted) setState(() {});

            debugPrint('VALUE :: $value');
            value.forEach((element) {
              // String shippingOption = element.name;
              // int shippingOptionAmount = element.price;
              // String currencySymbol = worldCurrencies[element.currency] ?? '';
              shippingOptions.add(element);
            });
          },
        ).catchError((error) {
          shippingOptionsLoading = false;
          if (mounted) setState(() {});
          showToast(message: error.toString());
        });
        if (mounted) setState(() {});
      } else {
        shippingOptions = [];
        if (mounted) setState(() {});
      }
    }
  }

  void selectCategory() async {}

  pickShippingOptions() async {
    ShippingOptionsModel? pickedShippingOption =
        await showDialog<ShippingOptionsModel>(
            context: context,
            builder: (context) => AlertDialog(
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.transparent,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SingleChildScrollView(
                          child: Column(
                            children:
                                shippingOptions.map<Widget>((mShippingOption) {
                              if (shippingOption?.id == mShippingOption.id) {
                                return Container(
                                  color: selectedListItemBackgroundBlue,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      mShippingOption.name,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    trailing: Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, mShippingOption);
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  mShippingOption.name,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                dense: true,
                                onTap: () {
                                  Navigator.pop(context, mShippingOption);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));

    if (pickedShippingOption != null) {
      shippingOption = pickedShippingOption;
      // userSelectedShippingOption.clear();
      selectedShippingOptionName = shippingOption?.name;
      userSelectedShippingOption[shippingOption!.owner] = shippingOption!.id;
      debugPrint('OWNER -> ${shippingOption!.owner}');
      debugPrint('OWNER ID -> ${shippingOption!.id}');
      debugPrint('USER OWNER  -> $userSelectedShippingOption');
      if (mounted) setState(() {});
    }
  }
}
