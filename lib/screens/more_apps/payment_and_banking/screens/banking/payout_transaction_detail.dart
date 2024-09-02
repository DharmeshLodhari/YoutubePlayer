import 'dart:io';
import 'dart:ui' as ui;

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/virtual_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../utils/global_key.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../models/payout.dart';

class PayoutTransactionDetail extends StatefulWidget {
  final dynamic arguments;

  const PayoutTransactionDetail({super.key, required this.arguments});

  @override
  State<PayoutTransactionDetail> createState() =>
      _PayoutTransactionDetailState();
}

class _PayoutTransactionDetailState extends State<PayoutTransactionDetail> {
  late Map<String, dynamic> arguments;
  Payout? payout;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  VirtualAccount? virtualAccount;
  String accountNumber = "";
  String bankName = "";
  String accountName = "";

  @override
  void initState() {
    arguments = widget.arguments;
    fetchPayout();
    getSlydoAccount();
    super.initState();
  }

  void fetchPayout() async {
    final transactionFromArgs = widget.arguments['transaction'];
    if (transactionFromArgs is String) {
      payout = await PaymentAndBankingAuth()
          .getSingleBankTransaction(transactionFromArgs);
    } else {
      payout = transactionFromArgs;
    }
    if (mounted) setState(() {});
  }

  void getSlydoAccount() async {
    isLoading = true;
    setState(() {});
    bool isFromServer = false;

    virtualAccount = await DatabaseHelper().getVirtualAccount();

    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
      isFromServer = true;
    }

    isLoading = false;

    if (virtualAccount != null) {
      if (isFromServer) {
        await DatabaseHelper().saveVirtualAccount(virtualAccount!);
      }
    }

