import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../constant.dart';
import '../../../../../main.dart';

class CreditCardOptionSelection extends StatefulWidget {
  CreditCardOptionSelection({Key? key}) : super(key: key);

  @override
  State<CreditCardOptionSelection> createState() =>
      _CreditCardOptionSelectionState();
}

class _CreditCardOptionSelectionState extends State<CreditCardOptionSelection> {
  late AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    getAppConfigurationModelFromLocalStorage();
  }

  getAppConfigurationModelFromLocalStorage() async {
    var str = await getStorage.read(appFeaturesKey);
    if(str != null){
      appConfigurationModel = AppConfigurationModel.deserialize(str!);
    }
  }

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
                      if (appConfigurationModel?.enableAddUserCreditCard ==
                          true) {
                        Navigator.of(context)
                            .pushNamed(Routes.CREDIT_CARD_LIST);
                      } else {
                        showToast(message: 'Coming soon');
                      }
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
        SizedBox(height: 20),
      ],
    );
  }
}
