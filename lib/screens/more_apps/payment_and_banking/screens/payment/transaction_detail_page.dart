import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class TransactionDetail extends StatefulWidget {
  final dynamic arguments;

  const TransactionDetail({super.key, required this.arguments});

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  Transaction? transaction;
  late CustomerProfileBloc customerProfileBloc;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    fetchTransaction();

    super.initState();
  }

  void fetchTransaction() async {
    final transactionFromArgs = widget.arguments['transaction'];
    if (transactionFromArgs is String) {
      transaction = await PaymentAndBankingAuth()
          .getRefundTransaction(transactionFromArgs);
    } else {
      transaction = transactionFromArgs;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
      centerTitle: false,
      title: Text(
        getAppLable(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        showMap(),
        const SizedBox(width: 16),
      ],
    );
  }

  String getAppLable() {
    if (transaction?.note?.contains("Refund") ?? true) {
      return "Refund Transaction";
    }
    return "Transaction";
  }

  Widget showMap() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: transaction?.latitude != "" ? goToMap : () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    if (transaction == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              displayTransactionInfo(),
              flexibleSpace(),
              buildButtons(),
            ],
          ),
        ),
      );
    }
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {
        if (transaction?.payee == "slydo_envelope" ||
            transaction?.payee == "slydo" ||
            transaction?.displayCustomer == "slydo" ||
            transaction?.displayCustomer == "slydo_envelope") {
          return;
        }
        if (!transaction!.isAnonymous!) {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": transaction!.payee});
        }
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      messageDecoderWithEmoji(transaction?.description) ?? "",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    String? text;
    if (transaction?.createdAt != null) {
      final DateTime transactionTime =
          DateTime.parse(transaction!.createdAt!).toLocal();
      final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
      final String time = DateFormat("hh:mm a").format(transactionTime);
      text = "$date • $time";
    }
    return Text(
      text ?? '',
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    return ClipOval(
        child: transaction?.isAnonymous ?? false
            ? Container(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  "assets/images/anonymous.png",
                  height: 48,
                  width: 48,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fitHeight,
                ),
              )
            : userImageUserInitialsPic(transaction?.avatar ?? "",
                transaction?.displayToCustomer ?? "", 25, 48));
  }

  Widget getSender() {
    return Text(
      messageDecoderWithEmoji(transaction?.displayCustomer) ?? "",
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[transaction?.currency] ?? "₦",
          style: TextStyle(
            color: transaction?.isCredit ?? false ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(transaction?.amount ?? 0),
          style: TextStyle(
              color: transaction?.isCredit ?? false ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget displayTransactionInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        decoration: decorateBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            displaySenderInfo(),
            displayBodyOfTransaction(),
          ],
        ),
      ),
    );
  }

  Widget displayBodyOfTransaction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(
          color: dividerColor,
          thickness: 1,
          height: 0,
        ),
        transactionOrPayoutTile(
            'assets/images/payout/status.svg',
            AppLocalization.of(context)!.status,
            transaction?.status ?? "",
            true),
        transactionOrPayoutTile(
            'assets/images/payout/category.svg',
            AppLocalization.of(context)!.category,
            transaction?.category ?? "",
            false),
        transactionOrPayoutTile(
            'assets/images/payout/note.svg',
            AppLocalization.of(context)!.note,
            getNoteAndDiscription(transaction?.note ?? ""),
            false,
            context: context),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.description,
            getNoteAndDiscription(transaction?.description ?? ""),
            false,
            context: context),
      ],
    );
  }

  String getNoteAndDiscription(String text) {
    text = messageDecoderWithEmoji(appendStringDot(text, 35)) ?? '---';
    return text;
  }

  Widget buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        children: [
          if (!transaction!.isCredit!)
            Expanded(
              child: OutlineCurvedButton(
                onPressed: () async {
                  if (appConfigurationModel?.enablePayment == true) {
                    customerProfileBloc.customer = await UserAuth()
                        .fetchCustomerProfile(transaction?.payee);
                    Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
                        arguments: <String, dynamic>{
                          'isFromProfile': false,
                          'transaction': transaction,
                          'showMoreOption': true,
                        });
                  } else {
                    showToast(message: 'Payment not available at the moment');
                  }
                },
                backgroundColor: white,
                textColor: navyBlue,
                text: "Send Again",
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: CurvedButton(
              onPressed: () async {
                // showSnackbar(context, message: "Coming soon");
                final pdfFile = await createPdf();
                await sharePdf(pdfFile);
              },
              backgroundColor: navyBlue,
              textColor: Colors.white,
              text: "Share Receipt",
            ),
          ),
        ],
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    MapsLauncher.launchCoordinates(double.parse(transaction!.latitude!),
        double.parse(transaction!.longitude!));
  }

  Future<File> createPdf() async {
    final pdf = pw.Document();

    final ByteData logoBytes = await rootBundle.load('assets/logo.png');
    final ByteData qrBytes = await rootBundle.load('assets/qr.png');

    final Uint8List logo = logoBytes.buffer.asUint8List();
    final Uint8List qr = qrBytes.buffer.asUint8List();

    final double amount = 100000.00;
    final String currency = "₦";
    final String status = "Successful";
    final String transactionType = "Slydo to Slydo";
    final String receiverUsername = "@prineygladhair";
    final String receiverAccountNumber = "542764367";
    final String senderUsername = "@gbemiglad";
    final String senderAccountNumber = "546789032";
    final String referenceNumber = "00065234179306328977635";
    final String category = "Shopping";
    final String description = "Hair";
    final DateTime transactionDate = DateTime(2024, 3, 28, 12, 6, 34);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logo),
                  height: 50,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Transaction Receipt",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  DateFormat('dd MMMM, yyyy, HH:mm:ss').format(transactionDate),
                  style: const pw.TextStyle(
                      fontSize: 16, color: PdfColors.grey700),
                ),
              ),
              pw.Divider(),
              buildPdfReceiptDetail(
                  "Amount", "$currency${amount.toStringAsFixed(2)}"),
              buildPdfReceiptDetail("Status", status),
              buildPdfReceiptDetail("Transaction Type", transactionType),
              buildPdfReceiptDetail("Receiver Details",
                  "$receiverUsername\n$receiverAccountNumber"),
              buildPdfReceiptDetail(
                  "Sender Details", "$senderUsername\n$senderAccountNumber"),
              buildPdfReceiptDetail("Reference Number", referenceNumber),
              buildPdfReceiptDetail("Category", category),
              buildPdfReceiptDetail("Description", description),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "Scan QR to download SLYDO APP",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(qr),
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Experience the convenience of Slydo...",
                  style: const pw.TextStyle(
                      fontSize: 14, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget buildPdfReceiptDetail(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.Flexible(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)],
          text: "Here is your receipt.");
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }
}
