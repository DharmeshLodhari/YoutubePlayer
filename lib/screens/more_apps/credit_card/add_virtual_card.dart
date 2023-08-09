import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/currency.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../shopping/shopping_auth.dart';

class AddVirtualCard extends StatefulWidget {
  const AddVirtualCard({Key? key}) : super(key: key);

  @override
  _AddVirtualCardState createState() => _AddVirtualCardState();
}

class _AddVirtualCardState extends State<AddVirtualCard> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  ProductCategory? pressedCategory;
  ProductCategory? selectedProductCategory;
  ProductCondition? selectedProductCondition;

  final ScrollController _scrollController = ScrollController();
  String firstName = "";
  String lastName = "";
  String address = "";
  String city = "";
  String state = "";
  String zipCode = "";
  String bvn = "";
  String idType = "";
  String idNumber = "";
  List<ProductCategory>? productCategories;
  List<ProductCategory>? productCategoriesCopy;
  bool isLoading = false;
  bool isAPILoading = false;
  List<String> stateList = [];
  List<String> idTypeList = ['NATIONAL ID','PASSPORT', 'VOTERS CARD', 'DRIVERS LICENSE'];
  List<String> stateListCopy = [];
  Map<String, bool> stateCheckMark = {};
  String selectedIdType = "";


  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    getStatesList();
    super.initState();
  }

  void getStatesList() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      stateList = getAllStates();
      stateListCopy = stateList;

      stateListCopy.forEach((element) {
        stateCheckMark[element] = false;
      });
    } catch (e) {
      stateList = [];
      stateListCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
      centerTitle: false,
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
        "Debit Card",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
      child: CircularLoadingIndicator(),
    )
    : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fill out your personal information",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  "1/2",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            ),
            const SizedBox(height: 15),

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
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        addFirstNameField(),
                        const SizedBox(
                          height: 10,
                        ),
                        addLastNameField(),

                        const SizedBox(height: 10),
                        addAddressField(),
                        const SizedBox(
                          height: 10,
                        ),
                        addCityField(),
                        const SizedBox(height: 10),
                        getStateField(),
                        const SizedBox(height: 10),
                        getZipCodeField(),
                        const SizedBox(height: 10),
                        getBvnField(),
                        const SizedBox(height: 10),
                        getIdTypeField(),
                        const SizedBox(height: 10),
                        getIdNumberField(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
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
            ),
          ],
        ),
      ),
    );

  }


  Widget addFirstNameField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.firstName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterFirstName;
      },
      onChanged: (val) {
        firstName = val;
      },
    );
  }

  Widget addLastNameField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.lastName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterLastName;
      },
      onChanged: (val) {
        lastName = val;
      },
    );
  }

  Widget addAddressField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.address,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterAddress;
      },
      onChanged: (val) {
        address = val;
      },
    );
  }

  Widget addCityField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.city,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterCity;
      },
      onChanged: (val) {
        city = val;
      },
    );
  }

  Widget getZipCodeField() {
    return CustomizedTextFormField(
      labelText: "Zip Code",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterZipCode;
      },
      onChanged: (val) {
        zipCode = val;
      },
    );
  }

  Widget getBvnField() {
    return CustomizedTextFormField(
      labelText: "BVN",
        inputFormatters: [
          LengthLimitingTextInputFormatter(11),
        ],
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterBvn;
      },
      onChanged: (val) {
        bvn = val;
      },
    );
  }

  Widget getIdNumberField() {
    return CustomizedTextFormField(
      labelText: "ID Number",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterIdNumber;
      },
      onChanged: (val) {
        idNumber = val;
      },
    );
  }


  Widget getStateField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.state,
      child: ListTile(
        dense: true,
        title: Text(
          state.isNotEmpty ? state : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          stateAndroidSheet();
        },
      ),
    );
  }

  Widget getIdTypeField() {
    return CustomizedDropDownField(
      title: "ID Type",
      child: ListTile(
        dense: true,
        title: Text(
          idType.isNotEmpty ? idType : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          idTypeAndroidSheet();
        },
      ),
    );
  }

  void stateAndroidSheet() {
    stateList = stateListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search State',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      stateList = stateListCopy.where((element) => element
                          .toLowerCase()
                          .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(() {});
                    } else {
                      stateList = stateListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: stateList.length,
                    itemBuilder: (context, index) {
                      String category = stateList[index];

                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          state = category;
                          Navigator.pop(context);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void idTypeAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: idTypeList.length,
                    itemBuilder: (context, index) {
                      String category = idTypeList[index];

                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          idType = category;
                          ['NATIONAL ID','PASSPORT', 'VOTERS CARD', 'DRIVERS LICENSE'];
                          if(category == 'NATIONAL ID'){
                            selectedIdType = "NATIONAL_ID";
                          }else if(category == 'PASSPORT'){
                            selectedIdType = "PASSPORT";
                          }else if(category == 'VOTERS CARD'){
                            selectedIdType = "VOTERSCARD";
                          }else if(category == 'DRIVERS LICENSE'){
                            selectedIdType = "DRIVERS_LICENSE";
                          }

                          Navigator.pop(context);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        gotoGenerateVirtualCard();

      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Proceed",
      isLoading: isAPILoading,
    );
  }

  Future<void> gotoGenerateVirtualCard() async {
    if (_formKey.currentState!.validate()) {

        if (validateDropdown()) {

          Map<String, dynamic> result = {
            "first_name": firstName,
            "last_name": lastName,
            "address1": address,
            "address2": address,
            "city": city,
            "state": state,
            "zipcode": zipCode,
            "id_number": idNumber,
            "id_type": selectedIdType,
            "customer_bvn": bvn,
          };


          final data = await Navigator.of(context).pushNamed(Routes.GENERATE_VIRTUAL_CARD, arguments: {
            'data': result,
          });

          // Handle the result (map) received from GENERATE_VIRTUAL_CARD
          if (data != null && data == true) {
            //send callback
            Navigator.pop(context, data);
            if(mounted)setState(() {});
          }
        }

    }
  }

  bool validateDropdown() {
    if (state.isNotEmpty && idType.isNotEmpty) {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectStateOrIdTYpe);
      return false;
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
