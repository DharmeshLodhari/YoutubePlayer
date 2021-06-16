import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class EditInvoiceItem extends StatefulWidget {
  var arguments;
  EditInvoiceItem({this.arguments});

  // Declare a field that holds the userData.
  @override
  _EditInvoiceItemState createState() => _EditInvoiceItemState();
}

class _EditInvoiceItemState extends State<EditInvoiceItem> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  UserBloc userBloc;

  InvoiceItem _invoiceItem;
  int itemIndex;

  final _formKey = GlobalKey<FormState>();
  final _addItemScaffoldKey = GlobalKey<ScaffoldState>();

  int amount;

  String errorMessage = "";
  String recipient;
  AddInvoiceBloc addInvoiceBloc;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void getInvoiceItem() async {
    if (_invoiceItem == null) {
      itemIndex = widget.arguments["index"];
      _invoiceItem = addInvoiceBloc.items.elementAt(itemIndex);
      _descriptionController.text = _invoiceItem.name;
      _amountController.text = _invoiceItem.amount.toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    addInvoiceBloc = Provider.of<AddInvoiceBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    getInvoiceItem();
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _addItemScaffoldKey,
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Edit item",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return _invoiceItem != null
        ? SingleChildScrollView(
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
                                    getQtyOfItem(),
                                    errorMessage == ""
                                        ? Container()
                                        : Text(
                                            errorMessage,
                                            style: TextStyle(
                                                color: mateRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                    SizedBox(
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
          )
        : Center(
            child: CircularLoadingIndicator(),
          );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getRecipientField() {
    return CustomizedTextFormField(
      labelText: "Item description",
      controller: _descriptionController,
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
    );
  }

  Widget getQtyOfItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Qty",
          style: TextStyle(
              color: darkGrey, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Container(
          width: 100,
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RoundedBackgroundIcon(
                  backgroundColor: iconBtnGrey,
                  icon: Icon(
                    SlydoAppIcon.minus,
                    color: blackFont,
                    size: 2,
                  ),
                  onTap: () {
                    if (_invoiceItem.quantity > 1) {
                      _invoiceItem.quantity--;
                      setState(() {});
                    }
                  }),
              Expanded(
                child: SizedBox(
                  width: 10,
                ),
              ),
              Text(
                _invoiceItem.quantity.toString(),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
              Expanded(
                child: SizedBox(
                  width: 10,
                ),
              ),
              RoundedBackgroundIcon(
                  backgroundColor: iconBtnGrey,
                  icon: Icon(
                    SlydoAppIcon.plus,
                    color: blackFont,
                    size: 16,
                  ),
                  onTap: () {
                    _invoiceItem.quantity++;
                    setState(() {});
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update item",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      try {
        var data = {
          "amount": amount.toString().trim(),
        };
        debugPrint("$data");

        _invoiceItem.name = _descriptionController.text.trim();
        _invoiceItem.amount = int.parse(_amountController.text.trim());
        _invoiceItem.currency = userBloc.user.currency;

        addInvoiceBloc.updateItem(index: itemIndex, invoiceItem: _invoiceItem);

        ///
        Navigator.pop(context);
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
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
