import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../widget/LoadingIndicator.dart';

// ignore: must_be_immutable
class AddContract extends StatefulWidget {
  var arguments;

  AddContract({this.arguments});

  // Declare a field that holds the userData.
  @override
  _AddContractState createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  TextEditingController noteCtrl = TextEditingController();
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();
  http.Response? response;

  final _formKey = GlobalKey<FormState>();
  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile? _payee;
  late UserBloc userBloc;

  bool isValidPayee = false;
  int? amount;
  String reference = "";
  String category = "";
  String errorMessage = "";
  String? recipient;

  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();

  Contract? contract;

  PaymentDuration? selectedDuration;

  @override
  void initState() {
    _recipientFocus
      ..addListener(() {
        if (!_recipientFocus.hasFocus) {
          if (mounted) {
            setState(() {
              _recipientController.text =
                  _recipientController.text.toLowerCase();
            });
          }
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _payee = null;

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _sendPaymentScaffold,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
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
        onPressed: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            await Future.delayed(Duration(milliseconds: 300));
          }
          _payee = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.addContract,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        userProfileIcon(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget userProfileIcon() {
    if (_payee != null || isValidPayee) {
      return RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          SlydoAppIcon.circle_user,
          size: 16,
          color: blackFont,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": _payee!.userName});
        },
        backgroundColor: iconBtnGrey,
        enableMargin: true,
      );
    }
    return Container(
      height: 10,
      width: 10,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Card(
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
                          getDisplayCard(),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  flexibleSpace(),
                                  getRecipientField(),
                                  flexibleSpace(),
                                  displayAmountField(),
                                  flexibleSpace(),
                                  getPaymentPeriodDropDown(),
                                  flexibleSpace(),
                                  getDateField(),
                                  flexibleSpace(),
                                  getNoteField(),
                                  flexibleSpace(),
                                  errorMessage == ""
                                      ? Container()
                                      : Text(
                                          errorMessage,
                                          style: TextStyle(
                                              color: mateRed,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                  flexibleSpace(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                  child: Column(
                    children: [
                      flexibleSpace(),
                      getSubmitButton(),
                      flexibleSpace(flex: 2),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget getUserProfileIcon() {
    if (_payee != null || isValidPayee) {
      return IconButton(
        icon: Icon(Icons.person),
        onPressed: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": _payee!.userName});
        },
      );
    }
    return Container(
      height: 1,
      width: 1,
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        _payee = null;
        Navigator.pop(context);
      },
    );
  }

  Widget getDisplayCard() {
    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            errorWidget: imageErrorWidget,
            imageUrl: _payee!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
      setState(() {
        isValidPayee = true;
      });

      qrCodeImage = CachedNetworkImage(
        errorWidget: imageErrorWidget,
        height: 48,
        width: 48,
        imageUrl: _payee!.qrCode ?? "",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      );
    }

    return _payee == null
        ? Container()
        : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _payee!.fullName!,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Text(
                    _payee!.userName!,
                    style: TextStyle(fontSize: 14, color: darkGrey),
                  ),
                  leading: avatarImage,
                  trailing: qrCodeImage,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUserName": _payee!.userName});
                  },
                ),
              ),
              Divider(
                color: dividerColor,
                height: 1,
                thickness: 1,
              ),
            ],
          );
  }

  Widget getRecipientField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.recipient,
      controller: _recipientController,
      focusNode: _recipientFocus,
      validator: (value) {
        if (value != _payee!.userName) {
          return AppLocalization.of(context)!.invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (_payee != null) {
              recipient = _payee!.userName;
            } else {
              recipient = val.toLowerCase();
            }
          });
        }
      },
    );
  }

  Widget getNoteField() {
    return SizedBox(
      height: 20,
      child: CustomizedTextFormField(
        maxLines: 3,
        controller: noteCtrl,
        labelText: AppLocalization.of(context)!.note,
      ),
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmount: true,
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = int.parse(val) * 100;
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            int.parse(val);
            return null;
          } catch (e) {}
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
      onTap: () async {
        isValidPayee = false;
        setState(() {});
        if (recipient != null) {
          recipient = recipient!.trim();
          if (mounted) {
            setState(() {
              _recipientController.text = recipient!;
            });
          }
          var customerProfile =
              await UserAuth().fetchCustomerProfileWithAuth(recipient);
          if (mounted) {
            setState(() {
              _payee = customerProfile;
              isValidPayee = _payee!.userName != userBloc.user.userName;
            });
          }
          _recipientController.text = customerProfile.userName!;
        }
      },
    );
  }

  Widget getDateField() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                lastDate: DateTime(2101),
              ).then((value) {
                startingDate = DateTime(value!.year, value.month, value.day);
                setState(() {});
              }).catchError((error) {});
            },
            child: CustomizedDropDownField(
              title: "Starting date",
              child: Container(
                child: ListTile(
                  dense: true,
                  title: Text(
                    formatDateInDigit(startingDate),
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  trailing: Icon(
                    SlydoAppIcon.date,
                    size: 16,
                    color: darkGrey,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                lastDate: DateTime(2101),
              ).then((value) {
                endingDate = DateTime(value!.year, value.month, value.day);
                setState(() {});
              }).catchError((error) {});
            },
            child: CustomizedDropDownField(
              title: "Ending date",
              child: Container(
                child: ListTile(
                  dense: true,
                  title: Text(
                    formatDateInDigit(endingDate),
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                  trailing: Icon(
                    SlydoAppIcon.date,
                    size: 16,
                    color: darkGrey,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getPaymentPeriodDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Payment period",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedDuration != null ? selectedDuration!.name! : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectDuration();
            },
          ),
        ),
      ],
    );
  }

  void selectDuration() async {
    final pressedDuration = await showDialog<PaymentDuration>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: paymentDurations.map<Widget>((duration) {
                          if (selectedDuration == duration) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  duration.name!,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, duration);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              duration.name!,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, duration);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedDuration != null) {
      selectedDuration = pressedDuration;
      setState(() {});
    }
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context)!.submit,
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (!isValidPayee) {
      setState(() {
        errorMessage = AppLocalization.of(context)!.invalidRecipient;
        return;
      });
    }

    print('RECIPIENT :: $recipient');
    print('RECIPIENT PAYEE :: ${_payee!.userName}');
    if (recipient != userBloc.user.userName) {
      if (!isValidPayee) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.invalidRecipient;
          return;
        });
      }

      if (isValidPayee && _formKey.currentState!.validate()) {
        if (userBloc.user.userName != recipient) {
          try {
            var data = {
              "contractor": _recipientController.text,
              "contractee": userBloc.user.userName.toString(),
              "currency": userBloc.user.currency.toString(),
              "amount": amount.toString().trim(),
              "start_date": dateToString(startingDate),
              "end_date": dateToString(endingDate),
              "payment_duration": selectedDuration!.value.toString(),
            };

            if (noteCtrl.text.isNotEmpty) {
              data['note'] = noteCtrl.text;
            }

            debugPrint('DATA ---> $data');

            showDialog(
                context: context,
                builder: (dialogLoadingContext) => LoadingIndicator());

            BusinessAuth().addContract(data).then((result) {
              Navigator.pop(context); // Dismiss the loading indicator

              if (result) {
                Navigator.pop(context,
                    true); // Pop this screen to go back to my_contract_list
              }
            }).catchError((error) {
              Navigator.pop(context);
              showToast(message: error.toString());
            });
          } catch (e) {
            Navigator.pop(context);
            debugPrint(e.toString());
            showToast(message: e.toString());
          }
        } else {
          showToast(message: AppLocalization.of(context)!.invalidRecipient);
        }
      }
    } else {
      print('IS VALID CONTRACT PAYEE ::: $isValidPayee');

      var msg = AppLocalization.of(context)!.invalidRecipient;
      showToast(message: msg);
    }
  }

  @override
  void dispose() {
    noteCtrl.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
