import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/util.dart';
import '../../../business/models/Invoice.dart';
import '../models/ChatConversation.dart';
import '../utils.dart';

class PostTileForInvoice extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  PostTileForInvoice(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<PostTileForInvoice> createState() => _PostTileForInvoiceState();
}

class _PostTileForInvoiceState extends State<PostTileForInvoice> {
  late InvoiceModel invoiceModel;
  late UserBloc userBloc;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic>? data;

    if (widget.message!['meta_data'] is String) {
      data = jsonDecode(widget.message!['meta_data']);
    } else if (widget.message!['meta_data'] is Map) {
      data = widget.message!['meta_data'];
    }

    invoiceModel = InvoiceModel.fromJson(data!);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    bool isSender = widget.message!["author"] == userBloc.user.userName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSender ? Container() : Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              child: getPaymentContractTile(),
            ),
            isSender
                ? Container(
                    width: 20,
                    child: isSender
                        ? Center(
                            child: getMessageTick(message: widget.message!),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSender ? Container() : const SizedBox(width: 20),
            Text(
              formatTime(widget.message!['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSender
                ? const SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        ),
      ],
    );
  }

  Widget getPaymentContractTile() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.INVOICE_DETAIL,
            arguments: {"id": invoiceModel.id});
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 3,
        child: Container(
          decoration: decorateBox(),
          child: getInvoiceWidget(),
        ),
      ),
    );
  }

  Widget getInvoiceWidget() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Row(
            children: [
              getAvatar(),
              const SizedBox(width: 20),
              const Text(
                'Invoice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 70),
              const Text('Total:'),
              const SizedBox(width: 20),
              getAmount(),
            ],
          ),
        ],
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[invoiceModel.currency!]!,
          style: TextStyle(
            fontFamily: "Inter",
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          '${moneyDisplayNormalizer(invoiceModel.amount)}',
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget getAvatar() {
    debugPrint('INVOICE ::: ${invoiceModel.fromCustomerAvatar}');

    return Stack(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(color: navyBlue, width: 2)),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: invoiceModel.fromCustomerAvatar == ""
                  ? defaultImage
                  : invoiceModel.fromCustomerAvatar!,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
        const Positioned(
          right: 0,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.description_rounded,
              size: 14,
            ),
          ),
        )
      ],
    );
  }
}
