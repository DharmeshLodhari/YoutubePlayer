import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddOrUpdateInvoiceItem extends StatefulWidget {
  int? invoiceId;
  final InvoiceItem? invoiceItem;

  AddOrUpdateInvoiceItem({this.invoiceItem, this.invoiceId});

  @override
  _AddOrUpdateInvoiceItemState createState() => _AddOrUpdateInvoiceItemState();
}

class _AddOrUpdateInvoiceItemState extends State<AddOrUpdateInvoiceItem> {
  double totalCost = 0;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  InvoiceItem? _invoiceItem;

  final _formKey = GlobalKey<FormState>();
  final _addItemScaffoldKey = GlobalKey<ScaffoldState>();

  late UserBloc userBloc;

  double? amount;

  String errorMessage = "";
  String? recipient;
  late AddInvoiceBloc addInvoiceBloc;

  @override
  void initState() {
    if (widget.invoiceItem != null) {
      _descriptionController.text = widget.invoiceItem!.name!;
      _amountController.text = (widget.invoiceItem!.amount! / 100).toString();
      _invoiceItem = InvoiceItem(
        id: widget.invoiceItem!.id,
        name: widget.invoiceItem!.name,
        currency: widget.invoiceItem!.currency,
        quantity: widget.invoiceItem!.quantity,
      );

      totalCost = (double.parse(_amountController.text.replaceAll(',', '')) *
              _invoiceItem!.quantity!)
          .toDouble();
    } else {
      _invoiceItem = InvoiceItem();
    }

    _amountController.addListener(() {
      if (_amountController.text.isEmpty) {
        totalCost = 0;
        _invoiceItem!.quantity = 1;
        if (mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    addInvoiceBloc = Provider.of<AddInvoiceBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _addItemScaffoldKey,
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.invoiceItem != null ? 'Update Item' : "Add item",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            getDescriptionField(),
                            const SizedBox(height: 20),
                            displayAmountField(),
                            const SizedBox(height: 20),
                            getQtyOfItem(),
                            const SizedBox(height: 20),
                            getTotalText(),
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                getSubmitButton(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getTotalText() {
    return _amountController.text.isNotEmpty
        ? Row(
            children: [
              Text(
                'Total: ',
                style: TextStyle(
                    color: darkGrey, fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text("$totalCost"),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getDescriptionField() {
    return CustomizedTextFormField(
      labelText: "Item description",
      controller: _descriptionController,
      validator: (value) {
        if (value.isNotEmpty) {
          return null;
        } else {
          return 'Field cannot be empty';
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Unit cost",
      isAmountField: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = double.parse(val.replaceAll(',', ''));

            totalCost =
                double.parse(_amountController.text.replaceAll(',', '')) *
                    _invoiceItem!.quantity!;
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            debugPrint("Error $e");
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getQtyOfItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Quantity",
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
                    if (_amountController.text.isNotEmpty) {
                      if (_invoiceItem!.quantity! > 1) {
                        _invoiceItem!.quantity = _invoiceItem!.quantity! - 1;
                        totalCost = (double.parse(_amountController.text
                                    .replaceAll(',', '')) *
                                _invoiceItem!.quantity!)
                            .toDouble();
                        setState(() {});
                      }
                    } else {
                      showToast(message: 'Add an amount');
                    }
                  }),
              const Expanded(
                child: SizedBox(
                  width: 10,
                ),
              ),
              Text(
                _invoiceItem!.quantity.toString(),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
              const Expanded(
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
                    if (_amountController.text.isNotEmpty) {
                      _invoiceItem!.quantity = _invoiceItem!.quantity! + 1;
                      totalCost = double.parse(
                              _amountController.text.replaceAll(',', '')) *
                          _invoiceItem!.quantity!;
                    } else {
                      showToast(message: 'Add an amount');
                    }
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
      text: widget.invoiceItem != null ? 'Update' : "Add item",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState!.validate()) {
      final InvoiceItem invoiceItem = InvoiceItem(
        amount: int.parse(_amountController.text
                .trim()
                .replaceAll(',', '')
                .split('.')[0]) *
            100,
        quantity: _invoiceItem!.quantity,
        currency: userBloc.user.currency,
        name: _descriptionController.text.trim(),
      );
      // To update an invoice
      if (widget.invoiceItem != null) {
        _updateInvoiceItem(widget.invoiceItem!.id!, invoiceItem);
      }
      // To add an item to an existing invoice.
      else if (widget.invoiceId != null) {
        _addInvoiceItemToExistingInvoice(widget.invoiceId!, invoiceItem);
      } else {
        // To add an item when creating a fresh invoice.
        try {
          // var data = {
          //   "amount": amount.toString().trim(),
          // };
          //
          // debugPrint(data.toString());

          _invoiceItem!.name = _descriptionController.text.trim();
          _invoiceItem!.amount = int.parse(
              _amountController.text.replaceAll(",", "").split('.')[0].trim());
          _invoiceItem!.currency = userBloc.user.currency;

          addInvoiceBloc.addItem(invoiceItem: _invoiceItem);

          Navigator.pop(context);
        } catch (e) {
          debugPrint(e.toString());
          showToast(message: e.toString());
        }
      }
    }
  }

  void _addInvoiceItemToExistingInvoice(
      int invoiceId, InvoiceItem invoiceItem) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());
    BusinessAuth()
        .addInvoiceItemToExistingInvoice(
            invoiceId: invoiceId, invoiceItem: invoiceItem)
        .then(
      (updated) {
        Navigator.pop(context); // Dismiss the loader.

        if (updated) {
          Navigator.pop(context, true); // Pop to Invoice detail page;
        }
      },
    ).catchError(
      (e) {
        Navigator.of(context).pop();
        showToast(message: 'ERROR ::: ${e.toString()}');
      },
    );
  }

  void _updateInvoiceItem(int itemId, InvoiceItem invoiceItem) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());
    BusinessAuth()
        .updateInvoiceItem(itemId: itemId, invoiceItem: invoiceItem)
        .then(
      (updated) {
        Navigator.pop(context); // Dismiss the loader.

        if (updated) {
          Provider.of<InvoiceBloc>(context, listen: false).isSender = true;
          Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
          Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
          Navigator.pop(context, true); // Pop to Invoice detail page;
        }
      },
    ).catchError(
      (e) {
        Navigator.of(context).pop();
        showToast(message: 'ERROR ::: ${e.toString()}');
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
