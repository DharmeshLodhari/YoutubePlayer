import 'dart:async';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'circle.dart';
import 'keyboard.dart';
import 'shake_curve.dart';

typedef PasswordEnteredCallback = void Function(String text);
typedef IsValidCallback = void Function();
typedef CancelCallback = void Function();

class CustomizedPassCodeScreen extends StatefulWidget {
  final Widget title;
  final int passwordDigits;
  final Color backgroundColor;
  final PasswordEnteredCallback passwordEnteredCallback;

  //isValidCallback will be invoked after passcode screen will pop.
  final IsValidCallback isValidCallback;
  final CancelCallback cancelCallback;

  // Cancel button and delete button will be switched based on the screen state
  final Widget cancelButton;
  final Widget deleteButton;
  final Stream<bool> shouldTriggerVerification;
  final Widget bottomWidget;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;
  final List<String> digits;

  CustomizedPassCodeScreen({
    Key key,
    @required this.title,
    this.passwordDigits = 6,
    @required this.passwordEnteredCallback,
    @required this.cancelButton,
    @required this.deleteButton,
    @required this.shouldTriggerVerification,
    this.isValidCallback,
    CircleUIConfig circleUIConfig,
    KeyboardUIConfig keyboardUIConfig,
    this.bottomWidget,
    this.backgroundColor,
    this.cancelCallback,
    this.digits,
  })  : circleUIConfig =
            circleUIConfig == null ? const CircleUIConfig() : circleUIConfig,
        keyboardUIConfig = keyboardUIConfig == null
            ? const KeyboardUIConfig()
            : keyboardUIConfig,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomizedPassCodeScreenState();
}

class _CustomizedPassCodeScreenState extends State<CustomizedPassCodeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  AnimationController controller;
  Animation<double> animation;

  @override
  initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerVerification
        .listen((isValid) => _showValidation(isValid));
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enteredPasscode = '';
            controller.value = 0;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildPortraitPasscodeScreen(),
    );
  }

  _buildPortraitPasscodeScreen() => Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    height: 150,
                    child: Column(
                      children: [
                        flexibleSpace(),
                        widget.title,
                        flexibleSpace(flex: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildCircles(),
                        ),
                        flexibleSpace(flex: 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 225,
                      color: HexColor("#F7F8FA"),
                      child: _buildKeyboard(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildDeleteButton(),
              ),
            ),
          ],
        ),
      );

  _buildLandscapePasscodeScreen() => Stack(
        children: [
          Positioned(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.title,
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildCircles(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        widget.bottomWidget != null
                            ? Positioned(
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: widget.bottomWidget),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  _buildKeyboard(),
                ],
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomRight,
              child: _buildDeleteButton(),
            ),
          )
        ],
      );

  _buildKeyboard() => Container(
        child: Keyboard(
          onKeyboardTap: _onKeyboardButtonPressed,
          keyboardUIConfig: widget.keyboardUIConfig,
          digits: widget.digits,
        ),
      );

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig;
    var extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: HexColor("#BEC2F4")),
          child: Circle(
            filled: i < enteredPasscode.length,
            circleUIConfig: CircleUIConfig(
                fillColor: navyBlue,
                borderColor:
                    i < enteredPasscode.length ? navyBlue : HexColor("#BEC2F4"),
                circleSize: 16),
            extraSize: extraSize,
          ),
        ),
      );
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.length > 0) {
      setState(() {
        enteredPasscode =
            enteredPasscode.substring(0, enteredPasscode.length - 1);
      });
    } else {
      // Navigator.pop(context);
      if (widget.cancelCallback != null) {
        widget.cancelCallback();
      }
    }
  }

  _onKeyboardButtonPressed(String text) {
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        if (enteredPasscode.length == widget.passwordDigits) {
          widget.passwordEnteredCallback(enteredPasscode);
        }
      }
    });
  }

  @override
  didUpdateWidget(CustomizedPassCodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification
          .listen((isValid) => _showValidation(isValid));
    }
  }

  @override
  dispose() {
    controller.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  _showValidation(bool isValid) {
    if (isValid) {
      Navigator.maybePop(context).then((pop) => _validationCallback());
    } else {
      controller.forward();
    }
  }

  _validationCallback() {
    if (widget.isValidCallback != null) {
      widget.isValidCallback();
    } else {
      print(
          "You didn't implement validation callback. Please handle a state by yourself then.");
    }
  }

  Widget _buildDeleteButton() {
    return Container(
      child: CupertinoButton(
        onPressed: _onDeleteCancelButtonPressed,
        child: Container(
          child: enteredPasscode.length == 0
              ? widget.cancelButton
              : widget.deleteButton,
        ),
      ),
    );
  }
}
