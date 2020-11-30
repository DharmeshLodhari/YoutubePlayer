import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/services/location_service.dart';
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
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class AddContract extends StatefulWidget {
  var arguments;

  AddContract({this.arguments});

  // Declare a field that holds the userData.
  @override
  _AddContractState createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();
  http.Response response;

  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile _payee;
  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  bool isValidPayee = false;
  int amount;
  String reference = "";
  String category = "";
  String errorMessage = "";
  String recipient;
  final locationService = LocationService();

  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();

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

  void initializeDisplayCard() {
    if (customerProfileBloc.customer.avatar != null) {
      if (mounted) {
        setState(() {
          _payee = customerProfileBloc.customer;
          recipient = _payee.userName;
          _recipientController.text = recipient;
          _auth.fetchCustomerProfile(recipient).then((customerProfile) {
            if (customerProfile != null) {
              if (mounted) {
                setState(() {
                  _payee = customerProfile;
                  isValidPayee = _payee.userName != userBloc.user.userName;
                });
              }
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        _payee = null;
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _sendPaymentScaffold,
        resizeToAvoidBottomInset: true,
        appBar: appBar(),
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
        "Add contract",
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
              arguments: {"searchedUser": _payee});
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
                                  getDateField(),
                                  flexibleSpace(),
                                  getPaymentPeriodField(),
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
              arguments: {"searchedUser": _payee});
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
    initializeDisplayCard();

    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _payee.avatar,
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
        height: 48,
        width: 48,
        imageUrl: _payee.qrCode ?? "",
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
                    _payee.fullName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Text(
                    _payee.userName,
                    style: TextStyle(fontSize: 14, color: darkGrey),
                  ),
                  leading: avatarImage,
                  trailing: qrCodeImage,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUser": _payee});
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
      labelText: AppLocalization.of(context).recipient,
      controller: _recipientController,
      focusNode: _recipientFocus,
      validator: (value) {
        if (value != _payee.userName) {
          return AppLocalization.of(context).invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (_payee != null) {
              recipient = _payee.userName;
            } else {
              recipient = val.toLowerCase();
            }
          });
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmount: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = int.parse(val);
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
        return AppLocalization.of(context).invalidAmount;
      },
      onTap: () async {
        isValidPayee = false;
        setState(() {});
        if (recipient != null) {
          recipient = recipient.trim();
          if (mounted) {
            setState(() {
              _recipientController.text = recipient;
            });
          }
          var customerProfile = await _auth.fetchCustomerProfile(recipient);
          if (mounted) {
            setState(() {
              _payee = customerProfile;
              isValidPayee = _payee.userName != userBloc.user.userName;
            });
          }
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
                startingDate = DateTime(value.year, value.month, value.day);
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
                endingDate = DateTime(value.year, value.month, value.day);
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

  Widget getPaymentPeriodField() {
    return CustomizedTextFormField(
      labelText: "Payment period",
      textCapitalization: TextCapitalization.sentences,
      controller: _referenceController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            reference = val;
          });
        }
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add contract",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (!isValidPayee) {
      setState(() {
        errorMessage = AppLocalization.of(context).invalidRecipient;
        return;
      });
    }

    if (recipient == _payee.userName) {
      if (!isValidPayee) {
        setState(() {
          errorMessage = AppLocalization.of(context).invalidRecipient;
          return;
        });
      }

      if (isValidPayee && _formKey.currentState.validate()) {
        if (userBloc.user.userName != recipient) {
          var userLocation;
          Map deviceData;
          try {
            userLocation = await locationService.getLocation();
            deviceData = await getDeviceInfo();
            var data = {
              "from_customer": userBloc.user.userName,
              "to_customer": recipient.trim(),
              "currency": userBloc.user.currency,
              "amount": amount.toString().trim(),
              "notes": reference.trim(),
              "description": reference.trim(),
              "latitude": userLocation.latitude,
              "longitude": userLocation.longitude,
              "deviceData": deviceData,
            };

            ///
            Navigator.pop(context);
          } catch (e) {
            debugPrint(e);
            Toast.show(e, context,
                gravity: Toast.BOTTOM, backgroundColor: darkBlue());
          }
        } else {
          Toast.show(
            AppLocalization.of(context).invalidRecipient,
            context,
            textColor: Colors.white,
            backgroundColor: darkBlue(),
          );
        }
      }
    } else {
      var msg = AppLocalization.of(context).invalidRecipient;
      Toast.show(msg, context,
          gravity: Toast.CENTER,
          backgroundColor: darkBlue(),
          textColor: Colors.white);
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
