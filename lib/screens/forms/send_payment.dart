import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/services/auth.dart';
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

  final _auth = AuthService();
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
  bool isValidPayee = false;
  int amount;
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

  @override
  void initState() {
    isFromProfile =
        widget.arguments != null ? widget.arguments['isFromProfile'] : false;
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
    amount = int.parse(_amountController.text);
    _referenceController.text = product.name;
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void setAllFieldService() {
    _amountController.text = service.price;
    amount = int.parse(_amountController.text);
    _referenceController.text = service.name;
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void initializeDisplayCard() {
    if (!isFromProfile) {
      if (customerProfileBloc.customer != null) {
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
    // return WillPopScope(
    //   onWillPop: () async {
    //     _payee = null;
    //     customerProfileBloc.customer = null;
    //     return true;
    //   },
    //   child: Scaffold(
    //     backgroundColor: lightBlue(),
    //     key: _sendPaymentScaffold,
    //     resizeToAvoidBottomInset: true,
    //     appBar: AppBar(
    //         actions: <Widget>[getUserProfileIcon()],
    //         leading: showBackArrow(),
    //         title: Center(child: Text(AppLocalization.of(context).sendPayment)),
    //         backgroundColor: darkBlue()),
    //     body: scaffoldBody(),
    //   ),
    // );
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
        onPressed: () {
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
        imageUrl: _payee.qrCode,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      );
    }

    // return _payee == null
    //     ? Container()
    //     : Card(
    //         semanticContainer: true,
    //         child: ListTile(
    //           dense: true,
    //           title: Text(
    //             _payee.fullName,
    //             style: TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 15),
    //           ),
    //           subtitle: Text(_payee.userName),
    //           leading: avatarImage,
    //           trailing: qrCodeImage,
    //           onTap: () {
    //             Navigator.pushNamed(context, '/profile',
    //                 arguments: {"searchedUser": _payee});
    //           },
    //         ),
    //       );

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
    // return TextFormField(
    //   controller: _recipientController,
    //   enabled: isFromProfile,
    //   focusNode: _recipientFocus,
    //   textCapitalization: TextCapitalization.none,
    //   cursorColor: darkBlue(),
    //   validator: (value) {
    //     if (!isFromProfile && value != _payee.userName) {
    //       return AppLocalization.of(context).invalidRecipient;
    //     }
    //     return null;
    //   },
    //   autofocus: false,
    //   obscureText: false,
    //   decoration: InputDecoration(
    //     prefixIcon: Icon(Icons.person),
    //     fillColor: Colors.white,
    //     filled: true,
    //     hintText: AppLocalization.of(context).recipient,
    //     labelStyle: TextStyle(
    //       color: Colors.black,
    //       fontSize: 16,
    //     ),
    //     border: OutlineInputBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(4)),
    //         borderSide: BorderSide(
    //             width: 1, color: Colors.white, style: BorderStyle.solid)),
    //   ),
    //   onChanged: (val) {
    //     setState(() {
    //       if (!isFromProfile && _payee != null) {
    //         recipient = _payee.userName;
    //       } else {
    //         recipient = val.toLowerCase();
    //       }
    //     });
    //   },
    // );
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
      onChange: (val) {
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
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   controller: _amountController,
    //   enabled: product == null && service == null,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.number,
    //   inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
    //   decoration: InputDecoration(
    //       fillColor: Colors.white,
    //       filled: true,
    //       prefixIcon: Container(
    //         width: 20,
    //         child: Center(
    //           child: Text(
    //             worldCurrencies[userBloc.user.currency],
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //               fontSize: 22,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.grey[600],
    //               fontFamily: "Roboto",
    //             ),
    //           ),
    //         ),
    //       ),
    //       hintText: AppLocalization.of(context).enterAmount,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       try {
    //         int.parse(val);
    //         return null;
    //       } catch (e) {}
    //     }
    //     return AppLocalization.of(context).invalidAmount;
    //   },
    //   onTap: () async {
    //     if (recipient != null) {
    //       recipient = recipient.trim();
    //       if (mounted) {
    //         setState(() {
    //           _recipientController.text = recipient;
    //         });
    //       }
    //       await _auth.fetchCustomerProfile(recipient).then((customerProfile) {
    //         if (customerProfile != null) {
    //           setState(() {
    //             _payee = customerProfile;
    //             isValidPayee = _payee.userName != userBloc.user.userName;
    //           });
    //         }
    //       });
    //     }
    //   },
    //   onChanged: (val) {
    //     setState(() {
    //       amount = int.parse(val);
    //     });
    //   },
    // );
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmount: true,
      type: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChange: (val) {
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
        child: IgnorePointer(
          ignoring: product != null || service != null,
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
              setState(() {
                selectedCategory = value;
              });
            },
            items: paymentCategories.map((String category) {
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
          child: IgnorePointer(
            ignoring: product != null || service != null,
            child: DropdownButton<String>(
              icon: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: darkGrey,
                  size: 20,
                ),
              ),
              isExpanded: true,
              underline: Divider(
                color: Colors.transparent,
              ),
              hint: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context).category),
              ),
              value: selectedCategory,
              onChanged: (String value) {
                if (mounted) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
              items: paymentCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                    child: Text(
                      category,
                      style: TextStyle(
                          color: blackFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget getReferenceField() {
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   enabled: product == null && service == null,
    //   obscureText: false,
    //   controller: _referenceController,
    //   textCapitalization: TextCapitalization.sentences,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.note),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).reference,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   onChanged: (val) {
    //     setState(() {
    //       reference = val;
    //     });
    //   },
    // );

    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).reference,
      textCapitalization: TextCapitalization.sentences,
      controller: _referenceController,
      enabled: product == null && service == null,
      onChange: (val) {
        if (mounted) {
          setState(() {
            reference = val;
          });
        }
      },
    );
  }

  Widget getSubmitButton() {
    // return ButtonTheme(
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //     elevation: 4.0,
    //     textColor: Colors.white,
    //     color: darkBlue(),
    //     height: 50,
    //     child: Text(AppLocalization.of(context).sendPayment),
    //     onPressed: () async {
    //       if (FocusScope.of(context).hasFocus) {
    //         FocusScope.of(context).unfocus();
    //       }
    //
    //       if (!isValidPayee) {
    //         setState(() {
    //           errorMessage = AppLocalization.of(context).invalidRecipient;
    //           return;
    //         });
    //       }
    //
    //       if (recipient == _payee.userName) {
    //         if (!isValidPayee) {
    //           setState(() {
    //             errorMessage = AppLocalization.of(context).invalidRecipient;
    //             return;
    //           });
    //         }
    //
    //         if (isValidPayee &&
    //             _formKey.currentState.validate() &&
    //             validateDropdown()) {
    //           if (userBloc.user.userName != recipient) {
    //             var userLocation;
    //             Map deviceData;
    //             try {
    //               userLocation = await locationService.getLocation();
    //               deviceData = await getDeviceInfo();
    //               var data = {
    //                 "from_customer": userBloc.user.userName,
    //                 "to_customer": recipient.trim(),
    //                 "currency": userBloc.user.currency,
    //                 "amount": amount.toString().trim(),
    //                 "category": selectedCategory.trim(),
    //                 "notes": reference.trim(),
    //                 "description": reference.trim(),
    //                 "latitude": userLocation.latitude,
    //                 "longitude": userLocation.longitude,
    //                 "deviceData": deviceData
    //               };
    //
    //               PassCodePopup(
    //                   context: context,
    //                   isValidCallback: () {
    //                     showDialog(
    //                         context: context,
    //                         builder: (context) => Center(
    //                                 child: CircularProgressIndicator(
    //                               strokeWidth: 2.5,
    //                               valueColor:
    //                                   AlwaysStoppedAnimation(Colors.white),
    //                               backgroundColor: lightBlue(),
    //                             )));
    //                     _auth.makePayment(data).then((value) {
    //                       response = value;
    //                       if (response.statusCode == 200) {
    //                         popFromShoppingCart(product);
    //                         //Pop Circular Progress Indicator
    //                         Navigator.pop(context);
    //                         //Pop send payment page
    //                         Navigator.pop(context);
    //                         Navigator.of(context).pushNamed(
    //                           '/transactions',
    //                         );
    //                       } else if (response.statusCode == 500) {
    //                         Navigator.pop(context);
    //                         setState(() {
    //                           errorMessage =
    //                               AppLocalization.of(context).serverError;
    //                           Toast.show(errorMessage, context,
    //                               gravity: Toast.TOP,
    //                               backgroundColor: darkBlue(),
    //                               textColor: Colors.white);
    //                         });
    //                       } else if (response.statusCode == 700) {
    //                         Navigator.pop(context);
    //                         Navigator.pushNamed(context, "/bvn-verification");
    //                       } else if (response.statusCode == 800) {
    //                         Navigator.pop(context);
    //                         Navigator.pushNamed(context, "/add-document");
    //                       } else {
    //                         Navigator.pop(context);
    //                         setState(() {
    //                           errorMessage = AppLocalization.of(context)
    //                               .somethingWentWrong;
    //                           Toast.show(errorMessage, context,
    //                               gravity: Toast.TOP,
    //                               backgroundColor: darkBlue(),
    //                               textColor: Colors.white);
    //                         });
    //                       }
    //                     });
    //                   },
    //                   cancelCallBack: () {
    //                     Navigator.pop(context);
    //                     _sendPaymentScaffold.currentState.showSnackBar(SnackBar(
    //                       content:
    //                           Text(AppLocalization.of(context).invalidPassword),
    //                     ));
    //                   });
    //             } catch (e) {
    //               print(e);
    //               Toast.show(e, context,
    //                   gravity: Toast.BOTTOM, backgroundColor: darkBlue());
    //             }
    //           } else {
    //             Toast.show(
    //               AppLocalization.of(context).invalidRecipient,
    //               context,
    //               textColor: Colors.white,
    //               backgroundColor: darkBlue(),
    //             );
    //           }
    //         }
    //       } else {
    //         var msg = AppLocalization.of(context).invalidRecipient;
    //         Toast.show(msg, context,
    //             gravity: Toast.CENTER,
    //             backgroundColor: darkBlue(),
    //             textColor: Colors.white);
    //       }
    //     },
    //   ),
    // );

    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context).sendPayment,
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
            userLocation = await locationService.getLocation();
            deviceData = await getDeviceInfo();
            var data = {
              "from_customer": userBloc.user.userName,
              "to_customer": recipient.trim(),
              "currency": userBloc.user.currency,
              "amount": amount.toString().trim(),
              "category": selectedCategory.trim(),
              "notes": reference.trim(),
              "description": reference.trim(),
              "latitude": userLocation.latitude,
              "longitude": userLocation.longitude,
              "deviceData": deviceData
            };

            BottomSheetPassCode(
                context: context,
                isValidCallback: () {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          Center(child: CircularLoadingIndicator()));
                  _auth.makePayment(data).then((value) {
                    response = value;
                    if (response.statusCode == 200) {
                      popFromShoppingCart(product);
                      //Pop Circular Progress Indicator
                      Navigator.pop(context);
                      //Pop send payment page
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(
                        '/transactions',
                      );
                    } else if (response.statusCode == 500) {
                      Navigator.pop(context);
                      setState(() {
                        errorMessage = AppLocalization.of(context).serverError;
                        Toast.show(errorMessage, context,
                            gravity: Toast.TOP,
                            backgroundColor: darkBlue(),
                            textColor: Colors.white);
                      });
                    } else if (response.statusCode == 700) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/bvn-verification");
                    } else if (response.statusCode == 800) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/add-document");
                    } else {
                      Navigator.pop(context);
                      setState(() {
                        errorMessage =
                            AppLocalization.of(context).somethingWentWrong;
                        Toast.show(errorMessage, context,
                            gravity: Toast.TOP,
                            backgroundColor: darkBlue(),
                            textColor: Colors.white);
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
            print(e);
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
    _amountController.dispose();
    _referenceController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
