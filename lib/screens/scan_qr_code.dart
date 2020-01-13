import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/services/auth.dart';
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
    final PayeeBloc payeeBloc = Provider.of<PayeeBloc>(context);
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      appBar: AppBar(
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
              children: <Widget>[
                //Text("This is the result of scan: $qrText"),
                RaisedButton(
                  onPressed: () async {
                    if (controller != null) {
                      controller.flipCamera();
                      String url = ums + "/api/v1/customer/alex.rasheed.2";

                      if (url.startsWith(ums)) {
                        Map<String, dynamic> jsonResponse = {
                          'full_name': 'Alex Rasheed',
                          'uuid': '',
                          'url':
                              'http://192.168.1.5:8080/media/customer/avatar/me_9c9uSF2.jpeg',
                          'username': 'alex.rasheed.2',
                          'avatar':
                              'http://192.168.1.5:8080/media/customer/avatar/me_rWdkxLb.jpeg',
                          'qr_code':
                              'http://192.168.1.5:8080/media/customer/qr-code/2b439ab4d0b343aab8360d6e38f6e83a.png'
                        };
                        Payee _payee = Payee(
                          uuid: jsonResponse['uuid'],
                          url: jsonResponse['url'],
                          fullName: jsonResponse['full_name'],
                          userName: jsonResponse['username'],
                          avatar: jsonResponse['avatar'],
                          qrCode: jsonResponse['qr_code'],
                        );
                        payeeBloc.payee = _payee;
                        Navigator.of(context).pushNamed('/send-payment');
                      }
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
    //final PayeeBloc payeeBloc = Provider.of<PayeeBloc>(context);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // if we get a text that belongs to us then we process it
//      if (scanData.startsWith(ums)) {
//        var response = await http.get(scanData);
//        if (response.statusCode == 200) {
//          var jsonResponse = json.decode(response.body);
//          if (jsonResponse != null) {
//            Payee _payee = Payee(
//              uuid: '', //jsonResponse['uuid'],
//              url: "", //jsonResponse['url'],
//              fullName: jsonResponse['full_name'],
//              userName: jsonResponse['username'],
//              avatar: jsonResponse['avatar']
//                  .replaceAll("http://127.0.0.1:8080", ums),
//              qrCode: jsonResponse['qrcode']
//                  .replaceAll("http://127.0.0.1:8080", ums),
//            );
//            payeeBloc.payee = _payee;
//            Navigator.of(context).pushNamed('/send-payment');
//          }
//        }
//      }
    });
  }
}
