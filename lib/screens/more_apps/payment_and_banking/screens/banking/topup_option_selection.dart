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
        title: AppLocalization.of(context)!.wallet,
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
                    title: AppLocalization.of(context)!.myWallet,
                    icon: Icons.account_balance_wallet,
                    iconColor: HexColor("#3F61DB"),
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed('/add-money-to-slydo-one');
                    }),
                getSettingTile(
                  title: AppLocalization.of(context)!.creditDebitCard,
                  icon: Icons.credit_card,
                  iconColor: naturalGreen,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/credit-card-option-selection');
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
