import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Invoice.dart';
import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../../widget/LoadingIndicator.dart';
import '../../../../search_user.dart';
import '../../business_auth.dart';

// ignore: must_be_immutable
class AddInvoice extends StatefulWidget {
  var arguments;

  AddInvoice({this.arguments});

  // Declare a field that holds the userData.
  @override
  _AddInvoiceState createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> {
  TextEditingController _recipientController = TextEditingController();
  TextEditingController _invoiceController = TextEditingController(text: "021");
  TextEditingController _amountController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();
  http.Response? response;

  final _formKey = GlobalKey<FormState>();
  final _addInvoiceScaffoldKey = GlobalKey<ScaffoldState>();
  CustomerProfile? _payee;
  late UserBloc userBloc;

  bool isValidPayee = false;
  int? amount;

  InvoiceModel? invoice;

  String errorMessage = "";
  String? recipient;

  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now();

  PaymentDuration? selectedDuration;
  late AddInvoiceBloc _addInvoiceBloc;
  String? conversationId;

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
    _addInvoiceBloc = Provider.of<AddInvoiceBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        _payee = null;
        _addInvoiceBloc.clearItems();

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _addInvoiceScaffoldKey,
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
          _addInvoiceBloc.clearItems();
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Add Invoice",
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getDisplayCard(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              getRecipientField(),
                              SizedBox(height: 8),
                              Text("Invoice detail",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: blackFont)),
                              SizedBox(height: 16),
                              getInvoiceNumber(),
                              // SizedBox(height: 8),
                              // displayAmountField(),

                              SizedBox(height: 8),
                              getDateField(),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Items",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: blackFont)),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed(Routes.ADD_INVOICE_ITEM);
                                    },
                                    child: Icon(Icons.add, size: 18),
                                  )
                                ],
                              ),
                              SizedBox(height: 8),
                              getInvoiceItems(),

                              SizedBox(height: 8),
                              getInvoiceTotal(),
                              // SizedBox(height: 16),
                              // getPaymentPeriodDropDown(),
                              SizedBox(height: 8),
                              errorMessage == ""
                                  ? Container()
                                  : Text(
                                      errorMessage,
                                      style: TextStyle(
                                          color: mateRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                              SizedBox(height: 8),
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
                  SizedBox(height: 20),
                  getSubmitButton(),
                  SizedBox(height: 20),
                ],
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

  Widget getInvoiceItems() {
    if (_addInvoiceBloc.items.length != 0) {
      if (mounted) {
        setState(() {
          errorMessage = '';
        });
      }
      return Column(
        children: enumerate(_addInvoiceBloc.items)
            .map(
              (indexedValue) => ListTile(
                onTap: () {
                  Navigator.pushNamed(context, Routes.EDIT_INVOICE_ITEM,
                      arguments: {"index": indexedValue.index});
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  indexedValue.value!.name!,
                  style: TextStyle(fontSize: 14, color: blackFont),
                  textAlign: TextAlign.justify,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      "Qty : ",
                      style: TextStyle(fontSize: 12, color: darkGrey),
                    ),
                    Text(
                      indexedValue.value!.quantity.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Unit price : ",
                      style: TextStyle(fontSize: 12, color: darkGrey),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₦",
                          style: TextStyle(
                              fontFamily: "Roboto",
                              color: blackFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        Text(
                          indexedValue.value!.amount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: blackFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "₦",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          color: navyBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      (indexedValue.value!.amount! *
                              indexedValue.value!.quantity!)
                          .toString(),
                      style: TextStyle(
                          color: navyBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Container(
        child: Center(child: Text("No item")),
        height: 100,
      );
    }
  }

  Widget getInvoiceTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Total",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: blackFont)),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "₦",
              style: TextStyle(
                  fontFamily: "Roboto",
                  color: navyBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            ),
            Text(
              _addInvoiceBloc.total.toString(),
              style: TextStyle(
                  color: navyBlue, fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ],
        ),
      ],
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
            imageUrl: _payee!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      );
      setState(() {
        isValidPayee = true;
      });

      qrCodeImage = CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: _payee!.qrCode ?? "",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        errorWidget: imageErrorWidget,
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
        CustomerProfile? userFound =
            await NavigationUtil.push(context, screen: SearchUser());

        if (userFound != null) {
          _payee = userFound;
          isValidPayee = _payee!.userName != userBloc.user.userName;
          _recipientController.text = _payee!.userName!;
          if (mounted)
            setState(() {
              errorMessage = "";
            });
        }
      },
    );
  }

  Widget getInvoiceNumber() {
    return CustomizedTextFormField(
        labelText: "Invoice number",
        controller: _invoiceController,
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
        });
  }

  // Widget displayAmountField() {
  //   return CustomizedTextFormField(
  //     labelText: "Amount",
  //     isAmountField: true,
  //     keyboardType: Platform.isIOS
  //         ? TextInputType.numberWithOptions(decimal: true)
  //         : TextInputType.number,
  //     // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //     controller: _amountController,
  //     onChanged: (val) {
  //       if (mounted) {
  //         setState(() {
  //           amount = int.parse(val);
  //         });
  //       }
  //     },
  //     validator: (val) {
  //       if (val.isNotEmpty) {
  //         try {
  //           int.parse(val);
  //           return null;
  //         } catch (e) {}
  //       }
  //       return AppLocalization.of(context)!.invalidAmount;
  //     },
  //     onTap: () async {
  //       isValidPayee = false;
  //       setState(() {});
  //       if (recipient != null) {
  //         recipient = recipient!.trim();
  //         if (mounted) {
  //           setState(() {
  //             _recipientController.text = recipient!;
  //           });
  //         }
  //         var customerProfile =
  //             await UserAuth().fetchCustomerProfileWithAuth(recipient);
  //         if (mounted) {
  //           setState(() {
  //             _payee = customerProfile;
  //             isValidPayee = _payee!.userName != userBloc.user.userName;
  //           });
  //         }
  //         _recipientController.text = customerProfile.userName!;
  //       }
  //     },
  //   );
  // }

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
                invoiceDate = DateTime(value!.year, value.month, value.day);
                setState(() {});
              }).catchError((error) {});
            },
            child: CustomizedDropDownField(
              title: "Invoice date",
              child: Container(
                child: ListTile(
                  dense: true,
                  title: Text(
                    formatDateInDigit(invoiceDate),
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
        SizedBox(width: 10),
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
                dueDate = DateTime(value!.year, value.month, value.day);
                setState(() {});
              }).catchError((error) {});
            },
            child: CustomizedDropDownField(
              title: "Due date",
              child: Container(
                child: ListTile(
                  dense: true,
                  title: Text(
                    formatDateInDigit(dueDate),
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
          "Currency",
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
      text: "Submit",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (isValidPayee == false) {
      errorMessage = AppLocalization.of(context)!.invalidRecipient;
      setState(() {});
      return;
    }

    if (_recipientController.text != userBloc.user.userName) {
      if (isValidPayee == false) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.invalidRecipient;
        });
        return;
      }
      if (_addInvoiceBloc.items.isEmpty) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.addItems;
        });
        return;
      }

      if (isValidPayee && _formKey.currentState!.validate()) {
        if (userBloc.user.userName != recipient) {
          try {
            List<InvoiceItem?> invoiceItem = [];

            invoiceItem = _addInvoiceBloc.items;

            await BusinessAuth()
                .getConversationId(name: _recipientController.text)
                .then(
              (value) {
                if (value != null) {
                  conversationId = value;
                }
              },
            );
            var data = {
              "from_customer": userBloc.user.userName,
              "to_customer": _recipientController.text.trim(),
              "invoice_number": _invoiceController.text.trim().toString(),
              // "invoice_date": dateToString(invoiceDate),
              "due_date": dateToString(dueDate),
              "items": invoiceItem
            };

            invoiceItem.forEach(
              (item) {
                print('AMOUNT PR ::: ${item!.amount}');
                int index = invoiceItem.indexOf(item);
                invoiceItem[index]!.amount = invoiceItem[index]!.amount! * 100;
              },
            );
            if (conversationId != null) {
              data['conversation_id'] = conversationId!;
            }

            showDialog(
                context: context,
                builder: (dialogLoadingContext) => LoadingIndicator());

            BusinessAuth().addInvoice(data).then((result) {
              Navigator.pop(context); // Dismiss the loading indicator

              if (result) {
                _addInvoiceBloc.clearItems();
                Navigator.pop(context, true);
              }
            }).catchError((error) {
              Navigator.pop(context); // Dismiss the loading indicator
              showToast(
                message: error.toString(),
              );
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
      var msg = AppLocalization.of(context)!.invalidRecipient;
      showToast(message: msg);
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }
}
