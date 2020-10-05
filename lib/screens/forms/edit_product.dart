import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class EditProduct extends StatefulWidget {
  var arguments;

  EditProduct({this.arguments});
  @override
  _EditProductState createState() => _EditProductState(arguments: arguments);
}

class _EditProductState extends State<EditProduct> {
  var arguments;
  _EditProductState({this.arguments});
  final _auth = AuthService();
  UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();

  String productId;
  Product currentProduct = Product();

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<File> productLocalImages = [];
  List<String> productImagesFromServer = List<String>();
  String productName = "";
  String productDescription = "";
  String productShortDescription = "";
  String productCategory = "";
  String productCondition = "";
  String productPrice = "";
  ProductCategory selectedProductCategory;
  ProductCondition selectedProductCondition;
  String productManufacturer = "";
  bool productIsAvailable = false;
  DateTime productAvailableFrom = DateTime.now();

  //text editing controllers for the edit fields
  TextEditingController productTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productShortDescriptionController =
      TextEditingController();
  TextEditingController productManufacturerController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();

  @override
  void initState() {
    productId = arguments['productId'];
    fetchProduct();
    super.initState();
  }

  void fetchProduct() async {
    //fetchProductFrom id to edit
    _auth.getProduct(productId).then((value) {
      if (mounted) {
        setState(() {
          currentProduct = value;
          // assigning to our edit controllers

          productTitleController.text = currentProduct.name;
          productDescriptionController.text = currentProduct.description;
          productPriceController.text = currentProduct.price;
          productManufacturerController.text = currentProduct.manufacturer;
          productShortDescriptionController.text =
              currentProduct.shortDescription;

          productImagesFromServer.addAll(currentProduct.serverImages);
          productName = currentProduct.name;
          productCategory = currentProduct.category;
          productCondition = currentProduct.condition;
          productPrice = currentProduct.price;
          productDescription = currentProduct.description;
          productManufacturer = currentProduct.manufacturer;
          productShortDescription = currentProduct.shortDescription;
          productIsAvailable = currentProduct.isAvailable;
          productAvailableFrom = currentProduct.availableFrom;

          // assigning the dropdown from currentProduct
          productCategories.forEach((catagory) {
            if (catagory.name == currentProduct.category) {
              selectedProductCategory = catagory;
            }
          });

          conditions.forEach((condition) {
            if (condition.name == currentProduct.condition) {
              selectedProductCondition = condition;
            }
          });
        });
      }
    }).catchError((error) {
      Toast.show(
        error.toString(),
        context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        gravity: Toast.CENTER,
      );
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
        appBar: appBar(),
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
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                checkImageLimitForServerImage()
                    ? viewServerImages()
                    : Container(),
                checkImageLimitForServerImage()
                    ? SizedBox(
                        height: 8,
                      )
                    : Container(),
                checkImageLimitForLocalImage() ? addLocalImages() : Container(),
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
                SizedBox(
                  height: 10,
                ),
                getProductConditionField(),
                SizedBox(height: 16),
                getIsAvailableField(),
                SizedBox(height: 16),
                getAvailableFromField(),
                SizedBox(height: 10),
                getProductShortDescription(),
                SizedBox(height: 10),
                getProductDescription(),
                SizedBox(height: 10),
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
                  AppLocalization.of(context).addImage,
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
              title: Text(AppLocalization.of(context).selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context).camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context).gallary),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker.pickImage(source: imageSource).then((value) {
        if (value != null) {
          if (mounted) {
            setState(() {
              productLocalImages.add(value);
            });
          }
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
                    productLocalImages[index],
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
                        productImagesFromServer[index],
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
                _auth.deleteProductOrServiceImage(imageId).then((value) {
                  if (value) {
                    if (mounted) {
                      setState(() {
                        productImagesFromServer.removeAt(index);
                      });
                    }
                  }
                }).catchError((error) {
                  debugPrint("ERROR" + error.toString());
                });
              },
            ),
          )
        ],
      ),
    );
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

  Widget addTitleField() {
    return CustomizedTextFormField(
      controller: productTitleController,
      labelText: AppLocalization.of(context).productName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterProductName;
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
      labelText: AppLocalization.of(context).description,
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
        return AppLocalization.of(context).shortDescription;
      },
      onTap: () async {},
      onChanged: (val) {
        productShortDescription = val;
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context).category,
      child: DropdownButton<ProductCategory>(
        isExpanded: true,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: selectedProductCategory,
        style: TextStyle(
            color: blackFont, fontSize: 16, fontWeight: FontWeight.w400),
        onChanged: (ProductCategory value) {
          if (mounted) {
            setState(() {
              selectedProductCategory = value;
              productCategory = selectedProductCategory.name;
            });
          }
        },
        selectedItemBuilder: (BuildContext context) {
          return productCategories.map<Widget>((ProductCategory category) {
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        items: productCategories.map((ProductCategory category) {
          return DropdownMenuItem<ProductCategory>(
            value: category,
            child: Container(
              child: Row(
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                        color: category == selectedProductCategory
                            ? navyBlue
                            : blackFont,
                        fontSize: 16,
                        fontWeight: category == selectedProductCategory
                            ? FontWeight.w600
                            : FontWeight.w400),
                  ),
                  flexibleSpace(),
                  category == selectedProductCategory
                      ? Icon(
                          SlydoAppIcon.checked,
                          color: navyBlue,
                          size: 14,
                        )
                      : Container()
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget getProductConditionField() {
    return CustomizedDropDownField(
      title: "Product condition",
      child: DropdownButton<ProductCondition>(
        underline: Divider(
          color: Colors.transparent,
        ),
        isExpanded: true,
        value: selectedProductCondition,
        onChanged: (ProductCondition value) {
          if (mounted) {
            setState(() {
              selectedProductCondition = value;
              productCondition = selectedProductCondition.name;
            });
          }
        },
        style: TextStyle(
            color: blackFont, fontSize: 16, fontWeight: FontWeight.w400),
        selectedItemBuilder: (BuildContext context) {
          return conditions.map((ProductCondition productCondition) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  productCondition.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    " (" + productCondition.description + ")",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: conditions.map((ProductCondition productCondition) {
          return DropdownMenuItem<ProductCondition>(
              value: productCondition,
              child: Container(
                child: Row(
                  children: [
                    Text(
                      productCondition.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: productCondition == selectedProductCondition
                              ? navyBlue
                              : blackFont,
                          fontSize: 16),
                    ),
                    Text(
                      " (" + productCondition.description + ")",
                      style: TextStyle(
                        color: productCondition == selectedProductCondition
                            ? navyBlue
                            : blackFont,
                        fontSize: 16,
                      ),
                    ),
                    flexibleSpace(),
                    productCondition == selectedProductCondition
                        ? Icon(
                            SlydoAppIcon.checked,
                            color: navyBlue,
                            size: 14,
                          )
                        : Container()
                  ],
                ),
              ));
        }).toList(),
      ),
    );
  }

  Widget getManufacturerField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).manufacturer,
      controller: productManufacturerController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterManufacturerName;
      },
      onChanged: (val) {
        productManufacturer = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      controller: productPriceController,
      keyboardType: TextInputType.number,
      isAmount: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            productPrice = double.parse(val).toString();
          } catch (e) {
            Toast.show(e, context);
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val);
            return null;
          } catch (e) {
            return AppLocalization.of(context).invalidAmount;
          }
        }
        return AppLocalization.of(context).invalidAmount;
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
                backgroundColor: mateRad,
                text: AppLocalization.of(context).delete,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  deleteProduct();
//                  editProduct();
                }),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: CurvedButton(
                textColor: Colors.white,
                text: AppLocalization.of(context).update,
                backgroundColor: navyBlue,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  editProduct();
                }),
          ),
        ],
      ),
    );
  }

  void editProduct() {
    if (_formKey.currentState.validate()) {
      if (productLocalImages.length >= 0) {
        if (validateDropdown()) {
          // setting updated value
          currentProduct.name = productName;
          currentProduct.description = productDescription;
          currentProduct.category = productCategory;
          currentProduct.condition = productCondition;
          currentProduct.price = productPrice;
          currentProduct.localImages = productLocalImages;
          currentProduct.serverImages = productImagesFromServer;
          currentProduct.isAvailable = productIsAvailable;
          currentProduct.availableFrom = productAvailableFrom;
          currentProduct.shortDescription = productShortDescription;
          currentProduct.manufacturer = productManufacturer;

          _auth.editProduct(currentProduct).then((value) {
            Toast.show(
                AppLocalization.of(context).productEditedSuccessfully, context,
                textColor: Colors.white, backgroundColor: darkBlue());
            Navigator.pop(context);
          }).catchError((error) {
            Toast.show(error.toString(), context,
                textColor: Colors.white, backgroundColor: darkBlue());
          });
        }
      } else {
        Toast.show(AppLocalization.of(context).pleaseAddImage, context,
            textColor: Colors.white, backgroundColor: darkBlue());
      }
    }
  }

  bool validateDropdown() {
    if (selectedProductCategory != null && selectedProductCondition != null) {
      return true;
    } else {
      Toast.show(
          AppLocalization.of(context).pleaseSelectProductCategoryAndCondition,
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
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
      title: "Available",
    );
  }

  Widget getAvailableFromField() {
    return Theme(
      data: Theme.of(context).copyWith(
          primaryColor: navyBlue,
          textTheme: TextTheme(
            button: TextStyle(color: navyBlue),
          ),
          colorScheme: ColorScheme(
            primary: navyBlue,
            primaryVariant: navyBlue,
            secondary: Colors.white,
            secondaryVariant: Colors.white,
            surface: Colors.white,
            background: whiteBackground,
            error: mateRad,
            brightness: Brightness.light,
            onPrimary: navyBlue,
            onBackground: Colors.white,
            onError: mateRad,
            onSecondary: Colors.white,
            onSurface: Colors.white,
          )),
      child: GestureDetector(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            firstDate: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            lastDate: DateTime(2101),
          ).then((value) {
            if (mounted) {
              setState(() {
                productAvailableFrom =
                    DateTime(value.year, value.month, value.day);
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
      ),
    );
  }

  void deleteProduct() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => ConfirmDelete(),
    );
    if (result) {
      _auth.deleteProduct(currentProduct.id).then((value) {
        Navigator.pop(context);
        Toast.show(
          AppLocalization.of(context).productDeletedSuccessfully,
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          duration: 3,
        );
      }).catchError((error) {
        Toast.show(error.toString(), context,
            backgroundColor: darkBlue(),
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG);
      });
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
    super.dispose();
  }
}
