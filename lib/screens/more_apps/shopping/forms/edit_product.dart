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
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/currency.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
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
  String? productCondition = "";
  String? productPrice = "";
  ProductCategory? selectedProductCategory;
  ProductCondition? selectedProductCondition;
  String? productManufacturer = "";
  bool? productIsAvailable = false;
  DateTime? productAvailableFrom = DateTime.now();
  List<ProductCategory>? productCategories;
  bool isLoading = false;
  bool isAPILoading = false;
  bool productEnableInSuperStore = false;

  //text editing controllers for the edit fields
  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productShortDescriptionController =
      TextEditingController();
  TextEditingController productManufacturerController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController inventoryCountController = TextEditingController();
  int inventoryCount = 0;
  List<Variant> productVariantList = [];
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

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    productId = arguments['productId'];
    getCategories();

    super.initState();
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
          productDescriptionController.text = messageDecoderWithEmoji(currentProduct.description!)!;

          productPriceController.text =
              moneyNormalizer(int.parse(currentProduct.price!)).toString();

          if (currentProduct.manufacturer != null) {
            productManufacturerController.text = currentProduct.manufacturer!;
          }
          productShortDescriptionController.text = messageDecoderWithEmoji(currentProduct.shortDescription!)!;

          productImagesFromServer.addAll(currentProduct.serverImages!);
          productName = currentProduct.name;
          productCategory = currentProduct.category;
          productCondition = currentProduct.condition;
          productPrice = moneyNormalizer(int.parse(currentProduct.price!));
          productDescription = messageDecoderWithEmoji(currentProduct.description);
          productManufacturer = currentProduct.manufacturer;
          productShortDescription = messageDecoderWithEmoji(currentProduct.shortDescription);
          productIsAvailable = currentProduct.isAvailable;
          productAvailableFrom = currentProduct.availableFrom;
          productEnableInSuperStore = currentProduct.enableInSuperStore!;

          // debugPrint('fola edit::::: ${currentProduct.toJson()}');

          weight = currentProduct.weight!;
          selectedWeight = currentProduct.weightSiUnit == 'g' ? 'Grams' :
          currentProduct.weightSiUnit == '' ? '' : 'Kilograms';
          height = currentProduct.height!;
          selectedHeight = currentProduct.heightSiUnit == 'cm' ? 'Centimetres' :
          currentProduct.heightSiUnit == "" ? '' :'Metres';
          width = currentProduct.width!;
          selectedWidth = currentProduct.widthSiUnit == 'cm' ? 'Centimetres' :
          currentProduct.widthSiUnit == "" ? '' : 'Metres';
          trackInventory = currentProduct.trackInventory!;

          trackInventoryView = trackInventory;

          weightController.text = currentProduct.weight != 0.0 ? currentProduct.weight.toString() : '';
          heightController.text = currentProduct.height != 0.0 ? currentProduct.height.toString() : '';
          widthController.text = currentProduct.width != 0.0 ? currentProduct.width.toString() : '';
          inventoryCount = currentProduct.quantity! ?? 0;
          inventoryCountController.text = inventoryCount.toString();

          //convert list to variant
          productVariantList = Variant.convertToVariantList(currentProduct.variant!);

          // assigning the dropdown from currentProduct
          productCategories?.forEach((catagory) {
            print('CURRENT CATEGORY :::: ${catagory}');

            if (catagory.name ==
                messageDecoderWithEmoji(currentProduct.category)) {
              selectedProductCategory = catagory;
            }
          });
          print('CURRENT PRODUCT NAME :::: ${selectedProductCategory?.name}');

          conditions.forEach((condition) {
            if (condition.name == currentProduct.condition) {
              selectedProductCondition = condition;
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
                      getProductConditionField(),
                      SizedBox(height: 16),
                      getProductShortDescription(),
                      SizedBox(height: 10),
                      getProductDescription(),

                      SizedBox(height: 10),
                      getIsAvailableField(),
                      const SizedBox(height: 16),
                      if(productIsAvailable == true)...[
                        getAvailableFromField(),
                        const SizedBox(height: 16),
                      ],
                      getMeasurementField(),
                      const SizedBox(height: 16),
                      if(measurementView == true)...[
                        getCategoryMeasurementField(),
                        const SizedBox(height: 16),
                      ],

                      if(pickedMeasurementList.isNotEmpty && measurementView == true)...[
                        if(containsWeight())...[
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
                        if(containsHeight())...[
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
                        if(containsWidth())...[
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

                      getTrackInventoryViewField(),
                      if(trackInventoryView == true)...[
                        const SizedBox(height: 16),
                        getInventoryFormField(),
                        const SizedBox(height: 16),
                        getTrackInventoryField(),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(height: 16),
                      getEnableInSuperStoreField(),
                      const SizedBox(height: 16),
                      if(productVariantList == null || productVariantList.isEmpty)...[
                        getAddVariationFormField(),
                      ]else...[
                        displaySelectedVariant(),
                      ],
                      SizedBox(height: 16),
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

  bool containsWeight(){
    return pickedMeasurementList.contains('Weight');
  }

  bool containsHeight(){
    return pickedMeasurementList.contains('Height');
  }

  bool containsWidth(){
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
      title: "Checking this field will automatically update the quantity when the product is purchased.",
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
          selectItemCategory();
        },
      ),
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

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ProductCategory>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
        if(containsWeight() && selectedWeight.isEmpty && weight != 0.0){
          showToast(message: AppLocalization.of(context)!
              .pleaseFillWeight);
          return;
        }
        if(containsHeight() && selectedHeight.isEmpty && height != 0.0){
          showToast(message: AppLocalization.of(context)!
              .pleaseFillHeight);
          return;
        }
        if(containsWidth() && selectedWidth.isEmpty && width != 0.0){
          showToast(message: AppLocalization.of(context)!
              .pleaseFillWidth);
          return;
        }

        if (validateDropdown()) {
          // setting updated value
          currentProduct.name = productName;
          currentProduct.description = messageDecoderWithEmoji(productDescription);
          currentProduct.category = messageDecoderWithEmoji(productCategory);
          currentProduct.condition = productCondition;
          currentProduct.price = moneyInputNormalizer(productPrice!).toString();
          currentProduct.localImages =
              productLocalImages.map((file) => File(file.path)).toList();
          currentProduct.serverImages = productImagesFromServer;
          currentProduct.isAvailable = productIsAvailable;
          currentProduct.availableFrom = productAvailableFrom;
          currentProduct.shortDescription = messageDecoderWithEmoji(productShortDescription);
          currentProduct.manufacturer = productManufacturer;
          currentProduct.enableInSuperStore = productEnableInSuperStore;

          currentProduct.weight = weight;
          currentProduct.weightSiUnit = selectedWeight == 'Grams' ? 'g' : selectedWeight == 'Kilograms' ? 'kg' : '';
          currentProduct.height = height;
          currentProduct.heightSiUnit = selectedHeight == 'Centimetres' ? 'cm' : selectedHeight == 'Metres' ? 'm' : '';
          currentProduct.width = width;
          currentProduct.widthSiUnit = selectedWidth == 'Centimetres' ? 'cm' : selectedWidth == 'Metres' ? 'm' : '';
          currentProduct.trackInventory = trackInventory;
          currentProduct.quantity = inventoryCount;

          await _auth.editProduct(currentProduct).then((value) {
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
          pickedMeasurementList.isNotEmpty ? pickedMeasurementList.join(', ') : '',
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
                        onChanged: (isChecked) {
                          changeState(() {
                            measurementCheckMark[measurement] = isChecked!;
                          });
                          if (pickedMeasurementList.contains(measurement)) {
                            pickedMeasurementList.remove(measurement);
                          } else {
                            pickedMeasurementList.add(measurement);
                          }
                          if(mounted)setState(() {});
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
      title: "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 10.0,
      maxLines: 2,
    );
  }

  Widget getAddVariationFormField() {
    return GestureDetector(
      onTap: () async {

        // Navigate to PRODUCT VARIANT LIST and wait for the result
        final result = await Navigator.of(context).pushNamed(Routes.PRODUCT_VARIANT_LIST,
            arguments: {
              'productId': productId,
            });

        // // Handle the result (map) received from Product Add New Option
        if (result != null && result is List<Variant>) {
          //save the variant details for later use
          productVariantList = result;
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

  Widget displaySelectedVariant(){

    return Column(
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
              onTap: (){
                final data = Navigator.of(context).pushNamed(Routes.PRODUCT_VARIANT_LIST,
                  arguments: {
                  'productId': productId,
                });

                // Handle the result (map) received from PRODUCT_VARIANT_LIST
                if (data != null && data is List<Variant>) {
                  //clear previous list, update the list
                  // debugPrint('fola data::: ${data}');
                  // debugPrint('fola data 2::: ${data.runtimeType}');

                  // productVariantList = [];
                  // productVariantList = Variant.convertToVariantList(data);
                  // productVariantList = data;

                  // variantData = data;
                  if(mounted)setState(() {});
                }
              },
              child: Text(
                'See all',
                maxLines: 1,
                style: TextStyle(
                    color: navyBlue,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
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
    return Container(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        //+1 for progressbar
        itemCount: productVariantList.length + 1,
        controller: scrollControllerVariant,
        itemBuilder: (BuildContext context, int index) {
          if (index == productVariantList.length) {
            return buildLoadingIndicator(isLoading: isLoading);
          } else {
            return productVariantTile(
                  variant: productVariantList[index],
                );
          }
        },

      ),
    );
  }

  Widget productVariantTile({required Variant variant}) {

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense:  true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appendStringDot(variant.title!, 20),
                maxLines: 1,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Text(
                'Available . ${variant.quantity!}',
                maxLines: 1,
                style: TextStyle(
                    color: blackFont.withOpacity(.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[variant.currency!]!,
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 18.0,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    moneyDisplayNormalizer(
                        int.parse(variant.price.toString())),
                    style: TextStyle(
                        fontSize: 18.0,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
          leading: GestureDetector(
            onTap: () {
              String? url = variant.serverImages![0]!;
              Navigator.of(context)
                  .pushNamed("/photo-viewer", arguments: url);
            },
            child: checkProductImage(variant),
          ),
        ),
      ),
    );
  }

  Widget checkProductImage(Variant variant) {
    // Retrieve the first image from the 'pictures' list
    String? url = "";

    for(var item in variant.serverImages!){
      url = item;
    }

    String imageUrl = url!.replaceAll('https//', 'https://');
    if (url == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(variant.title!).toUpperCase(),
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
              width: 100,
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
    productTitleController.dispose();
    productDescriptionController.dispose();
    productShortDescriptionController.dispose();
    productManufacturerController.dispose();
    productPriceController.dispose();
    _scrollController.dispose();
    scrollControllerVariant.dispose();
    super.dispose();
  }
}
