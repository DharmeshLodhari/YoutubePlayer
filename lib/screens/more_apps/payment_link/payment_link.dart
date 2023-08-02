import 'package:Slydo/screens/more_apps/payment_link/payment_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
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

  Map<String, dynamic> map = {
    'data': [
      {
        'name': 'Josh',
        'amount': '36,000.00',
        'status': 'Pending',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Service Payment',
        'amount': '1,000,000.00',
        'status': 'Successful',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Payment for the goods',
        'amount': '23,000.00',
        'status': 'Cancelled',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Food',
        'amount': '345,000.00',
        'status': 'Pending',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Payment for ABC',
        'amount': '56,000.00',
        'status': 'Processing',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Nute',
        'amount': '536,000.00',
        'status': 'Successful',
        'date': '18/08/2022 • 2:36 PM',
      },
      {
        'name': 'Josh',
        'amount': '36,000.00',
        'status': 'Pending',
        'date': '18/08/2022 • 2:36 PM',
      },
    ]
  };

  Widget paymentLinkCard({String? name, String? date, amount, status}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: () => NavigationUtil.push(
          context,
          screen: TransactionPaymentLink(
            date: date,
            amount: amount,
            status: status,
            name: name,
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
                      CustomText(
                        title: name ?? '',
                        fontSize: 14,
                        fontweight: FontWeight.w700,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        date ?? '',
                        style: const TextStyle(
                          color: Color(0xff8d92a3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        title: '₦${amount ?? ''}',
                        fontSize: 16,
                        fontweight: FontWeight.w700,
                      ),
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
        popUpMenuButton(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getSearchBtn() {
    return SizedBox(
      height: 36,
      width: 36,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {},
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
          margin: EdgeInsets.symmetric(
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
      // key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.filter_alt_rounded,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.listMap == null) {
      return;
    } else {
      map['data'] == widget.listMap;
    }
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
            if (widget.listMap != null)
              ...widget.listMap!
                  .map((e) => paymentLinkCard(
                      name: e['name'],
                      amount: e['amount'],
                      date: e['date'],
                      status: e['status']))
                  .toList(),
            ...map['data']!.map((e) => paymentLinkCard(
                name: e['name'],
                amount: e['amount'],
                date: e['date'],
                status: e['status']))
          ],
        ),
      ),
    );
  }
}
