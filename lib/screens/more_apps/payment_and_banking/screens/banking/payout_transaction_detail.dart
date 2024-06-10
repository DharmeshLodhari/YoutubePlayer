import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../utils/global_key.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../models/payout.dart';

class PayoutTransactionDetail extends StatefulWidget {
  final dynamic arguments;

  PayoutTransactionDetail({required this.arguments});

  @override
  _PayoutTransactionDetailState createState() =>
      _PayoutTransactionDetailState(arguments: arguments);
}

class _PayoutTransactionDetailState extends State<PayoutTransactionDetail> {
  Map<String, dynamic> arguments;
  Payout? payout;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  _PayoutTransactionDetailState({required this.arguments});

  @override
  void initState() {
    fetchPayout();
    super.initState();
  }

  void fetchPayout() async {
    payout = arguments['transaction'];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
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
    final DateTime transactionTime = DateTime.parse(payout!.timeStamp!);
    final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    final String time = DateFormat("hh:mm a").format(transactionTime);

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    final String? url = payout!.bankLogo;

    final String imageUrl = url!.replaceAll('https//', 'https://');

    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(payout!.bankName!).toUpperCase(),
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
      appendStringDot(payout!.bankName!, 20),
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
          worldCurrencies[payout!.currency!]!,
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(payout!.amount.toString())),
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
          payout!.status!,
          true,
        ),
        transactionOrPayoutTile(
          'assets/images/payout/account_name.svg',
          AppLocalization.of(context)!.accountNameHint,
          payout!.accountName!,
          false,
        ),
        transactionOrPayoutTile(
            'assets/images/payout/account_number.svg',
            AppLocalization.of(context)!.accountNumberHint,
            payout!.accountNumber!,
            false),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.description,
            messageDecoderWithEmoji(payout!.description) ?? '---',
            false),
      ],
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    // MapsLauncher.launchCoordinates(double.parse(transaction!.latitude!),
    //     double.parse(transaction!.longitude!));
  }
}
