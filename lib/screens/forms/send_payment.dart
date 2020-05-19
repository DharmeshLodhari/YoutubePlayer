import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/widget/passcodePopup.dart';
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
  List<String> paymentCategoriesTest = List();
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
          setState(() {
            _recipientController.text = _recipientController.text.toLowerCase();
          });
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
      if (customerProfileBloc.customer.userName != null) {
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
    basketBloc = Provider.of<BasketBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _payee = null;
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        key: _sendPaymentScaffold,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            actions: <Widget>[getUserProfileIcon()],
            leading: showBackArrow(),
            title: Center(child: Text(AppLocalization.of(context).sendPayment)),
            backgroundColor: darkBlue()),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          getDisplayCard(),
                          SizedBox(height: 10),
                          getRecipientField(),
                          SizedBox(height: 10),
                          displayAmountField(),
                          SizedBox(height: 10),
                          getCategoryField(),
                          SizedBox(height: 10),
                          getReferenceField(),
                          SizedBox(height: 10),
                          Text(
                            errorMessage,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          getSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
    //
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
    return Container();
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
      avatarImage = CachedNetworkImage(
        imageUrl: _payee.avatar,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
      setState(() {
        isValidPayee = true;
      });

      qrCodeImage = CachedNetworkImage(
        imageUrl: _payee.qrCode,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
    }

    return _payee == null
        ? Container()
        : Card(
            semanticContainer: true,
            child: ListTile(
              dense: true,
              title: Text(
                _payee.fullName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              subtitle: Text(_payee.userName),
              leading: avatarImage,
              trailing: qrCodeImage,
            ),
          );
  }

  Widget getRecipientField() {
    return TextFormField(
      controller: _recipientController,
      enabled: isFromProfile,
      focusNode: _recipientFocus,
      textCapitalization: TextCapitalization.none,
      cursorColor: darkBlue(),
      validator: (value) {
        if (!isFromProfile && value != _payee.userName) {
          return AppLocalization.of(context).invalidRecipient;
        }
        return null;
      },
      autofocus: false,
      obscureText: false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        fillColor: Colors.white,
        filled: true,
        hintText: AppLocalization.of(context).recipient,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(
                width: 1, color: Colors.white, style: BorderStyle.solid)),
      ),
      onChanged: (val) {
        setState(() {
          if (!isFromProfile && _payee != null) {
            recipient = _payee.userName;
          } else {
            recipient = val.toLowerCase();
          }
        });
      },
    );
  }

  Widget displayAmountField() {
    return TextFormField(
      cursorColor: darkBlue(),
      controller: _amountController,
      enabled: product == null && service == null,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Container(
            width: 20,
            child: Center(
              child: Text(
                worldCurrencies[userBloc.user.currency],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontFamily: "Roboto",
                ),
              ),
            ),
          ),
          hintText: AppLocalization.of(context).enterAmount,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
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
        if (recipient != null) {
          await _auth.fetchCustomerProfile(recipient).then((customerProfile) {
            if (customerProfile != null) {
              setState(() {
                _payee = customerProfile;
                isValidPayee = _payee.userName != userBloc.user.userName;
              });
            }
          });
        }
      },
      onChanged: (val) {
        setState(() {
          amount = int.parse(val);
        });
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
      ),
    );
  }

  Widget getReferenceField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      enabled: product == null && service == null,
      obscureText: false,
      controller: _referenceController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.note),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).reference,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      onChanged: (val) {
        setState(() {
          reference = val;
        });
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).sendPayment),
        onPressed: () async {
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
              // Todo: Add a try block here and stop user from continuing if they deny location permission
              if (userBloc.user.userName != recipient) {
                var userLocation;
                Map deviceData;
                try {
                  userLocation = await locationService.getLocation();
                  deviceData = await getDeviceInfo();
                  var data = {
                    "from_customer": userBloc.user.userName,
                    "to_customer": recipient,
                    "currency": userBloc.user.currency,
                    "amount": amount.toString(),
                    "category": selectedCategory,
                    "notes": reference,
                    "description": reference,
                    "latitude": userLocation.latitude,
                    "longitude": userLocation.longitude,
                    "deviceData": deviceData
                  };

                  PassCodePopup(
                      context: context,
                      isValidCallback: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                Center(child: CircularProgressIndicator()));
                        _auth.makePayment(data).then((value) {
                          response = value;
                          if (response.statusCode == 200) {
                            popFromShoppingCart(product);
                            Navigator.of(context).pushNamed(
                              '/transactions',
                            );
                          } else if (response.statusCode == 500) {
                            Navigator.pop(context);
                            setState(() {
                              errorMessage =
                                  AppLocalization.of(context).serverError;
                              Toast.show(errorMessage, context,
                                  gravity: Toast.TOP,
                                  backgroundColor: darkBlue(),
                                  textColor: Colors.white);
                            });
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              errorMessage = AppLocalization.of(context)
                                  .somethingWentWrong;
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
                          content:
                              Text(AppLocalization.of(context).invalidPassword),
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
        },
      ),
    );
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
}
