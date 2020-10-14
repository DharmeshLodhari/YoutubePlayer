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
  List<PickedFile> serviceLocalImages = List<PickedFile>();
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
      currentService = value;
      // asssigning to our edit controllers

      serviceTitleController.text = currentService.name;
      serviceDescriptionController.text = currentService.description;
      servicePriceController.text = currentService.price;
      serviceShortDescriptionController.text = currentService.shortDescription;

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
      if (mounted) setState(() {});
    }).catchError((error) {
      Toast.show(
        error.toString(),
        context,
        backgroundColor: navyBlue,
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
        "Edit service",
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
                    ? SizedBox(height: 8)
                    : Container(),
                checkImageLimitForLocalImage() ? addLocalImages() : Container(),
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
                SizedBox(height: 16),
                getIsAvailableField(),
                SizedBox(height: 16),
                getAvailableFromField(),
                SizedBox(height: 10),
                getServiceShortDescription(),
                SizedBox(height: 10),
                getServiceDescription(),
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

  Widget addLocalImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceLocalImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
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
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceImagesFromServer.length,
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
      ImagePicker().getImage(source: imageSource).then((value) {
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
                    File(serviceLocalImages[index].path),
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
                      serviceImagesFromServer[index],
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
    return CustomizedTextFormField(
      controller: serviceTitleController,
      labelText: "Service name",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterServiceName;
      },
      onChanged: (val) {
        serviceName = val;
      },
    );
  }

  Widget getServiceShortDescription() {
    return CustomizedTextFormField(
      controller: serviceShortDescriptionController,
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).shortDescription;
      },
      onChanged: (val) {
        serviceShortDescription = val;
      },
    );
  }

  Widget getServiceDescription() {
    return CustomizedTextFormField(
      maxLines: 5,
      labelText: AppLocalization.of(context).description,
      controller: serviceDescriptionController,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (val) {
        serviceDescription = val;
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context).category,
      child: ListTile(
        dense: true,
        title: Text(
          selectedServiceCategory != null ? selectedServiceCategory.name : "",
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

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ServiceCatagory>(
        barrierDismissible: false,
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
                        children: serviceCategories.map<Widget>((category) {
                          if (selectedServiceCategory == category) {
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
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedServiceCategory = pressedCategory;
      serviceCategory = selectedServiceCategory.name;
      setState(() {});
    }
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      controller: servicePriceController,
      keyboardType: TextInputType.number,
      isAmount: true,
      labelText: "Price of service",
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
    return Row(
      children: <Widget>[
        Expanded(
          child: CurvedButton(
              textColor: Colors.white,
              text: AppLocalization.of(context).delete,
              backgroundColor: mateRad,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                deleteProduct();
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
    );
  }

  void editProduct() {
    if (_formKey.currentState.validate()) {
      if (serviceLocalImages.length >= 0) {
        if (validateDropdown()) {
          // setting updated value
          currentService.name = serviceName;
          currentService.description = serviceDescription;
          currentService.localImages =
              serviceLocalImages.map((file) => File(file.path)).toList();
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
    return CustomizedCheckBoxField(
      onTap: () {
        serviceIsAvailable = !serviceIsAvailable;
        setState(() {});
      },
      isChecked: serviceIsAvailable,
      title: "Available",
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
              serviceAvailableFrom =
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
              formatDate(serviceAvailableFrom),
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
