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

import '../../../../../routes/route_constants.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../shopping_auth.dart';


class NewAddOn extends StatefulWidget {
  var arguments;

  NewAddOn({this.arguments, Key? key}) : super(key: key);

  @override
  _NewAddOnState createState() => _NewAddOnState();
}

class _NewAddOnState extends State<NewAddOn> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> productImages = [];
  List<String> croppedImageList = [];
  String size = "";
  String variantPrice = "";
  String comparePrice = "";
  String color = "";
  bool IsRequired = false;
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
                getIsAvailableField(),

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
                addOns(),

                const SizedBox(height: 30),
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

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        IsRequired = !IsRequired;
        setState(() {});
      },
      isChecked: IsRequired,
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

  Widget addOns(){
    return GestureDetector(
      onTap: () async {
        //disable click if variant is not empty
        final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_ADD_ON_OPTION_CREATE, arguments: {
          'productId': widget.arguments['productId'],
        });

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is List<Variant>) {
          //save the add-on details for later use
          // productVariantList = result;
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

        // await addVariant();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  Future<void> addVariant() async {
    if (_formKey.currentState!.validate()) {
      if (croppedImageList.length >= 1) {
        // if (productImages.length >= 1) {
        if (validateDropdown()) {
          Variant variant = Variant();
          // variant.localImages = productImages.map((file) => File(file.path)).toList();
          variant.localImages = croppedImageList.map((filePath) => File(filePath)).toList();
          variant.title = name;
          variant.colour = color;
          variant.value = value;
          variant.quantity = inventoryCount.toString();
          variant.type = selectedType;
          variant.price = moneyInputNormalizer(variantPrice).toString();
          variant.isAvailable = IsRequired;
          variant.availableFrom = productAvailableFrom;
          variant.trackInventory = trackInventory;
          variant.currency = 'NGN';
          if(optionOnWhatToDo == 'new'){
            //send the variant detail back to the previous page
            debugPrint('file path::: ${variant.localImages}');

            Navigator.pop(context, variant);
          }else if(optionOnWhatToDo == 'edit'){
            String productId = widget.arguments["productId"];
            //make api call to save the variant details
            saveVariant(productId, variant);
          }

        }
      } else {
        isAPILoading = false;
        if (mounted) setState(() {});
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }

    }

  }

  Future<void> saveVariant(String productId, Variant item) async {
    await _auth.addVariant(item, productId).then((value) {
      Navigator.pop(context, item);
      return true;

    }).catchError((error) {
      debugPrint(error.toString());
      isAPILoading = false;
      if (mounted) setState(() {});
      showToast(message: error.toString());
      // backValue = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
