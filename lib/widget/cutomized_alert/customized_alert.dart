import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/cutomized_alert/alert_style.dart';
import 'package:Slydo/widget/cutomized_alert/animation_transition.dart';
import 'package:Slydo/widget/cutomized_alert/constants.dart';
import 'package:Slydo/widget/cutomized_alert/dialog_button.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class CustomizedAlert {
  final BuildContext context;
  final AlertStyle style;
  final String? image;
  final String? title;
  final String? desc;
  final Widget? content;
  final List<DialogButton>? buttons;
  final Function? closeFunction;
  final RoundedBackgroundIcon? roundedBackgroundIcon;

  CustomizedAlert({
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
    return Center(
      child: ConstrainedBox(
        constraints: style.constraints ??
            const BoxConstraints.expand(
                width: double.infinity, height: double.infinity),
        child: Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: style.backgroundColor ??
                  Theme.of(context).dialogBackgroundColor,
              shape: style.alertBorder ?? _defaultShape(),
              titlePadding: const EdgeInsets.all(0.0),
              title: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Center(
                  child: content ??
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              const SizedBox(
                                height: 24,
                              ),
                              _getImage() ?? Container(),
                              const SizedBox(
                                height: 12,
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
                              SizedBox(
                                height: image != null ? 8 : 20,
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
                                        color: darkGrey,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Inter"),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )
                        ],
                      ),
                ),
              ),
              contentPadding: style.buttonAreaPadding,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getButtons(),
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
      final btnOne = Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: buttons?[0] ?? Container(),
        ),
      );
      expandedButtons.add(btnOne);
      if ((buttons?.length ?? 0) > 1) {
        final btnTwo = Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: buttons?[1] ?? Container(),
          ),
        );
        expandedButtons.add(btnTwo);
      }
    }

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
                    image ?? "",
                    height: 170,
                    width: 170,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    cacheHeight: 170,
                    cacheWidth: 170,
                    frameBuilder: imageFrameBuilder,
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          defaultImage,
                          colorBlendMode: BlendMode.darken,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      );
                    },
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
