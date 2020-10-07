import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/services/auth.dart';
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

// ignore: must_be_immutable
class RequestPayment extends StatefulWidget {
  var arguments;

  RequestPayment({this.arguments});

  // Declare a field that holds the userData.
  @override
  _RequestPaymentState createState() =>
      _RequestPaymentState(arguments: arguments);
}

class _RequestPaymentState extends State<RequestPayment> {
  TextEditingController _recipientController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();

  var arguments;

  DashboardBloc _dashboardBloc;

  _RequestPaymentState({this.arguments});

  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final requestPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile _payee;
  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  http.Response response;

  bool isFromProfile = false;
  bool isValidPayee = false;
  int amount;
  String reference = "";
  String errorMessage = "";
  String recipient;
  final locationService = LocationService();

  //variables for categories
  bool isLoading = true;
  List<String> paymentCategoriesTest = List();
  String selectedCategory;

  PaymentCategory selectedPaymentCategory;
  String paymentCategory;

  @override
  void initState() {
    isFromProfile = arguments != null
        ? arguments['isFromProfile'] != null
            ? arguments['isFromProfile']
            : false
        : false;

    /* adding listener on recipientFocus when user unFocus
    From Recipient Field then value of that field should be in lowerCase */
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

  void initializeDisplayCard() {
    if (mounted) {
      if (!isFromProfile) {
        if (customerProfileBloc.customer != null) {
          if (mounted) {
            setState(() {
              _payee = customerProfileBloc.customer;
              recipient = _payee.userName;
              _recipientController.text = recipient;
            });
          }
        }
      }
    }
  }

  void fetchCategory() async {
    _auth.getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          List categoriesList = result["results"]["data"];
          categoriesList.forEach((data) {
            paymentCategoriesTest.add(data["name"]);
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
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        _payee = null;
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        key: requestPaymentScaffold,
        backgroundColor: Colors.white,
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
        onPressed: () {
          _payee = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context).requestPayment,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        scanQRCodeBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed('/scan-qr', arguments: {"isRequest": true});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      children: [
                                        flexibleSpace(),
                                        getRecipientField(),
                                        flexibleSpace(),
                                        displayAmountField(),
                                        flexibleSpace(),
                                        getCategoryDropDown(),
                                        flexibleSpace(),
                                        getReferenceField(),
                                        flexibleSpace(),
                                        Text(
                                          errorMessage,
                                          style: TextStyle(
                                              color: mateRad,
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

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        _payee = null;
        Navigator.pop(context);
      },
    );
  }

  Widget displayQRCodeButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/scan-qr', arguments: {"isRequest": true});
        },
        child: Image.asset(
          'assets/images/qr_code.png',
          height: 24.0,
          width: 24.0,
          color: Colors.white,
        ),
      ),
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

      qrCodeImage = CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: _payee.qrCode,
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
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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

  Widget getCategoryField() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<String>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context).category),
              ),
            ],
          ),
          value: selectedCategory,
          onChanged: (String value) {
            if (mounted) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
          items: paymentCategoriesTest.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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
          child: ListTile(
            dense: true,
            title: Text(
              selectedCategory != null ? selectedCategory : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: blackFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
                        children: paymentCategoriesTest.map<Widget>((category) {
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
      setState(() {});
    }
  }

  Widget getReferenceField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).reference,
      textCapitalization: TextCapitalization.sentences,
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
      text: AppLocalization.of(context).requestPayment,
    );
  }

  void onSubmit() async {
    FocusScope.of(context).unfocus();

    if (!isValidPayee) {
      if (mounted) {
        setState(() {
          errorMessage = AppLocalization.of(context).invalidRecipient;
          return;
        });
      }
    }

    if (recipient == _payee.userName) {
      if (!isValidPayee) {
        if (mounted) {
          setState(() {
            errorMessage = AppLocalization.of(context).invalidRecipient;
            return;
          });
        }
      }

      if (isValidPayee &&
          _formKey.currentState.validate() &&
          validateDropdown()) {
        if (userBloc.user.userName != recipient) {
          var userLocation;
          try {
            userLocation = await locationService.getLocation();

            var data = {
              "from_customer": userBloc.user.userName.trim(),
              "to_customer": recipient.trim(),
              "currency": userBloc.user.currency,
              "amount": amount.toString().trim(),
              "category": selectedCategory.trim(),
              "notes": reference.trim(),
              "description": reference.trim(),
              "latitude": userLocation.latitude,
              "longitude": userLocation.longitude,
            };

            BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularLoadingIndicator()));
                  _auth.createPaymentRequests(data).then((value) {
                    response = value;
                    if (response.statusCode == 201) {
                      _dashboardBloc.index = 1;
                      Navigator.popUntil(
                          context, ModalRoute.withName("/dashboard"));
                    } else if (response.statusCode == 500) {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          errorMessage =
                              AppLocalization.of(context).serverError;
                          Toast.show(errorMessage, context,
                              gravity: Toast.TOP,
                              backgroundColor: darkBlue(),
                              textColor: Colors.white);
                        });
                      }
                    } else if (response.statusCode == 700) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/bvn-verification");
                    } else if (response.statusCode == 800) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/add-document");
                    } else {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          errorMessage =
                              AppLocalization.of(context).somethingWentWrong;
                          Toast.show(errorMessage, context,
                              gravity: Toast.TOP,
                              backgroundColor: darkBlue(),
                              textColor: Colors.white);
                        });
                      }
                    }
                  });
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                  requestPaymentScaffold.currentState.showSnackBar(SnackBar(
                    content: Text(AppLocalization.of(context).invalidPassword),
                  ));
                });
          } catch (e) {
            print(e);
            Toast.show(e, context,
                gravity: Toast.BOTTOM, backgroundColor: darkBlue());
          }
        } else {
          var msg = AppLocalization.of(context).invalidRecipient;
          Toast.show(msg, context,
              gravity: Toast.CENTER,
              backgroundColor: darkBlue(),
              textColor: Colors.white);
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

  bool validateDropdown() {
    if (selectedCategory != null) {
      return true;
    } else {
      Toast.show(AppLocalization.of(context).selectCategory, context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
      return false;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
