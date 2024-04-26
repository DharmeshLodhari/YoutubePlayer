import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../locator.dart';

class CreditCardOptionSelection extends StatefulWidget {
  CreditCardOptionSelection({Key? key}) : super(key: key);

  @override
  State<CreditCardOptionSelection> createState() =>
      _CreditCardOptionSelectionState();
}

class _CreditCardOptionSelectionState extends State<CreditCardOptionSelection> {
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();

    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
  }

  @override
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getChatSettingTitle(),
                const SizedBox(
                  height: 8,
                ),
                getSettingTile(
                    title: AppLocalization.of(context)!.myCreditAndDebitCards,
                    icon: Icons.credit_card,
                    iconColor: naturalGreen,
                    onTap: () async {
                      // if (appConfigurationModel?.enableAddUserCreditCard ==
                      //     true) {
                      //   Navigator.pushNamed(context, Routes.GET_VIRTUAL_CARD);
                      //   // Navigator.pushNamed(context, Routes.VIRTUAL_CARD_HOME);
                      // } else {
                      //   showToast(message: 'Coming soon');
                      // }
                      Navigator.pushNamed(context, Routes.VIRTUAL_CARD_HOME);
                    }),
                getSettingTile(
                  title:
                      AppLocalization.of(context)!.topUpWithCreditAndDebitCard,
                  icon: Icons.account_balance_wallet,
                  image: SvgPicture.asset('assets/images/top_up_icon.svg'),
                  iconColor: HexColor("#3F61DB"),
                  onTap: () {
                    if (appConfigurationModel
                            ?.enableWalletTopupWithCreditCard ==
                        true) {
                      Navigator.of(context)
                          .pushNamed(Routes.CARD_PAYMENT_PAGE, arguments: true);
                    } else {
                      showToast(message: 'Coming soon');
                    }
                  },
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }
}
