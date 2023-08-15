import 'dart:io';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_link/payment_link_cashout.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../data/currency.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../utils/util.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/dialog.dart';
import 'more_apps/shopping/shopping_auth.dart';
import 'more_apps/user_profile/user_auth.dart';

// ignore: must_be_immutable
class QRCodeView extends StatefulWidget {
  var arguments;

  QRCodeView({this.arguments, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState(arguments: arguments);
}

class _QRCodeViewState extends State<QRCodeView> {
  var arguments;
  late bool
      canShowDialogBox; // We need this variable to show the dialogbox just once cause qrscanner controller uses a stream(using a stream will make the dialogbox show up multiple times).
  _QRCodeViewState({this.arguments});

  bool? isRequest = false;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  AppConfigurationModel? appConfigurationModel;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController? controller;
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    canShowDialogBox = true;
    isRequest = arguments != null
        ? arguments['isRequest'] != null
            ? arguments['isRequest']
            : false
        : false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          qrCodeExpandedView(),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: <Widget>[],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: flipCameraExpandedView(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget flipCameraExpandedView() {
    return getFlipButton();
  }

  // Camera View of scanner
  Widget qrCodeExpandedView() {
    return QRView(
      key: qrKey,
      overlay: QrScannerOverlayShape(
        //overlayColor: Colors.transparent,
        borderRadius: 10,
        borderColor: navyBlue,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
      onQRViewCreated: _onQRViewCreated,
    );
  }

  // Flip the camera around
  Widget getFlipButton() {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(myGlobals.navigationKey.currentContext!)
                  .size
                  .width /
              2),
      child: CurvedButton(
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: AppLocalization.of(context)!.flip,
        onPressed: () async {
          if (controller != null) {
            controller!.flipCamera();
          }
        },
      ),
    );
  }

  // Scan qr code here and check on server then navigate to payment screen.
  void _onQRViewCreated(QRViewController controller) {
    customerProfileBloc =
        Provider.of<CustomerProfileBloc>(context, listen: false);
    userBloc = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      this.controller = controller;
      resumeCamara();
    });

    controller.scannedDataStream.listen((scanData) async {
      // if we get a text that belongs to us then we process it
      if (scanData != null) {

        if (scanData.code!.startsWith(AppConfig.baseUrl) ||
            scanData.code!.startsWith(AppConfig.baseUrl) ||
            scanData.code!.startsWith(AppConfig.merchantUrl) ||
            scanData.code!.startsWith("https://slydo.co") ||
            scanData.code!.startsWith(AppConfig.localHost)) {
          var scanDataList = scanData.code!.split('/');

          scanDataList.removeWhere((value) => value == "");
          if (canShowDialogBox) {
            controller.pauseCamera();
            getNavigationRoot(scanDataList, scanDataCode: scanData.code);
            controller.resumeCamera();
          }
          canShowDialogBox = false;
        }
      }
    });
  }

  void resumeCamara() {
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    // else if (Platform.isIOS) {
    //   controller!.resumeCamera();
    // }
    controller!.resumeCamera();
  }

