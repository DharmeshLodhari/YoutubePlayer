import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_add_on_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_variants_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/custom_textfield_tag.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../../routes/route_constants.dart';
import '../shopping_auth.dart';

// ignore: must_be_immutable
class EditProduct extends StatefulWidget {
  var arguments;

  EditProduct({Key? key, this.arguments}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState(arguments: arguments);
}

class _EditProductState extends State<EditProduct> {
  var arguments;

  _EditProductState({this.arguments});

  final _auth = ShoppingAuthService();
  UserBloc? userBloc;
  final _formKey = GlobalKey<FormState>();

  String? productId;
  Product currentProduct = Product();

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  ScrollController scrollControllerVariant = ScrollController();
  List<PickedFile> productLocalImages = [];
  List<String?> productImagesFromServer = [];
  String? productName = "";
  String? productDescription = "";
  String? productShortDescription = "";
  String? productCategory = "";
  String productSubCategory = "";
  ProductCategory? pressedCustomCategory;
  List<ProductCategory>? customCategories;
  ProductCategory? pressedSubCategory;
  List<ProductCategory>? subCategories;
  List<ProductCategory>? subCategoriesCopy;
  String? productCondition = "";
  String? preparationCondition = "";
  String? productPrice = "";
  ProductCategory? selectedProductCategory;
  ProductCategory? selectedSubCategory;
  ProductCategory? selectedCustomCategory;
  ProductCategory? pressedCategory;
  List<ProductCategory>? productCategoriesCopy;
  List<ProductCategory>? productCustomCategoriesCopy;
  String productCustomCategory = "";

  ProductCondition? selectedProductCondition;
  ProductCondition? selectedPreparationCondition;
  String? productManufacturer = "";
  bool? productIsAvailable = false;
  DateTime? productAvailableFrom = DateTime.now();
  List<ProductCategory>? productCategories;
  List<ProductCategory>? productCustomCategories;
  bool isLoading = false;
  bool isAPILoading = false;
  bool productEnableInSuperStore = false;
  TextfieldTagsController _myController = TextfieldTagsController();
  List<Tags> userTags = [];
  // List<Tags> allTags = [];

  //text editing controllers for the edit fields
  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productShortDescriptionController =
      TextEditingController();
  TextEditingController productManufacturerController = TextEditingController();
  TextEditingController customProductController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController inventoryCountController = TextEditingController();
  int inventoryCount = 0;
  List<Variant> productVariantList = [];
  List<AddOns> productAddOnsList = [];
  bool inventoryIsAvailable = false;
  var weightSi = ['Grams', 'Kilograms'];
  var widthSi = ['Centimetres', 'Metres'];
  var heightSi = ['Centimetres', 'Metres'];
  List<String> measurementList = ['Weight', 'Height', 'Width'];
  Map<String, bool> measurementCheckMark = {};
  List<String> pickedMeasurementList = [];
  double weight = 0.0;
  double width = 0.0;
  double height = 0.0;
  String selectedWeight = "";
  String selectedHeight = "";
  String selectedWidth = "";
  bool trackInventory = false;
  bool trackInventoryView = false;
  bool measurementView = false;
  bool show = false;

