import 'dart:io';
import 'dart:typed_data';

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
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  Map<String, bool> propertyAmenities = {
    "Laundry": false,
    "A/C": false,
    "Heating": false,
    "Parking": false,
    "Gated entry": false,
    "Doorman": false,
    "Gym": false,
    "Pool": false,
    "Dishwasher": false,
  };

  Map<String, bool> propertyRentDuration = {
    "Short term": true,
    "Long term": false,
  };

  Map<String, bool> propertyPetPolicy = {
    "Dogs allowed": false,
    "Cats allowed": false
  };

  List<bool> isPropertyForSellOrRent = [true, false];
  bool isPropertyFurnished = false;
  bool isPropertyForLongTerm = true;

  int imageCount = 5;
  ScrollController _imageScrollController = ScrollController();
  ScrollController _videoScrollController = ScrollController();

  List<PickedFile> propertyImages = List<PickedFile>();
  List<PickedFile> propertyVideos = List<PickedFile>();
  List<Uint8List> propertyVideoThumbnail = List<Uint8List>();

  String propertyTagLine = "";
  String propertyDescription = "";
  String propertyAddressLineOne = "";
  String propertyAddressLineTwo = "";
  String propertyPassCode = "";
  String propertyCity = "";
  String propertyCategory = "";
  String propertyCondition = "";
  String propertyPrice = "";
  String propertyManufacturer = "";
  bool propertyAvailableImmediately = true;
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
                SizedBox(height: 10),
                addVideos(),
                SizedBox(height: 10),
                sellOrRentSwitch(),
                SizedBox(
                  height: 10,
                ),
                addTagNameField(),
                SizedBox(
                  height: 10,
                ),
                isPropertyForSellOrRent[1] ? getRentDuration() : Container(),
                isPropertyForSellOrRent[1] ? SizedBox(height: 10) : Container(),
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
                SizedBox(height: 10),
                getPropertyFurnitureDetailField(),
                isPropertyForSellOrRent[1] ? SizedBox(height: 10) : Container(),
                isPropertyForSellOrRent[1] ? getPetPolicyField() : Container(),
                SizedBox(height: 10),
                getAmountField(),
                SizedBox(height: 10),
                getPropertyAddressLineOne(),
                SizedBox(height: 10),
                getPropertyAddressLineTwo(),
                SizedBox(height: 10),
                getPropertyPassCode(),
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
                SizedBox(height: 20),
                getSubmitButton(),
                SizedBox(height: 30),
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
        controller: _imageScrollController,
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

  Widget addVideos() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _videoScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: propertyVideos.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != propertyVideos.length
              ? showVideo(index)
              : propertyVideos.length != imageCount
                  ? addVideoButton()
                  : null,
        ),
      ),
    );
  }

  Widget addVideoButton() {
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
                  SlydoAppIcon.movies_moreapps,
                  color: darkGrey,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "Add Video",
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
              ],
            ),
            onTap: () {
              pickVideo();
            },
          ),
        ),
      ),
    );
  }

  void pickVideo() async {
    final videoSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select video source"),
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

    if (videoSource != null) {
      ImagePicker().getVideo(source: videoSource).then((value) {
        if (value != null) {
          setState(() {
            propertyVideos.add(value);
            getVideoThumbnail(propertyVideos.length - 1);
          });
        }
      });
    }
  }

  Widget showVideo(int index) {
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
            child: index < propertyVideoThumbnail.length
                ? Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: MemoryImage(propertyVideoThumbnail[index]),
                          fit: BoxFit.fill),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: CircularLoadingIndicator(),
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
                  propertyVideos.removeAt(index);
                  propertyVideoThumbnail.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  void getVideoThumbnail(int index) async {
    final uInt8list = await VideoThumbnail.thumbnailData(
      video: propertyVideos[index].path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          100, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    propertyVideoThumbnail.add(uInt8list);

    setState(() {});
  }

  Widget addTagNameField() {
    return CustomizedTextFormField(
      labelText: "Tag line",
      hintText: "A beautiful lake side cottage",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter tag line";
      },
      onChanged: (val) {
        propertyTagLine = val;
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

  Widget getPropertyPassCode() {
    return CustomizedTextFormField(
      labelText: "Passcode",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "Please enter passcode";
      },
      onChanged: (val) {
        propertyPassCode = val.toString();
      },
    );
  }

  Widget sellOrRentSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Property for",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 30,
          child: Row(
            children: [
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                fillColor: navyBlue,
                borderColor: navyBlue,
                constraints: BoxConstraints.expand(
                    height: 30,
                    width: (MediaQuery.of(context).size.width - 45) / 2),
                selectedBorderColor: navyBlue,
                children: <Widget>[
                  sellButton(),
                  rentButton(),
                ],
                isSelected: isPropertyForSellOrRent,
                onPressed: (int index) {
                  if (index == 0) {
                    isPropertyForSellOrRent[0] = true;
                    isPropertyForSellOrRent[1] = false;
                  } else {
                    isPropertyForSellOrRent[0] = false;
                    isPropertyForSellOrRent[1] = true;
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sellButton() {
    return Container(
      child: Text(
        "Sell",
        style: TextStyle(
            fontWeight:
                isPropertyForSellOrRent[0] ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
            color: isPropertyForSellOrRent[0] ? Colors.white : blackFont),
      ),
    );
  }

  Widget rentButton() {
    return Container(
      child: Text(
        "Rent",
        style: TextStyle(
            fontWeight:
                isPropertyForSellOrRent[1] ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
            color: isPropertyForSellOrRent[1] ? Colors.white : blackFont),
      ),
    );
  }

  Widget getRentDuration() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Rent Duration",
      child: ListTile(
        dense: true,
        title: Text(
          getRentDurationSelection(),
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
          selectRentDuration();
        },
      ),
    );
  }

  String getRentDurationSelection() {
    return isPropertyForLongTerm ? "Long term" : "Short term";
  }

  void selectRentDuration() {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, rentDurationStateSetter) {
              return AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: isPropertyForLongTerm
                                ? selectedListItemBackgroundBlue
                                : Colors.white,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                "Long term",
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    color: isPropertyForLongTerm
                                        ? navyBlue
                                        : blackFont,
                                    fontSize: 16,
                                    fontWeight: isPropertyForLongTerm
                                        ? FontWeight.w600
                                        : FontWeight.w400),
                              ),
                              trailing: isPropertyForLongTerm
                                  ? Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    )
                                  : Container(
                                      width: 1,
                                    ),
                              onTap: () {
                                isPropertyForLongTerm = !isPropertyForLongTerm;
                                rentDurationStateSetter(() {});
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            color: isPropertyForLongTerm
                                ? Colors.white
                                : selectedListItemBackgroundBlue,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                "Short term",
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    color: isPropertyForLongTerm
                                        ? blackFont
                                        : navyBlue,
                                    fontSize: 16,
                                    fontWeight: isPropertyForLongTerm
                                        ? FontWeight.w400
                                        : FontWeight.w600),
                              ),
                              trailing: isPropertyForLongTerm
                                  ? Container(
                                      width: 1,
                                    )
                                  : Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    ),
                              onTap: () {
                                isPropertyForLongTerm = !isPropertyForLongTerm;
                                rentDurationStateSetter(() {});
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
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
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Amenity",
      child: ListTile(
        dense: true,
        title: Text(
          getAmenities(),
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
          selectAmenities();
        },
      ),
    );
  }

  String getAmenities() {
    String amenities = "";
    propertyAmenities.forEach((key, value) {
      if (value) {
        amenities += "$key, ";
      }
    });
    if (amenities.length > 2) {
      amenities = amenities.substring(0, amenities.length - 2);
    }
    return amenities;
  }

  void selectAmenities() {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, amenitiesStateSetter) {
              return AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                          children: [
                            Column(
                              children: propertyAmenities.entries
                                  .map<Widget>((entry) {
                                if (entry.value) {
                                  return Container(
                                    color: selectedListItemBackgroundBlue,
                                    child: ListTile(
                                      dense: true,
                                      title: Text(
                                        entry.key,
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
                                        propertyAmenities[entry.key] =
                                            !propertyAmenities[entry.key];
                                        amenitiesStateSetter(() {});
                                        setState(() {});
                                      },
                                    ),
                                  );
                                }
                                return ListTile(
                                  title: Text(
                                    entry.key,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    propertyAmenities[entry.key] =
                                        !propertyAmenities[entry.key];
                                    amenitiesStateSetter(() {});
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                MaterialButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                MaterialButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  Widget getPetPolicyField() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Pet Policy",
      child: ListTile(
        dense: true,
        title: Text(
          getPetPolicySelection(),
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
          selectPetPolicy();
        },
      ),
    );
  }

  String getPetPolicySelection() {
    String petPolicy = "";
    propertyPetPolicy.forEach((key, value) {
      if (value) {
        petPolicy += "$key, ";
      }
    });
    if (petPolicy.length > 2) {
      petPolicy = petPolicy.substring(0, petPolicy.length - 2);
    }
    return petPolicy;
  }

  void selectPetPolicy() {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, petPolicyStateSetter) {
              return AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                          children: [
                            Column(
                              children: propertyPetPolicy.entries
                                  .map<Widget>((entry) {
                                if (entry.value) {
                                  return Container(
                                    color: selectedListItemBackgroundBlue,
                                    child: ListTile(
                                      dense: true,
                                      title: Text(
                                        entry.key,
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
                                        propertyPetPolicy[entry.key] =
                                            !propertyPetPolicy[entry.key];
                                        petPolicyStateSetter(() {});
                                        setState(() {});
                                      },
                                    ),
                                  );
                                }
                                return ListTile(
                                  title: Text(
                                    entry.key,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    propertyPetPolicy[entry.key] =
                                        !propertyPetPolicy[entry.key];
                                    petPolicyStateSetter(() {});
                                    setState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                MaterialButton(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                MaterialButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  Widget getPropertyFurnitureDetailField() {
    return CustomizedDropDownField(
      titleColor: darkGrey,
      title: "Furniture",
      child: ListTile(
        dense: true,
        title: Text(
          getPropertyFurnitureDetail(),
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
          selectFurnitureDetail();
        },
      ),
    );
  }

  String getPropertyFurnitureDetail() {
    return isPropertyFurnished ? "Furnished" : "Unfurnished";
  }

  void selectFurnitureDetail() {
    showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, furnitureDetailStateSetter) {
              return AlertDialog(
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: isPropertyFurnished
                                  ? selectedListItemBackgroundBlue
                                  : Colors.white,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  "Furnished",
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: isPropertyFurnished
                                          ? navyBlue
                                          : blackFont,
                                      fontSize: 16,
                                      fontWeight: isPropertyFurnished
                                          ? FontWeight.w600
                                          : FontWeight.w400),
                                ),
                                trailing: isPropertyFurnished
                                    ? Icon(
                                        SlydoAppIcon.checked,
                                        color: navyBlue,
                                        size: 12,
                                      )
                                    : Container(
                                        width: 1,
                                      ),
                                onTap: () {
                                  isPropertyFurnished = !isPropertyFurnished;
                                  furnitureDetailStateSetter(() {});
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              color: isPropertyFurnished
                                  ? Colors.white
                                  : selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  "Unfurnished",
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: isPropertyFurnished
                                          ? blackFont
                                          : navyBlue,
                                      fontSize: 16,
                                      fontWeight: isPropertyFurnished
                                          ? FontWeight.w400
                                          : FontWeight.w600),
                                ),
                                trailing: isPropertyFurnished
                                    ? Container(
                                        width: 1,
                                      )
                                    : Icon(
                                        SlydoAppIcon.checked,
                                        color: navyBlue,
                                        size: 12,
                                      ),
                                onTap: () {
                                  isPropertyFurnished = !isPropertyFurnished;
                                  furnitureDetailStateSetter(() {});
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
            }));
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
    _imageScrollController.dispose();
    super.dispose();
  }
}
