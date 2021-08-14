import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'more_apps/user_profile/user_auth.dart';

// ignore: must_be_immutable
class QRCodeView extends StatefulWidget {
  var arguments;

  QRCodeView({this.arguments, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState(arguments: arguments);
}

class _QRCodeViewState extends State<QRCodeView> {
  var arguments;

  _QRCodeViewState({this.arguments});

  bool isRequest = false;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  void initState() {
    isRequest = arguments != null
        ? arguments['isRequest'] != null
            ? arguments['isRequest']
            : false
        : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[],
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          qrCodeExpandedView(),
          flipCameraExpandedView(),
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
    return Expanded(
        child: Column(children: <Widget>[getFlipButton()]), flex: 1);
  }

  // Camera View of scanner
  Widget qrCodeExpandedView() {
    return Expanded(
      flex: 5,
      child: QRView(
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
      ),
    );
  }

  // Flip the camera around
  Widget getFlipButton() {
    return RaisedButton(
      onPressed: () async {
        if (controller != null) {
          controller.flipCamera();
        }
      },
      child: Text(AppLocalization.of(context).flip,
          style: TextStyle(fontSize: 20)),
    );
  }

  // Scan qr code here and check on server then navigate to payment screen.
  void _onQRViewCreated(QRViewController controller) {
    customerProfileBloc =
        Provider.of<CustomerProfileBloc>(context, listen: false);
    userBloc = Provider.of<UserBloc>(context, listen: false);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      //if we get a text that belongs to us then we process it
      if (scanData != null) {
        if (scanData.startsWith(secureBaseUrl) ||
            scanData.startsWith(secureBaseUrl) ||
            scanData.startsWith(localHostUrl)) {
          var scanDataList = scanData.split('/');
          scanDataList.removeWhere((value) => value == "");
          getNavigationRoot(scanDataList);
        }
      }
    });
  }

  // TODO: Add try block here and check if error occurred in server like 404 then take user to home page and show error
  void getNavigationRoot(List<String> scanDataList) async {
    debugPrint("test: " + scanDataList[scanDataList.length - 2]);
    if (scanDataList[scanDataList.length - 2] == "products") {
      var productId = scanDataList.last;
      var product = getProduct(productId);

      Navigator.pop(context);
      Navigator.of(context)
          .pushNamed("/product", arguments: {"product": product});
    } else if (scanDataList[scanDataList.length - 2] == "services") {
      var serviceId = scanDataList.last;
      var service = getService(serviceId);
      Navigator.pop(context);
      Navigator.of(context)
          .pushNamed("/service-detail", arguments: {"service": service});
    } else {
      var recipient = scanDataList.last;
      getRecipient(recipient);

      Navigator.pop(context);
      if (isRequest) {
        Navigator.of(context).pushNamed(
          '/request-payment',
          arguments: {
            'isRequest': true,
          },
        );
      } else {
        Navigator.of(context).pushNamed(
          '/send-payment',
          arguments: {
            'isFromProfile': false,
          },
        );
      }
    }
  }

  // Pull the user from the server
  void getRecipient(String recipient) async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(recipient);
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
