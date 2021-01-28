import 'dart:async';
import 'dart:convert';

import 'package:Slydo/services/nfc_reader_service.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:toast/toast.dart';

class NfcWriter extends StatefulWidget {
  @override
  _NfcWriterState createState() => _NfcWriterState();
}

class _NfcWriterState extends State<NfcWriter> {
  bool _writing = false;
  bool _supportsNFC = false;
  StreamSubscription<NDEFMessage> _stream;

  List<String> messageList = [];

  Map<String, dynamic> _data = {
    "title": "Payment Request",
    "body": "Black is Requesting ₦100 for Your Order.",
    "image":
        "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/a7269ba398324ee4920b44bd3ebca14b.jpg"
  };

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if the device supports NFC reading
    NFC.isNDEFSupported.then((bool isSupported) {
      _supportsNFC = isSupported;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar(),
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
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
        "NFC Writer",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return _supportsNFC
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: nfcActions()),
              Expanded(child: nfcOutputs()),
            ],
          )
        : Center(
            child: RaisedButton(
              child: const Text("You device does not support NFC"),
              onPressed: () {
                Toast.show("NFC NOT SUPPORTED!!", context);
              },
            ),
          );
  }

  Widget nfcActions() {
    return Container(
      child: Column(
        children: [
          Center(child: Text("Data To be Written:- \n $_data")),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                  child: Text("Start Writing"),
                  onPressed: () async {
                    if (_supportsNFC) {
                      await NFCReaderService().closeReadingSubSubscription();

                      if (_writing) {
                        _stream?.cancel();

                        _writing = false;
                        setState(() {});
                      }
                      _writing = true;
                      setState(() {});
                      Toast.show("NFC WRITING STARTED", context);

                      Stream<NDEFMessage> stream = NFC.readNDEF();

                      // Start writing using NFC.readNDEF()
                      _stream = stream.listen((NDEFMessage message) {
                        NDEFMessage newMessage = NDEFMessage.withRecords([
                          NDEFRecord.text(jsonEncode(_data)),
                        ]);
                        message.tag.write(newMessage);
                        messageList.add("NFC WRITTEN Successfully !!!");
                      });
                    } else {
                      Toast.show("NFC NOT SUPPORTED!!", context);
                    }
                  }),
              RaisedButton(
                  child: Text("Stop Writing"),
                  onPressed: () {
                    if (_supportsNFC) {
                      if (_writing) {
                        _stream?.cancel();

                        _writing = false;
                        setState(() {});
                      }
                    } else {
                      Toast.show("NFC NOT SUPPORTED!!", context);
                    }
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                  child: Text("Start Reading"),
                  onPressed: () async {
                    await NFCReaderService().initialize();
                  }),
              RaisedButton(
                  child: Text("Stop Reading"),
                  onPressed: () async {
                    await NFCReaderService().closeReadingSubSubscription();
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget nfcOutputs() {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(
            messageList[index],
            style: TextStyle(fontSize: 18),
          ),
          dense: true,
        ),
        itemCount: messageList.length,
      ),
    );
  }
}
