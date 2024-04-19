import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/currency.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/debouncer_widget.dart';
import '../../../widget/dialog.dart';
import '../../../widget/no_item_in_list.dart';
import '../../../widget/rounded_background_icon.dart';
import '../../../widget/slide_action_button.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';
import '../service_hub/screens/my_job_details.dart';
import 'payment_transaction_info.dart';

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

  final ScrollController _scrollController = ScrollController();

  SlidableController? _slideController;

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  Future<void> getPaymenttLinks({String? searchLink}) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final dynamic result =
            await _auth.getPaymentLinks(searchLink: searchLink);
        log('payment link search screen results::::: ${result.toString()}');

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];
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

  Widget paymentLinkCard({
    String? name,
    String? date,
    String? id,
    String? amount,
    String? currency,
    String? status,
    String? passcode,
    String? link,
    String? category,
  }) {
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
            link: link,
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
                      getAmount(int.parse(amount ?? ""), currency ?? ""),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getPaymenttLinks();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
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

  void rejectRequestAlert(Map data, int index) async {
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
      title: AppLocalization.of(context)!.cancel,
      description:
          "Are you sure want to cancel the payment link, your payment link fee of ${worldCurrencies[data['currency']]}35 will not be refunded?",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: "Ignore",
    );
    if (result != null && result) {
      final bool done = true;
      if (done) {
        setState(() {
          // paymentLinkList.removeAt(index);
          // getPaymenttLinks();
        });
      }
    }
  }

  List<Widget> listActionSlideActions(Map data, int index) {
    return data['status'].toString().toLowerCase() != 'active'
        ? []
        : [
            SlideActionButton(
              backgroundColor: mateRed,
              icon: SlydoAppIcon.cancel_connection_request,
              onTap: () {
                rejectRequestAlert(data, index);
              },
              title: AppLocalization.of(context)!.cancel,
              slideController: _slideController,
            ),
          ];
  }

  Widget _getSlidableWithLists(BuildContext context, Map e, int index) {
    return Slidable(
      key: Key(e["id"].toString()),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: listActionSlideActions(e, index),
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
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
            itemCount: paymentLinkList.length,
            itemBuilder: (BuildContext context, int index) {
              return _getSlidableWithLists(
                  context, paymentLinkList[index], index);
            },
            controller: _scrollController,
          );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 6),
          searchBox(),
          const SizedBox(height: 12),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: greyBorderColor,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
          else
            const SizedBox.shrink(),
          if (isSearchIsEmpty)
            Expanded(
              child: NoItemInList(
                msg:
                    AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
                isResult: false,
              ),
            )
          else
            noItemInList
                ? Expanded(
                    child: NoItemInList(
                      msg: AppLocalization.of(context)!.noResultFound,
                    ),
                  )
                : Expanded(
                    child: _buildFriendsList(),
                  ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          key: const ValueKey('Search'),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefix: const Padding(
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
