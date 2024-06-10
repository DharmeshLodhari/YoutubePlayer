import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../data/state_notifier.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../locator.dart';
import '../../../../../services/app_config_bloc.dart';
import '../../../../../widget/curved_btn.dart';

class PreAccountUpgrade extends StatefulWidget {
  const PreAccountUpgrade({Key? key});

  @override
  State<PreAccountUpgrade> createState() => _PreAccountUpgradeState();
}

class _PreAccountUpgradeState extends State<PreAccountUpgrade> {
  late UserBloc userBloc;
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;

    return Scaffold(
      appBar: customAppBar(context: context, title: 'Account Upgrade')
          as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Below are the business account features, Click proceed to continue your upgrade to business account.',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff030F36),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              const Text(
                'You will have access to :',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff030F36),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              listTiles('Web Dashboard'),
              listTiles('Store Listing'),
              listTiles('Invoicing'),
              listTiles('Digital Contract'),
              listTiles('Seamless Payment'),
              listTiles('Business Visibility'),
              const SizedBox(height: 5),
              const Text(
                'and every other social features.',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff030F36),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              CurvedButton(
                text: 'Submit',
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.CHOOSE_SUBSCRIPTIONS);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listTiles(String title) {
    return ListTile(
      // contentPadding: EdgeInsets.zero,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      minLeadingWidth: 0.0,
      minVerticalPadding: 0.0,
      horizontalTitleGap: 10.0,
      dense: false,
      leading: SvgPicture.asset(
        'assets/images/home/tick_subscription.svg',
        width: 20,
        height: 20,
      ),
      title: Text(title),
    );
  }
}
