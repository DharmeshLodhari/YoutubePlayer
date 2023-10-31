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
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../data/currency.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../shopping_auth.dart';


class CreateAddOn extends StatefulWidget {
  var arguments;

  CreateAddOn({this.arguments, Key? key}) : super(key: key);

  @override
  _CreateAddOnState createState() => _CreateAddOnState();
}

class _CreateAddOnState extends State<CreateAddOn> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  final ScrollController _scrollController = ScrollController();
  String size = "";
  String variantPrice = "";
  String comparePrice = "";
  String color = "";
  bool isRequired = false;
  bool inventoryIsAvailable = false;
  bool trackInventory = false;
  DateTime productAvailableFrom = DateTime.now();
  bool isLoading = false;
  bool isAPILoading = false;
  int inventoryCount = 0;
  var typeList = ['Single', 'Multiple'];
  String selectedType = "";
  String name = "";
  String description = "";
  String value = "";
  String optionOnWhatToDo = "";
  TextEditingController? groupDescriptionController;
  List<AddOnOption> productAddOnOptionList = [];
  ScrollController scrollControllerAddOnOption = ScrollController();
  AddOns addOns = AddOns();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    //get value if its form edit or add product
    optionOnWhatToDo = widget.arguments["option"];
    super.initState();
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
        AppLocalization.of(context)!.newAddOns,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
      child: CircularLoadingIndicator(),
    )
        : SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                const SizedBox(height: 10),
                addNameField(),
                const SizedBox(height: 10),
                getDescription(),
                const SizedBox(height: 10),
                getTypeField(),

                const SizedBox(height: 20),
                getIsRequiredField(),

                const SizedBox(height: 10),
                Text(
                  'Check this box to make this add-ons compulsory',
                  maxLines: 1,
                  style: TextStyle(
                      color: black,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),

                const SizedBox(height: 30),

                if(productAddOnOptionList == null || productAddOnOptionList.isEmpty)...[
                  getAddOns(),
                ]else...[
                  displaySelectedAddOnOption(),
                ],


                const SizedBox(height: 20),
                getSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getDescription() {
    return Container(
      child: CustomizedTextFormField(
        maxLines: 3,
        labelText: "Description",
        textCapitalization: TextCapitalization.sentences,
        // controller: groupDescriptionController,
        validator: (val) {
          if (val.isNotEmpty) {
            return null;
          }
          return AppLocalization.of(context)!.descriptionMustNotEmpty;
        },
        onChanged: (val) {
          description = val;
        },
      ),
    );
  }

  Widget addNameField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.name,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterTitle;
      },
      onChanged: (val) {
        name = val;
      },
    );
  }


  bool validateDropdown() {
    if (selectedType != null && selectedType != '') {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectCategory);
      return false;
    }
  }

  Widget getIsRequiredField() {
    return CustomizedCheckBoxField(
      onTap: () {
        isRequired = !isRequired;
        setState(() {});
      },
      isChecked: isRequired,
      title: "Required",
    );
  }

  Widget getTypeField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.selectType,
      child: ListTile(
        dense: true,
        title: Text(
          selectedType != null ? selectedType : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                Text(
                  'Select Category',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: typeList.length,
                    itemBuilder: (context, index) {
                      var category = typeList[index];
                      if (selectedType == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category,
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
                              selectedType = category;
                              Navigator.pop(context);
                              setState(() {});

                            },
                          ),
                        );
                      }
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
                          selectedType = category;
                          Navigator.pop(context);
                          setState(() {});
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

  Widget getAddOns(){
    return GestureDetector(
      onTap: () async {
        //disable click if add-on option is not empty
        final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_ADD_ON_OPTION_CREATE, arguments: {
          'productId': widget.arguments['productId'],
        });
        // final result = await Navigator.of(context).pushNamed(Routes.ADD_ON_OPTION_LIST, arguments: {
        //   'productId': widget.arguments['productId'],
        // });

        // Handle the result (map) received from Product Add-on Option
        if (result != null && result is AddOnOption) {
          //save the add-on option details for later use
          productAddOnOptionList.add(result);
          if(mounted)setState(() {});
        }
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Options',
              maxLines: 1,
              style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            Icon(
              SlydoAppIcon.add,
              size: 16,
              color: blackFont,
            ),

          ],
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
        FocusScope.of(context).unfocus();
        isAPILoading = true;
        if (mounted) setState(() {});

        await addNewAddOns();

        isAPILoading = false;
        if (mounted) setState(() {});

      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  Future<void> addNewAddOns() async {
    if (_formKey.currentState!.validate()) {
        if (validateDropdown()) {

          addOns.name = name;
          addOns.description = description;
          addOns.isRequired = isRequired;
          addOns.selectType = selectedType;
          addOns.options = productAddOnOptionList;

          await _auth.createAddOn(addOns,
              widget.arguments["productId"]).then((value) async {

            Navigator.pop(context, value);

          }).catchError((error) {
            debugPrint("ERROR While createAddOnOption :- $error");
            isAPILoading = false;
            if (mounted) setState(() {});
            showToast(message: "$error");
          });

        }

    }

  }

  Widget displaySelectedAddOnOption(){

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Options',
              maxLines: 1,
              style: TextStyle(
                  color: blackFont.withOpacity(.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                //disable click if add-on option is not empty
                final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_ADD_ON_OPTION_CREATE, arguments: {
                  'productId': widget.arguments['productId'],
                });

                // Handle the result (map) received from Product Add-on Option
                if (result != null && result is AddOnOption) {
                  //save the add-on option details for later use
                  productAddOnOptionList.add(result);
                  if(mounted)setState(() {});
                }
              },
              child: Icon(
                SlydoAppIcon.add,
                size: 16,
                color: blackFont,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        _buildAddOnOptionList(),
        SizedBox(height: 5.0),
        GestureDetector(
          onTap: () async {
            //disable click if add-on option is not empty
            final result = await Navigator.of(context).pushNamed(Routes.ADD_ON_OPTION_LIST, arguments: {
              'productId': widget.arguments['productId'],
            });

            // Handle the result (map) received from Product Add-on Option
            if (result != null && result is AddOnOption) {
              //save the add-on option details for later use
              productAddOnOptionList.add(result);
              if(mounted)setState(() {});
            }
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'See all',
              maxLines: 1,
              style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildAddOnOptionList() {

    return Container(
      height: 80 * productAddOnOptionList.length.toDouble(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        //+1 for progressbar
        itemCount: productAddOnOptionList.length + 1,
        controller: scrollControllerAddOnOption,
        itemBuilder: (BuildContext context, int index) {
          if (index == productAddOnOptionList.length) {
            return buildLoadingIndicator(isLoading: isLoading);
          } else {
            return addOnOptionTile(
              addOnOption: productAddOnOptionList[index],
            );
          }
        },

      ),
    );
  }

  Widget addOnOptionTile({required AddOnOption addOnOption}) {

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense:  true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("",
                maxLines: 1,
                style: TextStyle(
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
              Text(
                appendStringDot(addOnOption.name!, 10),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              Text(
                'Created: ${addOnOption.createdAt.toString()}',
                maxLines: 1,
                style: TextStyle(
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
              Text("",
                maxLines: 1,
                style: TextStyle(
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),

            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                worldCurrencies[addOnOption.currency!]!,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 18.0,
                    color: blackFont,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                moneyDisplayNormalizer(
                    int.parse(addOnOption.price.toString())),
                style: TextStyle(
                    fontSize: 18.0,
                    color: blackFont,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          leading: GestureDetector(
            onTap: () {
              String? url = addOnOption.picture;
              Navigator.of(context)
                  .pushNamed("/photo-viewer", arguments: url);
            },
            child: checkProductImage(addOnOption),
          ),
        ),
      ),
    );
  }

  Widget checkProductImage(AddOnOption addOnOption) {
    // Retrieve the first image from the 'pictures' list
    String? url = "";

    url = addOnOption.picture;

    String imageUrl = url!.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(addOnOption.name!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return SizedBox(
        height: 100,
        child: CustomBoxShadow(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: boxShadowTwo,
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(
                      imageUrl,
                    ),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );

    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
