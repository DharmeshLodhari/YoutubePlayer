import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/screens/more_apps/payment_link/payment_link_model.dart';
import 'package:http/http.dart' as http;
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import '../../../locale/app_localization.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_textform_field.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';

class PaymentLinkCashout extends StatefulWidget {
  PaymentLinkCashout({Key? key, this.id}) : super(key: key);
  String? id;

  @override
  State<PaymentLinkCashout> createState() => _PaymentLinkCashoutState();
}

class _PaymentLinkCashoutState extends State<PaymentLinkCashout> {
  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  String accountNameController = "";
  String bankController = "";
  final pinController = TextEditingController();
  String? accountNumber;
  PaymentLinkModel? _paymentLinkModel;
  bool loading = false;
  late http.Response response;

  @override
  void initState() {
    getPaymentLinkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          'Payment Link Cashout',
          style: TextStyle(color: black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: black,
          ),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
          child: Column(
            children: [
              loading
                  ? Center(child: CircularProgressIndicator())
                  : Card(
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
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Text('This card contains '),
                                    getAmount(_paymentLinkModel?.amount,
                                        _paymentLinkModel?.currency)
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                getBank(),
                                SizedBox(
                                  height: 20,
                                ),
                                getAccountNumber(),
                                SizedBox(
                                  height: 20,
                                ),
                                getAccountName(),
                                SizedBox(
                                  height: 20,
                                ),
                                inputPinCode(),
                                SizedBox(
                                  height: 60,
                                ),
                                CurvedButton(
                                  onPressed: () => cashOut(),
                                  backgroundColor: navyBlue,
                                  textColor: Colors.white,
                                  text: "Cash Out",
                                ),
                                SizedBox(
                                  height: 60,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          )),
    );
  }

  Widget getAccountNumber() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNumber,
      keyboardType: TextInputType.number,
      controller: accountNumberController,
      validator: (val) => val.length < 10
          ? AppLocalization.of(context)!.validationTextMessage1
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountNumber = val;
          });
        }
        if (mounted) setState(() {});
      },
    );
  }

  Widget getAccountName() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNameHint,
      keyboardType: TextInputType.text,
      enabled: true,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountNameController = val;
          });
        }
      },
    );
  }

  Widget getBank() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.bankName,
      keyboardType: TextInputType.text,
      enabled: true,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            bankController = val;
          });
        }
      },
    );
  }

  bool obscureChange = true;

  obscureTextWidget() {
    if (obscureChange) {
      return IconButton(
          onPressed: () => setState(() => obscureChange = !obscureChange),
          icon: const Icon(
            Icons.visibility,
            size: 20,
          ));
    } else {
      return IconButton(
          onPressed: () => setState(() => obscureChange = !obscureChange),
          icon: const Icon(
            Icons.visibility_off,
            size: 20,
          ));
    }
  }

  Widget inputPinCode() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.pincode,
      keyboardType: TextInputType.number,
      controller: pinController,
      suffixIcon: IconButton(
          onPressed: () => setState(() => obscureChange = !obscureChange),
          icon: Icon(
            obscureChange ? Icons.visibility : Icons.visibility_off,
            size: 20,
          )),
      obscureText: obscureChange,
      // validator: (val) => val.length < 10
      //     ? AppLocalization.of(context)!.validationTextMessage1
      //     : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            pinController.text = val;
          });
        }
        if (mounted) setState(() {});
      },
    );
  }

  void getPaymentLinkData() async {
    try {
      loading = true;
      var res = await _auth.getSinglePaymentLinkDetails(widget.id);
      _paymentLinkModel = PaymentLinkModel.fromJson(res);
      pinController.text = _paymentLinkModel!.pin.toString();
      loading = false;
      setState(() {});
      log('$res');
    } on Exception catch (e) {
      rethrow;
    }
  }

  cashOut() {
    dynamic data = {
      "bank": bankController,
      "pin": pinController.text,
      "recipient_account_name": accountNameController,
      "recipient_account_number": accountNumberController.text,
    };
    cashoutPaymentLink(data);
    setState(() {});
  }

  Future<void> cashoutPaymentLink(Map map) async {
    try {
      loading = true;
      log('message.....$map');
      await _auth.cashoutPaymentLink(map).then((value) async {
        debugPrint("status code:- ${value.statusCode}  body:- ${value.body}");
        dynamic res = jsonDecode(value.body);
        log("res.toString()${res.toString()}");

        response = value;
        if (response.statusCode == 200) {
          log(response.body.toString());
          showSnackbar(context, message: 'message');

          loading = false;
        } else if (response.statusCode == 400 || response.statusCode == 404) {
          loading = false;
          showSnackbar(context, message: 'Failed..!');
        } else if (response.statusCode == 500) {
          loading = false;
          showSnackbar(context, message: 'Failed..!');
        } else {
          loading = false;
          showSnackbar(context, message: 'Failed..!');
          loading = false;
        }
      });
    } catch (e) {
      log("$e");
    }
    setState(() {});
  }
}
