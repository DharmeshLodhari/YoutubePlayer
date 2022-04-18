import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import '../screens/more_apps/utility/select_provider_screen.dart';
import '../utils/enums.dart';
import '../utils/navigation_util.dart';

// ignore: must_be_immutable
class UtilityDashboardItemTile extends StatelessWidget {
  String title;
  IconData icon;
  Color iconColor;
  double height;
  double titleFontSize;
  UtilitiesProvidersEnum providersEnum;

  UtilityDashboardItemTile(
      {required this.title,
      this.titleFontSize = 14,
      required this.providersEnum,
      required this.icon,
      required this.iconColor,
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        height: height,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              flexibleSpace(flex: 3),
              RoundedBackgroundIcon(
                height: 50,
                width: 50,
                icon: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                backgroundColor: iconColor.withOpacity(0.08),
                borderRadius: 20,
                onTap: () {
                  NavigationUtil.push(
                    context,
                    screen: SelectProviderScreen(
                      nameOfProvider: title,
                      providerEnum: providersEnum,
                    ),
                  );
                },
              ),
              flexibleSpace(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: titleFontSize),
              ),
              flexibleSpace(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
