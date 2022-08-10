import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class WalletOptionsSelection extends StatefulWidget {
  @override
  _WalletOptionsSelectionState createState() => _WalletOptionsSelectionState();
}

class _WalletOptionsSelectionState extends State<WalletOptionsSelection> {
  final GlobalKey<ScaffoldState> _scaffoldTopUpOptionSelectionKey =
      new GlobalKey<ScaffoldState>();

  late AppLocalization appLocalization;

  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context)!;

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
                          .pushNamed(Routes.ADD_MONEY_TO_SLYDO_ONE);
                    }),
                getSettingTile(
                  title: AppLocalization.of(context)!.creditDebitCard,
                  icon: Icons.credit_card,
                  iconColor: naturalGreen,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.CREDIT_CARD_OPTION_SELECTION);
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
