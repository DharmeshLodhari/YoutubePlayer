import 'dart:convert';
import 'package:PayBay/data/state_notifier.dart';
import 'package:PayBay/models/user.dart';
import 'package:PayBay/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:http/http.dart' as http;

class QRCodeView extends StatefulWidget {
  const QRCodeView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              children: <Widget>[
                //Text("This is the result of scan: $qrText"),
                RaisedButton(
                  onPressed: () {
                    if (controller != null) {
                      controller.flipCamera();
                    }
                  },
                  child: Text('Flip', style: TextStyle(fontSize: 20)),
                )
              ],
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

  void _onQRViewCreated(QRViewController controller) {
    final PayeeBloc payeeBloc = Provider.of<PayeeBloc>(context);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // if we get a text that belongs to us then we process it
      if (scanData.startsWith(ums)) {
        var response = await http.get(scanData);
        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse != null) {
            Payee _payee = Payee(
              uuid: '', //jsonResponse['uuid'],
              url: "", //jsonResponse['url'],
              fullName: jsonResponse['full_name'],
              userName: jsonResponse['username'],
              avatar: jsonResponse['avatar']
                  .replaceAll("http://127.0.0.1:8080", ums),
              qrCode: jsonResponse['qrcode']
                  .replaceAll("http://127.0.0.1:8080", ums),
            );
            payeeBloc.payee = _payee;
            Navigator.of(context).pushNamed('/send-payment');
          }
        }
      }
    });
  }
}
