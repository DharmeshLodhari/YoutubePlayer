import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  Category selectedCategory;
  ProductCondition selectedProductCondition;

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<File> productImages = List<File>();
  String productName = "";
  String productDescription = "";
  String productCategory = "";
  String productCondition = "";
  String productPrice = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Add Product")),
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
                    addImages(),
                    SizedBox(
                      height: 10,
                    ),
                    addTitleField(),
                    SizedBox(height: 10),
                    getProductDescription(),
                    SizedBox(height: 10),
                    getCategoryField(),
                    SizedBox(
                      height: 10,
                    ),
                    getProductConditionField(),
                    SizedBox(
                      height: 10,
                    ),
                    getAmountField(),
                    SizedBox(height: 10),
                    getSubmitButton(),
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
    if (Platform.isAndroid) {
      return Text("");
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }
  }

  Widget addImages() {
    return Container(
      height: 100,
      color: lightBlue(),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length + 1,
        itemBuilder: (context, index) => Container(
          child: index != productImages.length
              ? showImage(index)
              : productImages.length != imageCount ? addImageButton() : null,
        ),
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
            Text("Add Image"),
          ],
        ),
        onTap: () {
          ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
            setState(() {
              productImages.add(value);
            });
          });
        },
      ),
    );
  }

  Widget showImage(int index) {
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
                  productImages[index],
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
                productImages.removeAt(index);
              });
            },
          ),
        )
      ],
    );
  }

  Widget addTitleField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            Icons.card_travel,
            color: darkBlue(),
          ),
          hintText: "Enter product name",
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
        return "Please Enter Product Name";
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
      autofocus: false,
      obscureText: false,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          hintText: "Describe your item hear....",
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

  Widget getCategoryField() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<Category>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Text("Select Category"),
          value: selectedCategory,
          onChanged: (Category value) {
            setState(() {
              selectedCategory = value;
              productCategory = selectedCategory.name;
            });
          },
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: <Widget>[
                  category.icon,
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    category.name,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
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
          hint: Text("Select item Condition"),
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
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.attach_money,
            color: darkBlue(),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: "Price of the product",
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
            return "Please Enter Valid amount";
          }
        }
        return "Please Enter Valid amount";
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
          elevation: 4.0,
          textColor: Colors.white,
          color: darkBlue(),
          height: 50,
          child: Text("Add"),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            addProduct();
          }),
    );
  }

  void addProduct() {
    if (_formKey.currentState.validate()) {
      if (productImages.length >= 1) {
        if (validateDropdown()) {
          Product product = Product();
          product.images = productImages;
          product.title = productName;
          product.description = productDescription;
          product.category = productCategory;
          product.condition = productCondition;
          product.price = productPrice;

          //TODO : call addProduct API
          _auth.addProduct(product).then((value) {
            Toast.show("Product Added Successfully", context,
                textColor: Colors.white, backgroundColor: darkBlue());
            Navigator.pop(context);
          }).catchError((error) {
            Toast.show(error.toString(), context,
                textColor: Colors.white, backgroundColor: darkBlue());
          });
        }
      } else {
        Toast.show("Please add Image of Product ", context,
            textColor: Colors.white, backgroundColor: darkBlue());
      }
    }
  }

  bool validateDropdown() {
    if (selectedCategory != null && selectedProductCondition != null) {
      return true;
    } else {
      Toast.show("Please Select Product Catagory and Condition", context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
      return false;
    }
  }
}
