import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/utility/models/utility_transaction_model.dart';
import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class UtilityHistoryDetailScreen extends StatefulWidget {
  final String transactionId;

  const UtilityHistoryDetailScreen({super.key, required this.transactionId});

  @override
  State<UtilityHistoryDetailScreen> createState() =>
      _UtilityHistoryDetailScreenState();
}

class _UtilityHistoryDetailScreenState
    extends State<UtilityHistoryDetailScreen> {
  bool isLoading = true;
  late UtilityHistoryModel _utilityHistoryModel;

  @override
  void initState() {
    super.initState();

    UtilityAuth()
        .getUtilityTransactionsDetails(transactionsId: widget.transactionId)
        .then(
      (utilityHistoryModel) {
        if (utilityHistoryModel != null) {
          isLoading = false;
          _utilityHistoryModel = utilityHistoryModel;
          if (mounted) {
            setState(() {});
          }
        }
      },
    );
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
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
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
        AppLocalization.of(context)!.utilityTransactionHistory,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        downloadBtn(),
        // showMap(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget downloadBtn() {
    return IconButton(
      icon: Icon(Icons.download_rounded, color: navyBlue),
      onPressed: () {
        // downloadContractFile();
      },
    );
  }

  // Widget showMap() {
  //   return RoundedBackgroundIcon(
  //     height: 34,
  //     width: 34,
  //     icon: Icon(
  //       SlydoAppIcon.location,
  //       size: 16,
  //       color: blackFont,
  //     ),
  //     onTap: 'utilityHistoryModel.latitude' != "" ? goToMap : () {},
  //     backgroundColor: iconBtnGrey,
  //     enableMargin: true,
  //   );
  // }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: isLoading
            ? Center(child: CircularLoadingIndicator())
            : Stack(
                children: [
                  Image.asset(
                    'assets/images/utility_history_details_background_card.png',
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              displayUtilityImage(),
                              const SizedBox(width: 10),
                              displayUtilityName(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          displayUtilityHistoryBody(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getFormattedDateTime() {
    final DateTime utilityTransactionTime =
        DateTime.parse(_utilityHistoryModel.createdAt);
    final String date = DateFormat.jm().format(utilityTransactionTime);
    final String time = DateFormat.yMMMMd().format(utilityTransactionTime);

    return "$date, $time";
  }

  List<Widget> getDashes({required int numberOfDashes}) {
    final List<Widget> widgets = [];
    for (int i = 0; i < numberOfDashes; i++) {
      widgets.add(
        Expanded(
          child: Container(
            width: 10,
            height: 1,
            color: const Color(0XFFD7DAEC),
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget displayUtilityImage() {
    return Card(
      elevation: 7,
      shadowColor: const Color(0XFF314167).withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CachedNetworkImage(
          height: 35,
          width: 35,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          imageUrl: _utilityHistoryModel.providerAvatar,
        ),
      ),
    );
  }

  Widget displayUtilityName() {
    return Expanded(
      child: Text(
        _utilityHistoryModel.providerName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[_utilityHistoryModel.currency]!,
          style: TextStyle(
            color: blackFont,
            // color: transaction!.isCredit! ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(_utilityHistoryModel.amount),
          style: TextStyle(
            color: blackFont,
            // color: transaction!.isCredit! ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget displayUtilityHistoryBody() {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          _historyDetailsTile(
            title: AppLocalization.of(context)!.amount,
            subTitleText:
                '${worldCurrencies[_utilityHistoryModel.currency]!}${moneyDisplayNormalizer(
              int.parse(_utilityHistoryModel.amount.toString()),
            )}',
            imagePathName: 'naira_icon.png',
          ),
          _historyDetailsTile(
            title: 'Date & Time',
            subTitleText: _getFormattedDateTime(),
            imagePathName: 'time_icon.png',
          ),
          _historyDetailsTile(
            title: AppLocalization.of(context)!.status,
            subTitleWidget: getStatusWidget(),
            imagePathName: 'status_icon.png',
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 1,
            shadowColor: const Color(0XFFD7DAEC),
            margin: const EdgeInsets.only(right: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/desc_icon.png',
                    width: 34,
                    height: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('------'),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // _historyDetailsTile(
          //   title: AppLocalization.of(context)!.description,
          //   subTitleText:
          //       '_utilityHistoryModel.description ?? "---", kljksjfklsjf kljsklfj skljfklsj flkj',
          //   // subTitleText: _utilityHistoryModel.description ?? "---",
          //   imagePathName: 'desc_icon.png',
          // ),
        ],
      ),
    );
  }

  Widget getStatusWidget() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _utilityHistoryModel.status == 'Successful'
            ? navyBlue.withOpacity(0.1)
            : mateRed.withOpacity(0.1),
      ),
      child: Text(
        _utilityHistoryModel.status,
        style: TextStyle(
          color:
              _utilityHistoryModel.status == 'Successful' ? navyBlue : mateRed,
        ),
      ),
    );
  }

  Widget _historyDetailsTile(
      {required String title,
      String subTitleText = "", // use this if you need a text for the subtitle.
      Widget? subTitleWidget, // use this if you need a widget for the subtitle.
      required String imagePathName}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        children: [
          Image.asset(
            'assets/images/$imagePathName',
            width: 34,
            height: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: blackFont,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  subTitleWidget ??
                      Text(
                        subTitleText,
                        style: TextStyle(
                          color: blackFont,
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                        ),
                      )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    // MapsLauncher.launchCoordinates(double.parse(utilityHistoryModel.latitude),
    //     double.parse(utilityHistoryModel.longitude));
  }
}