    accountNumber = virtualAccount?.accountNumber ?? "";
    bankName = virtualAccount?.financialInstitution?.name ?? "";
    accountName = virtualAccount?.accountName ?? "";

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: appBar() as PreferredSizeWidget?,
          // body: scaffoldBody(),
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: scaffoldBody()),
        ),
      ),
    );
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      payout = null;

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          fetchPayout();
        }
      });

      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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
        AppLocalization.of(context)!.bankPayout,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        showMap(),
        const SizedBox(width: 16),
      ],
    );
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
      // onTap: transaction!.latitude != "" ? goToMap : () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            displayPayoutInfo(),
            flexibleSpace(),
            buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        children: [
          Expanded(
            child: OutlineCurvedButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  Routes.SEND_PAYMENT,
                  arguments: <String, dynamic>{
                    'isFromCashOut': true,
                    'payout': payout,
                  },
                );
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

  Future<void> sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)],
          text: "Here is your receipt.");
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  Future<File> createPdf() async {
    final pdf = pw.Document();
    final customFont = await loadCustomFont();

    // Load the logo image
    final ByteData logoBytes =
        await rootBundle.load('assets/images/app_logo_navyBlue.png');
    final Uint8List logo = logoBytes.buffer.asUint8List();

    // Load the background image
    final ByteData backgroundBytes =
        await rootBundle.load('assets/images/receipt_bg_image.png');
    final Uint8List backgroundImage = backgroundBytes.buffer.asUint8List();

    // Other variables
    final String currency = worldCurrencies[payout?.currency] ?? "";
    final String? status = payout?.status;
    const String transactionType = "Bank Transfer";
    final String receiverUsername = "${payout?.accountName}";
    final String receiverAccountNumber =
        "${payout?.bankName} | ${payout?.accountNumber}";
    final String senderUsername = "${payout?.customerUsername}";
    final String senderAccountNumber = "$bankName | $accountNumber";
    final String receivingBank = "${payout?.bankName}";
    final String referenceNumber = "${payout?.referenceNumber}";
    final String category = "${payout?.category}";
    final String description = "${payout?.description}";

    final Uint8List qrCodeImage =
        await _generateQRCodeImage(getTransactionUrl());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(backgroundImage),
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAppTitle(logo),
                      _buildTransactionReceiptText(),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  _buildDate(),
                  pw.SizedBox(height: 20),
                  _buildPDFAmountIconText("Amount", customFont, currency),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Status", value: status ?? "", isColor: true),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Transaction Type",
                      value: transactionType,
                      isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Receiver Details",
                      value: receiverUsername,
                      subTitle: receiverAccountNumber,
                      isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Sender Details",
                      value: senderUsername,
                      subTitle: senderAccountNumber,
                      isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Receiving Bank",
                      value: receivingBank,
                      isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Reference Number",
                      value: referenceNumber,
                      isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Category", value: category, isColor: false),
                  pw.SizedBox(height: 8),
                  buildPdfReceiptDetail(
                      title: "Description", value: description, isColor: false),
                  pw.SizedBox(height: 5),
                  pw.Spacer(),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: buildPdfHorizontalDotBorder(),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: _buildPdfQrScan(qrCodeImage),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: _buildDescription(),
                  ),
                ],
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

  pw.Widget buildPdfReceiptDetail(
      {String? title, String? subTitle, String? value, bool? isColor}) {
    String? status = "";
    if (payout!.status! == 'Paid' || payout!.status! == 'Settled') {
      status = 'done';
    } else if (payout!.status! == 'Pending') {
      status = 'processing';
    } else if (payout!.status! == 'Cancelled') {
      status = 'cancel';
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title ?? "",
            style: const pw.TextStyle(
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                value ?? "",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.normal,
                  color: isColor == true
                      ? checkStatusTextPdfColor(status)
                      : PdfColors.black,
                ),
                textAlign: pw.TextAlign.right,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                subTitle ?? "",
                style: const pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget buildPdfHorizontalDotBorder() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 15),
      child: pw.Row(
        children: List.generate(48, (_) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 1),
            child: pw.Container(
              width: 8,
              height: 1,
              color: PdfColor.fromHex("#324EAF"),
            ),
          );
        }),
      ),
    );
  }

  pw.Widget _buildPDFAmountIconText(String text, pw.Font customFont, currency) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            font: customFont,
            color: PdfColors.black,
          ),
        ),
        pw.Text(
          "$currency${moneyDisplayNormalizer(payout?.amount)}",
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.normal,
            fontSize: 30,
            color: PdfColor.fromHex("#324EAF"),
            font: customFont,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAppTitle(Uint8List logo) {
    return pw.Row(
      children: [
        pw.Center(
          child: pw.Image(
            pw.MemoryImage(logo),
            height: 30,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          'Slydo',
          style: pw.TextStyle(
            fontSize: 24.0,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex("#324EAF"),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTransactionReceiptText() {
    return pw.Center(
      child: pw.Text(
        "Transaction Receipt",
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildDate() {
    String? formattedDate;
    try {
      final DateTime? dateTime =
          DateTime.tryParse(payout?.timeStamp ?? "")?.toLocal();
      final DateFormat dateFormat = DateFormat("MMMM dd, yyyy, h:mm:ss");
      dateTime != null ? formattedDate = dateFormat.format(dateTime) : "";
    } catch (e) {
      print("Error parsing date: $e");
      formattedDate = "";
    }
    return pw.Text(
      "$formattedDate",
      style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.normal,
          color: PdfColors.black),
    );
  }

  Future<pw.Font> loadCustomFont() async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    return pw.Font.ttf(ByteData.sublistView(fontData.buffer.asUint8List()));
  }

  pw.Widget _buildPdfQrScan(Uint8List qrCodeImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: "Scan QR to download ",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.black,
                ),
              ),
              pw.WidgetSpan(
                child: pw.SizedBox(width: 5),
              ),
              pw.TextSpan(
                text: "SLYDO APP",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#324EAF"),
                ),
              ),
            ],
          ),
        ),
        pw.Image(
          pw.MemoryImage(qrCodeImage),
          height: 80,
          width: 80,
        ),
      ],
    );
  }

  pw.Widget _buildDescription() {
    return pw.Center(
      child: pw.Text(
        "Experience the convenience of Slydo, your all-in-one Super App. Send and receive money, make payments, buy & sell as a merchant and effortlessly share your daily moments & thoughts. Download Slydo now and simplify your business, financial & social interactions.",
        style: pw.TextStyle(
          fontSize: 14,
          color: PdfColors.grey700,
          fontWeight: pw.FontWeight.normal,
        ),
      ),
    );
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {},
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      "${payout!.description}",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    String date = "";
    String time = "";
    if (payout?.timeStamp != null) {
      final DateTime transactionTime =
          DateTime.parse(payout!.timeStamp!).toLocal();
      date = DateFormat("dd/MM/yyyy").format(transactionTime);
      time = DateFormat("hh:mm a").format(transactionTime);
    }
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    final String? url = payout?.bankLogo;

    final String imageUrl = url?.replaceAll('https//', 'https://') ?? "";

    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(payout?.bankName ?? "").toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return ClipOval(
        child: GestureDetector(
          onTap: () {
            Navigator.of(myGlobals.navigationKey.currentContext!)
                .pushNamed("/photo-viewer", arguments: imageUrl);
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            errorWidget: imageErrorWidget,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => imageUrl == ""
                ? const Icon(Icons.person)
                : CircularLoadingIndicator(),
          ),
        ),
      );
    }
  }

  Widget getSender() {
    return Text(
      appendStringDot(payout?.bankName ?? "", 20),
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
          worldCurrencies[payout?.currency] ?? "NGN",
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(payout?.amount.toString() ?? "0")),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget displayPayoutInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            displaySenderInfo(),
            displayBodyOfPayout(),
          ],
        ),
      ),
    );
  }

  Widget displayBodyOfPayout() {
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
          payout?.status ?? "",
          true,
        ),
        transactionOrPayoutTile(
          'assets/images/payout/account_name.svg',
          AppLocalization.of(context)!.accountNameHint,
          payout?.accountName ?? "",
          false,
        ),
        transactionOrPayoutTile(
            'assets/images/payout/account_number.svg',
            AppLocalization.of(context)!.accountNumberHint,
            payout?.accountNumber ?? "",
            false),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.description,
            messageDecoderWithEmoji(payout?.description ?? "") ?? '---',
            false),
      ],
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    // MapsLauncher.launchCoordinates(double.parse(transaction!.latitude!),
    //     double.parse(transaction!.longitude!));
  }

  Future<Uint8List> _generateQRCodeImage(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrCode = qrValidationResult.qrCode;

    final painter = QrPainter.withQr(
      qr: qrCode!,
      emptyColor: const Color(0xFFFFFFFF),
      color: const Color(0xFF000000),
      gapless: true,
    );

    final ui.Picture picture = painter.toPicture(300);
    final ui.Image image = await picture.toImage(300, 300);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  String getTransactionUrl() {
    final String url =
        '${AppConfig.baseUrl}/api/v1/transactions/payout/${payout?.id}';
    return url;
  }
}