  // TODO: Add try block here and check if error occurred in server like 404 then take user to home page and show error
  void getNavigationRoot(List<String> scanDataList,
      {String? scanDataCode}) async {
    List<String> cleanScanDataLink = scanDataList;
    int qrCodeIndex = scanDataList.length - 2;

    debugPrint('SCANNED DATA ::: $scanDataList');
    debugPrint('SCANNED DATA LAST ::: ${scanDataList.length}');

    cleanScanDataLink.removeWhere((item) => [""].contains(item));
    print('cleean...$cleanScanDataLink');

    if (cleanScanDataLink[2] == 'payment-link') {
      String paymentLinkId = cleanScanDataLink[3];

      final result = await NavigationUtil.push(context,
          screen: PaymentLinkCashout(
            id: paymentLinkId,
          ));
      // Handle the result here
      if (result != null) {
        if (result == 'back pressed') {
          canShowDialogBox = true;
          if (mounted) setState(() {});
        }
      }
    }

      else if (scanDataList[qrCodeIndex] == "products") {
      var productId = scanDataList.last;
      var product = getProduct(productId);

      _dashboardBloc.index = 0;

      final result = await Navigator.of(context)
          .pushNamed("/product", arguments: {"product": product});
      // Handle the result here
      if (result != null) {
        if (result == 'back pressed') {
          canShowDialogBox = true;
          if (mounted) setState(() {});
        }
      }
    } else if (scanDataList[qrCodeIndex] == "services") {
      var serviceId = scanDataList.last;
      var service = getService(serviceId);
      _dashboardBloc.index = 0;

      final result = await Navigator.of(context)
          .pushNamed(Routes.SERVICE_DETAIL, arguments: {"service": service});
      // Handle the result here
      if (result != null) {
        if (result == 'back pressed') {
          canShowDialogBox = true;
          if (mounted) setState(() {});
        }
      }
    } else if (scanDataList[qrCodeIndex - 1] == 'anonymous-shopping-cart') {
      try {
        ShoppingCartModelFromQrCode? shoppingCartModel =
            await ShoppingAuthService()
                .getShoppingCartDataFromQrCode(url: scanDataCode);

        if (shoppingCartModel != null) {
          showDialogBox(
            context: context,
            actionTwoText: 'Pay',
            actionOneText: 'Cancel',
            actionTwoTextColor: white,
            actionOneBgColor: greyBorderColor,
            actionTwoBgColor: navyBlue,
            leftButtonOnPressed: () {
              canShowDialogBox = true;
              _dashboardBloc.index = 0;
            },
            rightButtonOnPressed: () {
              if (appConfigurationModel?.enablePayment == true) {
                BottomSheetPassCode(
                    context: context,
                    isValidCallback: () async {
                      showDialog(
                          context: context,
                          builder: (dialogLoadingContext) =>
                              LoadingIndicator());

                      bool isPaid = await ShoppingAuthService()
                          .payForShoppingCart(cartId: shoppingCartModel.id);
                      if (isPaid) {
                        Navigator.pop(context);
                        _dashboardBloc.index = 0;
                        Navigator.pushNamed(context, Routes.ORDERS_LIST);
                        showToast(message: 'Paid successfully');
                      } else {
                        Navigator.pop(context);
                        showToast(message: 'Something went wrong');
                      }
                    },
                    cancelCallBack: () {
                      Navigator.pop(context);
                    });
              } else {
                showToast(message: 'Payment not available at the moment');
              }
            },
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: shoppingCartModel.merchantAvatar,
                            errorWidget: imageErrorWidget,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shoppingCartModel.merchantName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: blackFont,
                            ),
                          ),
                          Text(
                            'Merchant',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: greyBorderColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Order',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 16.0,
                            fontFamily: "roberto"),
                      ),
                      Text(
                        shoppingCartModel.status,
                        style: TextStyle(
                            color: blackFont,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping price',
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 16.0,
                            fontFamily: "roberto"),
                      ),
                      Row(
                        children: [
                          Text(
                            worldCurrencies[
                                    shoppingCartModel.merchantCurrency] ??
                                'NGN',
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            moneyDisplayNormalizer(
                                shoppingCartModel.shippingPrice),
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub total',
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 16.0,
                            fontFamily: "roberto"),
                      ),
                      Row(
                        children: [
                          Text(
                            worldCurrencies[
                                    shoppingCartModel.merchantCurrency] ??
                                'NGN',
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            moneyDisplayNormalizer(shoppingCartModel.subTotal),
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 2),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 16.0,
                            fontFamily: "roberto"),
                      ),
                      Row(
                        children: [
                          Text(
                            worldCurrencies[
                                    shoppingCartModel.merchantCurrency] ??
                                'NGN',
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Text(
                            moneyDisplayNormalizer(
                                shoppingCartModel.totalPrice),
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      } catch (e) {
        print('ERROR :: ${e.toString()}');
        showToast(message: 'Something went wrong, please try again.');
        canShowDialogBox = true;
        if (mounted) setState(() {});
      }
    }
    else {
      var recipient = scanDataList.last;
      getRecipient(recipient);

      print('RECIPIENT ::: $recipient');

      _dashboardBloc.index = 0;

      if (appConfigurationModel?.enablePayment == true) {
        if (isRequest!) {
          final result = await Navigator.of(context).pushNamed(
            Routes.REQUEST_PAYMENT,
            arguments: {
              'isRequest': true,
            },
          );
          // Handle the result here
          if (result != null) {
            if (result == 'back pressed') {
              canShowDialogBox = true;
              if (mounted) setState(() {});
            }
          }
        } else {
          final result = await Navigator.of(context).pushNamed(
            Routes.SEND_PAYMENT,
            arguments: {
              'isFromProfile': false,
            },
          );

          // Handle the result here
          if (result != null) {
            if (result == 'back pressed') {
              //make scanning of qr active
              canShowDialogBox = true;
              if (mounted) setState(() {});
            }
          }
        }
      } else {
        showToast(message: 'Payment not available at the moment');
        canShowDialogBox = true;
        if (mounted) setState(() {});
      }
    }
  }

  // Pull the user from the server
  void getRecipient(String recipient) async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfileWithAuth(recipient);
  }

  Product getProduct(String productId) {
    Product product = Product();
    product.id = productId;
    product.name = "";
    product.shortDescription = "";
    product.description = "";
    product.condition = "";
    product.currency = userBloc.user.currency;
    product.price = "0";
    product.availableFrom = DateTime.now();
    product.isAvailable = false;
    product.qrCode = "";
    product.seller = "";
    product.manufacturer = "";
    product.serverImages = [];
    return product;
  }

  Service getService(String serviceId) {
    Service service = Service();
    service.id = serviceId;
    service.name = "";
    service.description = "";
    service.shortDescription = "";
    service.price = "0";
    service.localImages = [];
    service.serverImages = [];
    service.provider = "";
    service.providerAvatar = "";
    service.qrCode = "";
    service.category = "";
    service.isAvailable = true;
    service.availableFrom = DateTime.now();
    service.currency = userBloc.user.currency;
    service.pictureMap = [];
    return service;
  }
}
