import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../business_auth.dart';
import '../models/Invoice.dart';

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
  late Invoice invoice;
  bool isLoading = false;

  _InvoiceDetailState({this.arguments});

  @override
  void initState() {
    fetchContract();
    super.initState();
  }

  void fetchContract() async {
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
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    return "$date • $time";
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
          ),
          detailTile(
            SlydoAppIcon.date,
            "Due date",
            formatDate(invoice.dueDate!),
          ),
          getInvoiceItems()
        ],
      ),
    );
  }

  Widget getInvoiceItems() {
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
          SizedBox(
            height: 12,
          ),
          Divider(
            height: 0,
            color: dividerColor,
            thickness: 1,
          ),
          SizedBox(
            height: 4,
          ),
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
                    flex: 5,
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
                          "Sub total  ",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
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
              SizedBox(
                height: 8,
              ),
              Column(
                children:
                    invoice.items!.map((e) => getItemTile(item: e)).toList(),
              ),
              SizedBox(
                height: 8,
              ),
              Divider(
                height: 0,
                color: dividerColor,
                thickness: 1,
              ),
              SizedBox(
                height: 8,
              ),
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
              SizedBox(
                height: 16,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getItemTile({required InvoiceItem item}) {
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
          SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Text(item.quantity.toString()),
                flexibleSpace(),
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
                      moneyDisplayNormalizer(item.amount),
                    ),
                  ],
                ),
                flexibleSpace(),
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
                    Text(
                      moneyDisplayNormalizer(item.quantity! * item.amount!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailTile(IconData icon, String title, String subtitle) {
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
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
  }
}
