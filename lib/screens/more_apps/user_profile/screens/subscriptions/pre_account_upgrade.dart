import 'dart:async';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../locator.dart';
import '../../../../../services/app_config_bloc.dart';
import '../../../../../services/auth.dart';
import '../../../../../widget/LoadingIndicator.dart';
import '../../../../../widget/curved_btn.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../../../../widget/dialog.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../user_auth.dart';

class PreAccountUpgrade extends StatefulWidget {
  const PreAccountUpgrade({Key? key}) : super(key: key);

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
          padding: EdgeInsets.only(right: 20, left: 20, top: 24),
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

              ListTiles('Web Dashboard'),
              ListTiles('Store Listing'),
              ListTiles('Invoicing'),
              ListTiles('Digital Contract'),
              ListTiles('Seamless Payment'),
              ListTiles('Business Visibility'),

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

  Widget ListTiles(String title){
    return  ListTile(
      // contentPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
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

