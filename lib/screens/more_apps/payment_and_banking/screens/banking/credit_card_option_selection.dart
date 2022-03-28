import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreditCardOptionSelection extends StatelessWidget {
  const CreditCardOptionSelection({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: customAppBar(
        title: AppLocalization.of(context)!.cards,
        context: context,
      ) as PreferredSizeWidget?,
      body: scaffoldBody(context),
    );
  }

  Widget scaffoldBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getChatSettingTitle(),
                SizedBox(
                  height: 8,
                ),
                getSettingTile(
                    title: AppLocalization.of(context)!.myCreditAndDebitCards,
                    icon: Icons.credit_card,
                    iconColor: naturalGreen,
                    onTap: () async {
                      Navigator.of(context).pushNamed('/credit-card-list');
                    }),
                getSettingTile(
                    title: AppLocalization.of(context)!
                        .topUpWithCreditAndDebitCard,
                    icon: Icons.account_balance_wallet,
                    image: SvgPicture.asset('assets/images/top_up_icon.svg'),
                    iconColor: HexColor("#3F61DB"),
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed('/card-payment-page', arguments: true);
                    }),
              ],
            ),
          ),
        )),
        SizedBox(height: 20),
      ],
    );
  }
}
