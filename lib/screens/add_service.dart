import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

class AddService extends StatefulWidget {
  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  ServiceCatagory selectedServiceCategory;
  ProductCondition selectedProductCondition;

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<File> serviceImages = List<File>();
  String serviceName = "";
  String serviceShortDescription = "";
  String serviceDescription = "";
  String serviceCategory = "";
  String serviceCondition = "";
  String servicePrice = "";
  bool serviceIsAvailable = false;
  DateTime serviceAvailableFrom = DateTime.now();

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
            title: Center(child: Text("Add Service")),
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
                    SizedBox(
                      height: 10,
                    ),
                    getAmountField(),
                    SizedBox(height: 10),
                    getCategoryField(),
                    SizedBox(height: 10),
                    getIsAvailableField(),
                    SizedBox(height: 10),
                    getAvailableFromField(),
                    SizedBox(height: 10),
                    getServiceShortDescription(),
                    SizedBox(height: 10),
                    getServiceDescription(),
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
        itemCount: serviceImages.length + 1,
        itemBuilder: (context, index) => Container(
          child: index != serviceImages.length
              ? showImage(index)
              : serviceImages.length != imageCount ? addImageButton() : null,
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
              serviceImages.add(value);
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
                  serviceImages[index],
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
                serviceImages.removeAt(index);
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
          hintText: "Enter service name",
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
        return "Please Enter Service Name";
      },
      onTap: () async {},
      onChanged: (val) {
        serviceName = val;
      },
    );
  }

  Widget getServiceShortDescription() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Short Description",
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
        return "Short description";
      },
      onTap: () async {},
      onChanged: (val) {
        serviceShortDescription = val;
      },
    );
  }

  Widget getServiceDescription() {
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
          hintText: "Describe your service hear....",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      onChanged: (val) {
        serviceDescription = val;
      },
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Description Must Not empty";
      },
    );
  }

  Widget getCategoryField() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<ServiceCatagory>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Text("Select Category"),
          value: selectedServiceCategory,
          onChanged: (ServiceCatagory value) {
            setState(() {
              selectedServiceCategory = value;
              serviceCategory = selectedServiceCategory.name;
            });
          },
          items: serviceCategories.map((ServiceCatagory category) {
            return DropdownMenuItem<ServiceCatagory>(
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

  Widget getAmountField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefix: Container(
            margin: EdgeInsets.only(right: 10, left: 4),
            width: 22,
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
          hintText: "Price of the Service",
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
            servicePrice = double.parse(val).toString();
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
            addService();
          }),
    );
  }

  void addService() {
    if (_formKey.currentState.validate()) {
      if (serviceImages.length >= 1) {
        if (validateDropdown()) {
          Service service = Service();
          service.localImages = serviceImages;
          service.name = serviceName;
          service.shortDescription = serviceShortDescription;
          service.description = serviceDescription;
          service.category = serviceCategory;
          service.price = servicePrice;
          service.availableFrom = serviceAvailableFrom;
          service.isAvailable = serviceIsAvailable;

          _auth.addService(service).then((value) {
            Navigator.pop(context);
            Toast.show(
              "Service Added Successfully",
              context,
              textColor: Colors.white,
              backgroundColor: darkBlue(),
              duration: 3,
            );
          }).catchError((error) {
            Toast.show(error.toString(), context,
                textColor: Colors.white,
                backgroundColor: darkBlue(),
                duration: 5);
          });
        }
      } else {
        Toast.show("Please add Image of Service ", context,
            textColor: Colors.white, backgroundColor: darkBlue());
      }
    }
  }

  bool validateDropdown() {
    if (selectedServiceCategory != null) {
      return true;
    } else {
      Toast.show("Please Select Service Catagory", context,
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
          value: serviceIsAvailable,
          activeColor: Colors.white,
          checkColor: darkBlue(),
          onChanged: (value) {
            setState(() {
              serviceIsAvailable = value;
            });
          },
        ),
        Text(
          " is Available? ",
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
            serviceAvailableFrom = DateTime(value.year, value.month, value.day);
          });
        }).catchError((error) {});
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Available From"),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    serviceAvailableFrom.toString().substring(0, 10),
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
}
