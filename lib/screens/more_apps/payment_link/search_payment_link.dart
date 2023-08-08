import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/debouncer_widget.dart';
import '../../../widget/noItemInList.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';
import '../service_hub/screens/my_job_details.dart';
import 'paayment_transaction_info.dart';

class PaymentLinkSearch extends StatefulWidget {
  const PaymentLinkSearch({Key? key}) : super(key: key);

  @override
  State<PaymentLinkSearch> createState() => _PaymentLinkSearchState();
}

class _PaymentLinkSearchState extends State<PaymentLinkSearch> {
  final TextEditingController searchController = TextEditingController();

  final _debouncer = Debouncer(milliseconds: 500);

  int? count = 0;
  String? next = "";
  String? previous = "";
  List paymentLinkList = [];
  bool isLoading = false;
  bool noItemInList = false;
  bool isSearchIsEmpty = true;

  final _auth = PaymentAndBankingAuth();

  getPaymenttLinks({searchLink}) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        dynamic result = await _auth.getPaymentLinks(searchLink: searchLink);
        log('payment link search screen results::::: ${result.toString()}');

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        var tempList = result['results'];
        noItemInList = false;
        isLoading = false;
        paymentLinkList.addAll(tempList);
        isSearchIsEmpty = false;

        if (mounted) setState(() {});
      }
    }
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

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
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
      title: Text(
        "Search",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
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
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 6),
          searchBox(),
          SizedBox(height: 12),
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: greyBorderColor,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 14,
                      mainAxisExtent: 180,
                      crossAxisSpacing: 15,
                      maxCrossAxisExtent: 200,
                    ),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox.shrink(),
          isSearchIsEmpty
              ? Expanded(
                  child: NoItemInList(
                    msg: AppLocalization.of(context)!
                        .pleaseTypeSomethingToGetResult,
                    isResult: false,
                  ),
                )
              : noItemInList
                  ? Expanded(
                      child: NoItemInList(
                        msg: AppLocalization.of(context)!.noResultFound,
                      ),
                    )
                  : Expanded(
                      child: ListView(
                          padding: const EdgeInsets.all(22),
                          children: [
                            if (paymentLinkList.isNotEmpty)
                              ...paymentLinkList
                                  .map((e) => paymentLinkCard(
                                      name: e['reference'],
                                      amount: e['amount'],
                                      date: e['created_at'],
                                      currency: e['currency'],
                                      category: e['category'],
                                      passcode: e['pin'],
                                      id: e['id'],
                                      status: e['status']))
                                  .toList(),
                          ]),
                    ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          key: ValueKey('Search'),
          controller: searchController,
          onChanged: (value) {
            if (value.length >= 3) {
              _debouncer.run(() {
                setState(() {
                  count = 0;
                  next = "";
                  previous = "";
                  paymentLinkList.clear();
                  noItemInList = false;
                  getPaymenttLinks(searchLink: searchController.text);
                });
              });
            }
          },
          onFieldSubmitted: (val) {},
          autofocus: true,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            hintText: "",
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefix: Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
