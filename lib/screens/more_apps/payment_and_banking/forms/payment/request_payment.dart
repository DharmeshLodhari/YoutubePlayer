import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
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

import '../../payment_and_banking_auth.dart';

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

  late DashboardBloc _dashboardBloc;

  _RequestPaymentState({this.arguments});

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final requestPaymentScaffold = GlobalKey<ScaffoldState>();
  CustomerProfile? _payee;
  late UserBloc userBloc;
  late CustomerProfileBloc customerProfileBloc;

  late http.Response response;

  bool? isFromProfile = false;
  bool? isFromChat = false;
  bool isValidPayee = false;
  double? amount;
  String reference = "";
  String errorMessage = "";
  String? recipient;
  final locationService = LocationService();

  bool showMoreOption = false;

  String? conversationId;

  //variables for categories
  bool isLoading = true;

  List<String?> paymentCategoriesTest = [];

  String? selectedCategory;

  PaymentCategory? selectedPaymentCategory;
  String? paymentCategory;

  @override
  void initState() {
    isFromProfile = arguments != null
        ? arguments['isFromProfile'] != null
            ? arguments['isFromProfile']
            : false
        : false;
    isFromChat = widget.arguments != null
        ? widget.arguments['isFromChat'] != null
            ? widget.arguments['isFromChat']
            : false
        : false;
    conversationId = widget.arguments != null
        ? widget.arguments['conversationId'] != null
            ? widget.arguments['conversationId']
            : null
        : null;

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
      if (!isFromProfile!) {
        if (customerProfileBloc.customer != null) {
          if (mounted) {
            setState(() {
              _payee = customerProfileBloc.customer;
              recipient = _payee!.userName;
              _recipientController.text = recipient!;
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
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
          await Future.delayed(Duration(milliseconds: 300));
        }
        _payee = null;
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        key: requestPaymentScaffold,
        backgroundColor: Colors.white,
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
        onPressed: () {
          _payee = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.requestPayment,
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget getDisplayCard() {
    initializeDisplayCard();
    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      Color borderColor = getUserTypeColor(user: _payee!);

      avatarImage = Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed("/photo-viewer", arguments: _payee!.avatar);
          },
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: _payee!.avatar!,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      );

      qrCodeImage = GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed("/photo-viewer", arguments: _payee!.qrCode);
        },
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: _payee!.qrCode!,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          errorWidget: imageErrorWidget,
        ),
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
                    _payee!.displayName()!,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    _payee!.userName!,
                    style: TextStyle(fontSize: 14, color: darkGrey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
      enabled: isFromProfile,
      validator: (value) {
        if (!isFromProfile! && value != _payee!.userName) {
          return AppLocalization.of(context)!.invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (!isFromProfile! && _payee != null) {
              recipient = _payee!.userName;
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
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
      onTap: () async {
        isValidPayee = false;
        if (mounted) setState(() {});
        if (recipient != null) {
          recipient = recipient!.trim();

          _recipientController.text = recipient!;
          if (mounted) setState(() {});
          var customerProfile =
              await UserAuth().fetchCustomerProfile(recipient);

          _payee = customerProfile;
          isValidPayee = _payee!.userName != userBloc.user.userName;

          if (mounted) setState(() {});
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
                child: Text(AppLocalization.of(context)!.category),
              ),
            ],
          ),
          value: selectedCategory,
          onChanged: (String? value) {
            if (mounted) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
          items: paymentCategoriesTest.map((String? category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  category!,
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
          AppLocalization.of(context)!.category,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 6),
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
              selectedCategory != null ? selectedCategory! : "",
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
                                  category!,
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
                              category!,
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
      labelText: AppLocalization.of(context)!.reference,
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
      text: AppLocalization.of(context)!.requestPayment,
    );
  }

  void onSubmit() async {
    FocusScope.of(context).unfocus();

    await Future.delayed(Duration(milliseconds: 500));

    if (!isValidPayee) {
      if (mounted) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.invalidRecipient;
          return;
        });
      }
    }

    if (recipient == _payee!.userName) {
      if (!isValidPayee) {
        if (mounted) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.invalidRecipient;
            return;
          });
        }
      }

      if (isValidPayee &&
          _formKey.currentState!.validate() &&
          validateDropdown()) {
        if (userBloc.user.userName != recipient) {
          var userLocation;
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

                  var data = {
                    "from_customer": userBloc.user.userName!.trim(),
                    "to_customer": recipient!.trim(),
                    "currency": userBloc.user.currency,
                    "amount": moneyInputNormalizer(amount.toString()),
                    "category": selectedCategory!.trim(),
                    "notes": reference.trim(),
                    "description": reference.trim(),
                    "latitude": Platform.isIOS ? userLocation.latitude : "",
                    "longitude": Platform.isIOS ? userLocation.longitude : "",
                    "made_from_chat": isFromChat ?? false,
                  };
                  if (conversationId != null) {
                    data["conversation_id"] = conversationId;
                  }

                  await _auth.createPaymentRequests(data).then((value) {
                    response = value;
                    if (response.statusCode == 201) {
                      if (!isFromChat!) {
                        _dashboardBloc.index = 0;
                        showToast(message: 'Payment request sent');
                        RefreshBlocForRequestPayment
                            refreshBlocForRequestPayment =
                            Provider.of<RefreshBlocForRequestPayment>(context,
                                listen: false);
                        refreshBlocForRequestPayment.isRefresh = true;
                        Navigator.popUntil(
                            context, ModalRoute.withName("/dashboard"));
                      } else {
                        //Pop Circular Progress Indicator
                        Navigator.pop(context);
                        //Pop request payment page
                        Navigator.pop(context);
                      }
                    } else if (response.statusCode == 500) {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          errorMessage =
                              AppLocalization.of(context)!.serverError;
                          showToast(message: errorMessage);
                        });
                      }
                    } else {
                      Navigator.pop(context);
                      if (mounted) {
                        if (response.statusCode == 406) {
                          errorMessage = jsonDecode(value.body)[0];
                          showToast(message: "$errorMessage");
                          setState(() {});
                        } else {
                          debugPrint("ERROR:- ${response.body}");
                          setState(() {
                            errorMessage =
                                AppLocalization.of(context)!.somethingWentWrong;
                            showToast(message: "$errorMessage");
                          });
                        }
                      }
                    }
                  });
                },
                cancelCallBack: () async {
                  Navigator.pop(context);
                  requestPaymentScaffold.currentState!.showSnackBar(SnackBar(
                    content: Text(AppLocalization.of(context)!.invalidPassword),
                  ));
                });
          } catch (e) {
            debugPrint(e.toString());
            showToast(message: e.toString());
          }
        } else {
          var msg = AppLocalization.of(context)!.invalidRecipient;
          showToast(message: msg);
        }
      }
    } else {
      var msg = AppLocalization.of(context)!.invalidRecipient;
      showToast(message: msg);
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
    _recipientFocus.dispose();
    super.dispose();
  }
}
