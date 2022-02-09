import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SubscriptionType { ANNUALLY, MONTHLY, WEEKLY }

// _subscriptionType can be null
SubscriptionType? _subscriptionType;

class ChooseSubscription extends StatefulWidget {
  const ChooseSubscription({Key? key}) : super(key: key);

  @override
  State<ChooseSubscription> createState() => _ChooseSubscriptionState();
}

class _ChooseSubscriptionState extends State<ChooseSubscription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: 'Subscription')
          as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset('assets/images/subscription_img.svg'),
            SizedBox(height: 20),
            Text(
              'Choose your plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff030F36),
                  fontWeight: FontWeight.w700),
            ),
            SubscriptionTile(
              amount: '200,000',
              subscriptionType: SubscriptionType.ANNUALLY,
              onTap: () =>
                  setState(() => _subscriptionType = SubscriptionType.ANNUALLY),
            ),
            SubscriptionTile(
              amount: '100,000',
              tagName: 'Most Popular',
              subscriptionType: SubscriptionType.MONTHLY,
              onTap: () =>
                  setState(() => _subscriptionType = SubscriptionType.MONTHLY),
            ),
            SubscriptionTile(
              amount: '100,000',
              tagName: '1 Week Free Trial',
              subscriptionType: SubscriptionType.WEEKLY,
              onTap: () =>
                  setState(() => _subscriptionType = SubscriptionType.WEEKLY),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionTile extends StatelessWidget {
  final String amount;
  final String? tagName;
  final Function() onTap;
  final SubscriptionType subscriptionType;
  const SubscriptionTile(
      {Key? key,
      this.tagName,
      required this.onTap,
      required this.amount,
      required this.subscriptionType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
            side: _subscriptionType == subscriptionType
                ? BorderSide(color: navyBlue)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subscriptionType.toString().split('.').last,
                    style: TextStyle(
                      color: Color(0Xff75818F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _subscriptionType == subscriptionType
                      ? CircleAvatar(
                          radius: 14,
                          backgroundColor: navyBlue,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(Icons.check,
                                size: 20, color: Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.radio_button_unchecked_outlined,
                        ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(SlydoAppIcon.naira, size: 16),
                  Text(
                    amount,
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff030F36),
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(height: 10),
              tagName != null
                  ? Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: navyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        tagName!,
                        style: TextStyle(
                            color: navyBlue, fontWeight: FontWeight.w400),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 10),
              Text(
                'then £17.99 per month. Cancel anytime',
                style: TextStyle(
                  color: Color(0xff030F36),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
