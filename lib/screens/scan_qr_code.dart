import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QRCodeView extends StatefulWidget {
  const QRCodeView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  final _auth = AuthService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//      automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[],
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                //overlayColor: Colors.transparent,
                borderRadius: 10,
                borderColor: Colors.red,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[getFlipButton()],
            ),
            flex: 1,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

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
          var customerProfile = await _auth.fetchCustomerProfile(recipient);
          setState(() {
            customerProfileBloc.customer = customerProfile;
          });
          Navigator.of(context).pushNamed('/send-payment');
        }
      }
    });
  }
}
