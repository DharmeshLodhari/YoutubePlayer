import 'dart:developer';

import 'package:Slydo/screens/more_apps/payment_link/payment_screen.dart';
import 'package:Slydo/screens/more_apps/payment_link/search_payment_link.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/noItemInList.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';
import '../service_hub/screens/my_job_details.dart';
import 'paayment_transaction_info.dart';

class PaymentLink extends StatefulWidget {
  PaymentLink({Key? key, this.listMap}) : super(key: key);
  List? listMap = [];

  @override
  State<PaymentLink> createState() => _PaymentLinkState();
}

class _PaymentLinkState extends State<PaymentLink> {
  bool isPopMenuOpen = false;

  final _auth = PaymentAndBankingAuth();

  int? count = 0;
  String? next = "";
  String? previous = "";
  List paymentLinkList = [];
  bool isLoading = false;
  bool noItemInList = false;

  getPaymenttLinks() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        dynamic result = await _auth.getPaymentLinks();
        log('payment link results::::: ${result.toString()}');

        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        var tempList = result['results'];

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

  filterPaymenttLinks(String filter) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    paymentLinkList.clear();
    dynamic result = await _auth.filterPaymentLinks(filter: filter);
    log('filter link results::::: ${result.toString()}');

    if (result == null) {
      isLoading = false;
      return;
    }
    next = result['next'];
    count = result['count'];
    previous = result['previous'];
    var tempList = result['results'];

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
      amount,
      currency,
      status,
      passcode,
      link,
      category}) {
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
                            color: colorStats(status!),
                            fontSize: 10.80,
                            fontFamily: "Open Sans",
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
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      child: IconButton(
          onPressed: () {
            androidBottomSheet(
              context: context,
              child: StatefulBuilder(
                builder: (context, changeState) {
                  return SizedBox(
                    height: 370,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('');
                            },
                            child: Text(
                              'All',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                filterPaymenttLinks('Active');
                              },
                              child: Text(
                                'Active',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500),
                              )),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                filterPaymenttLinks('Inactive');
                              },
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500),
                              )),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('Paid');
                            },
                            child: Text('Paid',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('Cancelled');
                            },
                            child: Text('Cancelled',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('Suspended');
                            },
                            child: Text('Suspended',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('Reserved');
                            },
                            child: Text('Reserved',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              filterPaymenttLinks('Failed');
                            },
                            child: Text('Failed',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: black,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          icon: Icon(
            Icons.more_vert,
            color: blackFont,
          )),
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
        AppLocalization.of(context)!.paymentLink,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addBtn(),
        const SizedBox(width: 12.0),
        getSearchBtn(),
        const SizedBox(width: 12.0),
        _moreOptionsBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getSearchBtn() {
    return SizedBox(
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () =>
              NavigationUtil.push(context, screen: const PaymentLinkSearch()),
        ),
      ),
    );
  }

  Widget addBtn() {
    return SizedBox(
      child: GestureDetector(
        onTap: () =>
            NavigationUtil.push(context, screen: const PaymentLinkScreen()),
        child: Card(
          color: iconBtnGrey,
          elevation: 0,
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              'add_payment'.toSVG(),
            ),
          ),
        ),
      ),
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
                    filterPaymenttLinks('');
                  }
                  break;
                case 'active':
                  {
                    filterPaymenttLinks('Active');
                  }
                  break;
                case 'inactive':
                  {
                    filterPaymenttLinks('Inactive');
                  }
                  break;
                case 'paid':
                  {
                    filterPaymenttLinks('Paid');
                  }
                  break;
                case 'cancelled':
                  {
                    filterPaymenttLinks('Cancelled');
                  }
                  break;
                case 'suspended':
                  {
                    filterPaymenttLinks('Suspended');
                  }
                  break;

                case 'reversed':
                  {
                    filterPaymenttLinks('Reserved');
                  }
                  break;
                case 'failed':
                  {
                    filterPaymenttLinks('Failed');
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext bc) {
              return const [
                PopupMenuItem(
                  child: Text("All"),
                  value: 'all',
                ),
                PopupMenuItem(
                  child: Text("Active"),
                  value: 'active',
                ),
                PopupMenuItem(
                  child: Text("Inactive"),
                  value: 'inactive',
                ),
                PopupMenuItem(
                  child: Text("Paid"),
                  value: 'paid',
                ),
                PopupMenuItem(
                  child: Text("Cancelled"),
                  value: 'cancelled',
                ),
                PopupMenuItem(
                  child: Text("Suspended"),
                  value: 'suspended',
                ),
                PopupMenuItem(
                  child: Text("Reversed"),
                  value: 'reversed',
                ),
                PopupMenuItem(
                  child: Text("Failed"),
                  value: 'failed',
                ),
              ];
            },
          )),
    );
  }

  @override
  void initState() {
    getPaymenttLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 48.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (paymentLinkList.isEmpty)
              Center(
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: NoItemInList(
                    msg: AppLocalization.of(context)!.noResultFound,
                  ),
                ),
              ),
            if (paymentLinkList.isNotEmpty)
              ...paymentLinkList
                  .map((e) => paymentLinkCard(
                      name: e['reference'],
                      amount: e['amount'],
                      date: e['created_at'],
                      currency: e['currency'],
                      passcode: e['pin'],
                      status: e['status'],
                      id: e['id'],
                      category: e['category'],
                      link: e['link'] ?? ''))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
