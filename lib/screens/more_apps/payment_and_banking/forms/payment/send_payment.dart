import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../payment_and_banking_auth.dart';

// ignore: must_be_immutable
class SendPayment extends StatefulWidget {
  var arguments;

  SendPayment({this.arguments});

  // Declare a field that holds the userData.
  @override
  _SendPaymentState createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();
  http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile _payee;
  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  //for Product payment
  Product product;

  //for Service payment
  Service service;

  bool isFromProfile = false;
  bool isFromChat = false;
  bool isValidPayee = false;
  double amount;
  String reference = "";
  String category = "";
  String errorMessage = "";
  String recipient;
  final locationService = LocationService();

  //variables for categorie
  bool isLoading = true;
  List<String> paymentCategories = List();
  String selectedCategory;
  BasketBloc basketBloc;

  //variables for shoppingcart
  int itemIndex;

  bool sendMoneyAnonymous = false;

  bool showMoreOption = false;

  @override
  void initState() {
    isFromProfile = widget.arguments != null
        ? widget.arguments['isFromProfile'] != null
            ? widget.arguments['isFromProfile']
            : false
        : false;
    isFromChat = widget.arguments != null
        ? widget.arguments['isFromChat'] != null
            ? widget.arguments['isFromChat']
            : false
        : false;
    product = widget.arguments != null ? widget.arguments['product'] : null;
    service = widget.arguments != null ? widget.arguments['service'] : null;
    itemIndex = widget.arguments != null ? widget.arguments['itemIndex'] : null;

    if (product != null) {
      setAllFieldProduct();
    }
    if (service != null) {
      setAllFieldService();
    }
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
    fetchCategory();
    super.initState();
  }

