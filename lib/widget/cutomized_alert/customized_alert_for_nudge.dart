import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/animation_transition.dart';
import 'package:Slydo/widget/cutomized_alert/constants.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class CustomizedAlertForNudge {
  final BuildContext? context;
  final AlertStyle style;
  final String? image;
  final String? title;
  final String? desc;
  final Widget? content;
  final List<Widget>? buttons;
  final Function? closeFunction;
  final RoundedBackgroundIcon? roundedBackgroundIcon;

  CustomizedAlertForNudge({
    required this.context,
    this.style = const AlertStyle(),
    this.image,
    required this.title,
    this.roundedBackgroundIcon,
    this.desc,
    this.content,
    this.buttons,
    this.closeFunction,
  });

  /// Displays defined alert window
  Future<bool?> show() async {
    return await showGeneralDialog(
      context: context!,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return _buildDialog();
      },
      barrierDismissible: style.isOverlayTapDismiss,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
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
    return Center(
      child: ConstrainedBox(
        constraints: style.constraints ??
            BoxConstraints.expand(
                width: double.infinity, height: double.infinity),
        child: Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: style.backgroundColor ??
                  Theme.of(context!).dialogBackgroundColor,
              shape: style.alertBorder ?? _defaultShape(),
              titlePadding: EdgeInsets.all(0.0),
              title: Container(
                width: MediaQuery.of(context!).size.width - 40,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 24,
                          ),
                          _getImage()!,
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            title!,
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: image != null ? 8 : 20,
                          ),
                          desc == null
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    desc!,
                                    style: TextStyle(
                                        color: blackFont, fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          SizedBox(
                            height: 4,
                          ),
                          content == null ? Container() : content!,
                        ],
                      )
                    ],
                  ),
                ),
              ),
              contentPadding: style.buttonAreaPadding,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getButtons()!,
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
  List<Widget>? _getButtons() {
    List<Widget>? expandedButtons = buttons;
    // if (buttons != null) {
    //   var btnOne = Expanded(
    //     child: Padding(
    //       padding: EdgeInsets.only(right: 8.0),
    //       child: buttons[0],
    //     ),
    //   );
    //
    //   var btnTwo = Expanded(
    //     child: Padding(
    //       padding: EdgeInsets.only(left: 8.0),
    //       child: buttons[1],
    //     ),
    //   );
    //   expandedButtons.add(btnOne);
    //   expandedButtons.add(btnTwo);
    // }

    return expandedButtons;
  }

// Returns alert image for icon
  Widget? _getImage() {
    return roundedBackgroundIcon != null
        ? roundedBackgroundIcon
        : image != null
            ? Container(
                child: ClipOval(
                  child: Image.network(
                    image!,
                    height: 170,
                    width: 170,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    cacheHeight: 170,
                    cacheWidth: 170,
                    frameBuilder: imageFrameBuilder,
                  ),
                ),
              )
            : Container();
  }

// Shows alert with selected animation
  _showAnimation(animation, secondaryAnimation, child) {
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
