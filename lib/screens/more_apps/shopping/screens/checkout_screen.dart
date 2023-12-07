
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/user_address.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/currency.dart';
import '../../../../data/state_notifier.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/slydo_app_icon_icons.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? deliveryOption;
  String? merchantFullName;
  late BasketBloc basketBloc;
  List<String> merchantFullNames = [];
  String? selectedShippingOptionName;
  bool shippingOptionsLoading = false;
  ShippingOptionsModel? shippingOption;
  late CheckoutScreenBloc checkoutScreenBloc;
  List<ShippingOptionsModel> shippingOptions = [];
  Map<String, int?> userSelectedShippingOption = {};
  List<String> deliveryOptions = ['Pickup', 'Shipping/Delivery'];

  @override
  void initState() {
    super.initState();

    BasketBloc basketBloc = Provider.of<BasketBloc>(context, listen: false);
    basketBloc.merchantData.clear();
    basketBloc.getAllMerchant();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    checkoutScreenBloc = Provider.of<CheckoutScreenBloc>(context);

    basketBloc.merchantNameMapCopy.addAll(basketBloc.merchantNameMap);
    basketBloc.orderTotal = 0;
    basketBloc.totalShippingCost = 0;

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
              onTap: () => basketBloc.merchantNameMapCopy.isEmpty
                  ? null
                  : pickMerchantNames(),
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
                      amount: deliveryOption == 'Pickup' ||
                              shippingOptions.isEmpty
                          ? '0.00'
                          : shippingOption != null
                              ? moneyDisplayNormalizer(shippingOption!.price)
                              : '0.00'),
                  Divider(thickness: 0.3, color: blackFont),
                  priceRow(
                    title: 'Order total',
                    amount: deliveryOption == 'Pickup' ||
                            shippingOptions.isEmpty
                        ? moneyDisplayNormalizer(getSubTotalPrice())
                        : shippingOption != null && deliveryOption != 'Pickup'
                            ? moneyDisplayNormalizer(getOrderTotalPrice())
                            : moneyDisplayNormalizer(getSubTotalPrice()),
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
    return basketBloc.getTotalPriceByMerchant(
        merchantUserName: merchantFullName != null
            ? basketBloc.merchantNameMapCopy[merchantFullName!]!
            : '',
        shippingOptionPrice:
            shippingOption != null ? shippingOption!.price : 0);
  }

  getSubTotalPrice() {
    return basketBloc.getSubTotalPriceByMerchant(
        merchantUserName:
            basketBloc.merchantNameMapCopy[merchantFullName] ?? '');
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
    if (basketBloc.merchantData.isEmpty) {
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
    basketBloc.orderTotal += getOrderTotalPrice();
    basketBloc.totalShippingCost +=
        shippingOption != null ? shippingOption!.price : 0;

    if (basketBloc.merchantData.length == 1) {
      basketBloc.userSelectedShippingOption = userSelectedShippingOption;
      NavigationUtil.pushReplacement(context,
          screen: UserAddress(fromCheckoutScreen: true));
    } else {
      basketBloc.removeMerchant(merchantFullName!);
      if (mounted) setState(() {});
      resetData();
    }
  }

  resetData() {
    deliveryOption = null;
    merchantFullName = null;
    shippingOptions.clear();
    selectedShippingOptionName = '';
    if (mounted) setState(() {});
  }

  pickMerchantNames() async {
    merchantFullNames.clear();

    var allMerchants = basketBloc.merchantData;

    allMerchants.forEach((element) {
      merchantFullNames.add(element['name']!);
    });

    String? pickedMerchantName = await showPickItemDialog<String>(
      context: context,
      items: merchantFullNames,
      selectedItem: merchantFullName,
    );
    if (pickedMerchantName != null) {
      merchantFullName = pickedMerchantName;
      shippingOptions.clear();
      deliveryOption = '';
      shippingOptionsLoading = false;

      debugPrint(
          'NAME COPY::  ${basketBloc.merchantNameMapCopy[merchantFullName]}');
      debugPrint(
          'NAME ::: ${basketBloc.getSubTotalPriceByMerchant(merchantUserName: basketBloc.merchantNameMapCopy[merchantFullName] ?? '')}');
      if (mounted) setState(() {});
    }
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
            .getShippingOptions(
                merchantName: basketBloc.merchantNameMapCopy[merchantFullName]!)
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

class CheckoutScreenBloc extends ChangeNotifier {
  List<String> shippingOptionsList = [];

  set setShippingOptionsList(List<String> shippingOptions) {
    shippingOptionsList = shippingOptions;
    notifyListeners();
  }
}

class ShippingOptionsModel {
  int id;
  String currency;
  int price;
  String name;
  String owner;

  ShippingOptionsModel({
    required this.id,
    required this.currency,
    required this.price,
    required this.name,
    required this.owner,
  });

  factory ShippingOptionsModel.fromJson(Map<String, dynamic> json) {
    return ShippingOptionsModel(
      id: json['id'],
      currency: json['currency'],
      price: json['price'],
      name: json['name'],
      owner: json['owner'],
    );
  }

  //
  // {"id":50,
  // "currency":"NGN",
  // "price":800000,
  // "name":"USPS",
  // "owner":"abiola.rasheed.2",
  // "created_at":"2022-04-14T10:55:25.856426Z",
  // "updated_at":"2022-04-14T10:55:25.856448Z"}
}
