import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/search_user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddContract extends StatefulWidget {
  var arguments;

  AddContract({this.arguments});

  @override
  _AddContractState createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  String? conversationId;
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final FocusNode _recipientFocus = FocusNode();
  http.Response? response;

  final _formKey = GlobalKey<FormState>();
  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile? _payee; //The person you are offering the contract to.
  late UserBloc userBloc;

  bool isValidPayee = false;
  double? amount;
  String reference = "";
  String category = "";
  String errorMessage = "";
  String? recipient;

  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();

  ContractModel? contract;

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
            await Future.delayed(const Duration(milliseconds: 300));
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
        const SizedBox(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Expanded(
              flex: 9,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
              flex: 2,
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    getSubmitButton(),
                    flexibleSpace(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUserProfileIcon() {
    if (_payee != null || isValidPayee) {
      return IconButton(
        icon: const Icon(Icons.person),
        onPressed: () {
          Navigator.pushNamed(context, Routes.USER_PROFILE,
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
      icon: const Icon(Icons.arrow_back_ios),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _payee!.fullName!,
                    style: const TextStyle(
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
      isReadOnly: true,
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
      onTap: () async {
        final CustomerProfile? userFound =
            await NavigationUtil.push(context, screen: const SearchUser());

        if (userFound != null) {
          _payee = userFound;
          _recipientController.text = _payee!.userName!;
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget getNoteField() {
    return CustomizedTextFormField(
      maxLines: 3,
      controller: _noteCtrl,
      labelText: AppLocalization.of(context)!.note,
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
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
            }
          } catch (e) {
            debugPrint('ERROR VALIDATING AMOUNT FIELD ::: ${e.toString()}');
          }
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
          final customerProfile =
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
        const SizedBox(
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
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
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
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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

    if (_recipientController.text != userBloc.user.userName) {
      if (!isValidPayee) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.invalidRecipient;
          return;
        });
      }

      if (isValidPayee && _formKey.currentState!.validate()) {
        if (selectedDuration == null) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.selectPaymentDuration;
            return;
          });
        } else {
          if (userBloc.user.userName != recipient) {
            showDialogBox(
                context: context,
                actionOneTextColor: blackFont,
                actionOneBgColor: greyBorderColor,
                actionTwoTextColor: white,
                actionTwoBgColor: naturalGreen,
                title: 'Create Contract',
                actionTwoText: AppLocalization.of(context)!.create,
                actionOneText: AppLocalization.of(context)!.cancel,
                description: 'Are you sure you want to create this contract?',
                roundedBackgroundIcon: RoundedBackgroundIcon(
                  enableMargin: false,
                  width: 90,
                  height: 90,
                  image: Image.asset('assets/images/accept_dialog_icon.png'),
                ),
                rightButtonOnPressed: () {
                  sendContract();
                });
          } else {
            showToast(message: AppLocalization.of(context)!.invalidRecipient);
          }
        }
      }
    } else {
      final msg = AppLocalization.of(context)!.invalidRecipient;
      showToast(message: msg);
    }
  }

  sendContract() async {
    try {
      showDialog(
          context: context,
          builder: (dialogLoadingContext) => LoadingIndicator());

      await BusinessAuth()
          .getConversationId(name: _recipientController.text)
          .then(
        (value) {
          if (value != null) {
            conversationId = value;
          }
        },
      );

      final data = {
        "contractor": _recipientController.text,
        "currency": userBloc.user.currency.toString(),
        "amount": moneyInputNormalizer(amount.toString().trim()),
        "start_date": dateToString(startingDate),
        "end_date": dateToString(endingDate),
        "payment_duration": selectedDuration!.value.toString(),
      };

      if (_noteCtrl.text.isNotEmpty) {
        data['note'] = _noteCtrl.text;
      }
      if (conversationId != null) {
        data['conversation_id'] = conversationId!;
      }

      BusinessAuth().addContract(data).then((result) {
        Navigator.pop(context); // Dismiss the loading indicator

        if (result) {
          Navigator.pop(
              context, true); // Pop this screen to go back to my_contract_list
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
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
