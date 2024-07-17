import 'dart:isolate';
import 'dart:ui';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/environment.dart';
import '../business_auth.dart';

// ignore: must_be_immutable
class ContractDetail extends StatefulWidget {
  final dynamic arguments;

  const ContractDetail({super.key, required this.arguments});

  @override
  State<ContractDetail> createState() => _ContractDetailState();
}

class _ContractDetailState extends State<ContractDetail> {
  late ContractModel contract;
  bool isLoading = false;
  bool isDownloading = false;
  String savePath = "";

  // _ContractDetailState({this.arguments});

  int downloadProgress = 0;
  ReceivePort receivePort = ReceivePort();

  @override
  void initState() {
    fetchContract();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'contract_downloader_send_port');

    receivePort.listen((message) {
      downloadProgress = message[2];
      if (downloadProgress != 0) {
        isDownloading = true;
        if (mounted) setState(() {});

        if (downloadProgress == 100) {
          isDownloading = false;
          if (mounted) setState(() {});
          showToast(message: 'Downloaded');
        } else if (downloadProgress == -1) {
          isDownloading = false;
          if (mounted) setState(() {});
          showToast(message: 'File cannot be downloaded at the moment');
        }
      }

      debugPrint('DOWNLOAD MESSAGE ::: $message');
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('contract_downloader_send_port');
    super.dispose();
  }

  @pragma(
      'vm:entry-point') // To avoid tree shaking in release mode for Android.
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('contract_downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void fetchContract() async {
    isLoading = true;
    setState(() {});
    BusinessAuth().getContract(widget.arguments["id"].toString()).then((value) {
      contract = value;
      isLoading = false;

      setState(() {});
    }).catchError((error) {
      debugPrint(error);
    });
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
        "Contract",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (isLoading)
          const SizedBox.shrink()
        else
          IconButton(
            icon: getDownloadIconWidget(),
            onPressed: () {
              _downloadContract();
            },
          ),
        // transactionHistoryBtn(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget getDownloadIconWidget() {
    if (isDownloading) {
      return SizedBox(
        width: 25,
        height: 25,
        child: CircularLoadingIndicator(
          color: navyBlue,
        ),
      );
    }

    return Icon(Icons.download_rounded, color: navyBlue);
  }

  void _downloadContract() async {
    final String fileName = 'Contract_${contract.id}.pdf';
    final PermissionStatus status = await Permission.storage.request();

    final downloadsDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);

    if (status.isGranted) {
      setState(() {
        isDownloading = true;
      });
      final String formattedFileName =
          await makeFileName(downloadsDirectoryPath, fileName);

      await FlutterDownloader.enqueue(
        url:
            "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/download/${contract.id}/?download=true",
        fileName: formattedFileName,
        savedDir: downloadsDirectoryPath,
      );
    } else {
      Permission.storage.request();
    }
  }

  Widget transactionHistoryBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.transactions,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.CONTRACT_TRANSACTIONS);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  (AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  displayContractInfo(),
                  flexibleSpace(),
                ],
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
      onTap: () async {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": contract.contractor});
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      messageDecoderWithEmoji(contract.note)!,
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    final DateTime dateAndTime = DateTime.parse(contract.createdAt!);
    final String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    final String time = DateFormat("hh:mm a").format(dateAndTime);

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  String formatDate(String? datetime) {
    if (datetime == null) {
      return "";
    }
    final DateTime dateAndTime = DateTime.parse(datetime);
    final String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    final String time = DateFormat("hh:mm a").format(dateAndTime);
    return "$date • $time";
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: contract.contractorAvatar!,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => contract.contractorAvatar == ""
            ? const Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getSender() {
    return Text(
      contract.contractor!,
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
          worldCurrencies[contract.currency!]!,
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(contract.amount),
          style: TextStyle(
              color: navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget displayContractInfo() {
    return Container(
      decoration: decorateBox(),
      child: Card(
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
              displayBodyOfTransaction(),
            ],
          ),
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
        detailTile(
          Icons.history_edu,
          AppLocalization.of(context)!.status,
          contract.status!,
        ),
        detailTile(
          Icons.timer,
          "Payment duration",
          contract.paymentDuration!,
        ),
        detailTile(
          SlydoAppIcon.note_filled,
          AppLocalization.of(context)!.note,
          messageDecoderWithEmoji(contract.note) ?? '---',
        ),
        detailTile(
          SlydoAppIcon.date,
          "Starting date",
          formatDate(contract.startDate),
        ),
        detailTile(
          SlydoAppIcon.date,
          "Ending date",
          formatDate(contract.startDate),
        ),
      ],
    );
  }

  Widget detailTile(IconData icon, String title, String subtitle) {
    // return Container(
    //   child: ListTile(
    //     dense: true,
    //     leading: icon,
    //     title: Text(
    //       title,
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     subtitle: Text(
    //       subtitle,
    //       style: TextStyle(fontSize: 12),
    //     ),
    //   ),
    // );

    return ListTile(
      dense: true,
      leading: RoundedBackgroundIcon(
        icon: Icon(
          icon,
          color: blackFont,
          size: 18,
        ),
        backgroundColor: iconBtnGrey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: blackFont,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
        ),
      ),
    );
  }
}