  bool isDiscountLoading = false;
  bool discountView = false;
  int? discountItemCount = 0;
  String? discountNext = "";
  String? discountPrevious = "";
  List<DiscountModel> discountList = [];
  List<DiscountModel> discountListCopy = [];
  bool noItemInList = false;
  DiscountModel? pressedDiscount;
  DiscountModel? selectedDiscount;
  String discountName = "";
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    productId = arguments['productId'];
    getCategories();
    Future.delayed(Duration(seconds: 2), () {
      getDiscountList();
      obtainCategories();
      obtainCustomCategory();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    userBloc = Provider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      productCategories = await ShoppingAuthService().getProductCategories();
    } catch (e) {
      productCategories = [];
    }

    await fetchProduct();
    isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> fetchProduct() async {
    //fetchProductFrom id to edit
    await _auth.getProduct(productId!).then((value) {
      if (mounted) {
        setState(() {
          currentProduct = value;

          // assigning to our edit controllers
          productTitleController.text = currentProduct.name!;
          productDescriptionController.text =
              messageDecoderWithEmoji(currentProduct.description!)!;

          productPriceController.text =
              moneyNormalizer(int.parse(currentProduct.price!)).toString();

          if (currentProduct.manufacturer != null) {
            productManufacturerController.text = currentProduct.manufacturer!;
          }
          customProductController.text = currentProduct.customCategory!.name;

          productShortDescriptionController.text =
              messageDecoderWithEmoji(currentProduct.shortDescription!)!;

          productImagesFromServer.addAll(currentProduct.serverImages!);
          productName = currentProduct.name;
          productCategory = currentProduct.category!.name;
          productCondition = currentProduct.condition;
          productPrice = moneyNormalizer(int.parse(currentProduct.price!));
          productDescription =
              messageDecoderWithEmoji(currentProduct.description);
          productManufacturer = currentProduct.manufacturer;
          productShortDescription =
              messageDecoderWithEmoji(currentProduct.shortDescription);
          productIsAvailable = currentProduct.isAvailable;
          productAvailableFrom = currentProduct.availableFrom;
          productEnableInSuperStore = currentProduct.enableInSuperStore!;

          // debugPrint('fola edit::::: ${currentProduct.toJson()}');

          weight = currentProduct.weight!;
          selectedWeight = currentProduct.weightSiUnit == 'g'
              ? 'Grams'
              : currentProduct.weightSiUnit == ''
                  ? ''
                  : 'Kilograms';
          height = currentProduct.height!;
          selectedHeight = currentProduct.heightSiUnit == 'cm'
              ? 'Centimetres'
              : currentProduct.heightSiUnit == ""
                  ? ''
                  : 'Metres';
          width = currentProduct.width!;
          selectedWidth = currentProduct.widthSiUnit == 'cm'
              ? 'Centimetres'
              : currentProduct.widthSiUnit == ""
                  ? ''
                  : 'Metres';

          trackInventoryView = currentProduct.trackInventory!;
          selectedDiscount = currentProduct.discount;

          weightController.text = currentProduct.weight != 0.0
              ? currentProduct.weight.toString()
              : '';
          heightController.text = currentProduct.height != 0.0
              ? currentProduct.height.toString()
              : '';
          widthController.text = currentProduct.width != 0.0
              ? currentProduct.width.toString()
              : '';
          inventoryCount = currentProduct.quantity! ?? 0;
          inventoryCountController.text = inventoryCount.toString();

          //convert list to variant
          productVariantList = currentProduct.variantModels ?? [];
          // productVariantList = currentProduct.variantModels != null
          //     ? Variant.convertToVariantList(currentProduct.variantModels!)
          //     : [];
          //convert list to addOns
          productAddOnsList = currentProduct.addOnsModels ?? [];
          // productAddOnsList = currentProduct.addOnsModels != null
          //     ? AddOns.convertToAddOnList(currentProduct.addOnsModels!)
          //     : [];

          // assigning the dropdown from currentProduct
          selectedProductCategory = currentProduct.category;
          selectedSubCategory = currentProduct.subCategory;
          selectedCustomCategory = currentProduct.customCategory;
          userTags = currentProduct.tags!;

          print('CURRENT PRODUCT NAME :::: ${selectedProductCategory?.name}');

          conditions.forEach((condition) {
            if (condition.name == currentProduct.condition) {
              selectedProductCondition = condition;
            }
          });
          deliverTimeCondition.forEach((preparation) {
            if (preparation.name == currentProduct.preparationTime.toString()) {
              selectedPreparationCondition = preparation;
            }
          });

          if (weight != 0.0) {
            pickedMeasurementList.add('Weight');
          }

          if (height != 0.0) {
            pickedMeasurementList.add('Height');
          }

          if (width != 0.0) {
            pickedMeasurementList.add('Width');
          }
          measurementView = pickedMeasurementList.isEmpty ? false : true;
        });
      }
    });
  }

  void getDiscountList() async {
    if (!isDiscountLoading) {
      if (discountNext != null && !isDiscountLoading) {
        isDiscountLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfDiscounts(discountNext, discountPrevious);

        if (result == null) {
          isDiscountLoading = false;
          noItemInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        discountItemCount = result['count'];
        discountNext = result['next'];
        discountPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isDiscountLoading = false;
            discountList.addAll(tempList);

            discountListCopy = discountList;
          });
        }
      }
      if (discountList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (discountNext == null && discountList.length > 6) {
        _messengerScaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void obtainCategories() async {
    try {
      productCategories = await ShoppingAuthService()
          .obtainProductCategories(userBloc!.userAbout!.industry!.id!);

      productCategoriesCopy = productCategories;
    } catch (e) {
      productCategories = [];
      productCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void obtainCustomCategory() async {
    try {
      productCustomCategories = await ShoppingAuthService()
          .obtainCustomCategory(userBloc!.user.userName!);

      productCustomCategoriesCopy = productCustomCategories;
    } catch (e) {
      productCustomCategories = [];
      productCustomCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void getSubCategories(id) async {
    if (mounted) setState(() {});

    try {
      subCategories = await ShoppingAuthService().getProductSubCategories(id);

      subCategoriesCopy = subCategories;
    } catch (e) {
      subCategories = [];
      subCategoriesCopy = [];
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
    //
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
        "Edit product",
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      checkImageLimitForServerImage()
                          ? viewServerImages()
                          : Container(),
                      // checkImageLimitForServerImage()
                      //     ? SizedBox(
                      //         height: 8,
                      //       )
                      //     : Container(),
                      checkImageLimitForLocalImage()
                          ? addLocalImages()
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      addTitleField(),
                      SizedBox(
                        height: 10,
                      ),
                      getManufacturerField(),
                      SizedBox(
                        height: 10,
                      ),
                      getAmountField(),
                      SizedBox(height: 10),
                      getCategoryField(),
                      SizedBox(height: 10),
                      getSubCategoryField(),
                      const SizedBox(height: 10),
                      getCustomCategoryField(),
                      const SizedBox(height: 10),
                      getAddTagsField(),
                      getProductConditionField(),
                      const SizedBox(height: 10),
                      if (userBloc!.userAbout!.industry!.name! ==
                              "Restaurant/Cafe" ||
                          userBloc!.userAbout!.industry!.name! ==
                              "Pharmaceutical") ...[
                        getProductDeliveryTimeField(),
                        SizedBox(height: 10),
                      ],
                      getProductShortDescription(),
                      SizedBox(height: 10),
                      getProductDescription(),

                      SizedBox(height: 20),
                      getIsAvailableField(),
                      const SizedBox(height: 16),
                      if (productIsAvailable == true) ...[
                        getAvailableFromField(),
                        const SizedBox(height: 16),
                      ],

                      getMeasurementField(),
                      const SizedBox(height: 16),
                      if (measurementView == true) ...[
                        getCategoryMeasurementField(),
                        const SizedBox(height: 16),
                      ],

                      if (pickedMeasurementList.isNotEmpty &&
                          measurementView == true) ...[
                        if (containsWeight()) ...[
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
                        ],
                        if (containsHeight()) ...[
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
                        ],
                        if (containsWidth()) ...[
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
                          const SizedBox(height: 40),
                        ]
                      ],

                      getDiscountField(),
                      const SizedBox(height: 16),
                      if (discountView == true) ...[
                        getDiscountListField(),
                        const SizedBox(height: 16),
                      ],
                      getTrackInventoryViewField(),
                      if (trackInventoryView == true) ...[
                        const SizedBox(height: 16),
                        getInventoryFormField(),
                        const SizedBox(height: 16),
                        getTrackInventoryField(),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 16),

                      getEnableInSuperStoreField(),
                      const SizedBox(height: 16),

                      if (productVariantList == null ||
                          productVariantList.isEmpty) ...[
                        // getAddVariationFormField(),
                        productVariation(),
                      ] else ...[
                        displaySelectedVariant(),
                      ],
                      const SizedBox(height: 16),

                      if (productAddOnsList == null ||
                          productAddOnsList.isEmpty) ...[
                        productAddOns(),
                      ] else ...[
                        displaySelectedAddOn(),
                      ],
                      SizedBox(height: 30),

                      getSubmitButton(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget addLocalImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productLocalImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != productLocalImages.length
              ? showLocalImage(index)
              : productLocalImages.length + productImagesFromServer.length !=
                      imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
  }

  Widget viewServerImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImagesFromServer.length,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: showServerImage(index),
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
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
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
                SizedBox(
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

          productLocalImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showLocalImage(int index) {
    return Stack(
      children: <Widget>[
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: dividerColor,
          margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: FileImage(
                    File(productLocalImages[index].path),
                  ),
                  fit: BoxFit.fill),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            padding: EdgeInsets.only(right: 6, top: 6),
            alignment: Alignment.topRight,
            icon: Container(
              padding: EdgeInsets.all(2.0),
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
              if (mounted) {
                setState(() {
                  productLocalImages.removeAt(index);
                });
              }
            },
          ),
        )
      ],
    );
  }

  Widget showServerImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          CustomBoxShadow(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: boxShadowTwo,
              margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: NetworkImage(
                        productImagesFromServer[index]!,
                      ),
                      fit: BoxFit.fill),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: EdgeInsets.all(2.0),
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
                var imageId =
                    currentProduct.getImageId(productImagesFromServer[index]);
                debugPrint("imageId:- $imageId");
                _auth.deleteProductOrServiceImage(imageId).then((value) {
                  if (value) {
                    if (mounted) {
                      setState(() {
                        productImagesFromServer.removeAt(index);
                      });
                    }
                  }
                }).catchError((error) {
                  debugPrint("ERROR " + error.toString());
                });
              },
            ),
          )
        ],
      ),
    );
  }

