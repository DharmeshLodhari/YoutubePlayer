import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
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
      setState(() {
        currentProduct = value;
        // asssigning to our edit controllers

        productTitleController.text = currentProduct.name;
        productDescriptionController.text = currentProduct.description;
        productPriceController.text = currentProduct.price;
        productManufacturerController.text = currentProduct.manufacturer;
        productShortDescriptionController.text =
            currentProduct.shortDescription;

        productImagesFromServer.addAll(currentProduct.serverImages);
        productName = currentProduct.name;
        productCategory = currentProduct.category;
        debugPrint("product catagory : " + currentProduct.category);
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
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            title: Center(child: Text(AppLocalization.of(context).editProduct)),
            backgroundColor: darkBlue()),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    checkImageLimitForServerImage()
                        ? viewServerImages()
                        : Container(),
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
                    SizedBox(
                      height: 10,
                    ),
                    getProductConditionField(),
                    SizedBox(height: 10),
                    getIsAvailableField(),
                    SizedBox(height: 10),
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
        ),
      ),
    );
    //
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
      color: lightBlue(),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productLocalImages.length + 1,
        itemBuilder: (context, index) => Container(
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
      color: lightBlue(),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImagesFromServer.length,
        itemBuilder: (context, index) =>
            Container(child: showServerImage(index)),
      ),
    );
  }

  Widget addImageButton() {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: darkBlue()),
          borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add),
            Text(AppLocalization.of(context).addImage),
          ],
        ),
        onTap: () {
          ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
            setState(() {
              productLocalImages.add(value);
            });
          });
        },
      ),
    );
  }

  Widget showLocalImage(int index) {
    return Stack(
      children: <Widget>[
        Container(
          height: 80,
          width: 80,
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: FileImage(
                  productLocalImages[index],
                ),
                fit: BoxFit.fill),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            padding: EdgeInsets.only(right: 6, top: 8),
            alignment: Alignment.topRight,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                productLocalImages.removeAt(index);
              });
            },
          ),
        )
      ],
    );
  }

  Widget showServerImage(int index) {
    return Stack(
      children: <Widget>[
        Container(
          height: 80,
          width: 80,
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: NetworkImage(
                  productImagesFromServer[index],
                ),
                fit: BoxFit.fill),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            padding: EdgeInsets.only(right: 6, top: 8),
            alignment: Alignment.topRight,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              var imageId =
                  currentProduct.getImageId(productImagesFromServer[index]);
              _auth.deleteProductOrServiceImage(imageId).then((value) {
                if (value) {
                  setState(() {
                    productImagesFromServer.removeAt(index);
                  });
                }
              }).catchError((error) {
                debugPrint("ERROR" + error.toString());
              });
            },
          ),
        )
      ],
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
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      controller: productTitleController,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).productName,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
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
    return TextFormField(
      cursorColor: darkBlue(),
      controller: productDescriptionController,
      autofocus: false,
      obscureText: false,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).description,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      onChanged: (val) {
        productDescription = val;
      },
    );
  }

  Widget getProductShortDescription() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      controller: productShortDescriptionController,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).shortDescription,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
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
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<ProductCategory>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Text(AppLocalization.of(context).selectCategory),
          value: selectedProductCategory,
          onChanged: (ProductCategory value) {
            setState(() {
              selectedProductCategory = value;
              productCategory = selectedProductCategory.name;
            });
          },
          items: productCategories.map((ProductCategory category) {
            return DropdownMenuItem<ProductCategory>(
              value: category,
              child: Text(
                category.name,
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getManufacturerField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      controller: productManufacturerController,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).manufacturer,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterManufacturerName;
      },
      onTap: () async {},
      onChanged: (val) {
        productManufacturer = val;
      },
    );
  }

  Widget getProductConditionField() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.only(bottom: 16, right: 8, left: 8),
        width: double.infinity,
        child: DropdownButton<ProductCondition>(
          underline: Divider(
            color: Colors.transparent,
          ),
          isExpanded: true,
          hint: Text(AppLocalization.of(context).productCondition),
          value: selectedProductCondition,
          onChanged: (ProductCondition value) {
            setState(() {
              selectedProductCondition = value;
              productCondition = selectedProductCondition.name;
            });
          },
          items: conditions.map((ProductCondition productCondition) {
            return DropdownMenuItem<ProductCondition>(
                value: productCondition,
                child: ListTile(
                  dense: true,
                  title: Text(productCondition.name),
                  subtitle: Text(productCondition.description),
                ));
          }).toList(),
        ),
      ),
    );
  }

  Widget getAmountField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      controller: productPriceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Container(
            width: 20,
            child: Center(
              child: Text(
                worldCurrencies[userBloc.user.currency],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).price,
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
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
            child: MaterialButton(
                elevation: 4.0,
                textColor: Colors.white,
                color: Colors.red,
                height: 50,
                child: Text(AppLocalization.of(context).delete),
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
            child: MaterialButton(
                elevation: 4.0,
                textColor: Colors.white,
                color: darkBlue(),
                height: 50,
                child: Text(AppLocalization.of(context).update),
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
    return Row(
      children: <Widget>[
        Checkbox(
          value: productIsAvailable,
          activeColor: Colors.white,
          checkColor: darkBlue(),
          onChanged: (value) {
            setState(() {
              productIsAvailable = value;
            });
          },
        ),
        Text(
          AppLocalization.of(context).isAvailable + " ? ",
          style: TextStyle(
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget getAvailableFromField() {
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
          setState(() {
            productAvailableFrom = DateTime(value.year, value.month, value.day);
          });
        }).catchError((error) {});
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppLocalization.of(context).availableFrom),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    productAvailableFrom.toString().substring(0, 10),
                    style: TextStyle(
                      color: darkBlue(),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
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
}
