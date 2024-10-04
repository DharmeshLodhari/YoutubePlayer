import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../utils/util.dart';

// ignore: must_be_immutable
class ScanProductQr extends StatefulWidget {
  const ScanProductQr({super.key});

  @override
  State<StatefulWidget> createState() => _ScanProductQrViewState();
}

class _ScanProductQrViewState extends State<ScanProductQr> {
  late bool canShowDialogBox;
  // We need this variable to show the dialogbox just once cause qrscanner controller uses a stream(using a stream will make the dialogbox show up multiple times).

  late UserBloc userBloc;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    canShowDialogBox = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar() {
    return AppBar(
      leading: _buildIcon(),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          padding: EdgeInsets.zero,
          iconSize: 30,
          icon: SvgPicture.asset(
            'assets/images/rider/flip_camera.svg',
            fit: BoxFit.cover,
          ),
          onPressed: () async {
            if (controller != null) {
              controller!.flipCamera();
            }
          },
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context, "back pressed");
      },
      icon: const Icon(
        Icons.keyboard_arrow_left,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        QRView(
          key: qrKey,
          overlay: QrScannerOverlayShape(
            overlayColor: Colors.black,
            borderRadius: 10,
            borderColor: navyBlue,
            borderLength: 0,
            borderWidth: 0,
            cutOutSize: 300,
          ),
          onQRViewCreated: _onQRViewCreated,
        ),
        _buildAppbar(),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 + 150,
          left: 0,
          right: 0,
          child: const Align(
            alignment: Alignment.center,
            child: Text(
              'Scan QR Code to Check Product Price',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ),
        ),
      ],
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
          final scanDataList = scanData.code!.split('/');

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
    final List<String> cleanScanDataLink = scanDataList;
    final int qrCodeIndex = scanDataList.length - 2;

    // debugPrint('SCANNED DATA ::: $scanDataList');
    // debugPrint('SCANNED DATA LAST ::: ${scanDataList.length}');

    cleanScanDataLink.removeWhere((item) => [""].contains(item));
    // debugPrint('cleean...$cleanScanDataLink');

    if (scanDataList[qrCodeIndex] == "products") {
      final productId = scanDataList.last;
      final product = getProduct(productId);

      final result = await Navigator.of(context)
          .pushNamed(Routes.PRODUCT_DETAIL_PAGE, arguments: {
        "product": product,
        "isUserNotLogIn": true,
      });
      // Handle the result here
      if (result != null) {
        if (result == 'back pressed') {
          canShowDialogBox = true;
          if (mounted) setState(() {});
        }
      }
    }
  }

  Product getProduct(String productId) {
    final Product product = Product();
    product.id = productId;
    product.name = "";
    product.shortDescription = "";
    product.description = "";
    product.condition = "";
    product.currency = userBloc.user.currency;
    product.price = 0;
    product.availableFrom = DateTime.now();
    product.isAvailable = false;
    product.qrCode = "";
    product.seller = "";
    product.manufacturer = "";
    product.serverImages = [];
    return product;
  }
}
