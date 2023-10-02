import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/product/product_variant_list.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../shopping_auth.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  ProductCategory? pressedCategory;
  ProductCategory? selectedProductCategory;
  ProductCondition? selectedProductCondition;

  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> productImages = [];
  String productName = "";
  String productDescription = "";
  String productShortDescription = "";
  String productCategory = "";
  String productCondition = "";
  String productPrice = "";
  String productManufacturer = "";
  bool productIsAvailable = false;
  bool inventoryIsAvailable = false;
  bool productEnableInSuperStore = false;
  DateTime productAvailableFrom = DateTime.now();
  List<ProductCategory>? productCategories;
  List<ProductCategory>?
      productCategoriesCopy; //To hold the full product category at all times.
  bool isLoading = false;
  bool isAPILoading = false;
  int inventoryCount = 0;
  List<Variant> productVariantList = [];
  var weightSi = ['Grams', 'Kilograms'];
  var widthSi = ['Centimetres', 'Metres'];
  var heightSi = ['Centimetres', 'Metres'];
  double weight = 0.0;
  double width = 0.0;
  double height = 0.0;
  String selectedWeight = "";
  String selectedHeight = "";
  String selectedWidth = "";
  bool trackInventory = false;


  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    getCategories();

    selectedWeight = 'Grams';
    selectedHeight = 'Centimetres';
    selectedWidth = 'Centimetres';

    if(mounted)setState(() {});

    super.initState();
  }

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      productCategories = await ShoppingAuthService().getProductCategories();
      productCategoriesCopy = productCategories;
    } catch (e) {
      productCategories = [];
      productCategoriesCopy = [];
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
        "Add product",
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
                      addImages(),
                      const SizedBox(height: 10),
                      addTitleField(),
                      const SizedBox(
                        height: 10,
                      ),
                      getManufacturerField(),
                      const SizedBox(
                        height: 10,
                      ),
                      getAmountField(),
                      const SizedBox(height: 10),
                      getCategoryField(),
                      const SizedBox(height: 10),
                      getProductConditionField(),
                      const SizedBox(height: 16),
                      getAvailableFromField(),
                      const SizedBox(height: 10),
                      getProductShortDescription(),
                      const SizedBox(height: 10),
                      getProductDescription(),

                      const SizedBox(height: 20),
                      //weight section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: getWeightField(),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            flex: 1,
                            child: getWeightSiUnitField(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      //height section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: getHeightField(),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            flex: 1,
                            child: getHeightSiUnitField(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      //width section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: getWidthField(),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            flex: 1,
                            child: getWidthSiUnitField(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      getInventoryFormField(),
                      const SizedBox(height: 40),

                      getIsAvailableField(),
                      const SizedBox(height: 16),
                      getTrackInventoryField(),

                      const SizedBox(height: 16),
                      getEnableInSuperStoreField(),

                      //TODO: hide this variant option
                      // const SizedBox(height: 16),
                      // if(productVariantList.isEmpty)...[
                      //   getAddVariationFormField(),
                      // ]else...[
                      //   displaySelectedVariant(),
                      // ],

                      const SizedBox(height: 16),
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

  Widget addImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != productImages.length
              ? showImage(index)
              : productImages.length != imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
  }

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  SlydoAppIcon.add_image,
                  color: darkGrey,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
              ],
            ),
            onTap: () {
              pickImage();
            },
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalization.of(context)!.selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.gallery),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().pickImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          productImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(productImages[index].path),
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: const EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: iconBtnGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  SlydoAppIcon.remove,
                  color: blackFont,
                  size: 15,
                ),
              ),
              onPressed: () {
                setState(() {
                  productImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.productName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterProductName;
      },
      onChanged: (val) {
        productName = val;
      },
    );
  }

  Widget getProductShortDescription() {
    return CustomizedTextFormField(
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onChanged: (val) {
        productShortDescription = val;
      },
    );
  }

  Widget getProductDescription() {
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context)!.description,
      onChanged: (val) {
        productDescription = val;
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.category,
      child: ListTile(
        dense: true,
        title: Text(
          selectedProductCategory != null ? selectedProductCategory!.name : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    productCategories = productCategoriesCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      productCategories = productCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      productCategories = productCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: productCategories!.length,
                    itemBuilder: (context, index) {
                      ProductCategory category = productCategories![index];
                      if (selectedProductCategory == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category.name,
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
                              pressedCategory = category;
                              Navigator.pop(context);
                              if (pressedCategory != null) {
                                selectedProductCategory = pressedCategory;
                                productCategory = selectedProductCategory!.name;
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedCategory = category;
                          Navigator.pop(context);
                          if (pressedCategory != null) {
                            selectedProductCategory = pressedCategory;
                            productCategory = selectedProductCategory!.name;
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

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ProductCategory>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        children: productCategories?.map<Widget>((category) {
                              if (selectedProductCategory == category) {
                                return Container(
                                  color: selectedListItemBackgroundBlue,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      category.name,
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
                                      Navigator.pop(context, category);
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  category.name,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                dense: true,
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedProductCategory = pressedCategory;
      productCategory = selectedProductCategory!.name;
      setState(() {});
    }
  }

  Widget getProductConditionField() {
    return CustomizedDropDownField(
      title: "Product condition",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              selectedProductCondition != null
                  ? selectedProductCondition!.name
                  : "",
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: Text(
                selectedProductCondition != null
                    ? " (" + selectedProductCondition!.description + ")"
                    : "",
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                ),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectItemCondition();
        },
      ),
    );
  }

  void selectItemCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: conditions.map<Widget>((condition) {
                          if (selectedProductCondition == condition) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      condition.name,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProductCondition != null
                                            ? " (" +
                                                selectedProductCondition!
                                                    .description +
                                                ")"
                                            : "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 16, color: navyBlue),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, condition);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  condition.name,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                Expanded(
                                  child: Text(
                                    " (" + condition.description + ")",
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16, color: blackFont),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, condition);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      selectedProductCondition = pressedCondition;
      productCondition = selectedProductCondition!.name;
      setState(() {});
    }
  }

  Widget getManufacturerField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.manufacturer,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterManufacturerName;
      },
      onChanged: (val) {
        productManufacturer = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.price,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            productPrice = double.parse(val.replaceAll(',', '')).toString();
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
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
    );
  }

  Widget getWeightSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedWeight.isNotEmpty ? selectedWeight : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          weightSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getWeightField() {
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.weight,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        // isAmountField: true,

        onChanged: (val) {
          if (val.isNotEmpty) {
            try {
              weight = double.parse(val);
            } catch (e) {
              showToast(message: e.toString());
            }
          }
        },
        validator: (val) {
          if (val.isNotEmpty) {
            try {
              double.parse(val);
              return null;
            } catch (e) {
              return AppLocalization.of(context)!.invalidWeight;
            }
          }
          return AppLocalization.of(context)!.pleaseEnterValidWeight;
        },
      ),
    );
  }

  Widget getHeightSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedHeight.isNotEmpty ? selectedHeight : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          heightSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getHeightField() {
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.height,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        // isAmountField: true,

        onChanged: (val) {
          if (val.isNotEmpty) {
            try {
              height = double.parse(val);
            } catch (e) {
              showToast(message: e.toString());
            }
          }
        },
        validator: (val) {
          if (val.isNotEmpty) {
            try {
              double.parse(val);
              return null;
            } catch (e) {
              return AppLocalization.of(context)!.invalidHeight;
            }
          }
          return AppLocalization.of(context)!.pleaseEnterValidHeight;
        },
      ),
    );
  }

  Widget getWidthSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedWidth.isNotEmpty ? selectedWidth : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          widthSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getWidthField() {
    return Container(
      padding: EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.width,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,

        onChanged: (val) {
          if (val.isNotEmpty) {
            try {
              width = double.parse(val);
            } catch (e) {
              showToast(message: e.toString());
            }
          }
        },
        validator: (val) {
          if (val.isNotEmpty) {
            try {
              double.parse(val);
              return null;
            } catch (e) {
              return AppLocalization.of(context)!.invalidWidth;
            }
          }
          return AppLocalization.of(context)!.pleaseEnterValidWidth;
        },
      ),
    );
  }

  void weightSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Weight SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: weightSi.length,
                    itemBuilder: (context, index) {
                      var category = weightSi[index];
                      if (selectedWeight == category) {
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
                              selectedWeight = category;
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
                          selectedWeight = category;
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

  void heightSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Height SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: heightSi.length,
                    itemBuilder: (context, index) {
                      var height = heightSi[index];
                      if (selectedHeight == height) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              height,
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
                              selectedHeight = height;
                              Navigator.pop(context);
                              setState(() {});

                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          height,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          selectedHeight = height;
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

  void widthSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Width SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widthSi.length,
                    itemBuilder: (context, index) {
                      var category = widthSi[index];
                      if (selectedWidth == category) {
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
                              selectedWidth = category;
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
                          selectedWidth = category;
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

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addProduct();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add product",
      isLoading: isAPILoading,
    );
  }

  Future<void> addProduct() async {
    if (_formKey.currentState!.validate()) {
      if (productImages.length >= 1) {
        if (validateDropdown() && validateDropdownHeightWidthWeight()) {

          Product product = Product();
          product.localImages =
              productImages.map((file) => File(file.path)).toList();
          product.name = productName;
          product.description = messageDecoderWithEmoji(productDescription);
          product.shortDescription = messageDecoderWithEmoji(productShortDescription);
          product.category = productCategory;
          product.condition = productCondition;
          product.price = moneyInputNormalizer(productPrice).toString();
          product.isAvailable = productIsAvailable;
          product.manufacturer = productManufacturer;
          product.availableFrom = productAvailableFrom;
          product.enableInSuperStore = productEnableInSuperStore;

          product.weight = weight;
          product.weightSiUnit = selectedWeight == 'Grams' ? 'g' : 'kg';
          product.height = height;
          product.heightSiUnit = selectedHeight == 'Centimetres' ? 'cm' : 'm';
          product.width = width;
          product.widthSiUnit = selectedWidth == 'Centimetres' ? 'cm' : 'm';
          product.trackInventory = trackInventory;
          product.quantity = inventoryCount;
          // product.variant = [];

          //the api call will first create the product then use the id from the
          //response to save the variant
          await _auth.addProduct(product, '').then((value) async {

            var productId = value[1];

            if(productVariantList.isEmpty){
              Navigator.pop(context);
              showToast(
                  message: AppLocalization.of(context)!.productAddedSuccessfully);

              Navigator.pushNamed(context, Routes.PRODUCT,
                  arguments: {"productId": productId});
            }else{
              //loop and add all variant
              addVariants(productId);
              // for(var variantItem in productVariantList){
              //   await _auth.addVariant(variantItem, productId).then((value) {
              //     // backValue = true;
              //
              //   }).catchError((error) {
              //     debugPrint(error.toString());
              //     debugPrint("Product check variant::: ${error.toString()}");
              //     // showToast(message: error.toString());
              //   });
              // }
            }

          }).catchError((error) {
            debugPrint("Product check::: ${error.toString()}");
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  Future<void> addVariants(String productId) async {
    for (var variantItem in productVariantList) {
      // Make the API call for the current product variant
      await makeApiCallAddVariant(variantItem, productId);
    }

    // This will be executed after all API calls are completed
    print("All API calls are done!");
    Navigator.pop(context);
    showToast(
        message: AppLocalization.of(context)!.productAddedSuccessfully);

    Navigator.pushNamed(context, Routes.PRODUCT,
        arguments: {"productId": productId});
  }

  Future<void> makeApiCallAddVariant(Variant variantItem, String productId) async {

      await _auth.addVariant(variantItem, productId).then((value) {
        // backValue = true;

      }).catchError((error) {
        debugPrint(error.toString());
        debugPrint("Product check variant::: ${error.toString()}");
        // showToast(message: error.toString());
      });

  }

  bool validateDropdown() {
    if (selectedProductCategory != null && selectedProductCondition != null) {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectProductCategoryAndCondition);
      return false;
    }
  }

  bool validateDropdownHeightWidthWeight() {
    if (selectedWeight.isNotEmpty && selectedHeight.isNotEmpty && selectedWidth.isNotEmpty) {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectWeightHeightWidth);
      return false;
    }
  }

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable;
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Is product available now?",
    );
  }

  Widget getTrackInventoryField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventory = !trackInventory;
        setState(() {});
      },
      isChecked: trackInventory,
      title: "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 12.0,
      maxLines: 2,
    );
  }

  Widget getEnableInSuperStoreField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productEnableInSuperStore = !productEnableInSuperStore;
        setState(() {});
      },
      isChecked: productEnableInSuperStore,
      title: AppLocalization.of(context)!.enableInSuperStore,
    );
  }

  Widget getAvailableFromField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          productAvailableFrom = DateTime(value!.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(productAvailableFrom),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              SlydoAppIcon.date,
              size: 16,
              color: darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget getInventoryFormField() {
    return CustomizedTextFormField(
      labelText: "Inventory (Available Quantity)",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: false)
          : TextInputType.number,

      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            inventoryCount = int.parse(val);
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            val;
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidCount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidCount;
      },
    );
    return CustomizedDropDownField(
      title: "Inventory (Available Quantity)",
      child: SizedBox(
        height: 55,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            dense: true,
            title: Center(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: greyBorderColor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
                  child: Text(
                    inventoryCount.toString(),
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: RoundedBackgroundIcon(
                backgroundColor: greyBorderColor,
                icon: Icon(
                  SlydoAppIcon.plus,
                  color: blackFont,
                  size: 14,
                ),
                onTap: () => addInventory()
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: RoundedBackgroundIcon(
                backgroundColor: greyBorderColor,
                icon: Icon(
                  SlydoAppIcon.minus,
                  color: blackFont,
                  size: 2,
                ),
                onTap: () => subtractInventory()
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addInventory() {
    setState(() {
      inventoryCount++;
    });
  }

  void subtractInventory() {
    if (inventoryCount > 0) {
      setState(() {
        inventoryCount--;
      });
    }
  }


  Widget getAddVariationFormField() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
          'option': 'new',
          'productId': '',
        });

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is Variant) {
          //save the variant details for later use
          productVariantList.add(result);
          if(mounted)setState(() {});
        }
      },
      child: CustomizedDropDownField(
        title: "Option",
        child: ListTile(
          dense: true,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'Add different variation like colour & size',
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
            margin: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
            decoration: BoxDecoration(
                border: Border.all(
                  color: navyBlue,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            child: Center(
              child: Text(
                'Create Variant',
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displaySelectedVariant() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Variant',
                maxLines: 1,
                style: TextStyle(
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
                    'option': 'new',
                    'productId': '',
                  });

                  // Handle the result (map) received from Product Add New Option
                  if (result != null && result is Variant) {
                    //save the variant details for later use
                    productVariantList.add(result);
                    if(mounted)setState(() {});
                  }
                },
                child: Text(
                  'Add more',
                  maxLines: 1,
                  style: TextStyle(
                      color: navyBlue,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            decoration: decorateBox(),
            // Use `SingleChildScrollView` to provide a bounded height for the content
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      // Use `physics` property to prevent nested scrolling
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productVariantList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          shadowColor: boxShadowTwo,
                          elevation: 0,
                          child: Container(
                            decoration: decorateBox(),
                            child: ListTile(
                              dense: true,
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appendStringDot(productVariantList[index].title!, 10),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    'Available . ${productVariantList[index].quantity!}',
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: blackFont.withOpacity(.5),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      worldCurrencies[productVariantList[index].currency!]!,
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 18.0,
                                          color: blackFont,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      moneyDisplayNormalizer(
                                          int.parse(productVariantList[index].price.toString())),
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          color: blackFont,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              leading: getVariantLeading(productVariantList[index]),
                              trailing: getVariantTrailing(productVariantList[index]),
                            ),
                          ),
                        );
                      },

                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getVariantLeading(Variant productVariant) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
            image: FileImage(
              File(productVariant.localImages![0].path),
            ),
            fit: BoxFit.cover),
      ),
    );
  }

  Widget getVariantTrailing(Variant productVariant) {

    return IconButton(
      padding: const EdgeInsets.only(right: 6),
      alignment: Alignment.topRight,
      icon: Container(
        decoration: BoxDecoration(
          color: iconBtnGrey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          SlydoAppIcon.remove,
          color: blackFont,
          size: 15,
        ),
      ),
      onPressed: () {
        removeSelectedVariant(productVariant.title.toString());
        if(mounted) setState(() {});
      },
    );
  }

  void removeSelectedVariant(String selectedVariantTitle) {
    // Use the removeWhere method to remove the variant with the specified title.
    productVariantList.removeWhere((variant) => variant.title == selectedVariantTitle);
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}
