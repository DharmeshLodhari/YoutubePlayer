import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/country_picker/country.dart';
import 'package:Slydo/models/country_picker/country_picker_dialog.dart';
import 'package:Slydo/models/country_picker/utils.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
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
    setState(() {
      isLoading = true;
    });
    _auth.fetchUserAddress().then((value) {
      setState(() {
        addressBloc.address = value;
        isLoading = false;

        addressLineOneController.text = addressBloc.address.addressLineOne;
        addressLineTwoController.text = addressBloc.address.addressLineTwo;
        cityController.text = addressBloc.address.city;
        stateController.text = addressBloc.address.state;
        selectedCountry = CountryPickerUtils.getCountryByIsoCode(
            addressBloc.address.countryIsoCode);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addressBloc = Provider.of<AddressBloc>(context);
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text(AppLocalization.of(context).addAddress),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 20),
                    getAddressLineOne(),
                    SizedBox(height: 10),
                    getAddressLineTwo(),
                    SizedBox(height: 10),
                    getCity(),
                    SizedBox(height: 10),
                    getState(),
                    SizedBox(height: 10),
                    getCountryDropdown(),
                    SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 10),
                    getSubmitButton(userBloc.user.userName),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAddressLineOne() {
    return TextFormField(
      controller: addressLineOneController,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.home),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).addressLine1,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    );
  }

  Widget getAddressLineTwo() {
    return TextFormField(
      controller: addressLineTwoController,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.home),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).addressLine2,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidAddress : null,
    );
  }

  Widget getCity() {
    return TextFormField(
      controller: cityController,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_city),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).city,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidCity : null,
    );
  }

  Widget getState() {
    return TextFormField(
      controller: stateController,
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.flag),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).state,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
      validator: (val) =>
          val.length == 0 ? AppLocalization.of(context).invalidState : null,
    );
  }

  getCountryDropdown() {
    return Card(
      margin: EdgeInsets.all(0),
      borderOnForeground: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
            child: Text(
              AppLocalization.of(context).selectYourCountry,
              style: TextStyle(color: darkBlue()),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            onTap: _openCountryPickerDialog,
            title: _buildDialogItem(selectedCountry),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text("+${country.phoneCode}"),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name))
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

  Widget getSubmitButton(String userName) {
    return ButtonTheme(
      //color: Colors.green,
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
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
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(AppLocalization.of(context).submitButton),
      ),
    );
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
