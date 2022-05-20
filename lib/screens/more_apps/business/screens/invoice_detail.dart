import 'dart:io';

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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:Slydo/services/auth.dart';

import '../../../../data/environment.dart';
import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/curved_btn.dart';

import '../business_auth.dart';
import '../forms/invoice/add_or_update_invoice_item.dart';
import '../models/Invoice.dart';
import 'package:dio/dio.dart';

// ignore: must_be_immutable
class InvoiceDetail extends StatefulWidget {
  var arguments;

  InvoiceDetail({required this.arguments});

  @override
  _InvoiceDetailState createState() =>
      _InvoiceDetailState(arguments: arguments);
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  var arguments;
  late InvoiceModel invoice;
  bool isLoading = false;
  late UserBloc userBloc;
  // var imageUrl =
  //     "https://www.itl.cat/pngfile/big/10-100326_desktop-wallpaper-hd-full-screen-free-download-full.jpg";
  bool isDownloading = false;
  String savePath = "";
  DateTime invoiceDate = DateTime.now();

  _InvoiceDetailState({this.arguments});

  @override
  void initState() {
    fetchInvoice();
    super.initState();
  }

  void fetchInvoice() async {
    isLoading = true;
    setState(() {});
    BusinessAuth().getInvoice(arguments["id"].toString()).then((value) {
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
                    icon: Icon(Icons.download_rounded, color: navyBlue),
                    onPressed: () {
                      downloadFile(invoice);
                    },
                  )
                : SizedBox.shrink(),
        SizedBox(width: 16),

        // openGraphBtn(),
        // SizedBox(
        //   width: 16,
        // ),
      ],
    );
  }

  Widget openGraphBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: goToMap,
      backgroundColor: iconBtnGrey,
      enableMargin: true,
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
          ),
          detailTile(
            SlydoAppIcon.date,
            "Due date",
            formatDate(invoice.dueDate!),
            editDate: canEditDate,
          ),
          getInvoiceItems()
        ],
      ),
    );
  }

  Widget getInvoiceItems() {
    bool canDeleteInvoiceItem =
        invoice.fromCustomer == userBloc.user.userName &&
            invoice.status != "Paid" &&
            invoice.items!.length > 1;
    bool canEditInvoiceItem = invoice.status != "Paid";
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
                    .map((e) =>
                        getItemTile(length: invoice.items!.length, item: e))
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

  Widget getItemTile({required int length, required InvoiceItem item}) {
    bool canDeleteInvoiceItem =
        invoice.fromCustomer == userBloc.user.userName &&
            invoice.status != "Paid" &&
            length > 1;
    bool canEditInvoiceItem = invoice.status != "Paid";

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
                    Text(itemAmount.length > 8
                        ? '${itemAmount.substring(0, 8)}...'
                        : itemAmount),
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
                          showDeleteDialog(item);
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
      {bool editDate = false}) {
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

                        _updateInvoiceDate();
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

  _updateInvoiceDate({bool isDueDate = false}) {
    BusinessAuth()
        .updateInvoice(
      id: invoice.id.toString(),
      data: isDueDate
          ? {
              "due_date": dateToString(invoiceDate),
            }
          : {
              "invoice_date": dateToString(invoiceDate),
            },
    )
        .then(
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

  void goToMap() {
    debugPrint("go to Map Called !");
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

  Future downloadFile(InvoiceModel invoice) async {
    print('INVOICE ID :: ${invoice.id}');
    if (mounted) {
      setState(() {
        isDownloading = true;
      });
    }
    try {
      Dio dio = Dio();

      String pdfUrl =
          "${AppConfig.baseUrl}/api/v1/transactions/invoice/download/${invoice.id}/?download=true";

      String fileName = 'Invoice_${invoice.id}.pdf';

      var authHeaders = await BusinessAuth().getAuthHeaders();

      savePath = await getFilePath(fileName);
      Response response = await dio.download(
        pdfUrl,
        savePath,
        options: Options(
          headers: authHeaders,
        ),
        onReceiveProgress: (rec, total) {},
      );
      setState(() {
        isDownloading = false;
      });
      if (response.statusCode == 200) {
        showToast(message: 'Download complete');
      } else {
        showToast(message: 'Something went wrong, please try again');
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      print(e.toString());
      showToast(message: 'ERROR ::: ${e.toString()}');
    }
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = Directory('/storage/emulated/0/Download');
    // Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName';

    return path;
  }

  showDeleteDialog(InvoiceItem item) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      actionOneBgColor: greyBorderColor,
      title: AppLocalization.of(context)!.delete,
      actionTwoText: AppLocalization.of(context)!.delete,
      actionOneText: AppLocalization.of(context)!.cancel,
      description: 'Are you sure you want to delete your invoice item?',
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
