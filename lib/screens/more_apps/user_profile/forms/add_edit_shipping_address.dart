import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/states_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class AddEditShippingAddress extends StatefulWidget {
  AddEditShippingAddress({Key? key, this.shippingAddress}) : super(key: key);

  final ShippingAddress? shippingAddress;

  @override
  _AddEditShippingAddressState createState() => _AddEditShippingAddressState();
}

class _AddEditShippingAddressState extends State<AddEditShippingAddress> {
  final _formKey = GlobalKey<FormState>();

  late GoogleMapController mapController;
  LocationData? currentLocation;
  Set<Marker> currentLocationMarker = <Marker>{};
  String? _mapStyle;

  bool isAPILoading = false;

  bool isDeleteLoading = false;

  late ShippingAddress shippingAddress;
  bool isEdit = false;

  List<Product> selectedProducts = [];
  bool isSelectAll = false;
  bool isItemSelected = false;
  String country = "Nigeria";
  String? selectedState;
  String? selectedCity;
  bool isLoading = false;
  List<StatesModel> itemList = [];
  List<Cities> cityList = [];
  List<String> states = [];
  late UserBloc userBloc;
  String? name, phone;
  final Location location = Location();

  @override
  void initState() {
    getCurrentLocation();

    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });

    if (widget.shippingAddress != null) {
      isEdit = true;
    }
    shippingAddress = widget.shippingAddress?.copyWith() ?? ShippingAddress();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userBloc = Provider.of<UserBloc>(context, listen: false);

      getShippingStates();
    });
    super.initState();
  }

  void getCurrentLocation() async {
    // Location location = Location();

    // Request permission to access the device's location
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }
    }

    // Check if permission to access location is granted
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission denied.');
        return;
      }
    }

    try {
      if (isEdit) {
        currentLocation = LocationData.fromMap({
          'latitude': shippingAddress.latitude,
          'longitude': shippingAddress.longitude,
        });
      } else {
        currentLocation = await location.getLocation();
      }
      if (currentLocation != null) {
        currentLocationMarker = {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: LatLng(currentLocation?.latitude ?? 0,
                currentLocation?.longitude ?? 0),
            infoWindow: InfoWindow(title: 'Current Location'),
          )
        };
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
    // final LocationData location = await _locationTracker.getLocation();
  }

  // Future<LocationData?> getCurrentLocation() async {
  //   LocationData? currentLocation;
  //   try {
  //     currentLocation = await location.getLocation();
  //     double? accuracy = currentLocation.accuracy;
  //     print('Location Accuracy: $accuracy meters');
  //   } catch (e) {
  //     print('Error getting location: $e');
  //   }
  //   // final LocationData location = await _locationTracker.getLocation();
  //   return currentLocation;
  // }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      controller.setMapStyle(_mapStyle);
      mapController = controller;
    });
  }

  void _changeLocation(LatLng newLocation) {
    LocationData currentLocation = LocationData.fromMap({
      'latitude': newLocation.latitude,
      'longitude': newLocation.longitude,
    });

    setState(() {
      currentLocation = currentLocation;
      debugPrint(
          'getChangeLocation: ${currentLocation.latitude}, ${currentLocation.longitude}');
      currentLocationMarker = {
        Marker(
          markerId: MarkerId('currentLocation'),
          position: newLocation,
          infoWindow: InfoWindow(title: 'Current Location'),
        )
      };
    });
    mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  void getShippingStates() async {
    selectedState = shippingAddress.stateName;
    selectedCity = shippingAddress.city;
    if (mounted) setState(() {});

    if (!isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic>? result =
          await ShoppingAuthService().getShippingStates();

      if (result == null) {
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      List<StatesModel> tempList = result['results'];
      // tempList.forEach((element) {
      //   states.add(element.name!);
      // });
      if (mounted) {
        setState(() {
          isLoading = false;
          itemList.addAll(tempList);
        });
      }

      StatesModel? selectedStateModel;

      for (StatesModel statesModel in tempList) {
        if (statesModel.name == shippingAddress.stateName) {
          selectedStateModel = statesModel;
          break;
        }
      }
      if (selectedStateModel != null) {
        String? code = selectedStateModel.isoCode;
        if (code != null) {
          getShippingCities(code);
        }
      }
    }
  }

  Future<void> getShippingCities(code) async {
    if (mounted) setState(() {});
    if (!isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic>? result =
          await ShoppingAuthService().getShippingCities(code);

      if (result == null) {
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      List<Cities> tempList = result['results'];
      cityList = [];
      if (mounted) {
        setState(() {
          isLoading = false;
          cityList.addAll(tempList);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0.5,
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
        isEdit ? "Edit address" : "Add Address",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      shadowColor: greySecondaryYarn,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                showMapLocation(),
                const SizedBox(
                  height: 16,
                ),
                addTitleField(),
                const SizedBox(
                  height: 16,
                ),
                addAddressField(),
                const SizedBox(
                  height: 16,
                ),
                addAddressField2(),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Country',
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
                SizedBox(height: 6),
                countryDropdown(),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'State',
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
                SizedBox(height: 6),
                stateDropdownSearch(),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'City',
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
                SizedBox(height: 6),
                cityDropdownSearch(),
                const SizedBox(
                  height: 16,
                ),
                addPostalField(),
                const SizedBox(height: 16),
                toggleActiveTag(),
                const SizedBox(height: 32),
                getSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget showMapLocation() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: greyBorderColor,
      ),
      child: currentLocation == null && isEdit == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: isEdit
                    ? LatLng(shippingAddress.latitude ?? 0,
                        shippingAddress.longitude ?? 0)
                    : LatLng(currentLocation?.latitude ?? 0,
                        currentLocation?.longitude ?? 0),
                zoom: 15.0,
              ),
              markers: currentLocationMarker,
              onTap: (LatLng location) {
                _changeLocation(location);
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                new Factory<OneSequenceGestureRecognizer>(
                  () => new EagerGestureRecognizer(),
                ),
              ].toSet(),
            ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Address Name",
      initialValue: shippingAddress.name ?? "",
      hintText: 'My Ikeja dispatch location',
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.name = val;
      },
    );
  }

  Widget addPhoneNumberField() {
    return CustomizedTextFormField(
      labelText: "Phone Number",
      initialValue: shippingAddress.phone ?? userBloc.user.phoneNumber,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.phone = val;
      },
    );
  }

  Widget addEmailField() {
    return CustomizedTextFormField(
      labelText: "Email Address",
      initialValue: shippingAddress.email ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.email = val;
      },
    );
  }

  Widget addStateField() {
    return CustomizedTextFormField(
      labelText: "State",
      initialValue: shippingAddress.stateName ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.stateName = val;
      },
    );
  }

  Widget addCityField() {
    return CustomizedTextFormField(
      labelText: "City",
      initialValue: shippingAddress.city ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.city = val;
      },
    );
  }

  Widget addAddressField() {
    return CustomizedTextFormField(
      labelText: "Address Line 1",
      initialValue: shippingAddress.line_1 ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.line_1 = val;
      },
    );
  }

  Widget addAddressField2() {
    return CustomizedTextFormField(
      labelText: "Address Line 2",
      initialValue: shippingAddress.line_2 ?? "",
      onChanged: (val) {
        shippingAddress.line_2 = val;
      },
    );
  }

  Widget addPostalField() {
    return CustomizedTextFormField(
      labelText: "Postcode",
      initialValue: shippingAddress.zip ?? "",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        shippingAddress.zip = val;
      },
    );
  }

  Widget countryDropdown() {
    return DropdownButtonFormField2(
      buttonHeight: 50,
      isExpanded: true,
      value: country,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
      items: ["Nigeria"].map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? value) {
        shippingAddress.country = "NG";
        setState(() {
          country = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick a country';
        }
      },
    );
  }

  // Widget stateDropdown() {
  //   return DropdownButtonFormField2(
  //     buttonHeight: 50,
  //     isExpanded: true,
  //     value: selectedState,
  //     style: TextStyle(
  //       fontSize: 16,
  //       color: blackFont,
  //       fontWeight: FontWeight.w600,
  //     ),
  //     decoration: InputDecoration(
  //       contentPadding: EdgeInsets.symmetric(horizontal: 0),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //       errorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //     ),
  //     items: itemList.map((StatesModel item) {
  //       return DropdownMenuItem<String>(
  //         value: item.name,
  //         child: Text(item.name!),
  //       );
  //     }).toList(),
  //     onChanged: (String? value) async {
  //       StatesModel picked =
  //           itemList.firstWhere((element) => element.name == value);
  //       selectedCity = null;
  //       await getShippingCities(picked.isoCode);
  //       shippingAddress.stateName = picked.name;
  //       setState(() {
  //         selectedState = value!;
  //       });
  //     },
  //     validator: (String? value) {
  //       if (value != null && value.isNotEmpty) {
  //         return null;
  //       } else {
  //         return 'Pick a state';
  //       }
  //     },
  //   );
  // }

  Widget stateDropdownSearch() {
    return DropdownSearch<String>(
      popupProps: PopupProps.dialog(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            cursorColor: navyBlue,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: navyBlue,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
            ),
          )),
      items: itemList.map((StatesModel item) {
        return messageDecoderWithEmoji(item.name) ?? "";
      }).toList(),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
        ),
        baseStyle: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w600,
        ),
      ),
      onChanged: (String? value) async {
        StatesModel picked =
            itemList.firstWhere((element) => element.name == value);
        selectedCity = null;
        await getShippingCities(picked.isoCode);
        shippingAddress.stateName = picked.name;
        setState(() {
          selectedState = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick a state';
        }
      },
      selectedItem: selectedState,
    );

    return DropdownButtonFormField2(
      buttonHeight: 50,
      isExpanded: true,
      value: selectedCity,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
      items: cityList.map((Cities item) {
        return DropdownMenuItem<String>(
          value: item.name,
          child: Text(item.name!),
        );
      }).toList(),
      onChanged: (String? value) {
        shippingAddress.city = value;
        setState(() {
          selectedCity = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick a city';
        }
      },
    );
  }

  // Widget cityDropdown() {
  //   return DropdownButtonFormField2(
  //     buttonHeight: 50,
  //     isExpanded: true,
  //     value: selectedCity,
  //     style: TextStyle(
  //       fontSize: 16,
  //       color: blackFont,
  //       fontWeight: FontWeight.w600,
  //     ),
  //     decoration: InputDecoration(
  //       contentPadding: EdgeInsets.symmetric(horizontal: 0),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //       errorBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //         borderSide: BorderSide(
  //           color: greyBorderColor,
  //           width: 1.0,
  //         ),
  //       ),
  //     ),
  //     items: cityList.map((Cities item) {
  //       return DropdownMenuItem<String>(
  //         value: item.name,
  //         child: Text(item.name!),
  //       );
  //     }).toList(),
  //     onChanged: (String? value) {
  //       shippingAddress.city = value;
  //       setState(() {
  //         selectedCity = value!;
  //       });
  //     },
  //     validator: (String? value) {
  //       if (value != null && value.isNotEmpty) {
  //         return null;
  //       } else {
  //         return 'Pick a city';
  //       }
  //     },
  //   );
  // }

  Widget cityDropdownSearch() {
    return DropdownSearch<String>(
      popupProps: PopupProps.dialog(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            cursorColor: navyBlue,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: navyBlue,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: greyBorderColor,
                  width: 1.0,
                ),
              ),
            ),
          )),
      items: cityList.map((Cities item) {
        return messageDecoderWithEmoji(item.name) ?? "";
      }).toList(),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: greyBorderColor,
              width: 1.0,
            ),
          ),
        ),
        baseStyle: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w600,
        ),
      ),
      onChanged: (String? value) {
        shippingAddress.city = value;
        setState(() {
          selectedCity = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick a city';
        }
      },
      selectedItem: selectedCity,
    );

    return DropdownButtonFormField2(
      buttonHeight: 50,
      isExpanded: true,
      value: selectedCity,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
      items: cityList.map((Cities item) {
        return DropdownMenuItem<String>(
          value: item.name,
          child: Text(item.name!),
        );
      }).toList(),
      onChanged: (String? value) {
        shippingAddress.city = value;
        setState(() {
          selectedCity = value!;
        });
      },
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return 'Pick a city';
        }
      },
    );
  }

  Widget getSubmitButton() {
    if (isEdit) {
      return Row(
        children: [
          if (!widget.shippingAddress!.is_default!) ...[
            Expanded(
              child: CurvedButton(
                onPressed: isDeleteLoading
                    ? () {}
                    : () async {
                        FocusScope.of(context).unfocus();
                        deleteDispachAddressDialog();
                      },
                backgroundColor: red,
                textColor: Colors.white,
                text: "Delete",
                isLoading: isDeleteLoading,
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ],
          Expanded(
            child: CurvedButton(
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAPILoading = true;
                      if (mounted) setState(() {});

                      await addEditItem();

                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: Colors.white,
              text: "Update",
              isLoading: isAPILoading,
            ),
          )
        ],
      );
    }

    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addEditItem();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  void deleteDispachAddressDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Dispatch Address',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this dispatch address?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        isDeleteLoading = true;
        if (mounted) setState(() {});

        await deleteItem();

        isDeleteLoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> addEditItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      //the api call will first create the product then use the id from the
      //response to save the variant
      shippingAddress.email = userBloc.user.userName! + "@slydo.co";
      shippingAddress.phone = userBloc.user.phoneNumber;
      shippingAddress.first_name = userBloc.user.fullName!.split(" ").first;
      shippingAddress.last_name = userBloc.user.fullName!.split(" ").last;
      shippingAddress.is_residential = shippingAddress.is_residential;
      shippingAddress.latitude = currentLocation?.latitude;
      shippingAddress.longitude = currentLocation?.longitude;

      await ShoppingAuthService()
          .addUpdateAddress(shippingAddress, isEdit: isEdit)
          .then((value) async {
        Navigator.pop(context, true);
        showToast(
          message: isEdit
              ? "Address updated successfully"
              : "Address added successfully",
        );
      }).catchError((error) {
        debugPrint("Product check::: ${error.toString()}");
        showToast(message: error.toString());
      });
    } else {
      showToast(message: "Please fill all the details");
    }
  }

  Future<void> deleteItem() async {
    await ShoppingAuthService()
        .deleteAddress(shippingAddress.id!)
        .then((value) async {
      Navigator.pop(context, true);
      showToast(
        message: "Address deleted successfully",
      );
    }).catchError((error) {
      debugPrint("Product check::: ${error.toString()}");
      showToast(message: error.toString());
    });
  }

  Widget toggleActiveTag() {
    return CustomizedCheckBoxField(
      onTap: () {
        shippingAddress.is_residential = !shippingAddress.is_residential;
        setState(() {});
      },
      isChecked: shippingAddress.is_residential,
      title: "This is a residential address",
    );
  }

// Widget productSelection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       GestureDetector(
//         onTap: () async {
//           var result = await NavigationUtil.push(
//             context,
//             screen: UserProductListForDiscount(item: shippingAddress),
//           );

//           if (result != null && result is Map<String, dynamic>) {
//             isItemSelected = true;
//             if (result["isSelectAll"] as bool == true) {
//               discountModel.addProductsToDiscount(["*"]);
//               isSelectAll = true;
//             } else {
//               discountModel.addProductsToDiscount(result["ids"]);
//               selectedProducts = result["products"];
//             }
//             if (mounted) setState(() {});
//           }
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Product",
//               style: TextStyle(
//                   fontSize: 16,
//                   color: blackFont,
//                   fontWeight: FontWeight.w600),
//             ),
//             SizedBox(
//               height: 18,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     "Attach product to this discount",
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: darkGrey,
//                         fontFamily: "Inter",
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 18,
//                   color: navyBlue,
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//       if (isItemSelected || isEdit)
//         Column(
//           children: [
//             SizedBox(
//               height: 16,
//             ),
//             Text(
//               "This discount will apply on ${isSelectAll ? "all" : isEdit ? (discountModel.consumables?.product?.length ?? 0) : selectedProducts.length} items",
//               style: TextStyle(
//                   fontSize: 12, color: navyBlue, fontWeight: FontWeight.w600),
//             ),
//           ],
//         )
//     ],
//   );
// }
}
