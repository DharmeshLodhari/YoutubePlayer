import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class EditService extends StatefulWidget {
  var arguments;
  EditService({this.arguments});
  @override
  _EditServiceState createState() => _EditServiceState(arguments: arguments);
}

class _EditServiceState extends State<EditService> {
  var arguments;
  _EditServiceState({this.arguments});
  final _auth = AuthService();
  UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();

  String serviceId;
  Service currentService = Service();

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<File> serviceLocalImages = List<File>();
  List<String> serviceImagesFromServer = List<String>();
  String serviceName = "";
  String serviceDescription = "";
  String serviceCategory = "";
  String serviceShortDescription = "";
  String servicePrice = "";
  ServiceCatagory selectedServiceCategory;
  bool serviceIsAvailable = false;
  DateTime serviceAvailableFrom = DateTime.now();

  //text editing controllers for the edit fields
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescriptionController = TextEditingController();
  TextEditingController serviceShortDescriptionController =
      TextEditingController();
  TextEditingController servicePriceController = TextEditingController();

  @override
  void initState() {
    serviceId = arguments['serviceId'];
    fetchProduct();
    super.initState();
  }

  void fetchProduct() {
    // assigning the dropdown
    serviceCategories.forEach((catagory) {
      if (catagory.name == currentService.category) {
        selectedServiceCategory = catagory;
      }
    });

    //fetchProductFrom id to edit
    _auth.getService(serviceId).then((value) {
      if (mounted) {
        setState(() {
          currentService = value;
          // asssigning to our edit controllers

          serviceTitleController.text = currentService.name;
          serviceDescriptionController.text = currentService.description;
          servicePriceController.text = currentService.price;
          serviceShortDescriptionController.text =
              currentService.shortDescription;

          serviceImagesFromServer.addAll(currentService.serverImages);
          serviceName = currentService.name;
          serviceCategory = currentService.category;
          servicePrice = currentService.price;
          serviceDescription = currentService.description;
          serviceIsAvailable = currentService.isAvailable;
          serviceAvailableFrom = currentService.availableFrom;
          serviceShortDescription = currentService.shortDescription;

          // assigning the dropdown from currentProduct
          serviceCategories.forEach((catagory) {
            if (catagory.name == currentService.category) {
              selectedServiceCategory = catagory;
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
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            title: Center(child: Text(AppLocalization.of(context).editService)),
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
        itemCount: serviceLocalImages.length + 1,
        itemBuilder: (context, index) => Container(
          child: index != serviceLocalImages.length
              ? showLocalImage(index)
              : serviceLocalImages.length + serviceImagesFromServer.length !=
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
        itemCount: serviceImagesFromServer.length,
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
          pickImage();
        },
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
              serviceLocalImages.add(value);
            });
          }
        }
      });
    }
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
                  serviceLocalImages[index],
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
              if (mounted) {
                setState(() {
                  serviceLocalImages.removeAt(index);
                });
              }
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
                  serviceImagesFromServer[index],
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
                  currentService.getImageId(serviceImagesFromServer[index]);
              _auth.deleteProductOrServiceImage(imageId).then((value) {
                if (value) {
                  if (mounted) {
                    setState(() {
                      serviceImagesFromServer.removeAt(index);
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
    );
  }

  // decide that serverImage List is need to be show or not
  bool checkImageLimitForServerImage() {
    if (serviceLocalImages.length + serviceImagesFromServer.length !=
            imageCount ||
        serviceImagesFromServer.length != 0) {
      return true;
    }
    return false;
  }

  // decide that localImage List is need to be show or not
  bool checkImageLimitForLocalImage() {
    if (serviceLocalImages.length + serviceImagesFromServer.length !=
            imageCount ||
        serviceLocalImages.length != 0) {
      return true;
    }
    return false;
  }

  Widget addTitleField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      controller: serviceTitleController,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).enterServiceName,
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
        return AppLocalization.of(context).pleaseEnterServiceName;
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
      controller: serviceShortDescriptionController,
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
      controller: serviceDescriptionController,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).describeYourServiceHere,
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
          hint: Text(AppLocalization.of(context).selectCategory),
          value: selectedServiceCategory,
          onChanged: (ServiceCatagory value) {
            if (mounted) {
              setState(() {
                selectedServiceCategory = value;
                serviceCategory = selectedServiceCategory.name;
              });
            }
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
      controller: servicePriceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Container(
            width: 20,
            child: Center(
              child: Text(
                worldCurrencies[userBloc.user.currency],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalization.of(context).priceOfService,
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
            return AppLocalization.of(context).invalidAmount;
          }
        }
        return AppLocalization.of(context).invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
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
      if (serviceLocalImages.length >= 0) {
        if (validateDropdown()) {
          // setting updated value
          currentService.name = serviceName;
          currentService.description = serviceDescription;
          currentService.localImages = serviceLocalImages;
          currentService.serverImages = serviceImagesFromServer;
          currentService.category = serviceCategory;
          currentService.shortDescription = serviceShortDescription;
          currentService.price = servicePrice;
          currentService.isAvailable = serviceIsAvailable;
          currentService.availableFrom = serviceAvailableFrom;

          _auth.editService(currentService).then((value) {
            Toast.show(
                AppLocalization.of(context).serviceEditedSuccessfully, context,
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
    if (selectedServiceCategory != null) {
      return true;
    } else {
      Toast.show(AppLocalization.of(context).selectCategory, context,
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
            if (mounted) {
              setState(() {
                serviceIsAvailable = value;
              });
            }
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
          if (mounted) {
            setState(() {
              serviceAvailableFrom =
                  DateTime(value.year, value.month, value.day);
            });
          }
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

  void deleteProduct() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => ConfirmDelete(),
    );
    if (result) {
      _auth.deleteService(currentService.id).then((value) {
        Navigator.pop(context);
        Toast.show(
          AppLocalization.of(context).serviceDeletedSuccessfully,
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
    serviceTitleController.dispose();
    serviceDescriptionController.dispose();
    serviceShortDescriptionController.dispose();
    servicePriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