  bool containsWeight() {
    return pickedMeasurementList.contains('Weight');
  }

  bool containsHeight() {
    return pickedMeasurementList.contains('Height');
  }

  bool containsWidth() {
    return pickedMeasurementList.contains('Width');
  }

  // decide that serverImage List is need to be show or not
  bool checkImageLimitForServerImage() {
    if (productLocalImages.length + productImagesFromServer.length !=
            imageCount ||
        productImagesFromServer.length != 0) {
      return true;
    }
    return false;
  }

  // decide that localImage List is need to be show or not
  bool checkImageLimitForLocalImage() {
    if (productLocalImages.length + productImagesFromServer.length !=
            imageCount ||
        productLocalImages.length != 0) {
      return true;
    }
    return false;
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
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.weight,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: weightController,
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
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.height,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: heightController,
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
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.width,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: widthController,
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

  Widget getTrackInventoryField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventory = !trackInventory;
        setState(() {});
      },
      isChecked: trackInventory,
      title:
          "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 12.0,
      maxLines: 2,
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      controller: productTitleController,
      labelText: AppLocalization.of(context)!.productName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterProductName;
      },
      onTap: () async {},
      onChanged: (val) {
        productName = val;
      },
    );
  }

  Widget getProductDescription() {
    return CustomizedTextFormField(
      controller: productDescriptionController,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context)!.description,
      onChanged: (val) {
        productDescription = val;
      },
    );
  }

  Widget getProductShortDescription() {
    return CustomizedTextFormField(
      labelText: "Short description",
      controller: productShortDescriptionController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onTap: () async {},
      onChanged: (val) {
        productShortDescription = val;
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
          // selectItemCategory();
          categoryAndroidSheet();
        },
      ),
    );
  }

  Widget getProductDeliveryTimeField() {
    return CustomizedDropDownField(
      title: "Preparation Time",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              selectedPreparationCondition != null
                  ? selectedPreparationCondition!.description
                  : "",
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectDeliveryTimeCondition();
        },
      ),
    );
  }

  void selectDeliveryTimeCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        children: deliverTimeCondition.map<Widget>((condition) {
                          if (selectedPreparationCondition == condition) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedPreparationCondition != null
                                            ? selectedPreparationCondition!
                                                .description
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
                                Expanded(
                                  child: Text(
                                    condition.description,
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
      selectedPreparationCondition = pressedCondition;
      preparationCondition = selectedPreparationCondition!.name;
      setState(() {});
    }
  }

  Widget getAddTagsField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tag",
              style: TextStyle(
                  color: darkGrey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () async {
                var result = await Navigator.of(context).pushNamed(
                    Routes.ADD_TAGS,
                    arguments: {"tagList": userTags});
                if (result != null && result is List<Tags>) {
                  userTags = [];
                  _myController.clearTags();

                  for (var tags in result) {
                    if (tags.isSelected == true) {
                      // _myController.addTag = tags.name
                      //         ?.replaceAll(" ", "-")
                      //         .toLowerCase() ??

                      _myController.addTag = tags.name ?? "";

                      Tags tagData = Tags(id: tags.id, name: tags.name);
                      userTags.add(tagData);
                    }
                  }
                  // userTags.addAll(allTags);
                }
                setState(() {});
              },
              child: Text(
                "Add Tags",
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 6,
        ),
        CustomTextFieldTag(
          initialTags: (userTags).map((e) => e.name!).toList(),
          textfieldTagsController: _myController,
          onTap: (String tag) {
            setState(() {
              userTags.removeWhere((e) => e.name == tag);
            });
            userTags.removeWhere((tag) => tag.name!.isEmpty);
          },
        ),
      ],
    );
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
                style: TextStyle(
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

  String getCustomCategoryLabel() {
    String industryName = userBloc!.userAbout!.industry!.name!;
    switch (industryName) {
      case 'Electronics Store':
        return "Aisle";
      case 'Furniture':
        return "Aisle";
      case 'Grocery Store':
        return "Aisle";
      case 'Liquor Store':
        return "Aisle";
      case 'Pharmaceutical':
        return "Aisle";
      case 'Restaurant/Cafe':
        return "Menu";
      case 'Retail':
        return "Aisle";
      default:
        return "Custom Category";
    }
  }

  Widget getCustomCategoryField() {
    return CustomizedDropDownField(
      title: getCustomCategoryLabel(),
      child: ListTile(
        dense: true,
        title: Text(
          selectedCustomCategory != null ? selectedCustomCategory!.name : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          customCategoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  Widget getSubCategoryField() {
    return CustomizedDropDownField(
      title: "Sub-Category",
      child: ListTile(
        dense: true,
        title: Text(
          selectedSubCategory != null ? selectedSubCategory!.name : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          subCategoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  void subCategoryAndroidSheet() {
    subCategories = subCategoriesCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search  sub category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      subCategories = subCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      subCategories = subCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                subCategories == null
                    ? SizedBox()
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: subCategories!.length,
                          itemBuilder: (context, index) {
                            ProductCategory category = subCategories![index];
                            if (selectedSubCategory == category) {
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
                                    pressedSubCategory = category;
                                    Navigator.pop(context);
                                    if (pressedSubCategory != null) {
                                      selectedSubCategory = pressedSubCategory;
                                      productSubCategory =
                                          selectedSubCategory!.name;
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
                                  selectedSubCategory = pressedCategory;
                                  productCategory = selectedSubCategory!.name;
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

  void customCategoryAndroidSheet() {
    customCategories = productCustomCategoriesCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search  custom category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      customCategories = productCustomCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      customCategories = productCustomCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customCategories!.length,
                    itemBuilder: (context, index) {
                      ProductCategory category = customCategories![index];
                      if (selectedCustomCategory == category) {
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
                              pressedCustomCategory = category;
                              Navigator.pop(context);
                              if (pressedSubCategory != null) {
                                selectedCustomCategory = pressedCustomCategory;
                                productCustomCategory =
                                    selectedCustomCategory!.name;
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
                          pressedCustomCategory = category;
                          Navigator.pop(context);
                          if (pressedCustomCategory != null) {
                            selectedCustomCategory = pressedCustomCategory;
                            productCustomCategory =
                                selectedCustomCategory!.name;
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
                            getSubCategories(category.id);
                            selectedProductCategory = pressedCategory;
                            productCategory = selectedProductCategory!.name;
                            productSubCategory = "";
                            selectedSubCategory = null;
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

  void selectItemCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
      controller: productManufacturerController,
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
      controller: productPriceController,
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
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
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      child: Row(
        children: <Widget>[
          Expanded(
            child: CurvedButton(
                textColor: Colors.white,
                backgroundColor: mateRed,
                text: AppLocalization.of(context)!.delete,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  deleteProduct();
                }),
          ),
          SizedBox(width: 8),
          Expanded(
            child: CurvedButton(
              textColor: Colors.white,
              text: AppLocalization.of(context)!.update,
              backgroundColor: navyBlue,
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAPILoading = true;
                      if (mounted) setState(() {});

                      await editProduct();

                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
              isLoading: isAPILoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editProduct() async {
    if (_formKey.currentState!.validate()) {
      if (productLocalImages.length >= 0) {
        if (containsWeight() && selectedWeight.isEmpty && weight != 0.0) {
          showToast(message: AppLocalization.of(context)!.pleaseFillWeight);
          return;
        }
        if (containsHeight() && selectedHeight.isEmpty && height != 0.0) {
          showToast(message: AppLocalization.of(context)!.pleaseFillHeight);
          return;
        }
        if (containsWidth() && selectedWidth.isEmpty && width != 0.0) {
          showToast(message: AppLocalization.of(context)!.pleaseFillWidth);
          return;
        }

        if (validateDropdown()) {
          // setting updated value
          currentProduct.name = productName;
          currentProduct.description =
              messageDecoderWithEmoji(productDescription);
          currentProduct.category = selectedProductCategory;
          currentProduct.subCategory = selectedSubCategory;
          currentProduct.customCategory = selectedCustomCategory;
          currentProduct.tags = userTags;
          if (selectedPreparationCondition != null) {
            currentProduct.preparationTime =
                int.parse(selectedPreparationCondition!.name);
          }
          currentProduct.condition = productCondition;
          currentProduct.price = moneyInputNormalizer(productPrice!).toString();
          currentProduct.localImages =
              productLocalImages.map((file) => File(file.path)).toList();
          currentProduct.serverImages = productImagesFromServer;
          currentProduct.isAvailable = productIsAvailable;
          currentProduct.availableFrom = productAvailableFrom;
          currentProduct.shortDescription =
              messageDecoderWithEmoji(productShortDescription);
          currentProduct.manufacturer = productManufacturer;
          currentProduct.enableInSuperStore = productEnableInSuperStore;

          currentProduct.weight = weight;
          currentProduct.weightSiUnit = selectedWeight == 'Grams'
              ? 'g'
              : selectedWeight == 'Kilograms'
                  ? 'kg'
                  : '';
          currentProduct.height = height;
          currentProduct.heightSiUnit = selectedHeight == 'Centimetres'
              ? 'cm'
              : selectedHeight == 'Metres'
                  ? 'm'
                  : '';
          currentProduct.width = width;
          currentProduct.widthSiUnit = selectedWidth == 'Centimetres'
              ? 'cm'
              : selectedWidth == 'Metres'
                  ? 'm'
                  : '';
          currentProduct.discount = selectedDiscount;
          currentProduct.trackInventory = trackInventory;
          currentProduct.quantity = inventoryCount;
          await _auth
              .editProduct(currentProduct, productAddOnsList)
              .then((value) {
            showToast(
                message:
                    AppLocalization.of(context)!.productEditedSuccessfully);
            Navigator.pop(context, "update_item");
          }).catchError((error) {
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
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

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable!;
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Is product available now?",
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
          context: context,
          builder: customThemeBuilder,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          if (mounted) {
            setState(() {
              productAvailableFrom =
                  DateTime(value!.year, value.month, value.day);
            });
          }
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(productAvailableFrom!),
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

  void deleteProduct() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => ConfirmDelete(),
    );
    if (result) {
      await _auth.deleteProduct(currentProduct.id!).then((value) {
        Navigator.pop(context, "delete_item");
        showToast(
            message: AppLocalization.of(context)!.productDeletedSuccessfully);
      }).catchError((error) {
        showToast(message: error.toString());
      });
    }
  }

  Widget getInventoryFormField() {
    return CustomizedTextFormField(
      labelText: "Inventory (Available Quantity)",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: false)
          : TextInputType.number,
      controller: inventoryCountController,
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
  }

  Widget getMeasurementField() {
    return CustomizedCheckBoxField(
      onTap: () {
        measurementView = !measurementView;
        setState(() {});
      },
      isChecked: measurementView,
      title: AppLocalization.of(context)!.measurement,
    );
  }

  Widget getDiscountField() {
    return CustomizedCheckBoxField(
      onTap: () {
        discountView = !discountView;
        setState(() {});
      },
      isChecked: discountView,
      title: AppLocalization.of(context)!.discount,
    );
  }

  Widget getTrackInventoryViewField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventoryView = !trackInventoryView;
        setState(() {});
      },
      isChecked: trackInventoryView,
      title: AppLocalization.of(context)!.trackInventoryView,
    );
  }

  Widget getCategoryMeasurementField() {
    return CustomizedDropDownField(
      title: '',
      child: ListTile(
        dense: true,
        title: Text(
          pickedMeasurementList.isNotEmpty
              ? pickedMeasurementList.join(', ')
              : '',
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          measurementAndroidSheet();
        },
      ),
    );
  }

  void measurementAndroidSheet() {
    measurementCheckMark['Height'] = containsHeight() ? true : false;
    measurementCheckMark['Weight'] = containsWeight() ? true : false;
    measurementCheckMark['Width'] = containsWidth() ? true : false;

    androidBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: measurementList.length,
                    itemBuilder: (context, index) {
                      String measurement = measurementList[index];
                      return CheckboxListTile(
                        value: measurementCheckMark[measurement] ?? false,
                        activeColor: navyBlue,
                        onChanged: (isChecked) {
                          changeState(() {
                            measurementCheckMark[measurement] = isChecked!;
                          });
                          if (pickedMeasurementList.contains(measurement)) {
                            pickedMeasurementList.remove(measurement);
                          } else {
                            pickedMeasurementList.add(measurement);
                          }
                          if (mounted) setState(() {});
                        },
                        title: Text(
                          measurement,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                  ),
                ),
                CurvedButton(
                  text: 'Pick',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getIsInventoryAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        inventoryIsAvailable = !inventoryIsAvailable;
        setState(() {});
      },
      isChecked: inventoryIsAvailable,
      title:
          "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 10.0,
      maxLines: 2,
    );
  }

  Widget getDiscountListField() {
    return CustomizedDropDownField(
      title: 'Discount',
      fontSize: 12,
      titleColor: blackFont,
      fontWeight: FontWeight.w400,
      child: ListTile(
        dense: true,
        title: Text(
          selectedDiscount != null
              ? messageDecoderWithEmoji(selectedDiscount?.name) ??
                  selectedDiscount?.merchant ??
                  ""
              : "",
          style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          discountAndroidSheet();
        },
      ),
    );
  }

  void discountAndroidSheet() {
    discountList = discountListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search discount',
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      discountList = discountListCopy
                          .where((element) =>
                              (messageDecoderWithEmoji(element.name) ??
                                      element.merchant ??
                                      "")
                                  .toLowerCase()
                                  .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      discountList = discountListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: discountList.length,
                    itemBuilder: (context, index) {
                      DiscountModel discount = discountList[index];
                      if (selectedDiscount == discount) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              messageDecoderWithEmoji(discount.name) ??
                                  discount.merchant ??
                                  "",
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 16,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              SlydoAppIcon.checked,
                              color: navyBlue,
                              size: 12,
                            ),
                            onTap: () {
                              pressedDiscount = discount;
                              Navigator.pop(context);
                              if (pressedDiscount != null) {
                                selectedDiscount = pressedDiscount;
                                discountName = messageDecoderWithEmoji(
                                        selectedDiscount?.name) ??
                                    selectedDiscount?.merchant ??
                                    "";
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          messageDecoderWithEmoji(discount.name) ??
                              discount.merchant ??
                              "",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedDiscount = discount;
                          Navigator.pop(context);
                          if (pressedDiscount != null) {
                            selectedDiscount = pressedDiscount;
                            discountName = messageDecoderWithEmoji(
                                    selectedDiscount?.name) ??
                                selectedDiscount?.merchant ??
                                "";
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

  Widget getAddVariationFormField() {
    return GestureDetector(
      onTap: () async {
        // Navigate to PRODUCT VARIANT LIST and wait for the result
        final result = await Navigator.of(context)
            .pushNamed(Routes.PRODUCT_VARIANT_LIST, arguments: {
          'productId': productId,
        });

        // // Handle the result (map) received from Product Add New Option
        if (result != null && result is List<Variant>) {
          //save the variant details for later use
          productVariantList = result;
          if (mounted) setState(() {});
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
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          subtitle: Container(
            padding: const EdgeInsets.only(
                left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
            margin: const EdgeInsets.only(
                left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
            decoration: BoxDecoration(
                border: Border.all(
                  color: navyBlue,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Variant',
              maxLines: 1,
              style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                final data = await Navigator.of(context)
                    .pushNamed(Routes.PRODUCT_VARIANT_LIST, arguments: {
                  'productId': productId,
                });

                // Handle the result (map) received from PRODUCT_VARIANT_LIST
                if (data != null && data is Variant) {
                  //clear previous list, update the list
                  // debugPrint('fola data::: ${data}');
                  // debugPrint('fola data 2::: ${data.runtimeType}');

                  // productVariantList = [];
                  // productVariantList = Variant.convertToVariantList(data);
                  // productVariantList = data;

                  // variantData = data;
                  productVariantList.add(data);
                  if (mounted) setState(() {});
                }
              },
              child: Text(
                'See all',
                maxLines: 1,
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        _buildProductVariantList(),
      ],
    );
  }

  Widget _buildProductVariantList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: scrollControllerVariant,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: productVariantList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == productVariantList.length) {
          return buildLoadingIndicator(isLoading: isLoading);
        } else {
          return FormVariantsTile(
              productVariantList: productVariantList,
              index: index,
              type: 'edit');
        }
      },
    );
  }

  Widget productVariation() {
    return GestureDetector(
      onTap: () async {
        //disable click if add-on is not empty
        if (productAddOnsList.isNotEmpty) {
          return;
        }
        final result = await Navigator.of(context).pushNamed(
            Routes.PRODUCT_NEW_OPTION,
            arguments: {'productId': productId, 'option': 'edit'});

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is Variant) {
          //save the variant details for later use
          productVariantList.add(result);
          if (mounted) setState(() {});
        }
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Product Variation',
              maxLines: 1,
              style: TextStyle(
                  color: productAddOnsList.isNotEmpty ? darkGrey : navyBlue,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: blackFont,
            ),
          ],
        ),
      ),
    );
  }

  Widget productAddOns() {
    return GestureDetector(
      onTap: () async {
        //disable click if variant is not empty
        if (productVariantList.isNotEmpty) {
          return;
        }

        final result = await Navigator.of(context)
            .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
          'productId': productId,
          'isForCheckboxSelection': true,
        });

        // Handle the result (map) received from PRODUCT_ADD_ON_LIST
        if (result != null && result is List<AddOns>) {
          //save the add-on details
          productAddOnsList = result;
          if (mounted) setState(() {});
        }
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Product Add-ons',
              maxLines: 1,
              style: TextStyle(
                  color: productVariantList.isNotEmpty ? darkGrey : navyBlue,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 14),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: blackFont,
            ),
          ],
        ),
      ),
    );
  }

  Widget displaySelectedAddOn() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Add-ons',
              maxLines: 1,
              style: TextStyle(
                  color: darkGrey, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                final data = await Navigator.of(context)
                    .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
                  'productId': productId,
                  'isForCheckboxSelection': true,
                });

                // Handle the result (map) received from PRODUCT_ADD_ON_LIST
                if (data != null && data is List<AddOns>) {
                  //save the add-on details
                  productAddOnsList = data;
                  if (mounted) setState(() {});
                }
              },
              child: Text(
                'See all',
                maxLines: 1,
                style: TextStyle(
                    color: navyBlue, fontWeight: FontWeight.w400, fontSize: 14),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        _buildAddOnList(),
      ],
    );
  }

  Widget _buildAddOnList() {
    return Container(
      // height: 200,
      height: 80 * productAddOnsList.length.toDouble(),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        //+1 for progressbar
        itemCount: productAddOnsList.length + 1,
        controller: scrollControllerVariant,
        itemBuilder: (BuildContext context, int index) {
          if (index == productAddOnsList.length) {
            return buildLoadingIndicator(isLoading: isLoading);
          } else {
            return FormAddOnTile(
              productAddOnsList: productAddOnsList,
              index: index,
            );
          }
        },
      ),
    );
  }

  // Widget addOnTile({required AddOns addOns}) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  //     shadowColor: boxShadowTwo,
  //     elevation: 0,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  //       decoration: BoxDecoration(
  //         border: Border.all(width: 1, color: greyBorderColor),
  //         borderRadius: BorderRadius.all(Radius.circular(10)),
  //       ),
  //       child: ListTile(
  //         dense: true,
  //         title: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               appendStringDot(addOns.name!, 20),
  //               maxLines: 1,
  //               style: TextStyle(
  //                   color: blackFont,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 18),
  //             ),
  //             Text(
  //               '${addOns.options!.length} items',
  //               maxLines: 1,
  //               style: TextStyle(
  //                   color: darkGrey, fontWeight: FontWeight.w400, fontSize: 14),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    productTitleController.dispose();
    productDescriptionController.dispose();
    productShortDescriptionController.dispose();
    productManufacturerController.dispose();
    productPriceController.dispose();
    _scrollController.dispose();
    scrollControllerVariant.dispose();
    _myController.dispose();

    super.dispose();
  }
}
