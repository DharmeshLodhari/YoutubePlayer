import 'dart:developer';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/payment_link/payment_screen.dart';
import 'package:Slydo/screens/payment_link/search_payment_link.dart';
import 'package:Slydo/screens/service_hub/screens/my_job_details.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'payment_transaction_info.dart';

class PaymentLink extends StatefulWidget {
  PaymentLink({super.key, this.listMap});
  List? listMap = [];

  @override
  State<PaymentLink> createState() => _PaymentLinkState();
}

class _PaymentLinkState extends State<PaymentLink>
    with SingleTickerProviderStateMixin {
  bool isPopMenuOpen = false;

  final _auth = PaymentAndBankingAuth();

  int? count = 0;
  String? next = "";
  String? previous = "";
  List paymentLinkList = [];
  bool isLoading = false;
  bool noItemInList = false;

  final ScrollController _scrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> getPaymentLinks() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final dynamic result = await _auth.getPaymentLinks();

        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        isLoading = false;
        paymentLinkList.addAll(tempList);

        if (mounted) setState(() {});
      }
    }
    if (paymentLinkList.isEmpty) {
      noItemInList = true;

      if (mounted) setState(() {});
    }
  }

  Future<void> cancelPaymentLinks(String cancelPaymentLink) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final dynamic result = await _auth.cancelPaymentLinks(cancelPaymentLink);

    if (result == true) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _onRefresh();
    } else {
      isLoading = false;
      showToast(
          context: context, message: 'Payment link cancellation failed.!');
    }

    setState(() {});
  }

  void filterPaymentLinks(String filter) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    paymentLinkList.clear();
    final dynamic result = await _auth.filterPaymentLinks(filter: filter);
    log('filter link results::::: ${result.toString()}');

    if (result == null) {
      isLoading = false;
      return;
    }
    next = result['next'];
    count = result['count'];
    previous = result['previous'];
    final tempList = result['results'];

    isLoading = false;
    paymentLinkList.addAll(tempList);

    if (mounted) setState(() {});

    if (paymentLinkList.isEmpty) {
      noItemInList = true;

      if (mounted) setState(() {});
    }
  }

  Widget paymentLinkCard(
      {String? name,
      String? date,
      String? id,
      int? amount,
      String? currency,
      String? status,
      int? passcode,
      String? link,
      String? category}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: () => NavigationUtil.push(
          context,
          screen: TransactionPaymentLink(
            date: date,
            amount: amount.toString(),
            status: status,
            name: name,
            currency: currency,
            passcode: passcode.toString(),
            category: category,
            link: link,
            id: id,
          ),
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: decorateBox(),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText1(
                        title: name ?? '',
                        fontSize: 14,
                        fontweight: FontWeight.w700,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      getDateTime(context, date!)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      getAmount(amount, currency),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: colorStats(status!).withOpacity(0.1),
                        ),
                        child: Text(
                          status.toString().toLowerCase() == 'processing'
                              ? 'Pending'
                              : status,
                          style: TextStyle(
                            color: colorStats(status),
                            fontSize: 10.80,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Widget _moreOptionsBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      backgroundColor: iconBtnGrey,
      enableMargin: false,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      onTap: () {
        androidBottomSheet(
          context: context,
          child: StatefulBuilder(
            builder: (context, changeState) {
              return SizedBox(
                height: 370,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('');
                        },
                        child: Text(
                          'All',
                          style: TextStyle(
                              fontSize: 18,
                              color: black,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            filterPaymentLinks('Active');
                          },
                          child: Text(
                            'Active',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600),
                          )),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            filterPaymentLinks('Inactive');
                          },
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600),
                          )),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('Paid');
                        },
                        child: Text('Paid',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('Cancelled');
                        },
                        child: Text('Cancelled',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('Suspended');
                        },
                        child: Text('Suspended',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('Reserved');
                        },
                        child: Text('Reserved',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          filterPaymentLinks('Failed');
                        },
                        child: Text('Failed',
                            style: TextStyle(
                                fontSize: 18,
                                color: black,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
        AppLocalization.of(context)!.paymentLink,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addBtn(),
        const SizedBox(width: 8.0),
        getSearchBtn(),
        const SizedBox(width: 8.0),
        _moreOptionsBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getSearchBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      backgroundColor: iconBtnGrey,
      enableMargin: false,
      icon: const Icon(
        Icons.search,
        color: Colors.black,
        size: 20,
      ),
      onTap: () {
        NavigationUtil.push(context, screen: const PaymentLinkSearch());
      },
    );
  }

  Widget addBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      backgroundColor: iconBtnGrey,
      enableMargin: false,
      icon: const Icon(
        Icons.add_circle,
        color: Colors.black,
        size: 18,
      ),
      onTap: () {
        NavigationUtil.push(context, screen: const PaymentLinkScreen());
      },
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
          color: isPopMenuOpen ? navyBlue : iconBtnGrey,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: PopupMenuButton(
            icon: Icon(
              Icons.filter_alt_rounded,
              color: isPopMenuOpen ? Colors.white : Colors.black,
              size: 20,
            ),
            onSelected: (value) {
              switch (value) {
                case 'all':
                  {
                    filterPaymentLinks('');
                  }
                  break;
                case 'active':
                  {
                    filterPaymentLinks('Active');
                  }
                  break;
                case 'inactive':
                  {
                    filterPaymentLinks('Inactive');
                  }
                  break;
                case 'paid':
                  {
                    filterPaymentLinks('Paid');
                  }
                  break;
                case 'cancelled':
                  {
                    filterPaymentLinks('Cancelled');
                  }
                  break;
                case 'suspended':
                  {
                    filterPaymentLinks('Suspended');
                  }
                  break;

                case 'reversed':
                  {
                    filterPaymentLinks('Reserved');
                  }
                  break;
                case 'failed':
                  {
                    filterPaymentLinks('Failed');
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext bc) {
              return const [
                PopupMenuItem(
                  value: 'all',
                  child: Text("All"),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Text("Active"),
                ),
                PopupMenuItem(
                  value: 'inactive',
                  child: Text("Inactive"),
                ),
                PopupMenuItem(
                  value: 'paid',
                  child: Text("Paid"),
                ),
                PopupMenuItem(
                  value: 'cancelled',
                  child: Text("Cancelled"),
                ),
                PopupMenuItem(
                  value: 'suspended',
                  child: Text("Suspended"),
                ),
                PopupMenuItem(
                  value: 'reversed',
                  child: Text("Reversed"),
                ),
                PopupMenuItem(
                  value: 'failed',
                  child: Text("Failed"),
                ),
              ];
            },
          )),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getPaymentLinks();
    super.initState();
  }

  void rejectRequestAlert(data, index) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      leftButtonOnPressed: () => cancelPaymentLinks(data['id']),
      title: AppLocalization.of(context)!.cancel,
      description:
          "Are you sure want to cancel the payment link, your payment link fee of ${worldCurrencies[data['currency']]}35 will not be refunded.!",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: "Ignore",
    );
    if (result != null && result) {
      const bool done = true;
      if (done) {
        setState(() {
          // paymentLinkList.removeAt(index);
          // getPaymenttLinks();
        });
      }
    }
  }

  List<Widget> listActionSlideActions(Map data, int index) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: mateRed,
        icon: SlydoAppIcon.cancel_connection_request,
        onPressed: (con) {
          rejectRequestAlert(data, index);
        },
        label: AppLocalization.of(context)!.cancel,
      ),
    ];
  }

  Widget _getSlidableWithLists(BuildContext context, Map e, int index) {
    return Slidable(
      key: Key(e["id"].toString()),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio:
            e['status'].toString().toLowerCase() != 'active' ? 0.0001 : 0.25,
        children: listActionSlideActions(e, index),
      ),
      child: paymentLinkCard(
          name: e['reference'],
          amount: e['amount'],
          date: e['created_at'],
          currency: e['currency'],
          passcode: e['pin'],
          status: e['status'],
          id: e['id'],
          category: e['category'],
          link: e['link'] ?? ''),
    );
  }

  Widget _buildFriendsList() {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.only(top: 48.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : isLoading && paymentLinkList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: paymentLinkList.length + 1,
                itemBuilder: (context, index) {
                  if (index == paymentLinkList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                        context, paymentLinkList[index], index);
                  }
                },
                controller: _scrollController,
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar() as PreferredSizeWidget?,
      body: SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: noItemInList
                ? NoItemInList(
                    msg: AppLocalization.of(context)!.noPaymentLink,
                  )
                : _buildFriendsList()),
      ),
    );
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      next = "";
      previous = "";
      count = 0;
      isLoading = false;
      paymentLinkList = [];
      getPaymentLinks();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }
}