  void setAllFieldProduct() {
    _amountController.text = product.price;
    amount = double.parse(_amountController.text);
    _referenceController.text = product.name;
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void setAllFieldService() {
    _amountController.text = service.price;
    amount = double.parse(_amountController.text);
    _referenceController.text = service.name;
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void initializeDisplayCard() {
    // if (!isFromProfile && product != null) {
    if (!isFromProfile) {
      if (customerProfileBloc.customer != null) {
        if (mounted) {
          setState(() {
            _payee = customerProfileBloc.customer;
            recipient = _payee.userName;
            _recipientController.text = recipient;
            UserAuth().fetchCustomerProfile(recipient).then((customerProfile) {
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
  }

  Future<String> getAccountBalance() async {
    Map<String, dynamic> data =
        await PaymentAndBankingAuth().getAccountBalance();
    int spendableBalance = data["spendable_balance"];

    String accountBalance = moneyDisplayNormalizer(spendableBalance);
    return accountBalance;
  }

  void fetchCategory() async {
    _auth.getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          List categoriesList = result["results"]["data"];
          categoriesList.forEach((data) {
            paymentCategories.add(data["name"]);
          });
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);

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
        AppLocalization.of(context).sendPayment,
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
              arguments: {"searchedUserName": _payee.userName});
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
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
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
                              getDisplayCard(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    getRecipientField(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    displayAmountField(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    showMoreOption
                                        ? getMoreOption()
                                        : Container(),
                                    getMoreOptionTrigger(),
                                    errorMessage == ""
                                        ? Container()
                                        : Text(
                                            errorMessage,
                                            style: TextStyle(
                                                color: mateRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                    errorMessage == ""
                                        ? Container()
                                        : SizedBox(
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
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        getSubmitButton(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget getMoreOption() {
    return Column(
      children: [
        getCategoryDropDown(),
        SizedBox(
          height: 20,
        ),
        getReferenceField(),
        SizedBox(
          height: 20,
        ),
        isFromChat ? Container() : sendMoneyAnonymouslySwitch(),
      ],
    );
  }

  Widget getMoreOptionTrigger() {
    return GestureDetector(
      onTap: () {
        showMoreOption = !showMoreOption;
        if (mounted) setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              showMoreOption
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: darkGrey,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              showMoreOption ? "less options" : "more options",
              style: TextStyle(
                  color: darkGrey, fontSize: 14, fontWeight: FontWeight.w600),
            )
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
              arguments: {"searchedUserName": _payee.userName});
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
      Color borderColor = getUserTypeColor(user: _payee);

      avatarImage = Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    _payee.userName,
                    style: TextStyle(fontSize: 14, color: darkGrey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  leading: avatarImage,
                  trailing: qrCodeImage,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUserName": _payee.userName});
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
      enabled: isFromProfile,
      validator: (value) {
        if (!isFromProfile && value != _payee.userName) {
          return AppLocalization.of(context).invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (!isFromProfile && _payee != null) {
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
      enabled: product == null && service == null,
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = double.parse(val);
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double amount = double.parse(val);
            if (amount > 0.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context).invalidAmount;
          }
        }
        return AppLocalization.of(context).invalidAmount;
      },
      onTap: () async {
        isValidPayee = false;
        if (mounted) setState(() {});
        if (recipient != null) {
          recipient = recipient.trim();

          _recipientController.text = recipient;
          if (mounted) setState(() {});

          var customerProfile =
              await UserAuth().fetchCustomerProfile(recipient);

          _payee = customerProfile;
          isValidPayee = _payee.userName != userBloc.user.userName;

          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget getCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context).category,
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
          child: IgnorePointer(
            ignoring: product != null || service != null,
            child: ListTile(
              dense: true,
              title: Text(
                selectedCategory != null ? selectedCategory : "",
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
              ),
              onTap: () {
                selectCategory();
              },
            ),
          ),
        ),
      ],
    );
  }

  void selectCategory() async {
    final pressedCategory = await showDialog<String>(
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
                        children: paymentCategories.map<Widget>((category) {
                          if (selectedCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category,
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
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedCategory = pressedCategory;
      debugPrint("selected category $selectedCategory");
      setState(() {});
    }
  }

  Widget getReferenceField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).reference,
      textCapitalization: TextCapitalization.sentences,
      controller: _referenceController,
      enabled: product == null && service == null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            reference = val;
          });
        }
      },
    );
  }

  Widget sendMoneyAnonymouslySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Send money anonymously",
          style: TextStyle(fontWeight: FontWeight.w400, color: darkGrey),
        ),
        Switch(
          value: sendMoneyAnonymous,
          onChanged: (value) {
            sendMoneyAnonymous = value;
            setState(() {});
            if (value) sendMoneyAnonymousAlert();
          },
          activeTrackColor: navyBlueLight,
          activeColor: navyBlue,
          inactiveTrackColor: navyBlueLight,
        ),
      ],
    );
  }

  void sendMoneyAnonymousAlert() {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, rentDurationStateSetter) {
              return AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                content: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Container(
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
                          child: Container(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        child: Text(
                                          "Note",
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          style: TextStyle(
                                              color: blackFont,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: Text(
                                          "This transaction will be done anonymously recipient will not be able to see sender information. ",
                                          style: TextStyle(
                                              color: blackFont,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FlatButton(
                                      padding: EdgeInsets.zero,
                                      child: Text("OK",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: blackFont,
                                              fontWeight: FontWeight.w600)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 100) / 2,
                      top: -30,
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: dividerColor, width: 1.5),
                              borderRadius: BorderRadius.circular(60)),
                          height: 60,
                          width: 60,
                          child: Center(
                            child: Image.asset(
                              "assets/images/anonymous.png",
                              height: 45,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }));
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Pay",
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

      if (isValidPayee &&
          _formKey.currentState.validate() &&
          validateDropdown()) {
        if (userBloc.user.userName != recipient) {
          var userLocation;
          Map deviceData;
          try {
            BottomSheetPassCode(
                context: context,
                isValidCallback: () async {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularLoadingIndicator()));

                  if (Platform.isIOS) {
                    userLocation = await locationService.getLocation();
                  }

                  String accountBalance = await getAccountBalance();

                  double currentBalance = double.parse(accountBalance);
                  double transactionalAmount = double.parse(amount.toString());
                  debugPrint("ACCOUNT BALANCE:- $accountBalance");
                  debugPrint("AMOUNT:- ${amount.toString()}");

                  if (transactionalAmount > currentBalance) {
                    Navigator.pop(context);

                    errorMessage = "Insufficient funds !!";
                    setState(() {});
                    Toast.show(errorMessage, context,
                        gravity: Toast.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white);
                    return;
                  }

                  deviceData = await getDeviceInfo();
                  var data = {
                    "from_customer": userBloc.user.userName,
                    "to_customer": recipient.trim(),
                    "currency": userBloc.user.currency,
                    "amount": moneyInputNormalizer(amount.toString()),
                    "category": selectedCategory.trim(),
                    "notes": reference.trim(),
                    "description": reference.trim(),
                    "latitude": Platform.isIOS ? userLocation.latitude : "",
                    "longitude": Platform.isIOS ? userLocation.longitude : "",
                    "deviceData": deviceData,
                    "is_anonymous": sendMoneyAnonymous,
                    "made_from_chat": isFromChat ?? false,
                  };

                  debugPrint("Data:- $data");
                  _auth.makePayment(data).then((value) {
                    debugPrint(
                        "status code:- ${value.statusCode}  body:- ${value.body}");
                    response = value;
                    if (response.statusCode == 200) {
                      popFromShoppingCart(product);
                      //Pop Circular Progress Indicator
                      Navigator.pop(context);
                      //Pop send payment page
                      Navigator.pop(context);

                      debugPrint(" isFromChat:- $isFromChat");

                      if (!isFromChat) {
                        Navigator.of(context).pushNamed(
                          '/transactions',
                        );
                      }
                    } else if (response.statusCode == 400) {
                      Navigator.pop(context);
                      setState(() {
                        errorMessage = "${jsonDecode(value.body)["errors"]}";

                        Toast.show(errorMessage, context,
                            gravity: Toast.BOTTOM,
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      });
                    } else if (response.statusCode == 500) {
                      Navigator.pop(context);
                      setState(() {
                        errorMessage = AppLocalization.of(context).serverError;
                        Toast.show(
                          errorMessage,
                          context,
                          gravity: Toast.TOP,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      });
                    }
                    // else if (response.statusCode == 800) {
                    //   Navigator.pop(context);
                    //   Navigator.pushNamed(context, "/add-document");
                    // }
                    else {
                      Navigator.pop(context);
                      setState(() {
                        errorMessage =
                            AppLocalization.of(context).somethingWentWrong;
                        Toast.show(
                          errorMessage,
                          context,
                          gravity: Toast.TOP,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                      });
                    }
                  });
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                  _sendPaymentScaffold.currentState.showSnackBar(SnackBar(
                    content: Text(AppLocalization.of(context).invalidPassword),
                  ));
                });
          } catch (e) {
            debugPrint(e);
            Toast.show(
              e,
              context,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          }
        } else {
          Toast.show(
            AppLocalization.of(context).invalidRecipient,
            context,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        }
      }
    } else {
      var msg = AppLocalization.of(context).invalidRecipient;
      Toast.show(
        msg,
        context,
        gravity: Toast.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void popFromShoppingCart(Product product) {
    if (itemIndex != null) {
      try {
        basketBloc.removeItemFromCart(basketBloc.items[itemIndex]);
      } catch (e) {
        debugPrint("SendPayment PopFromShopping cart : " + e.toString());
      }
    }
  }

  bool validateDropdown() {
    if (selectedCategory != null) {
      return true;
    } else {
      selectedCategory = "General";
      return true;
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
