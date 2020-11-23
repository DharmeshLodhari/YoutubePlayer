import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/more_apps/property/models/PropertyType.dart';
import 'package:Slydo/screens/more_apps/property/utils/utils.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;
  PropertyType selectedPropertyType;

  ProductCondition selectedProductCondition;

  int bedroomCount = 0;
  int bathroomCount = 0;
  int livingRoomCount = 0;

  List<String> cities = ["Lagos", "Kano", "Ibadan", "Benin City", "Abuja"];

  bool amenityIsLaundryAvailable = false;
  bool amenityIsACAvailable = false;
  bool amenityIsHeatingAvailable = false;
  bool amenityIsParkingAvailable = false;
  bool amenityIsGatedEntryAvailable = false;
  bool amenityIsDoormanAvailable = false;
  bool amenityIsGymAvailable = false;
  bool amenityIsPoolAvailable = false;
  bool amenityIsDishwasherAvailable = false;

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<PickedFile> propertyImages = List<PickedFile>();
  String propertyName = "";
  String propertyDescription = "";
  String propertyAddressLineOne = "";
  String propertyAddressLineTwo = "";
  String propertyPinCode = "";
  String propertyCity = "";
  String propertyCategory = "";
  String propertyCondition = "";
  String propertyPrice = "";
  String propertyManufacturer = "";
  bool propertyAvailableImmediately = false;
  DateTime propertyAvailableFrom = DateTime.now();

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
        "Add property",
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
                Row(
                  children: <Widget>[
                    Expanded(child: getPropertyType()),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(child: getBedroomCountField()),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: getBathroomCountField(),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: getLivingRoomCountField(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                getAmenityField(),
                SizedBox(height: 16),
                getAmountField(),
                SizedBox(height: 16),
                getPropertyAddressLineOne(),
                SizedBox(height: 10),
                getPropertyAddressLineTwo(),
                SizedBox(height: 10),
                getPropertyPinCode(),
                SizedBox(height: 10),
                getPropertyCity(),
                SizedBox(height: 16),
                getIsAvailableImmediately(),
                SizedBox(height: 16),
                propertyAvailableImmediately
                    ? Container()
                    : getAvailableFromField(),
                propertyAvailableImmediately
                    ? Container()
                    : SizedBox(height: 10),
                getPropertyDescription(),
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
        itemCount: propertyImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != propertyImages.length
              ? showImage(index)
              : propertyImages.length != imageCount
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
                  child: Text(AppLocalization.of(context).gallary),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().getImage(source: imageSource).then((value) {
        if (value != null) {
          setState(() {
            propertyImages.add(value);
          });
        }
      });
    }
  }

  Widget showImage(int index) {
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
                      File(propertyImages[index].path),
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
                  propertyImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Property name",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter property name";
      },
      onChanged: (val) {
        propertyName = val;
      },
    );
  }

  Widget getPropertyAddressLineOne() {
    return CustomizedTextFormField(
      labelText: "Address line 1",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter address line 1";
      },
      onChanged: (val) {
        propertyAddressLineOne = val;
      },
    );
  }

  Widget getPropertyAddressLineTwo() {
    return CustomizedTextFormField(
      labelText: "Address line 2",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter address line 2";
      },
      onChanged: (val) {
        propertyAddressLineTwo = val;
      },
    );
  }

  Widget getPropertyPinCode() {
    return CustomizedTextFormField(
      labelText: "Pincode",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter pincode";
      },
      onChanged: (val) {
        propertyPinCode = val.toString();
      },
    );
  }

  Widget getPropertyCity() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "City",
      child: ListTile(
        dense: true,
        title: Text(
          propertyCity != null ? propertyCity : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectPropertyCity();
        },
      ),
    );
  }

  void selectPropertyCity() async {
    final city = await showDialog<String>(
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
                        children: cities.map<Widget>((city) {
                          if (propertyCity == city) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  city,
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
                                  Navigator.pop(context, city);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              city,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, city);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (city != null) {
      propertyCity = city;
      setState(() {});
    }
  }

  Widget getPropertyDescription() {
    return CustomizedTextFormField(
      maxLines: 5,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter description";
      },
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context).description,
      onChanged: (val) {
        propertyDescription = val;
      },
    );
  }

  Widget getPropertyType() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Type",
      child: ListTile(
        dense: true,
        title: Text(
          selectedPropertyType != null ? selectedPropertyType.name : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectPropertyType();
        },
      ),
    );
  }

  Widget getBedroomCountField() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Bedroom",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              bedroomCount.toString(),
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
          selectBedroomCount();
        },
      ),
    );
  }

  Widget getBathroomCountField() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Bathroom",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              bathroomCount.toString(),
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
          selectBathroomCount();
        },
      ),
    );
  }

  Widget getLivingRoomCountField() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Living room",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              livingRoomCount.toString(),
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
          selectLivingRoomCount();
        },
      ),
    );
  }

  void selectPropertyType() async {
    final pressedCategory = await showDialog<PropertyType>(
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
                        children: propertyTypes.map<Widget>((category) {
                          if (selectedPropertyType == category) {
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
                              softWrap: false,
                              overflow: TextOverflow.fade,
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
      selectedPropertyType = pressedCategory;
      propertyCategory = selectedPropertyType.name;
      setState(() {});
    }
  }

  void selectBedroomCount() async {
    final count = await showDialog<int>(
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
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: quantity.map<Widget>((count) {
                          if (bedroomCount == count) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, count);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, count);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (count != null) {
      bedroomCount = count;
      setState(() {});
    }
  }

  void selectBathroomCount() async {
    final count = await showDialog<int>(
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
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: quantity.map<Widget>((count) {
                          if (bathroomCount == count) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, count);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, count);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (count != null) {
      bathroomCount = count;
      setState(() {});
    }
  }

  void selectLivingRoomCount() async {
    final count = await showDialog<int>(
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
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: quantity.map<Widget>((count) {
                          if (livingRoomCount == count) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, count);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  count.toString(),
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, count);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (count != null) {
      livingRoomCount = count;
      setState(() {});
    }
  }

  Widget getIsAvailableImmediately() {
    return CustomizedCheckBoxField(
      onTap: () {
        propertyAvailableImmediately = !propertyAvailableImmediately;
        setState(() {});
      },
      isChecked: propertyAvailableImmediately,
      title: "Is available immediately",
    );
  }

  Widget getAmenityField() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Amenities",
            style: TextStyle(color: darkGrey, fontSize: 14),
          ),
          SizedBox(
            height: 12,
          ),
          Wrap(
            direction: Axis.horizontal,
            runSpacing: 12,
            spacing: 16,
            children: [
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsLaundryAvailable = !amenityIsLaundryAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsLaundryAvailable,
                  title: "Laundry"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsACAvailable = !amenityIsACAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsACAvailable,
                  title: "A/C"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsHeatingAvailable = !amenityIsHeatingAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsHeatingAvailable,
                  title: "Heating"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsParkingAvailable = !amenityIsParkingAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsParkingAvailable,
                  title: "Parking"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsGatedEntryAvailable =
                        !amenityIsGatedEntryAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsGatedEntryAvailable,
                  title: "Gated entry"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsDoormanAvailable = !amenityIsDoormanAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsDoormanAvailable,
                  title: "Doorman"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsGymAvailable = !amenityIsGymAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsGymAvailable,
                  title: "Gym"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsPoolAvailable = !amenityIsPoolAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsPoolAvailable,
                  title: "Pool"),
              CustomizedCheckBoxField(
                  onTap: () {
                    amenityIsDishwasherAvailable =
                        !amenityIsDishwasherAvailable;
                    setState(() {});
                  },
                  isChecked: amenityIsDishwasherAvailable,
                  title: "Dishwasher"),
            ],
          )
        ]);
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).price,
      keyboardType: TextInputType.number,
      isAmount: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            propertyPrice = double.parse(val).toString();
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
        addProperty();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add property",
    );
  }

  void addProperty() async {
    // if (_formKey.currentState.validate()) {
    // if (propertyImages.length >= 1) {
    // if (validateDropdown()) {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.pop(context);
    // Product product = Product();
    // product.localImages =
    //     propertyImages.map((file) => File(file.path)).toList();
    // product.name = propertyName;
    // product.description = propertyDescription;
    // product.shortDescription = propertyShortDescription;
    // product.category = propertyCategory;
    // product.condition = propertyCondition;
    // product.price = propertyPrice;
    // product.isAvailable = propertyAvailableImmediately;
    // product.manufacturer = propertyManufacturer;
    // product.availableFrom = propertyAvailableFrom;

    // _auth.addProduct(product).then((value) {
    //   Navigator.pop(context);
    //   Toast.show(
    //     AppLocalization.of(context).productAddedSuccessfully,
    //     context,
    //     textColor: Colors.white,
    //     backgroundColor: darkBlue(),
    //     duration: 3,
    //   );
    // }).catchError((error) {
    //   debugPrint(error.toString());
    //   Toast.show(error.toString(), context,
    //       textColor: Colors.white, backgroundColor: darkBlue());
    // });
    // }
    // } else {
    //   Toast.show(AppLocalization.of(context).pleaseAddImage, context,
    //       textColor: Colors.white, backgroundColor: darkBlue());
    // }
    // }
  }

  bool validateDropdown() {
    if (selectedPropertyType != null && propertyCity != null) {
      return true;
    } else if (selectedPropertyType == null && propertyCity == null) {
      Toast.show("Please select Property type and Property City", context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
      return false;
    } else if (selectedPropertyType == null && propertyCity != null) {
      Toast.show("Please select Property type", context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
      return false;
    } else {
      Toast.show("Please select Property city", context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
          gravity: Toast.CENTER);
      return false;
    }
  }

  Widget getAvailableFromField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          propertyAvailableFrom = DateTime(value.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        titleColor: darkGrey,
        title: "Available from",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(propertyAvailableFrom),
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
