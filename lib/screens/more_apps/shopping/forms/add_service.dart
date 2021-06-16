import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../shopping_auth.dart';

class AddService extends StatefulWidget {
  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  ServiceCatagory selectedServiceCategory;
  ProductCondition selectedProductCondition;

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<PickedFile> serviceImages = List<PickedFile>();
  String serviceName = "";
  String serviceShortDescription = "";
  String serviceDescription = "";
  String serviceCategory = "";
  String serviceCondition = "";
  String servicePrice = "";
  bool serviceIsAvailable = false;
  DateTime serviceAvailableFrom = DateTime.now();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
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
        "Add service",
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
              crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget addImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != serviceImages.length
              ? showImage(index)
              : serviceImages.length != imageCount
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
                  child: Text(AppLocalization.of(context).gallery),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().getImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          String croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          serviceImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
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
                    File(serviceImages[index].path),
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
                serviceImages.removeAt(index);
              });
            },
          ),
        )
      ],
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Service name",
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
    return CustomizedTextFormField(
      labelText: "Short description",
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
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context).description,
      onChanged: (val) {
        serviceDescription = val;
      },
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).descriptionMustNotEmpty;
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
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
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
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        addService();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add service",
    );
  }

  void addService() {
    if (_formKey.currentState.validate()) {
      if (serviceImages.length >= 1) {
        if (validateDropdown()) {
          Service service = Service();
          service.localImages =
              serviceImages.map((file) => File(file.path)).toList();
          service.name = serviceName;
          service.shortDescription = serviceShortDescription;
          service.description = serviceDescription;
          service.category = serviceCategory;
          service.price = moneyInputNormalizer(servicePrice).toString();
          service.availableFrom = serviceAvailableFrom;
          service.isAvailable = serviceIsAvailable;

          _auth.addService(service).then((value) {
            Navigator.pop(context);
            Toast.show(
              AppLocalization.of(context).serviceAddedSuccessfully,
              context,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              duration: 3,
            );
          }).catchError((error) {
            Toast.show(error.toString(), context,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                duration: 5);
          });
        }
      } else {
        Toast.show(
          AppLocalization.of(context).pleaseAddImage,
          context,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
  }

  bool validateDropdown() {
    if (selectedServiceCategory != null) {
      return true;
    } else {
      Toast.show(AppLocalization.of(context).selectCategory, context,
          backgroundColor: Colors.black,
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
