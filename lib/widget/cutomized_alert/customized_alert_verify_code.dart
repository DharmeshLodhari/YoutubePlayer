import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/animation_transition.dart';
import 'package:Slydo/widget/cutomized_alert/constants.dart';
import 'package:Slydo/widget/cutomized_alert/dialog_button.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CustomizedAlertVerifyCode {
  final BuildContext context;
  final AlertStyle style;
  final String? title;
  final String? desc;
  final Widget? content;
  final List<DialogButton>? buttons;
  final Function? closeFunction;
  final RoundedBackgroundIcon? roundedBackgroundIcon;
  TextEditingController? codeController;
  final FocusNode _pinPutFocusNode = FocusNode();
  final bool isCloseIconShow;

  CustomizedAlertVerifyCode({
    required this.context,
    this.style = const AlertStyle(),
    required this.title,
    this.roundedBackgroundIcon,
    this.desc,
    this.content,
    this.buttons,
    this.closeFunction,
    this.codeController,
    this.isCloseIconShow = false,
  });

  /// Displays defined alert window
  Future<bool?> show() async {
    return await showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return _buildDialog();
      },
      barrierDismissible: style.isOverlayTapDismiss,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: style.overlayColor,
      transitionDuration: style.animationDuration,
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          _showAnimation(animation, secondaryAnimation, child),
    );
  }

  // Alert dialog content widget
  Widget _buildDialog() {
    final defaultPinTheme = PinTheme(
      height: 40,
      width: 40,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: darkGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      textStyle: TextStyle(
        fontSize: 35,
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: style.constraints ??
            const BoxConstraints.expand(
                width: double.infinity, height: double.infinity),
        child: Center(
          child: SingleChildScrollView(
            child: PopScope(
              canPop: false,
              child: AlertDialog(
                insetPadding: EdgeInsets.zero,
                backgroundColor: style.backgroundColor ?? white,
                shape: style.alertBorder ?? _defaultShape(),
                titlePadding: const EdgeInsets.all(0.0),
                title: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Center(
                    child: content ??
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 20,
                                ),
                                if (isCloseIconShow)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  title ?? "",
                                  style: TextStyle(
                                      color: blackFont,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Inter",
                                      fontSize: 16.0),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (desc == null)
                                  Container()
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Text(
                                      desc ?? "",
                                      style: TextStyle(
                                        color: blackFont,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Inter",
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Pinput(
                                    obscureText: true,
                                    obscuringCharacter: '•',
                                    showCursor: false,
                                    validator: (val) => val!.length < 4
                                        ? AppLocalization.of(context)!
                                            .invalidPassword
                                        : null,
                                    length: 4,
                                    focusNode: _pinPutFocusNode,
                                    controller: codeController,
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration!.copyWith(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: navyBlue),
                                      ),
                                    ),
                                    submittedPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration!.copyWith(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: navyBlue),
                                      ),
                                    ),
                                    errorPinTheme:
                                        defaultPinTheme.copyBorderWith(
                                      border:
                                          Border.all(color: Colors.redAccent),
                                    ),
                                    pinAnimationType: PinAnimationType.scale,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                  ),
                ),
                contentPadding: style.buttonAreaPadding,
                content: Column(
                  children: _getButtons(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns alert default border style
  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  // Returns defined buttons. Default: Cancel Button
  List<Widget> _getButtons() {
    final List<Widget> expandedButtons = [];
    if (buttons != null) {
      final btnOne = Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: buttons?[0] ?? Container(),
      );
      expandedButtons.add(btnOne);
      if ((buttons?.length ?? 0) > 1) {
        final btnTwo = Padding(
          padding: const EdgeInsets.all(10.0),
          child: buttons?[1] ?? Container(),
        );
        expandedButtons.add(btnTwo);
      }
    }

    return expandedButtons;
  }

// Shows alert with selected animation
  AnimatedWidget _showAnimation(animation, secondaryAnimation, child) {
    if (style.animationType == AnimationType.fromRight) {
      return AnimationTransition.fromRight(
          animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.fromLeft) {
      return AnimationTransition.fromLeft(animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.fromBottom) {
      return AnimationTransition.fromBottom(
          animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.grow) {
      return AnimationTransition.grow(animation, secondaryAnimation, child);
    } else if (style.animationType == AnimationType.shrink) {
      return AnimationTransition.shrink(animation, secondaryAnimation, child);
    } else {
      return AnimationTransition.fromTop(animation, secondaryAnimation, child);
    }
  }
}
