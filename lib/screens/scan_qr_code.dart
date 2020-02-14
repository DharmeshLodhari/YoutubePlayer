import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QRCodeView extends StatefulWidget {
  var arguments;
//  const QRCodeView({
//    Key key,
//  }) : super(key: key);

  QRCodeView({this.arguments, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState(arguments: arguments);
}

class _QRCodeViewState extends State<QRCodeView> {
  var arguments;
  _QRCodeViewState({this.arguments});

  bool isRequest = false;

  final _auth = AuthService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    isRequest = arguments != null ? arguments['isRequest'] : false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Platform.isAndroid ? false : true,
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
    return Expanded(child: Column(children: <Widget>[getFlipButton()]), flex: 1);
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
          borderColor: lightBlue(),
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
      child: Text('Flip', style: TextStyle(fontSize: 20)),
    );
  }

  // Scan qr code here and check on server then navigate to payment screen.
  void _onQRViewCreated(QRViewController controller) {
    final CustomerProfileBloc customerProfileBloc =
        Provider.of<CustomerProfileBloc>(context, listen: false);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      //if we get a text that belongs to us then we process it
      if (scanData != null) {
        if (scanData.startsWith(baseUrl) || scanData.startsWith(localHostUrl)) {
          var scanDataList = scanData.split('/');
          scanDataList.removeWhere((value) => value == "");
          var recipient = scanDataList.last;

          // Pull the user from the server
          // TODO: Add try block here and check if error occurred in server like 404 then take user to home page and show error
          customerProfileBloc.customer = await _auth.fetchCustomerProfile(recipient);
          Navigator.pop(context);
          print(isRequest);
          if (isRequest) {
            Navigator.of(context).pushNamed('/request-payment', arguments: {'isRequest': true});
          } else {
            Navigator.of(context)
                .pushNamed('/send-payment', arguments: <String, bool>{'isFromProfile': false});
          }
        }
      }
    });
  }
}
