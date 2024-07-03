import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../payment_and_banking/payment_and_banking_auth.dart';

class EditShippingOptions extends StatefulWidget {
  final dynamic arguments;
  final Function(bool)? callback;

  const EditShippingOptions({super.key, this.callback, this.arguments});

  @override
  State<EditShippingOptions> createState() => _EditShippingOptionsState();
}

class _EditShippingOptionsState extends State<EditShippingOptions> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final _editShippingOptionScaffold = GlobalKey<ScaffoldState>();
  final _editShippingOptionScaffoldMessenger =
      GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;

  double? amount = 0.0;
  String errorMessage = "";
  String location = '';
  bool isLoading = false;
  bool isEdit = false;

  @override
  void initState() {
    _locationController = TextEditingController();
    _amountController = TextEditingController();
    fetchData();
    super.initState();
  }

  void fetchData() {
    _locationController.text = widget.arguments['name'];
    _amountController.text = (widget.arguments['price'] / 100).toString();
    location = _locationController.text;
    amount = double.tryParse(_amountController.text);
    isEdit = true;
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _editShippingOptionScaffoldMessenger,
      child: Scaffold(
        backgroundColor: lightGrey,
        key: _editShippingOptionScaffold,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget scaffoldBody() {
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
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (isEdit == true) ...[
                  getUpdateAndDeleteButton()
                ] else if (amount == 0.0) ...[
                  const SizedBox()
                ] else ...[
                  getUpdateAndDeleteButton()
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
      surfaceTintColor: Colors.transparent,
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
        AppLocalization.of(context)!.shipping,
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
      controller: _locationController,
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
            if (amount > 0.0) {
              return null;
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

  Widget getUpdateAndDeleteButton() {
    return Row(
      children: [
        Expanded(
          child: CurvedButton(
            onPressed: () {
              showDeleteShippingOptionDialog();
            },
            backgroundColor: red,
            textColor: Colors.white,
            text: AppLocalization.of(context)!.delete,
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: CurvedButton(
            onPressed: onSubmit,
            backgroundColor: navyBlue,
            textColor: Colors.white,
            text: AppLocalization.of(context)!.update,
          ),
        ),
      ],
    );
  }

  void showDeleteShippingOptionDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Shipping Option',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this shipping option?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        deleteShippingOption();
      },
    );
  }

  void deleteShippingOption() async {
    final int? shippingId = widget.arguments['id'];
    final bool? data = await _auth.deleteShippingOption(shippingId!);
    if (data != null && data) {
      showToast(message: "Shipping Option Deleted Successfully");
      Navigator.pop(context);
      Navigator.of(context).pushNamed(Routes.SHIPPING_OPTIONS);
    } else {
      showToast(message: "Unable to Deleted Shipping Option");
    }
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

      final int? shippingId = widget.arguments['id'];

      await _auth.editShippingOption(data, shippingId!).then((value) async {
        debugPrint(
            "Shipping update status code:- ${value.statusCode}  body:- ${value.body}");
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

          showToast(message: 'Shipping Option Updated');

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
            showToast(message: errorMessage);
            setState(() {});
          } else {
            debugPrint("ERROR:- ${response.body}");
            setState(() {
              errorMessage = AppLocalization.of(context)!.somethingWentWrong;
              showToast(message: errorMessage);
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
    _locationController.dispose();
    super.dispose();
  }
}
