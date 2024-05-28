import 'dart:typed_data';

import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PrintQRCode extends StatefulWidget {
  var arguments;

  PrintQRCode({required this.arguments});

  @override
  _PrintQRCodeState createState() => _PrintQRCodeState();
}

class _PrintQRCodeState extends State<PrintQRCode> {
  String? imageUrl;
  String? itemName;

  @override
  void initState() {
    imageUrl = widget.arguments["imageUrl"];
    itemName = widget.arguments["itemName"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: whiteBackground,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: navyBlue,
                size: 24,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Theme(
                data: ThemeData(
                  primaryColor: navyBlue,
                ),
                child: PdfPreview(
                  pdfPreviewPageDecoration:
                      BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: boxShadowTwo,
                        offset: const Offset(2, 2),
                        blurRadius: 5,
                        spreadRadius: 5)
                  ]),
                  scrollViewDecoration: BoxDecoration(color: whiteBackground),
                  build: (format) => _generatePdf(format, itemName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TODO:Change the pdf library
  Future<Uint8List> _generatePdf(PdfPageFormat format, String? title) async {
    // final pdf = pw.Document(title: itemName);

    final pw.Document doc = pw.Document(title: itemName);
    // // ignore: deprecated_member_use

    // final image = await imageFromAssetBundle('assets/image.png');

    final imageProvider = await networkImage(imageUrl!);

    // final file = await getFileFromNetworkImage("<your network image Url here>");
    //
    // im.Image imageNew = im.Image.fromBytes(100,100,await file.readAsBytes());
    // final PdfImage image = await PdfImage.fromImage(doc.document, image: imageNew);

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(imageProvider),
          ); // Center
        },
      ),
    ); // Page
    //
    // PdfImage image = PdfImage.fromImage(pdf.document, image: im.Image());
    //
    // pdf.addPage(
    //   pw.Page(build: (pw.Context context) {
    //     return pw.Container(
    //       // ignore: deprecated_member_use
    //       child: pw.Image(image.),
    //     ); // Center
    //   }),
    // );
    return doc.save();
  }
}
