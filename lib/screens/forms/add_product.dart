import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../utils/colors.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  ProductCategory selectedProductCategory;
  ProductCondition selectedProductCondition;

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<File> productImages = List<File>();
  String productName = "";
  String productDescription = "";
  String productShortDescription = "";
  String productCategory = "";
  String productCondition = "";
  String productPrice = "";
  String productManufacturer = "";
  bool productIsAvailable = false;
  DateTime productAvailableFrom = DateTime.now();

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
    // return SingleChildScrollView(
    //   child: Container(
    //     padding: EdgeInsets.symmetric(horizontal: 30),
    //     child: Center(
    //       child: Form(
    //         key: _formKey,
    //         child: Column(
    //           children: <Widget>[
    //             SizedBox(height: 10),
    //             addImages(),
    //             SizedBox(
    //               height: 10,
    //             ),
    //             addTitleField(),
    //             SizedBox(
    //               height: 10,
    //             ),
    //             getManufacturerField(),
    //             SizedBox(
    //               height: 10,
    //             ),
    //             getAmountField(),
    //             SizedBox(height: 10),
    //             getCategoryField(),
    //             SizedBox(
    //               height: 10,
    //             ),
    //             getProductConditionField(),
    //             SizedBox(height: 10),
    //             getIsAvailableField(),
    //             SizedBox(height: 10),
    //             getAvailableFromField(),
    //             SizedBox(height: 10),
    //             getProductShortDescription(),
    //             SizedBox(height: 10),
    //             getProductDescription(),
    //             SizedBox(height: 10),
    //             getSubmitButton(),
    //             SizedBox(height: 20),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                addImages(),
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
                SizedBox(height: 40),
                getSubmitButton(),
                SizedBox(height: 40),
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

  Widget addImages() {
    // return Container(
    //   height: 100,
    //   color: lightBlue(),
    //   child: ListView.builder(
    //     controller: _scrollController,
    //     scrollDirection: Axis.horizontal,
    //     itemCount: productImages.length + 1,
    //     itemBuilder: (context, index) => Container(
    //       child: index != productImages.length
    //           ? showImage(index)
    //           : productImages.length != imageCount ? addImageButton() : null,
    //     ),
    //   ),
    // );
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != productImages.length
              ? showImage(index)
              : productImages.length != imageCount ? addImageButton() : null,
        ),
      ),
    );
  }

  Widget addImageButton() {
    // return Container(
    //   margin: EdgeInsets.all(8.0),
    //   padding: EdgeInsets.all(8.0),
    //   decoration: BoxDecoration(
    //       color: Colors.white,
    //       border: Border.all(color: darkBlue()),
    //       borderRadius: BorderRadius.circular(5)),
    //   child: InkWell(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Icon(Icons.add),
    //         Text(AppLocalization.of(context).addImage),
    //       ],
    //     ),
    //     onTap: () {
    //       pickImage();
    //     },
    //   ),
    // );
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
          setState(() {
            productImages.add(value);
          });
        }
      });
    }
  }

  Widget showImage(int index) {
    // return Stack(
    //   children: <Widget>[
    //     Container(
    //       height: 80,
    //       width: 80,
    //       margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    //       decoration: BoxDecoration(
    //         border: Border.all(color: Colors.transparent),
    //         borderRadius: BorderRadius.circular(5),
    //         image: DecorationImage(
    //             image: FileImage(
    //               productImages[index],
    //             ),
    //             fit: BoxFit.fill),
    //       ),
    //     ),
    //     Positioned(
    //       right: 0,
    //       top: 0,
    //       child: IconButton(
    //         padding: EdgeInsets.only(right: 6, top: 8),
    //         alignment: Alignment.topRight,
    //         icon: Icon(
    //           Icons.close,
    //           color: Colors.white,
    //           size: 20,
    //         ),
    //         onPressed: () {
    //           setState(() {
    //             productImages.removeAt(index);
    //           });
    //         },
    //       ),
    //     )
    //   ],
    // );
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
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      productImages[index],
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
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   obscureText: false,
    //   decoration: InputDecoration(
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).productName,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       return null;
    //     }
    //     return AppLocalization.of(context).pleaseEnterProductName;
    //   },
    //   onTap: () async {},
    //   onChanged: (val) {
    //     productName = val;
    //   },
    // );
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).productName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterProductName;
      },
      onChanged: (val) {
        productName = val;
      },
    );
  }

  Widget getProductShortDescription() {
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   obscureText: false,
    //   decoration: InputDecoration(
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).shortDescription,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       return null;
    //     }
    //     return AppLocalization.of(context).shortDescription;
    //   },
    //   onChanged: (val) {
    //     productShortDescription = val;
    //   },
    // );
    return CustomizedTextFormField(
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).shortDescription;
      },
      onChanged: (val) {
        productShortDescription = val;
      },
    );
  }

  Widget getProductDescription() {
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   obscureText: false,
    //   maxLines: 5,
    //   textCapitalization: TextCapitalization.sentences,
    //   decoration: InputDecoration(
    //       isDense: true,
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).description,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   onChanged: (val) {
    //     productDescription = val;
    //   },
    // );
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context).description,
      onChanged: (val) {
        productDescription = val;
      },
    );
  }

  Widget getCategoryField() {
    // return Card(
    //   margin: EdgeInsets.all(0),
    //   child: Container(
    //     padding: EdgeInsets.all(8),
    //     width: double.infinity,
    //     child: DropdownButton<ProductCategory>(
    //       isExpanded: true,
    //       underline: Divider(
    //         color: Colors.transparent,
    //       ),
    //       hint: Text(AppLocalization.of(context).category),
    //       value: selectedProductCategory,
    //       onChanged: (ProductCategory value) {
    //         setState(() {
    //           selectedProductCategory = value;
    //           productCategory = selectedProductCategory.name;
    //         });
    //       },
    //       items: productCategories.map((ProductCategory category) {
    //         return DropdownMenuItem<ProductCategory>(
    //           value: category,
    //           child: Text(
    //             category.name,
    //             style: TextStyle(color: Colors.black),
    //           ),
    //         );
    //       }).toList(),
    //     ),
    //   ),
    // );
    return CustomizedDropDownField(
      title: AppLocalization.of(context).category,
      child: DropdownButton<ProductCategory>(
        isExpanded: true,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: selectedProductCategory,
        onChanged: (ProductCategory value) {
          selectedProductCategory = value;
          productCategory = selectedProductCategory.name;
          setState(() {});
        },
        style: TextStyle(
            color: blackFont, fontSize: 16, fontWeight: FontWeight.w400),
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
    // return Card(
    //   margin: EdgeInsets.all(0),
    //   child: Container(
    //     padding: EdgeInsets.only(bottom: 16, right: 8, left: 8),
    //     width: double.infinity,
    //     child: DropdownButton<ProductCondition>(
    //       underline: Divider(
    //         color: Colors.transparent,
    //       ),
    //       isExpanded: true,
    //       hint: Text(AppLocalization.of(context).productCondition),
    //       value: selectedProductCondition,
    //       onChanged: (ProductCondition value) {
    //         setState(() {
    //           selectedProductCondition = value;
    //           productCondition = selectedProductCondition.name;
    //         });
    //       },
    //       items: conditions.map((ProductCondition productCondition) {
    //         return DropdownMenuItem<ProductCondition>(
    //             value: productCondition,
    //             child: ListTile(
    //               dense: true,
    //               title: Text(productCondition.name),
    //               subtitle: Text(productCondition.description),
    //             ));
    //       }).toList(),
    //     ),
    //   ),
    // );

    return CustomizedDropDownField(
      title: "Product condition",
      child: DropdownButton<ProductCondition>(
        underline: Divider(
          color: Colors.transparent,
        ),
        isExpanded: true,
        value: selectedProductCondition,
        onChanged: (ProductCondition value) {
          selectedProductCondition = value;
          productCondition = selectedProductCondition.name;
          setState(() {});
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
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   obscureText: false,
    //   decoration: InputDecoration(
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).manufacturer,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       return null;
    //     }
    //     return AppLocalization.of(context).pleaseEnterManufacturerName;
    //   },
    //   onTap: () async {},
    //   onChanged: (val) {
    //     productManufacturer = val;
    //   },
    // );
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).manufacturer,
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
    // return TextFormField(
    //   cursorColor: darkBlue(),
    //   autofocus: false,
    //   obscureText: false,
    //   keyboardType: TextInputType.number,
    //   decoration: InputDecoration(
    //       prefixIcon: Container(
    //         width: 20,
    //         child: Center(
    //           child: Text(
    //             worldCurrencies[userBloc.user.currency],
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //                 fontFamily: "Roboto",
    //                 fontSize: 22,
    //                 fontWeight: FontWeight.bold,
    //                 color: Colors.grey[600]),
    //           ),
    //         ),
    //       ),
    //       fillColor: Colors.white,
    //       filled: true,
    //       hintText: AppLocalization.of(context).price,
    //       labelStyle: TextStyle(
    //         color: Colors.black,
    //         fontSize: 16,
    //       ),
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.all(Radius.circular(4)),
    //           borderSide: BorderSide(
    //               width: 1, color: Colors.white, style: BorderStyle.solid))),
    //   onChanged: (val) {
    //     if (val.isNotEmpty) {
    //       try {
    //         productPrice = double.parse(val).toString();
    //       } catch (e) {
    //         Toast.show(e, context);
    //       }
    //     }
    //   },
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       try {
    //         double.parse(val);
    //         return null;
    //       } catch (e) {
    //         return AppLocalization.of(context).invalidAmount;
    //       }
    //     }
    //     return AppLocalization.of(context).pleaseEnterValidAmout;
    //   },
    // );
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).price,
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
        return AppLocalization.of(context).pleaseEnterValidAmout;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        addProduct();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add product",
    );
    // return ButtonTheme(
    //   minWidth: double.infinity,
    //   child: MaterialButton(
    //       elevation: 4.0,
    //       textColor: Colors.white,
    //       color: darkBlue(),
    //       height: 50,
    //       child: Text(AppLocalization.of(context).add),
    //       onPressed: () async {
    //         FocusScope.of(context).unfocus();
    //         addProduct();
    //       }),
    // );
  }

  void addProduct() {
    if (_formKey.currentState.validate()) {
      if (productImages.length >= 1) {
        if (validateDropdown()) {
          Product product = Product();
          product.localImages = productImages;
          product.name = productName;
          product.description = productDescription;
          product.shortDescription = productShortDescription;
          product.category = productCategory;
          product.condition = productCondition;
          product.price = productPrice;
          product.isAvailable = productIsAvailable;
          product.manufacturer = productManufacturer;
          product.availableFrom = productAvailableFrom;

          _auth.addProduct(product).then((value) {
            Navigator.pop(context);
            Toast.show(
              AppLocalization.of(context).productAddedSuccessfully,
              context,
              textColor: Colors.white,
              backgroundColor: darkBlue(),
              duration: 3,
            );
          }).catchError((error) {
            debugPrint(error.toString());
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
    // return Row(
    //   children: <Widget>[
    //     Checkbox(
    //       value: productIsAvailable,
    //       activeColor: Colors.white,
    //       checkColor: darkBlue(),
    //       onChanged: (value) {
    //         setState(() {
    //           productIsAvailable = value;
    //         });
    //       },
    //     ),
    //     Text(
    //       AppLocalization.of(context).isAvailable + " ? ",
    //       style: TextStyle(
    //         color: Colors.white,
    //       ),
    //     )
    //   ],
    // );
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
    // return GestureDetector(
    //   onTap: () {
    //     showDatePicker(
    //       context: context,
    //       initialDate: DateTime(
    //           DateTime.now().year, DateTime.now().month, DateTime.now().day),
    //       firstDate: DateTime(
    //           DateTime.now().year, DateTime.now().month, DateTime.now().day),
    //       lastDate: DateTime(2101),
    //     ).then((value) {
    //       setState(() {
    //         productAvailableFrom = DateTime(value.year, value.month, value.day);
    //       });
    //     }).catchError((error) {});
    //   },
    //   child: Card(
    //     child: Container(
    //       padding: EdgeInsets.all(8.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: <Widget>[
    //           Text(AppLocalization.of(context).availableFrom),
    //           Row(
    //             children: <Widget>[
    //               Icon(Icons.date_range),
    //               SizedBox(
    //                 width: 10,
    //               ),
    //               Text(
    //                 productAvailableFrom.toString().substring(0, 10),
    //                 style: TextStyle(
    //                   color: darkBlue(),
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               )
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return GestureDetector(
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          productAvailableFrom = DateTime(value.year, value.month, value.day);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
