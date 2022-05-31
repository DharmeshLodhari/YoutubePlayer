import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CreditCardOptionSelection extends StatelessWidget {
  CreditCardOptionSelection({Key? key}) : super(key: key);

  AppConfigurationBloc? appConfiguration;

  Widget build(BuildContext context) {
    appConfiguration = Provider.of<AppConfigurationBloc>(context);

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
                      Navigator.of(context).pushNamed(Routes.CREDIT_CARD_LIST);
                    }),
                getSettingTile(
                    title: AppLocalization.of(context)!
                        .topUpWithCreditAndDebitCard,
                    icon: Icons.account_balance_wallet,
                    image: SvgPicture.asset('assets/images/top_up_icon.svg'),
                    iconColor: HexColor("#3F61DB"),
                    onTap: () async {
                      if (appConfiguration!
                          .appConfigurationModel!.creditCardWorks) {
                        Navigator.of(context).pushNamed(
                            Routes.CARD_PAYMENT_PAGE,
                            arguments: true);
                      } else {
                        showToast(message: 'Cannot top up at the moment.');
                      }
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
