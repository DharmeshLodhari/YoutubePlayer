import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class TopUpOptionSelection extends StatefulWidget {
  @override
  _TopUpOptionSelectionState createState() => _TopUpOptionSelectionState();
}

class _TopUpOptionSelectionState extends State<TopUpOptionSelection> {
  final GlobalKey<ScaffoldState> _scaffoldTopUpOptionSelectionKey =
      new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldTopUpOptionSelectionKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: customAppBar(
        title: 'Top Up',
        context: context,
      ) as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
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
                  title: AppLocalization.of(context)!.creditDebitCard,
                  icon: Icons.credit_card,
                  iconColor: naturalGreen,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/credit-card-option-selection');
                  },
                ),
                getSettingTile(
                    title: AppLocalization.of(context)!.virtualAccount,
                    icon: Icons.account_balance_wallet,
                    iconColor: HexColor("#3F61DB"),
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed('/add-money-to-slydo-one');
                    }),
                getSettingTile(
                  title: AppLocalization.of(context)!.bankAccount,
                  icon: Icons.account_balance,
                  iconColor: HexColor("#F35B46"),
                  onTap: () {
                    Navigator.of(context).pushNamed('/bank-account-list');
                  },
                ),
              ],
            ),
          ),
        )),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
