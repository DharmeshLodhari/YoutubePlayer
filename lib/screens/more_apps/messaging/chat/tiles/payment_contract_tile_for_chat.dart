import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/util.dart';
import '../../../business/models/Contract.dart';
import '../models/ChatConversation.dart';
import '../utils.dart';

class PostTileForPaymentContract extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  PostTileForPaymentContract(
      {Key? key, required this.message, required this.chatConversation})
      : super(key: key);

  @override
  State<PostTileForPaymentContract> createState() =>
      _PostTileForPaymentContractState();
}

class _PostTileForPaymentContractState
    extends State<PostTileForPaymentContract> {
  late ContractModel contract;
  late UserBloc userBloc;
  int amountLength =
      10000000000; // If the contract amount is greater than this, the amount shown will be truncated.

  @override
  void initState() {
    super.initState();

    Map<String, dynamic>? data;

    if (widget.message!['meta_data'] is String) {
      data = jsonDecode(widget.message!['meta_data']);
    } else if (widget.message!['meta_data'] is Map) {
      data = widget.message!['meta_data'];
    }

    contract = ContractModel.fromJson(data!);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    final bool isSender = widget.message!["author"] == userBloc.user.userName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSender) Container() else Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              child: getPaymentContractTile(),
            ),
            if (isSender)
              Container(
                width: 20,
                child: isSender
                    ? Center(
                        child: getMessageTick(message: widget.message!),
                      )
                    : Container(),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isSender) Container() else const SizedBox(width: 20),
            Text(
              formatTime(widget.message!['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            if (isSender)
              const SizedBox(
                width: 20,
              )
            else
              Container(),
          ],
        ),
      ],
    );
  }

  Widget getPaymentContractTile() {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.CONTRACT_DETAIL, arguments: {"id": contract.id});
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 3,
        child: Container(
          decoration: decorateBox(),
          child: paymentContractInfo(),
        ),
      ),
    );
  }

  Widget paymentContractInfo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  getAvatar(),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 100,
                    child: Text(
                      contract.contractor!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              getAmount(),
            ],
          ),
        ),
        getContractDuration(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[contract.currency!]!,
          style: TextStyle(
            fontFamily: "Inter",
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          contract.amount! > amountLength
              ? '${moneyDisplayNormalizer(contract.amount)}...'
              : moneyDisplayNormalizer(contract.amount),
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget getTitle() {
    return Text(
      contract.contractor!,
      maxLines: 1,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getContractDuration() {
    final String startDate =
        DateFormat('MMMMd').format(DateTime.parse(contract.startDate!));
    final String startYear =
        DateFormat('y').format(DateTime.parse(contract.startDate!));

    final String endDate =
        DateFormat('MMMMd').format(DateTime.parse(contract.endDate!));
    final String endYear =
        DateFormat('y').format(DateTime.parse(contract.endDate!));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        flexibleSpace(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              startDate,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              startYear,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: blackFont,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          width: 70,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 6,
                child: Container(
                  width: 70,
                  child: Image.asset(
                    "assets/images/arrow_right.png",
                  ),
                ),
              ),
              // Positioned(
              //   top: -6,
              //   left: 16,
              //   child: Text(
              //     tickets[0].journeyTime!,
              //     style: TextStyle(
              //       fontWeight: FontWeight.w400,
              //       fontSize: 12,
              //       color: darkGrey,
              //     ),
              //     overflow: TextOverflow.visible,
              //     maxLines: 1,
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              endDate,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              endYear,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: blackFont,
              ),
            ),
          ],
        ),
        flexibleSpace(),
      ],
    );
  }

  Widget getAvatar() {
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
              imageUrl: contract.contractorAvatar == ""
                  ? defaultImage
                  : contract.contractorAvatar!,
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
