import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';

class AddEditCurrency extends StatefulWidget {
  AddEditCurrency({super.key, this.arguments});

  dynamic arguments;

  @override
  State<AddEditCurrency> createState() => _AddEditCurrencyState();
}

class _AddEditCurrencyState extends State<AddEditCurrency> {
  final _formKey = GlobalKey<FormState>();
  bool slydoRate = false;
  bool isEdit = false;
  bool isDeleteLoading = false;
  bool isAPILoading = false;
  String? selectedCurrency;

  List<String> currencyList = [
    "MVR (Rf)",
    "MWK (MK)",
    "MXN (Mex\$)",
    "MYR (RM)",
    "MZN (MT)",
    "NAD (N\$)",
    "NGN (₦)",
    "NIO (C\$)",
    "NOK (Nkr)",
    "NPR (₨)",
    "NZD (NZ\$)",
    "TRY (TL)",
    "TTD (TT\$)",
    "TVD (\$T)",
    "TWD (NT\$)",
    "UAH (₴)",
    "UGX (USh)",
    "UYU (\$U)",
    "VEF (Bs)",
    "VND (₫)",
    "VUV (VT)",
    "WST (WS\$)",
    "XAF (FCFA)",
    "XCD (EC\$)",
    "XDR (SDR)",
    "XOF (CFA)",
    "ZAR (R)",
    "ZMK (ZK)",
    "ZWL (Z\$)",
    "ZWD (Z\$)",
    "USD (\$)"
  ];

  @override
  void initState() {
    if (widget.arguments != null) {
      isEdit = widget.arguments['isEdit'];
    }
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
          }),
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
                    const SizedBox(height: 10),
                    slydoRateSwitch(),
                  ],
                ),
              ),
            ),
          ),
          getSubmitButton(),
          const SizedBox(height: 20),
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
          selectCurrency();
        },
      ),
    );
  }

  void selectCurrency() async {
    final pressedCurrency = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                        children: currencyList.map<Widget>((currency) {
                          if (selectedCurrency == currency.toString()) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  currency.toString(),
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
                                  Navigator.pop(context, currency);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              currency.toString(),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, currency);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCurrency != null) {
      selectedCurrency = pressedCurrency;
      setState(() {});
    }
  }

  Widget exchangeRateField() {
    return CustomizedTextFormField(
      labelText: "Exchange Rate (₦)",
      // initialValue: messageDecoderWithEmoji(flashTagAlertModel.title ?? ""),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        // flashTagAlertModel.title = val;
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
              value: slydoRate,
              onChanged: (value) {
                slydoRate = value;
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
                      // deleteFlashTagDialog();
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

                      // await addEditItem();

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

              // await addEditItem();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  dynamic getExitDialog(BuildContext context) async {
    await showExitDialogBackButton(
      context: context,
      leftButtonOnPressed: () {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        FocusScope.of(context).unfocus();
        // await addEditItem();
      },
    );
  }
}
