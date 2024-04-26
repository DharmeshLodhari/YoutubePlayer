import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../payment_and_banking/payment_and_banking_auth.dart';

class AddShippingOptions extends StatefulWidget {
  final Function(bool)? callback;

  AddShippingOptions({this.callback});

  // Declare a field that holds the userData.
  @override
  _AddShippingOptionsState createState() => _AddShippingOptionsState();
}

class _AddShippingOptionsState extends State<AddShippingOptions> {
  TextEditingController _amountController = TextEditingController();
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final _addShippingOptionScaffold = GlobalKey<ScaffoldState>();
  final _addShippingOptionScaffoldMessenger =
      GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;

  double? amount = 0.0;
  String errorMessage = "";
  String location = '';
  bool isLoading = false;

  @override
  void initState() {
    _amountController = TextEditingController(text: '');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _addShippingOptionScaffoldMessenger,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _addShippingOptionScaffold,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(context),
      ),
    );
  }

  Widget scaffoldBody(BuildContext context) {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    if (isLoading == true) {
      return _buildLoadingIndicator();
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: iconBtnGrey,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBtnGrey, width: 1)),
                child: Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              getLocation(),
                              const SizedBox(
                                height: 20,
                              ),
                              displayAmountField(),
                              const SizedBox(
                                height: 20,
                              ),
                              if (errorMessage == "")
                                Container()
                              else
                                Text(
                                  errorMessage,
                                  style: TextStyle(
                                      color: mateRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              if (errorMessage == "")
                                Container()
                              else
                                const SizedBox(
                                  height: 20,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (amount == 0.0) ...[
                  const SizedBox()
                ] else ...[
                  getSubmitButton()
                ],
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.addShippingOption,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isLoading == true ? 1.0 : 00,
      child: isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.5,
                valueColor: AlwaysStoppedAnimation(navyBlue),
                backgroundColor: Colors.transparent,
              ),
            )
          : Container(),
    );
  }

  Widget getLocation() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.location,
      keyboardType: TextInputType.text,
      validator: (val) =>
          val.length < 2 ? AppLocalization.of(context)!.locationError : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            location = val;
          });
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      enabled: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = double.parse(val.replaceAll(',', ''));
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            final double amount = double.parse(val.replaceAll(',', ''));
            if (amount == 0.0) {
              throw Exception("Invalid amount");
              // return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context)!.addShippingOption,
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (amount == 0.0 || _amountController.text.isEmpty) {
      return showToast(message: 'Amount must be greater 0');
    } else if (location.isEmpty && location == '') {
      return showToast(message: 'Location is empty');
    } else if (location.length < 2) {
      return showToast(message: 'Location text is too short');
    }

    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 500));

    // if (_formKey.currentState?.validate()) {

    try {
      await Future.delayed(const Duration(seconds: 3));
      errorMessage = '';

      final data = {
        "currency": userBloc.user.currency,
        "price": moneyInputNormalizer(amount.toString()),
        "name": location,
      };

      debugPrint("Shipping status:- $data");

      await _auth.addShippingOption(data).then((value) async {
        debugPrint(
            "Shipping status code:- ${value.statusCode}  body:- ${value.body}");
        isLoading = false;

        response = value;

        try {
          handleServerErrors(response);
        } catch (e) {
          return Future.error(response.body);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          widget.callback!(true);

          //Pop page back to shipping options list
          Navigator.pop(context);

          showToast(message: 'Shipping Option Queued');

          return;
        } else if (response.statusCode == 400) {
          // Navigator.pop(context);
          setState(() {
            errorMessage = "${jsonDecode(value.body)["errors"]}";

            showToast(message: errorMessage);
          });
        } else if (response.statusCode == 500) {
          // Navigator.pop(context);
          setState(() {
            errorMessage = AppLocalization.of(context)!.serverError;
            showToast(message: errorMessage);
          });
        } else {
          if (response.statusCode == 406) {
            errorMessage = jsonDecode(value.body)[0];
            showToast(message: "$errorMessage");
            setState(() {});
          } else {
            debugPrint("ERROR:- ${response.body}");
            setState(() {
              errorMessage = AppLocalization.of(context)!.somethingWentWrong;
              showToast(message: "$errorMessage");
            });
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      showToast(message: e.toString());
    }
    // }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
