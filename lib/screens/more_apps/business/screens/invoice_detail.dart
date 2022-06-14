import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:Slydo/services/auth.dart';

import '../../../../data/environment.dart';
import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/curved_btn.dart';

import '../bloc/invoice_bloc.dart';
import '../business_auth.dart';
import '../forms/invoice/add_or_update_invoice_item.dart';
import '../models/Invoice.dart';

// ignore: must_be_immutable
class InvoiceDetail extends StatefulWidget {
  var arguments;

  InvoiceDetail({required this.arguments});

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  late InvoiceModel invoice;
  bool isLoading = false;
  late UserBloc userBloc;
  bool isDownloading = false;
  String savePath = "";
  DateTime invoiceDate = DateTime.now();

  int downloadProgress = 0;
  ReceivePort receivePort = ReceivePort();

  @override
  void initState() {
    fetchInvoice();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'invoice_downloader_send_port');

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

  @pragma(
      'vm:entry-point') // To avoid tree shaking in release mode for Android.
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('invoice_downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('invoice_downloader_send_port');
    super.dispose();
  }

  void fetchInvoice() async {
    isLoading = true;
    setState(() {});
    BusinessAuth().getInvoice(widget.arguments["id"].toString()).then((value) {
      invoice = value;
      isLoading = false;
      setState(() {});
    }).catchError((error) {
      debugPrint(error);
    });
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: isLoading
            ? Center(child: CircularLoadingIndicator())
            : scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
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
        "Invoice",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        isLoading
            ? SizedBox.shrink()
            : invoice.status != 'Draft'
                ? IconButton(
                    icon: getDownloadIconWidget(),
                    onPressed: () {
                      _downloadInvoice();
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.delete, color: mateRed),
                    onPressed: () {
                      showDeleteDialogForInvoice();
                    },
                  ),
        SizedBox(width: 16),
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

  showDeleteDialogForInvoice() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      actionOneBgColor: greyBorderColor,
      title: AppLocalization.of(context)!.delete,
      actionTwoText: AppLocalization.of(context)!.delete,
      actionOneText: AppLocalization.of(context)!.cancel,
      description: 'Are you sure you want to delete this invoice?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () {
        deleteInvoice();
      },
    );
  }

  deleteInvoice() {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());
    BusinessAuth().deleteInvoice(invoiceId: invoice.id!).then((deleted) {
      Navigator.pop(context);
      if (deleted) {
        showToast(message: 'Invoice deleted.');
        Navigator.pop(context);
        Provider.of<InvoiceBloc>(context, listen: false).isSender = true;
        Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
        Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
      } else {
        showToast(message: 'Something went wrong.');
      }
    }).catchError(
      (error) {
        Navigator.pop(context);
        showToast(message: 'Something went wrong');
      },
    );
  }

  Widget scaffoldBody() {
    bool canPayForInvoice = invoice.fromCustomer != userBloc.user.userName &&
        invoice.status == "Unpaid";
    bool canAddInvoiceItem = invoice.status == 'Draft';

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isDownloading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularLoadingIndicator(),
                        SizedBox(width: 12),
                        Text(
                          'Downloading...',
                          style: TextStyle(color: darkGrey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            displayContractInfo(),
            SizedBox(height: 14),
            canPayForInvoice
                ? CurvedButton(
                    text: "Pay Now",
                    onPressed: () {
                      _payInvoice();
                    })
                : SizedBox.shrink(),
            SizedBox(height: 10),
            canAddInvoiceItem
                ? CurvedButton(
                    width: 150,
                    text: 'Add  item',
                    onPressed: () async {
                      bool? updated = await NavigationUtil.push(
                        context,
                        screen: AddOrUpdateInvoiceItem(
                          invoiceId: invoice.id,
                          // invoiceItem: item,
                        ),
                      );

                      if (updated == true) {
                        fetchInvoice();
                      }
                    },
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void _payInvoice() {
    BusinessAuth().payInvoice(invoiceId: invoice.id!).then(
      (value) {
        showToast(message: "Invoice Paid");
      },
    ).catchError(
      (e) {
        showToast(message: "Something went wrong, please try again.");
      },
    );
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {
        Navigator.pushNamed(context, Routes.PROFILE,
            arguments: {"searchedUserName": invoice.toCustomer});
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      "",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    DateTime dateAndTime = DateTime.parse(invoice.createdAt!);
    String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    String time = DateFormat("hh:mm a").format(dateAndTime);

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  String formatDate(String datetime) {
    DateTime dateAndTime = DateTime.parse(datetime);
    String date = DateFormat("dd/MM/yyyy").format(dateAndTime);
    String time = DateFormat("hh:mm a").format(dateAndTime);
    return "$date • $time ";
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: invoice.toCustomerAvatar!,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => invoice.toCustomerAvatar == ""
            ? Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getSender() {
    return Text(
      invoice.toCustomer!,
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
          worldCurrencies[invoice.currency!]!,
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Roboto",
          ),
        ),
        Text(
          moneyDisplayNormalizer(invoice.amount),
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
    bool canEditDate = invoice.status == 'Draft';
    return Container(
      child: Column(
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
            invoice.status!,
          ),
          detailTile(
            SlydoAppIcon.date,
            "Invoice date",
            formatDate(invoice.invoiceDate!),
            editDate: canEditDate,
            isDueDate: false,
          ),
          detailTile(
            SlydoAppIcon.date,
            "Due date",
            formatDate(invoice.dueDate!),
            editDate: canEditDate,
            isDueDate: true,
          ),
          getInvoiceItems()
        ],
      ),
    );
  }

  Widget getInvoiceItems() {
    bool canDeleteInvoiceItem =
        invoice.fromCustomer == userBloc.user.userName &&
            invoice.status == "Draft" &&
            invoice.items!.length > 1;
    bool canEditInvoiceItem = invoice.status == "Draft";
    bool canShowActionsText = canDeleteInvoiceItem || canEditInvoiceItem;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ITEMS",
            style: TextStyle(
                fontSize: 14, color: blackFont, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Divider(
            height: 0,
            color: dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 4),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Name",
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        Text(
                          "Qty",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        flexibleSpace(),
                        Text(
                          "Amount",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        flexibleSpace(),
                        Text(
                          "Sub total",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        canShowActionsText
                            ? flexibleSpace()
                            : SizedBox.shrink(),
                        canShowActionsText
                            ? Text(
                                "Actions",
                                style: TextStyle(
                                    color: blackFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Divider(
                height: 0,
                color: dividerColor,
                thickness: 1,
              ),
              SizedBox(height: 8),
              Column(
                children: invoice.items!
                    .map((e) => getItemTile(
                        invoiceItemLength: invoice.items!.length, item: e))
                    .toList(),
              ),
              SizedBox(height: 8),
              Divider(
                height: 0,
                color: dividerColor,
                thickness: 1,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Total :- ",
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Text(
                    worldCurrencies[invoice.currency!]!,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    moneyDisplayNormalizer(invoice.amount),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          )
        ],
      ),
    );
  }

  Widget getItemTile(
      {required int invoiceItemLength, required InvoiceItem item}) {
    bool canDeleteInvoiceItem =
        invoice.fromCustomer == userBloc.user.userName &&
            invoice.status == "Draft" &&
            invoiceItemLength > 1;
    bool canEditInvoiceItem = invoice.status == "Draft";

    String subtotalAmount =
        moneyDisplayNormalizer(item.quantity! * item.amount!);

    String itemAmount = moneyDisplayNormalizer(item.amount!);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name!,
                    style: TextStyle(color: blackFont),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Text(item.quantity.toString()),
                flexibleSpace(),

                //Amount (figure)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      worldCurrencies[item.currency!]!,
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontFamily: "Roboto",
                      ),
                    ),
                    Text(
                      truncateString(str: itemAmount, lengthToTruncateAt: 8),
                    ),
                  ],
                ),
                flexibleSpace(),

                //Subtotal amount
                Row(
                  children: [
                    Text(
                      worldCurrencies[item.currency!]!,
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontFamily: "Roboto",
                      ),
                    ),
                    Text(subtotalAmount.length > 8
                        ? '${subtotalAmount.substring(0, 8)}...'
                        : subtotalAmount),
                  ],
                ),
                canDeleteInvoiceItem || canEditInvoiceItem
                    ? flexibleSpace()
                    : SizedBox.shrink(),
                canDeleteInvoiceItem
                    ? InkWell(
                        child: Icon(
                          Icons.delete,
                          size: 20,
                          color: mateRed,
                        ),
                        onTap: () {
                          showDeleteDialogForInvoiceItem(item);
                        },
                      )
                    : SizedBox.shrink(),
                SizedBox(width: 5),
                canEditInvoiceItem
                    ? InkWell(
                        child: Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        onTap: () async {
                          bool? updated = await NavigationUtil.push(
                            context,
                            screen: AddOrUpdateInvoiceItem(
                              invoiceItem: item,
                            ),
                          );

                          if (updated == true) {
                            fetchInvoice();
                          }
                        },
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailTile(IconData icon, String title, String subtitle,
      {bool editDate = false, bool isDueDate = false}) {
    return Container(
      child: ListTile(
        dense: true,
        leading: RoundedBackgroundIcon(
          icon: Icon(
            icon,
            color: blackFont,
            size: 18,
          ),
          backgroundColor: iconBtnGrey,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 5),
            editDate
                ? InkWell(
                    onTap: () {
                      showDatePicker(
                        builder: customThemeBuilder,
                        context: context,
                        initialDate: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day),
                        firstDate: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day),
                        lastDate: DateTime(2101),
                      ).then((value) {
                        invoiceDate =
                            DateTime(value!.year, value.month, value.day);

                        _updateInvoiceDate(isDueDate: isDueDate);

                        // setState(() {});
                      }).catchError((error) {});
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 12,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  _updateInvoiceDate({required bool isDueDate}) {
    BusinessAuth().updateInvoice(invoiceId: invoice.id.toString(), data: {
      isDueDate ? "due_date" : "invoice_date": dateToString(invoiceDate),
    }).then(
      (updated) {
        if (updated) {
          fetchInvoice();
          showToast(message: 'Updated successfully');
        } else {
          showToast(message: 'Something went wrong');
        }
      },
    ).catchError(
      (e) {
        showToast(message: e.toString());
      },
    );
  }

  void _deleteInvoiceItem(InvoiceItem item) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    BusinessAuth().deleteInvoiceItem(itemId: item.id!).then((value) {
      Navigator.of(context).pop();
      // invoice.status = action;
      fetchInvoice();
      showToast(message: "Item deleted successfully");
    }).catchError((error) {
      Navigator.of(context).pop();

      showToast(message: "Something went wrong, please try again.");
    });
  }

  _downloadInvoice() async {
    String fileName = 'Invoice_${invoice.id}.pdf';
    PermissionStatus status = await Permission.storage.request();

    var downloadsDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);

    if (status.isGranted) {
      setState(() {
        isDownloading = true;
      });
      String formattedFileName =
          await makeFileName(downloadsDirectoryPath, fileName);

      await FlutterDownloader.enqueue(
        url:
            "${AppConfig.baseUrl}/api/v1/transactions/invoice/download/${invoice.id}/?download=true",
        fileName: formattedFileName,
        savedDir: downloadsDirectoryPath,
      );
    } else {
      Permission.storage.request();
    }
  }

  showDeleteDialogForInvoiceItem(InvoiceItem item) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      actionOneBgColor: greyBorderColor,
      title: AppLocalization.of(context)!.delete,
      actionTwoText: AppLocalization.of(context)!.delete,
      actionOneText: AppLocalization.of(context)!.cancel,
      description: 'Are you sure you want to delete this invoice item?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () {
        _deleteInvoiceItem(item);
      },
    );
  }
}
