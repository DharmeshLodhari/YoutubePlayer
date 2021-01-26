import 'dart:async';
import 'dart:convert';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:toast/toast.dart';

class NFCReaderService {
  // NFC.readNDEF returns a stream of NDEFMessage
  static Stream<NDEFMessage> _stream = NFC.readNDEF();

  static StreamSubscription<NDEFMessage> _streamSubscription;

  bool _supportsNFC = false;

  Future initialize() async {
    NFC.isNDEFSupported.then((bool isSupported) {
      debugPrint("===========> NFC SUPPORTED => $isSupported");
      if (isSupported) {
        _supportsNFC = isSupported;

        debugPrint("===========> NFC LISTENER INITIALIZED <===========");
        _streamSubscription = _stream?.listen((NDEFMessage message) {
          nfcMessageHandler(message: message);

          print("records: ${message.records.length}");
        });
      }
    });
  }

  void showAlertMessage(
      {Map<String, dynamic> data, BuildContext context}) async {
    debugPrint("NFC DATA:- $data");
    try {
      // show the notification in the dialog
      bool result = await showDialogBoxWithImage(
        context: context,
        actionOneBgColor: greyBorderColor,
        actionOneTextColor: blackFont,
        actionTwoBgColor: naturalGreen,
        actionTwoTextColor: Colors.white,
        firstActionPrimary: false,
        title: data['title'],
        description: data['body'],
        image: data['image'],
        actionOne: AppLocalization.of(context).cancel,
        actionTwo: "Pay",
      );
      if (result) {
        Navigator.pop(context);
        Toast.show("Payment Done!!", context);
      } else {
        Navigator.pop(context);
        Toast.show("Payment Cancel!!", context);
      }
    } catch (error) {
      debugPrint("Error:- " + error.toString());
    }
  }

  void nfcMessageHandler({NDEFMessage message}) {
    debugPrint("NFC Message ID: ${message.id}");
    debugPrint("NFC Message DATA:${message.data}");
    debugPrint("NFC Message PAYLOAD: ${message.payload}");
    debugPrint("NFC Message RECORDS: ${message.records}");
    debugPrint(
        "NFC Message FIRST RECORD PAYLOAD: ${message.records.first.payload}");
    debugPrint("NFC Message FIRST RECORD DATA: ${message.records.first.data}");

    /// json Payload which will be sent:-
    /// {
    ///         "title": "Payment Request",
    ///         "body": "Black is Requesting ₦100 for Your Order",
    ///         "image": "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/a7269ba398324ee4920b44bd3ebca14b.jpg"
    ///     }

    String messageData = message.payload;
    // String messageData = message.records.first.payload;

    Map<String, dynamic> data = jsonDecode(messageData);
    showAlertMessage(data: data, context: myGlobals.scaffoldKey.currentContext);
  }

  Future<void> closeReadingSubSubscription() async {
    return await _streamSubscription?.cancel();
  }
}
