import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/country_picker/country.dart';
import 'package:Slydo/models/country_picker/country_picker_dialog.dart';
import 'package:Slydo/models/country_picker/utils.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../locale/app_localization.dart';

class UserAddress extends StatefulWidget {
  @override
  _UserAddressState createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  TextEditingController addressLineOneController = TextEditingController();
  TextEditingController addressLineTwoController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  Country selectedCountry = CountryPickerUtils.getCountryByIsoCode('NG');

  AddressBloc addressBloc;
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    if (mounted) setState(() {});

    _auth.fetchUserAddress().then((value) {
      addressBloc.address = value;
      isLoading = false;

      addressLineOneController.text = addressBloc.address.addressLineOne;
      addressLineTwoController.text = addressBloc.address.addressLineTwo;
      cityController.text = addressBloc.address.city;
      stateController.text = addressBloc.address.state;
      selectedCountry = CountryPickerUtils.getCountryByIsoCode(
          addressBloc.address.countryIsoCode);
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addressBloc = Provider.of<AddressBloc>(context);

    // return WillPopScope(
    //   onWillPop: () async {
    //     return true;
    //   },
    //   child: Scaffold(
    //     backgroundColor: lightBlue(),
    //     resizeToAvoidBottomInset: true,
    //     appBar: AppBar(
    //       backgroundColor: darkBlue(),
    //       title: Text(AppLocalization.of(context).addAddress),
    //       elevation: 0.0,
    //     ),
    //     body: scaffoldBody(),
    //   ),
    // );
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context).addAddress,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    flexibleSpace(),
                    getAddressLineOne(),
                    flexibleSpace(),
                    getAddressLineTwo(),
                    flexibleSpace(),
                    getCity(),
                    flexibleSpace(),
                    getState(),
                    flexibleSpace(),
                    getCountryDropdown(),
                    flexibleSpace(),
                    Text(
                      errorMessage,
                      style: TextStyle(color: mateRad, fontSize: 14),
                    ),
                    flexibleSpace(),
                    getSubmitButton(),
                    flexibleSpace(),
                  ],
                ),
              ),
            ),
            flexibleSpace(flex: 2)
          ],
        ),
      ),
    );
  }

  Widget getAddressLineOne() {
    // return TextFormField(
    //   controller: addressLineOneController,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.text,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.home),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).addressLine1,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) =>
    //       val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    // );

    return CustomizedTextFormField(
      labelText: "Address line 1",
      controller: addressLineOneController,
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    );
  }

  Widget getAddressLineTwo() {
    // return TextFormField(
    //   controller: addressLineTwoController,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.text,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.home),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).addressLine2,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) =>
    //       val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    // );
    return CustomizedTextFormField(
      labelText: "Address line 2",
      controller: addressLineTwoController,
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    );
  }

  Widget getCity() {
    // return TextFormField(
    //   controller: cityController,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.text,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.location_city),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).city,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) =>
    //       val.length == 0 ? AppLocalization.of(context).invalidCity : null,
    // );

    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).city,
      controller: cityController,
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidCity : null,
    );
  }

  Widget getState() {
    // return TextFormField(
    //   controller: stateController,
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.text,
    //   decoration: InputDecoration(
    //       prefixIcon: Icon(Icons.flag),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).state,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.green, style: BorderStyle.solid))),
    //   validator: (val) =>
    //       val.length == 0 ? AppLocalization.of(context).invalidState : null,
    // );

    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).state,
      controller: stateController,
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidState : null,
    );
  }

  Widget getCountryDropdown() {
    // return Card(
    //   margin: EdgeInsets.all(0),
    //   borderOnForeground: true,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
    //         child: Text(
    //           AppLocalization.of(context).selectYourCountry,
    //           style: TextStyle(color: darkBlue()),
    //         ),
    //       ),
    //       ListTile(
    //         contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
    //         onTap: _openCountryPickerDialog,
    //         title: _buildDialogItem(selectedCountry),
    //       ),
    //     ],
    //   ),
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context).selectYourCountry,
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
            onTap: _openCountryPickerDialog,
            title: _buildDialogItem(selectedCountry),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text(
          "+${country.phoneCode}",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ),
        SizedBox(width: 8.0),
        Flexible(
            child: Text(
          country.name,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: blackFont),
        ))
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration:
                InputDecoration(hintText: AppLocalization.of(context).search),
            isSearchable: true,
            title: Text(AppLocalization.of(context).selectYourPhoneCode),
            onValuePicked: (Country country) =>
                setState(() => selectedCountry = country),
            itemBuilder: _buildDialogItem,
          ),
        ),
      );

  Widget getSubmitButton() {
    // return ButtonTheme(
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //     onPressed: onSubmit,
    //     textColor: Colors.white,
    //     color: darkBlue(),
    //     height: 50,
    //     child: Text(AppLocalization.of(context).submitButton),
    //   ),
    // );

    return CurvedButton(
      onPressed: onSubmit,
      text: AppLocalization.of(context).submitButton,
      textColor: Colors.white,
      backgroundColor: navyBlue,
    );
  }

  void onSubmit() async {
    if (_formKey.currentState.validate()) {
      Map data = {
        "address_line_1": addressLineOneController.text,
        "address_line_2": addressLineTwoController.text,
        "city": cityController.text,
        "state": stateController.text,
        "country": selectedCountry.name,
        "coutry_iso_name": selectedCountry.isoCode,
      };
      _auth.addUserAddress(data).then((value) {
        Toast.show(
          AppLocalization.of(context).addressAddedSuccessFully + " !!!",
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG,
        );
        Navigator.pop(context);
      });
    } else {
      setState(() {
        errorMessage = AppLocalization.of(context).errorMsg1;
      });
    }
  }

  @override
  void dispose() {
    addressLineOneController.dispose();
    addressLineTwoController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }
}
