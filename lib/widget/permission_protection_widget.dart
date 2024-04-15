import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../locale/app_localization.dart';

class PermissionProtectionWidget extends StatelessWidget {
  PermissionProtectionWidget(
      {required this.child,
      required this.permissionName,
      this.position = 0,
      super.key});

  final Widget child;
  final String permissionName;
  double position;
  late UserBloc userBloc;
  bool hasPermission = false;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    hasPermission = userBloc.user.hasWritePermission(
        permissionName); // if user have permission for given variable

    return !hasPermission
        ? GestureDetector(
            onTap: () {
              showSnackbar(context,
                  message: AppLocalization.of(context)?.doNotPermission ?? "");
            },
            child: Stack(
              children: [
                child,
                if (!hasPermission)
                  Positioned(
                    top: position, // Adjust the top value as needed
                    right: -3, // Adjust the right value as needed
                    child: SvgPicture.asset(
                      'home/padlock'.toSVG(),
                      color: darkGreyYarn,
                    ),
                  ),
              ],
            ),
          )
        : child;

    // return Stack(
    //   children: [
    //     GestureDetector(
    //       onTap: hasPermission
    //           ? null
    //           : () {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text(
    //                       AppLocalization.of(context)?.doNotPermission ?? ""),
    //                 ),
    //               );
    //             },
    //       child: child,
    //     ),
    //     if (!hasPermission)
    //       // Align(
    //       //   alignment: alignment,
    //       //   child: SvgPicture.asset(
    //       //     'home/padlock'.toSVG(),
    //       //     color: darkGreyYarn,
    //       //   ),
    //       // ),
    //       Positioned(
    //         top: 0, // Adjust the top value as needed
    //         right: -3, // Adjust the right value as needed
    //         child: SvgPicture.asset(
    //           'home/padlock'.toSVG(),
    //           color: darkGreyYarn,
    //         ),
    //       ),
    //   ],
    // );
  }
}
