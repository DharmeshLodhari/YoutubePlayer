import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class AddEditCurrency extends StatefulWidget {
  AddEditCurrency({super.key, this.currencyModel, this.currencyList});

  final CurrencyModel? currencyModel;
  final List<CurrencyModel>? currencyList;

  @override
  State<AddEditCurrency> createState() => _AddEditCurrencyState();
}

class _AddEditCurrencyState extends State<AddEditCurrency> {
  final _formKey = GlobalKey<FormState>();
  bool isEdit = false;
  bool isDeleteLoading = false;
  bool isAPILoading = false;
  String? selectedCurrency;
  late CurrencyModel currencyModel;

  List<String> currencyListData = [
    "USD",
    "GBP",
    "EUR",
    "KHR",
    "CAD",
  ];

  @override
  void initState() {
    if (widget.currencyModel != null) {
      isEdit = true;
    }
    currencyModel = widget.currencyModel?.copyWith() ?? CurrencyModel();
    selectedCurrency = currencyNameAndSymbol(currencyModel.currency);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await getExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: false,
        appBar: appBar(context) as PreferredSizeWidget?,
        body: buildBody(),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () async {
          await getExitDialog(context);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.currency,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    currencyField(),
                    const SizedBox(height: 10),
                    exchangeRateField(),
                    // const SizedBox(height: 10),
                    // slydoRateSwitch(),
                    const SizedBox(height: 20),
                    getSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget currencyField() {
    return CustomizedDropDownField(
      title: "Currency",
      child: ListTile(
        dense: true,
        title: Text(
          selectedCurrency ?? "",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          if (!isEdit) {
            selectCurrency();
          }
        },
      ),
    );
  }

  void selectCurrency() async {
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: SizedBox(
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
                  children: currencyListData
                      .where((String currency) => !widget.currencyList!.any(
                          (CurrencyModel model) => model.currency == currency))
                      .map<Widget>((String currency) {
                    if (currencyModel.currency == currency) {
                      return Container(
                        color: selectedListItemBackgroundBlue,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            currencyNameAndSymbol(currency),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: navyBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            SlydoAppIcon.checked,
                            color: navyBlue,
                            size: 12,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            currencyModel.currency = currency;
                            selectedCurrency = currencyNameAndSymbol(currency);
                            setState(() {});
                          },
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(
                        currencyNameAndSymbol(currency),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontFamily: "Inter",
                            color: blackFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context);
                        currencyModel.currency = currency;
                        selectedCurrency = currencyNameAndSymbol(currency);
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget exchangeRateField() {
    return CustomizedTextFormField(
      labelText: "Exchange Rate (₦)",
      initialValue: currencyModel.rate != null
          ? moneyDisplayNormalizer(currencyModel.rate)
          : "",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
      onChanged: (String val) {
        if (val.isNotEmpty) {
          try {
            currencyModel.rate = moneyInputNormalizer(val);
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
    );
  }

  Widget slydoRateSwitch() {
    return Row(
      children: [
        SizedBox(
          width: 50,
          height: 35,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch(
              value: currencyModel.isAutoUpdatedBySlydo ?? false,
              onChanged: (value) {
                currencyModel.isAutoUpdatedBySlydo = value;
                setState(() {});
              },
              thumbIcon: MaterialStateProperty.all(const Icon(null)),
              activeTrackColor: navyBlue,
              activeColor: Colors.white,
              inactiveTrackColor: darkGreyYarn,
              inactiveThumbColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Slydo Rate",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getSubmitButton() {
    if (isEdit) {
      return Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: isDeleteLoading
                  ? () {}
                  : () {
                      FocusScope.of(context).unfocus();
                      deleteCurrencyDialog();
                    },
              backgroundColor: red,
              textColor: Colors.white,
              text: "Delete",
              isLoading: isDeleteLoading,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: CurvedButton(
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAPILoading = true;
                      if (mounted) setState(() {});

                      await addEditCurrency();

                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: Colors.white,
              text: "Update",
              isLoading: isAPILoading,
            ),
          )
        ],
      );
    }

    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addEditCurrency();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  void deleteCurrencyDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Currency',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this Currency ?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        isDeleteLoading = true;
        if (mounted) setState(() {});

        await deleteCurrency();

        isDeleteLoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> addEditCurrency() async {
    if (_formKey.currentState?.validate() ?? false) {
      await UserAuth()
          .addUpdateCurrency(currencyModel, isEdit: isEdit)
          .then((value) async {
        Navigator.pop(context, true);
        showToast(
          message: isEdit
              ? "Currency updated successfully"
              : "Currency added successfully",
        );
      }).catchError((error) {
        debugPrint("Currency check::: ${error.toString()}");
        showToast(message: error.toString());
      });
    } else {
      showToast(message: "Please fill all the details");
    }
  }

  Future<void> deleteCurrency() async {
    await UserAuth().deleteCurrency(currencyModel.id ?? "").then((value) async {
      Navigator.pop(context, true);
      showToast(
        message: "Currency deleted successfully",
      );
    }).catchError((error) {
      debugPrint("Currency::: ${error.toString()}");
      showToast(message: error.toString());
    });
  }

  dynamic getExitDialog(BuildContext context) async {
    await showExitDialogBackButton(
      context: context,
      leftButtonOnPressed: () {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        FocusScope.of(context).unfocus();
        await addEditCurrency();
      },
    );
  }
}
