import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../routes/route_constants.dart';
import '../user_auth.dart';

// ignore: must_be_immutable
class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  String newPassword = "";
  String oldPassword = "";
  String confirmPassword = "";

  TextEditingController? _newPasswordController;
  TextEditingController? _oldPasswordController;
  TextEditingController? _confirmPasswordController;

  @override
  void initState() {
    _newPasswordController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    super.initState();
  }

  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: appBar() as PreferredSizeWidget?,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: MediaQuery.of(context).size.height -
                    (AppBar().preferredSize.height +
                        MediaQuery.of(context).padding.top),
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      oldPasswordWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      newPasswordWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      confirmPasswordWidget(),
                      const SizedBox(
                        height: 40,
                      ),
                      changePasswordBtn(),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Change password",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget oldPasswordWidget() {
    return CustomizedTextFormField(
      maxLength: 6,
      obscureText: true,
      keyboardType: TextInputType.number,
      labelText: "Current password",
      controller: _oldPasswordController,
      isPassword: true,
      validator: validateOldEnteredPassword,
      onChanged: (val) {
        oldPassword = val;
      },
    );
  }

  Widget newPasswordWidget() {
    return CustomizedTextFormField(
      maxLength: 6,
      obscureText: true,
      keyboardType: TextInputType.number,
      labelText: "New password",
      controller: _newPasswordController,
      isPassword: true,
      validator: validateEnteredPassword,
      onChanged: (val) {
        newPassword = val;
      },
    );
  }

  Widget confirmPasswordWidget() {
    return CustomizedTextFormField(
      obscureText: true,
      maxLength: 6,
      labelText: "Confirm password",
      isPassword: true,
      controller: _confirmPasswordController,
      keyboardType: TextInputType.number,
      validator: validateEnteredConfirmPassword,
      onChanged: (val) {
        confirmPassword = val;
      },
    );
  }

  // validate old password
  String? validateOldEnteredPassword(String val) {
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    }
    return null;
  }

  String? validateEnteredPassword(String val) {
    ///regexp for repeated number
    final matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  // validate confirm password
  String? validateEnteredConfirmPassword(String val) {
    final matcher = RegExp(
      r'^(.)\1{1,}$',
      caseSensitive: true,
    );
    if (val.length != 6) {
      return AppLocalization.of(context)!.invalidPassword;
    } else if (val != _newPasswordController!.text) {
      return AppLocalization.of(context)!.passwordMismatch;
    } else if ("0123456789".contains(val)) {
      return "you can not set this type of password";
    } else if ("9876543210".contains(val)) {
      return "you can not set this type of password";
    } else if (matcher.hasMatch(val)) {
      return "you can not set this type of password";
    }
    return null;
  }

  Widget changePasswordBtn() {
    return CurvedButton(
      onPressed: verifyPassword,
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Change Password",
    );
  }

  void verifyPassword() async {
    //for closing the keypad if it is open
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    if (_formKey.currentState!.validate()) {
      debugPrint("userBloc.user.password ${userBloc.user.password}");
      if (userBloc.user.password == oldPassword) {
        final data = {
          "new_password1": newPassword,
          "new_password2": confirmPassword,
          "old_password": oldPassword,
        };

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
                  child: CircularLoadingIndicator(),
                ));

        await UserAuth().changePassword(data).then((value) async {
          if (value.isNotEmpty) {
            userBloc.user.password = value["new_password"];

            await storePasswordInSecureStorage(
                password: userBloc.user.password);
            await storePasswordInDB(password: userBloc.user.password);

            showToast(message: "Password updated successfully !!");

            Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
          } else {
            Navigator.pop(context);
          }
        }).catchError((error) {
          showToast(message: error.toString());
          Navigator.pop(context);
          debugPrint("ERROR:- $error");
        });
      } else {
        showToast(message: "Please enter a correct password !!");
      }
    }
  }

  Future<void> storePasswordInSecureStorage({String? password}) async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final bool? isRemember = _sharedPreferences.getBool('isChecked');
    if (isRemember != null && isRemember) {
      await SecureStorage().updateUserPassword(password: password);
    }
  }

  Future<void> storePasswordInDB({String? password}) async {
    final int result = await DatabaseHelper().updateUserPassword(password!);
    debugPrint("RESULT:- Password update:- $result");
  }
}
