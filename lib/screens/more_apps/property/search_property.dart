import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/movies/custom_slider_thumb_circle_for_range_slider.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/PropertyItem.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

// ignore: must_be_immutable
class SearchProperty extends StatefulWidget {
  var arguments;

  SearchProperty({this.arguments});

  @override
  _SearchPropertyState createState() => _SearchPropertyState();
}

class _SearchPropertyState extends State<SearchProperty> {
  List<String> searchSuggestion = [];

  TextEditingController searchedText = TextEditingController();
  String selectedSearch = "London";

  List<int> numberCount = List.generate(10, (index) => ++index);
  RangeValues selectedPriceValue = RangeValues(20000, 50000);

  List<bool> isForBuyOrRent = [true, false];

  List<PropertyItem> propertyList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// type of property filter variables
  bool typeIsAny = true;
  bool typeIsApartment = false;
  bool typeIsCondo = false;
  bool typeIsDuplex = false;
  bool typeIsHouse = false;
  bool typeIsTownHouse = false;

  /// duration of property filter variables
  bool durationAtLeastAYear = true;
  bool durationAtFewMonths = false;
  bool durationAtFewWeeks = false;
  bool durationAtFewDays = false;
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now();
  int selectedGuestCount = 1;

  /// Roommates property filter variables
  bool roommatesNeeded = false;
  bool roommatesDoesNotNeeded = true;

  /// Bedrooms property filter variables
  bool bedroomIsStudio = true;
  bool bedroomIs1 = false;
  bool bedroomIs2 = false;
  bool bedroomIs3 = false;
  bool bedroomIs4Plus = false;

  /// Bathroom property filter variables
  bool bathroomIs1 = true;
  bool bathroomIs2 = false;
  bool bathroomIs3 = false;
  bool bathroomIs4 = false;
  bool bathroomIs5Plus = false;

  /// Pet Policy property filter variables
  bool isDogAllowed = false;
  bool isCatAllowed = false;

  /// Furniture property filter variables
  bool isFurnished = false;
  bool isUnfurnished = true;

  /// Amenities property filter variables
  bool amenityIsAny = true;
  bool amenityIsLaundryAvailable = false;
  bool amenityIsACAvailable = false;
  bool amenityIsHeatingAvailable = false;
  bool amenityIsParkingAvailable = false;
  bool amenityIsGatedEntryAvailable = false;
  bool amenityIsDoormanAvailable = false;
  bool amenityIsGymAvailable = false;
  bool amenityIsPoolAvailable = false;
  bool amenityIsDishwasherAvailable = false;

  PropertyFilterBloc? _propertyFilterBloc;

  bool isLoading = false;

  @override
  void initState() {
    _propertyFilterBloc = widget.arguments["filterBloc"];
    setFilterProperty();

    PropertyAuthService().getLocation().then((value) {
      searchSuggestion.addAll(value);
    });

    super.initState();
  }

  void setFilterProperty() {
    typeIsAny = _propertyFilterBloc!.typeIsAny;
    typeIsApartment = _propertyFilterBloc!.typeIsApartment;
    typeIsCondo = _propertyFilterBloc!.typeIsCondo;
    typeIsDuplex = _propertyFilterBloc!.typeIsDuplex;
    typeIsHouse = _propertyFilterBloc!.typeIsHouse;
    typeIsTownHouse = _propertyFilterBloc!.typeIsTownHouse;
    durationAtLeastAYear = _propertyFilterBloc!.durationAtLeastAYear;
    durationAtFewMonths = _propertyFilterBloc!.durationAtFewMonths;
    durationAtFewWeeks = _propertyFilterBloc!.durationAtFewWeeks;
    durationAtFewDays = _propertyFilterBloc!.durationAtFewDays;
    checkInDate = _propertyFilterBloc!.checkInDate;
    checkOutDate = _propertyFilterBloc!.checkOutDate;
    selectedGuestCount = _propertyFilterBloc!.selectedGuestCount;
    roommatesNeeded = _propertyFilterBloc!.roommatesNeeded;
    roommatesDoesNotNeeded = _propertyFilterBloc!.roommatesDoesNotNeeded;
    bedroomIsStudio = _propertyFilterBloc!.bedroomIsStudio;
    bedroomIs1 = _propertyFilterBloc!.bedroomIs1;
    bedroomIs2 = _propertyFilterBloc!.bedroomIs2;
    bedroomIs3 = _propertyFilterBloc!.bedroomIs3;
    bedroomIs4Plus = _propertyFilterBloc!.bedroomIs4Plus;
    bathroomIs1 = _propertyFilterBloc!.bathroomIs1;
    bathroomIs2 = _propertyFilterBloc!.bathroomIs2;
    bathroomIs3 = _propertyFilterBloc!.bathroomIs3;
    bathroomIs4 = _propertyFilterBloc!.bathroomIs4;
    bathroomIs5Plus = _propertyFilterBloc!.bathroomIs5Plus;
    isDogAllowed = _propertyFilterBloc!.isDogAllowed;
    isCatAllowed = _propertyFilterBloc!.isCatAllowed;
    isFurnished = _propertyFilterBloc!.isFurnished;
    isUnfurnished = _propertyFilterBloc!.isUnfurnished;
    amenityIsAny = _propertyFilterBloc!.amenityIsAny;
    amenityIsLaundryAvailable = _propertyFilterBloc!.amenityIsLaundryAvailable;
    amenityIsACAvailable = _propertyFilterBloc!.amenityIsACAvailable;
    amenityIsHeatingAvailable = _propertyFilterBloc!.amenityIsHeatingAvailable;
    amenityIsParkingAvailable = _propertyFilterBloc!.amenityIsParkingAvailable;
    amenityIsGatedEntryAvailable =
        _propertyFilterBloc!.amenityIsGatedEntryAvailable;
    amenityIsDoormanAvailable = _propertyFilterBloc!.amenityIsDoormanAvailable;
    amenityIsGymAvailable = _propertyFilterBloc!.amenityIsGymAvailable;
    amenityIsPoolAvailable = _propertyFilterBloc!.amenityIsPoolAvailable;
    amenityIsDishwasherAvailable =
        _propertyFilterBloc!.amenityIsDishwasherAvailable;
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult("");
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
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
        "Search",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        locationChip(),
        SizedBox(
          width: 8,
        ),
        filterPropertyBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget filterPropertyBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.filter,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        setFilterProperty();
        showFilterPropertySheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget locationChip() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60), color: iconBtnGrey),
      child: Row(
        children: [
          Icon(
            SlydoAppIcon.location,
            color: blackFont,
            size: 14,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            selectedSearch,
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 6,
          ),
          // searchBox(),
          searchBoxWithSuggestion(),
          SizedBox(
            height: 12,
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularLoadingIndicator(),
                  ),
                )
              : propertyList.isEmpty
                  ? Expanded(child: searchBackground())
                  : Expanded(
                      child: SmartRefresher(
                        enablePullDown: true,
                        header: WaterDropHeader(
                          complete: Container(),
                          waterDropColor: navyBlue,
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          child: Column(
                            children: propertyList
                                .map(
                                  (element) => Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child:
                                          RentPropertyTile(property: element)),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget searchBackground() {
    return NoItemInList(
      msg: "Please type something to get results",
      isResult: false,
    );
  }

  Widget searchBoxWithSuggestion() {
    // return SearchWidget<String>(
    //   dataList: searchSuggestion,
    //   hideSearchBoxWhenItemSelected: false,
    //   listContainerHeight: MediaQuery.of(context).size.height / 4,
    //   queryBuilder: (String query, List<String> list) {
    //     return list;
    //   },
    //   onItemSelected: (item) {
    //     selectedSearch = item;
    //     setState(() {});
    //     getResult(item);
    //   },
    //   popupListItemBuilder: (String item) {
    //     return PopupListItemWidget(item);
    //   },
    //   selectedItemBuilder:
    //       (String selectedItem, VoidCallback deleteSelectedItem) {
    //     return Container();
    //   },
    //   // widget customization
    //   noItemsFoundWidget: NoItemsFound(),
    //   textFieldBuilder: (tempController, FocusNode focusNode) {
    //     return MyTextField(tempController, focusNode);
    //   },
    // );
    return Container();
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                SlydoAppIcon.search,
                color: darkGrey,
                size: 14,
              ),
              onPressed: () {},
            ),
            hintText: "Search",
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefix: Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getResult(String item) async {
    isLoading = true;
    propertyList.clear();
    if (mounted) {
      setState(() {});
    }

    propertyList = await PropertyAuthService().getPropertyList();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void showFilterPropertySheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSheetSetState) =>
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.66,
                      padding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            "Filter",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: blackFont),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  buyOrRentSwitch(
                                      bottomSheetSetState: bottomSheetSetState),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getHouseTypeRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getDurationRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getRoommatesRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getBedroomRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getBathroomRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getPetPolicyRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getFurnitureRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  getAmenityRequirement(
                                    bottomSheetSetState: bottomSheetSetState,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Divider(
                                    height: 0,
                                    thickness: 1,
                                    color: dividerColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  getPriceSelection(bottomSheetSetState),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  getFilerSubmitButton(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
          );
        });
  }

  Widget getHouseTypeRequirement({StateSetter? bottomSheetSetState}) {
    return getChipsList(
      title: "Type",
      bottomSheetSetState: bottomSheetSetState,
      children: [
        ChipData(name: "Any", isSelected: typeIsAny, variableName: "typeIsAny"),
        ChipData(
            name: "Apartment",
            isSelected: typeIsApartment,
            variableName: "typeIsApartment"),
        ChipData(
            name: "Condo",
            isSelected: typeIsCondo,
            variableName: "typeIsCondo"),
        ChipData(
            name: "Duplex",
            isSelected: typeIsDuplex,
            variableName: "typeIsDuplex"),
        ChipData(
            name: "House",
            isSelected: typeIsHouse,
            variableName: "typeIsHouse"),
        ChipData(
            name: "Townhouse",
            isSelected: typeIsTownHouse,
            variableName: "typeIsTownHouse"),
      ],
    );
  }

  Widget getDurationRequirement({StateSetter? bottomSheetSetState}) {
    bool isForRent = isForBuyOrRent[1];
    return !isForRent
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: dividerColor,
              ),
              SizedBox(
                height: 10,
              ),
              getChipsList(
                title: "Duration",
                bottomSheetSetState: bottomSheetSetState,
                children: [
                  ChipData(
                      name: "At least a year",
                      isSelected: durationAtLeastAYear,
                      variableName: "durationAtLeastAYear"),
                  ChipData(
                      name: "At few months",
                      isSelected: durationAtFewMonths,
                      variableName: "durationAtFewMonths"),
                  ChipData(
                      name: "At few weeks",
                      isSelected: durationAtFewWeeks,
                      variableName: "durationAtFewWeeks"),
                  ChipData(
                      name: "At few days",
                      isSelected: durationAtFewDays,
                      variableName: "durationAtFewDays"),
                ],
              ),
              getDateField(bottomSheetSetState: bottomSheetSetState),
              getGuestCountDropDown(bottomSheetSetState: bottomSheetSetState),
            ],
          );
  }

  Widget getDateField({StateSetter? bottomSheetSetState}) {
    return durationAtLeastAYear || durationAtFewMonths
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDatePicker(
                          builder: customThemeBuilder,
                          context: context,
                          initialDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                          firstDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                          lastDate: DateTime(2101),
                        ).then((value) {
                          checkInDate =
                              DateTime(value!.year, value.month, value.day);
                          bottomSheetSetState!(() {});
                        }).catchError((error) {});
                      },
                      child: CustomizedDropDownField(
                        title: "Check in",
                        titleColor: blackFont,
                        child: Container(
                          child: ListTile(
                            dense: true,
                            title: Text(
                              formatDateInDigit(checkInDate),
                              style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              maxLines: 1,
                            ),
                            trailing: Icon(
                              SlydoAppIcon.date,
                              size: 16,
                              color: darkGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showDatePicker(
                          builder: customThemeBuilder,
                          context: context,
                          initialDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                          firstDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day),
                          lastDate: DateTime(2101),
                        ).then((value) {
                          checkOutDate =
                              DateTime(value!.year, value.month, value.day);
                          bottomSheetSetState!(() {});
                        }).catchError((error) {});
                      },
                      child: CustomizedDropDownField(
                        title: "Check out",
                        titleColor: blackFont,
                        child: Container(
                          child: ListTile(
                            dense: true,
                            title: Text(
                              formatDateInDigit(checkOutDate),
                              style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              maxLines: 1,
                            ),
                            trailing: Icon(
                              SlydoAppIcon.date,
                              size: 16,
                              color: darkGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
  }

  Widget getGuestCountDropDown({StateSetter? bottomSheetSetState}) {
    return durationAtLeastAYear || durationAtFewMonths
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Text(
                "Guest",
                style: TextStyle(color: blackFont, fontSize: 14),
              ),
              SizedBox(
                height: 6,
              ),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: greyBorderColor)),
                margin: EdgeInsets.all(0),
                borderOnForeground: true,
                child: ListTile(
                  dense: true,
                  title: Text(
                    selectedGuestCount.toString(),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    color: darkGrey,
                  ),
                  onTap: () {
                    selectGuestCount(bottomSheetSetState: bottomSheetSetState);
                  },
                ),
              ),
            ],
          );
  }

  void selectGuestCount({StateSetter? bottomSheetSetState}) async {
    final pressedCategory = await showDialog<int>(
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
                        children: numberCount.map<Widget>((count) {
                          if (selectedGuestCount == count) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  count.toString(),
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
                                  Navigator.pop(context, count);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              count.toString(),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
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
    if (pressedCategory != null) {
      selectedGuestCount = pressedCategory;
      bottomSheetSetState!(() {});
    }
  }

  Widget getRoommatesRequirement({StateSetter? bottomSheetSetState}) {
    bool isForRent = isForBuyOrRent[1];
    return !isForRent
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: dividerColor,
              ),
              SizedBox(
                height: 10,
              ),
              getChipsList(
                title: "Roommates",
                bottomSheetSetState: bottomSheetSetState,
                children: [
                  ChipData(
                    name: "I don't want roommate",
                    isSelected: roommatesDoesNotNeeded,
                    variableName: "roommatesDoesNotNeeded",
                  ),
                  ChipData(
                    name: "I need a roommate",
                    isSelected: roommatesNeeded,
                    variableName: "roommatesNeeded",
                  ),
                ],
              )
            ],
          );
  }

  Widget getPetPolicyRequirement({StateSetter? bottomSheetSetState}) {
    bool isForRent = isForBuyOrRent[1];
    return !isForRent
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: dividerColor,
              ),
              SizedBox(
                height: 10,
              ),
              getChipsList(
                title: "Pet Policy",
                bottomSheetSetState: bottomSheetSetState,
                children: [
                  ChipData(
                    name: "Dogs allowed",
                    isSelected: isDogAllowed,
                    variableName: "isDogAllowed",
                  ),
                  ChipData(
                    name: "Cats allowed",
                    isSelected: isCatAllowed,
                    variableName: "isCatAllowed",
                  ),
                ],
              ),
            ],
          );
  }

  Widget getBedroomRequirement({StateSetter? bottomSheetSetState}) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          height: 0,
          thickness: 1,
          color: dividerColor,
        ),
        SizedBox(
          height: 10,
        ),
        getChipsList(
          title: "Bedrooms",
          bottomSheetSetState: bottomSheetSetState,
          children: [
            ChipData(
              name: "Studio",
              isSelected: bedroomIsStudio,
              variableName: "bedroomIsStudio",
            ),
            ChipData(
              name: "1 bed",
              isSelected: bedroomIs1,
              variableName: "bedroomIs1",
            ),
            ChipData(
              name: "2 bed",
              isSelected: bedroomIs2,
              variableName: "bedroomIs2",
            ),
            ChipData(
              name: "3 bed",
              isSelected: bedroomIs3,
              variableName: "bedroomIs3",
            ),
            ChipData(
              name: "4+",
              isSelected: bedroomIs4Plus,
              variableName: "bedroomIs4Plus",
            ),
          ],
        ),
      ],
    );
  }

  Widget getBathroomRequirement({StateSetter? bottomSheetSetState}) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          height: 0,
          thickness: 1,
          color: dividerColor,
        ),
        SizedBox(
          height: 10,
        ),
        getChipsList(
          title: "Bathrooms",
          bottomSheetSetState: bottomSheetSetState,
          children: [
            ChipData(
              name: "1 bath",
              isSelected: bathroomIs1,
              variableName: "bathroomIs1",
            ),
            ChipData(
              name: "2 bath",
              isSelected: bathroomIs2,
              variableName: "bathroomIs2",
            ),
            ChipData(
              name: "3 bath",
              isSelected: bathroomIs3,
              variableName: "bathroomIs3",
            ),
            ChipData(
              name: "4 bath",
              isSelected: bathroomIs4,
              variableName: "bathroomIs4",
            ),
            ChipData(
              name: "5+",
              isSelected: bathroomIs5Plus,
              variableName: "bathroomIs5Plus",
            ),
          ],
        ),
      ],
    );
  }

  Widget getFurnitureRequirement({StateSetter? bottomSheetSetState}) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          height: 0,
          thickness: 1,
          color: dividerColor,
        ),
        SizedBox(
          height: 10,
        ),
        getChipsList(
          title: "Furniture",
          bottomSheetSetState: bottomSheetSetState,
          children: [
            ChipData(
              name: "Furnished",
              isSelected: isFurnished,
              variableName: "isFurnished",
            ),
            ChipData(
              name: "Unfurnished",
              isSelected: isUnfurnished,
              variableName: "isUnfurnished",
            ),
          ],
        ),
      ],
    );
  }

  Widget getAmenityRequirement({StateSetter? bottomSheetSetState}) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          height: 0,
          thickness: 1,
          color: dividerColor,
        ),
        SizedBox(
          height: 10,
        ),
        getChipsList(
          title: "Amenities",
          bottomSheetSetState: bottomSheetSetState,
          children: [
            ChipData(
              name: "Any",
              isSelected: amenityIsAny,
              variableName: "amenityIsAny",
            ),
            ChipData(
              name: "Laundry",
              isSelected: amenityIsLaundryAvailable,
              variableName: "amenityIsLaundryAvailable",
            ),
            ChipData(
              name: "A/C",
              isSelected: amenityIsACAvailable,
              variableName: "amenityIsACAvailable",
            ),
            ChipData(
              name: "Heating",
              isSelected: amenityIsHeatingAvailable,
              variableName: "amenityIsHeatingAvailable",
            ),
            ChipData(
              name: "Parking",
              isSelected: amenityIsParkingAvailable,
              variableName: "amenityIsParkingAvailable",
            ),
            ChipData(
              name: "Gated entry",
              isSelected: amenityIsGatedEntryAvailable,
              variableName: "amenityIsGatedEntryAvailable",
            ),
            ChipData(
              name: "Doorman",
              isSelected: amenityIsDoormanAvailable,
              variableName: "amenityIsDoormanAvailable",
            ),
            ChipData(
              name: "Gym",
              isSelected: amenityIsGymAvailable,
              variableName: "amenityIsGymAvailable",
            ),
            ChipData(
              name: "Pool",
              isSelected: amenityIsPoolAvailable,
              variableName: "amenityIsPoolAvailable",
            ),
            ChipData(
              name: "Dishwasher",
              isSelected: amenityIsDishwasherAvailable,
              variableName: "amenityIsDishwasherAvailable",
            ),
          ],
        ),
      ],
    );
  }

  Widget getChipsList(
      {required String title,
      StateSetter? bottomSheetSetState,
      required List<ChipData> children}) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Wrap(
            direction: Axis.horizontal,
            clipBehavior: Clip.hardEdge,
            alignment: WrapAlignment.start,
            runSpacing: 8,
            spacing: 8,
            children: children
                .map((element) => selectionCard(
                    chipData: element,
                    bottomSheetSetState: bottomSheetSetState))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buyOrRentSwitch({StateSetter? bottomSheetSetState}) {
    return Container(
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
              buyButton(),
              rentButton(),
            ],
            isSelected: isForBuyOrRent,
            onPressed: (int index) {
              if (index == 0) {
                isForBuyOrRent[0] = true;
                isForBuyOrRent[1] = false;
              } else {
                isForBuyOrRent[0] = false;
                isForBuyOrRent[1] = true;
              }
              bottomSheetSetState!(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget buyButton() {
    return Container(
      child: Text(
        "Buy",
        style: TextStyle(
            fontWeight: isForBuyOrRent[0] ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
            color: isForBuyOrRent[0] ? Colors.white : blackFont),
      ),
    );
  }

  Widget rentButton() {
    return Container(
      child: Text(
        "Rent",
        style: TextStyle(
            fontWeight: isForBuyOrRent[1] ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
            color: isForBuyOrRent[1] ? Colors.white : blackFont),
      ),
    );
  }

  Widget selectionCard(
      {required ChipData chipData, StateSetter? bottomSheetSetState}) {
    return InkWell(
      onTap: () {
        chipSelection(
            chipData: chipData, bottomSheetSetState: bottomSheetSetState);
      },
      child: Card(
        shadowColor: boxShadowTwo,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: boxShadowTwo,
                offset: Offset(0.0, 0.0),
                blurRadius: 1.0,
              ),
            ],
            color: chipData.isSelected! ? navyBlue : Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            border: new Border.all(
                color: chipData.isSelected! ? navyBlue : dividerColor,
                width: 1.0,
                style: BorderStyle.solid),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            chipData.name!,
            style: TextStyle(
              color: chipData.isSelected! ? Colors.white : blackFont,
              fontSize: 14,
              fontWeight:
                  chipData.isSelected! ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void chipSelection(
      {required ChipData chipData, StateSetter? bottomSheetSetState}) {
    switch (chipData.variableName) {
      case "typeIsAny":
        if (typeIsAny == false) {
          typeIsAny = true;
          typeIsApartment = false;
          typeIsCondo = false;
          typeIsDuplex = false;
          typeIsHouse = false;
          typeIsTownHouse = false;
        } else {
          typeIsAny = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "typeIsApartment":
        if (typeIsApartment == false) {
          typeIsApartment = true;
          typeIsAny = false;
        } else {
          typeIsApartment = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "typeIsCondo":
        if (typeIsCondo == false) {
          typeIsCondo = true;
          typeIsAny = false;
        } else {
          typeIsCondo = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "typeIsDuplex":
        if (typeIsDuplex == false) {
          typeIsDuplex = true;
          typeIsAny = false;
        } else {
          typeIsDuplex = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "typeIsHouse":
        if (typeIsHouse == false) {
          typeIsHouse = true;
          typeIsAny = false;
        } else {
          typeIsHouse = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "typeIsTownHouse":
        if (typeIsTownHouse == false) {
          typeIsTownHouse = true;
          typeIsAny = false;
        } else {
          typeIsTownHouse = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "durationAtLeastAYear":
        if (durationAtLeastAYear == false) {
          durationAtLeastAYear = true;
          durationAtFewMonths = false;
          durationAtFewWeeks = false;
          durationAtFewDays = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "durationAtFewMonths":
        if (durationAtFewMonths == false) {
          durationAtLeastAYear = false;
          durationAtFewMonths = true;
          durationAtFewWeeks = false;
          durationAtFewDays = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "durationAtFewWeeks":
        if (durationAtFewWeeks == false) {
          durationAtLeastAYear = false;
          durationAtFewMonths = false;
          durationAtFewDays = false;
          durationAtFewWeeks = true;
        }
        bottomSheetSetState!(() {});
        break;
      case "durationAtFewDays":
        if (durationAtFewDays == false) {
          durationAtLeastAYear = false;
          durationAtFewMonths = false;
          durationAtFewWeeks = false;
          durationAtFewDays = true;
        }
        bottomSheetSetState!(() {});
        break;
      case "roommatesNeeded":
        if (roommatesNeeded == false) {
          roommatesNeeded = true;
          roommatesDoesNotNeeded = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "roommatesDoesNotNeeded":
        if (roommatesDoesNotNeeded == false) {
          roommatesNeeded = false;
          roommatesDoesNotNeeded = true;
        }
        bottomSheetSetState!(() {});
        break;
      case "bedroomIsStudio":
        bedroomIsStudio = !bedroomIsStudio;
        bottomSheetSetState!(() {});
        break;
      case "bedroomIs1":
        bedroomIs1 = !bedroomIs1;
        bottomSheetSetState!(() {});
        break;
      case "bedroomIs2":
        bedroomIs2 = !bedroomIs2;
        bottomSheetSetState!(() {});
        break;
      case "bedroomIs3":
        bedroomIs3 = !bedroomIs3;
        bottomSheetSetState!(() {});
        break;
      case "bedroomIs4Plus":
        bedroomIs4Plus = !bedroomIs4Plus;
        bottomSheetSetState!(() {});
        break;
      case "bathroomIs1":
        bathroomIs1 = !bathroomIs1;
        bottomSheetSetState!(() {});
        break;
      case "bathroomIs2":
        bathroomIs2 = !bathroomIs2;
        bottomSheetSetState!(() {});
        break;
      case "bathroomIs3":
        bathroomIs3 = !bathroomIs3;
        bottomSheetSetState!(() {});
        break;
      case "bathroomIs4":
        bathroomIs4 = !bathroomIs4;
        bottomSheetSetState!(() {});
        break;
      case "bathroomIs5Plus":
        bathroomIs5Plus = !bathroomIs5Plus;
        bottomSheetSetState!(() {});
        break;
      case "isDogAllowed":
        isDogAllowed = !isDogAllowed;
        bottomSheetSetState!(() {});
        break;
      case "isCatAllowed":
        isCatAllowed = !isCatAllowed;
        bottomSheetSetState!(() {});
        break;
      case "isFurnished":
        if (isFurnished == false) {
          isFurnished = true;
          isUnfurnished = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "isUnfurnished":
        if (isUnfurnished == false) {
          isUnfurnished = true;
          isFurnished = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "amenityIsAny":
        if (amenityIsAny == false) {
          amenityIsAny = true;
          amenityIsLaundryAvailable = false;
          amenityIsACAvailable = false;
          amenityIsHeatingAvailable = false;
          amenityIsParkingAvailable = false;
          amenityIsGatedEntryAvailable = false;
          amenityIsDoormanAvailable = false;
          amenityIsGymAvailable = false;
          amenityIsPoolAvailable = false;
          amenityIsDishwasherAvailable = false;
        } else {
          amenityIsAny = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "amenityIsLaundryAvailable":
        if (amenityIsLaundryAvailable == false) {
          amenityIsLaundryAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsLaundryAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsACAvailable":
        if (amenityIsACAvailable == false) {
          amenityIsACAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsACAvailable = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "amenityIsHeatingAvailable":
        if (amenityIsHeatingAvailable == false) {
          amenityIsHeatingAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsHeatingAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsParkingAvailable":
        if (amenityIsParkingAvailable == false) {
          amenityIsParkingAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsParkingAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsGatedEntryAvailable":
        if (amenityIsGatedEntryAvailable == false) {
          amenityIsGatedEntryAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsGatedEntryAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsDoormanAvailable":
        if (amenityIsDoormanAvailable == false) {
          amenityIsDoormanAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsDoormanAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsGymAvailable":
        if (amenityIsGymAvailable == false) {
          amenityIsGymAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsGymAvailable = false;
        }

        bottomSheetSetState!(() {});
        break;
      case "amenityIsPoolAvailable":
        if (amenityIsPoolAvailable == false) {
          amenityIsPoolAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsPoolAvailable = false;
        }
        bottomSheetSetState!(() {});
        break;
      case "amenityIsDishwasherAvailable":
        if (amenityIsDishwasherAvailable == false) {
          amenityIsDishwasherAvailable = true;
          amenityIsAny = false;
        } else {
          amenityIsDishwasherAvailable = false;
        }
        bottomSheetSetState!(() {});
        break;
      default:
        bottomSheetSetState!(() {});
    }
  }

  Widget getPriceSelection(bottomSheetSetState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Price",
        style: TextStyle(
            color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      SizedBox(
        height: 16,
      ),
      Container(
        height: 20,
        width: MediaQuery.of(context).size.width - 20,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 1,
                rangeThumbShape: CustomRangeThumbShapeForProperty(
                    selectedPriceValue.start.toInt(),
                    selectedPriceValue.end.toInt()),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                minThumbSeparation: 30,
              ),
              child: RangeSlider(
                activeColor: navyBlue,
                inactiveColor: dividerColor,
                onChanged: (RangeValues rangeValue) {
                  selectedPriceValue = rangeValue;
                  bottomSheetSetState(() {});
                },
                min: 1000,
                max: 100000,
                values: selectedPriceValue,
              ),
            ),
          ],
        ),
      )
    ]);
  }

  Widget getFilerSubmitButton() {
    return CurvedButton(
      backgroundColor: navyBlue,
      onPressed: () {
        updateFilterValue();
        Navigator.pop(context);
        getResult("");
      },
      text: "Submit",
      textColor: Colors.white,
    );
  }

  void updateFilterValue() {
    _propertyFilterBloc!.isForBuyOrRent = isForBuyOrRent;
    _propertyFilterBloc!.typeIsAny = typeIsAny;
    _propertyFilterBloc!.typeIsApartment = typeIsApartment;
    _propertyFilterBloc!.typeIsCondo = typeIsCondo;
    _propertyFilterBloc!.typeIsDuplex = typeIsDuplex;
    _propertyFilterBloc!.typeIsHouse = typeIsHouse;
    _propertyFilterBloc!.typeIsTownHouse = typeIsTownHouse;
    _propertyFilterBloc!.durationAtLeastAYear = durationAtLeastAYear;
    _propertyFilterBloc!.durationAtFewMonths = durationAtFewMonths;
    _propertyFilterBloc!.durationAtFewWeeks = durationAtFewWeeks;
    _propertyFilterBloc!.durationAtFewDays = durationAtFewDays;
    _propertyFilterBloc!.checkInDate = checkInDate;
    _propertyFilterBloc!.checkOutDate = checkOutDate;
    _propertyFilterBloc!.selectedGuestCount = selectedGuestCount;
    _propertyFilterBloc!.roommatesNeeded = roommatesNeeded;
    _propertyFilterBloc!.roommatesDoesNotNeeded = roommatesDoesNotNeeded;
    _propertyFilterBloc!.bedroomIsStudio = bedroomIsStudio;
    _propertyFilterBloc!.bedroomIs1 = bedroomIs1;
    _propertyFilterBloc!.bedroomIs2 = bedroomIs2;
    _propertyFilterBloc!.bedroomIs3 = bedroomIs3;
    _propertyFilterBloc!.bedroomIs4Plus = bedroomIs4Plus;
    _propertyFilterBloc!.bathroomIs1 = bathroomIs1;
    _propertyFilterBloc!.bathroomIs2 = bathroomIs2;
    _propertyFilterBloc!.bathroomIs3 = bathroomIs3;
    _propertyFilterBloc!.bathroomIs4 = bathroomIs4;
    _propertyFilterBloc!.bathroomIs5Plus = bathroomIs5Plus;
    _propertyFilterBloc!.isDogAllowed = isDogAllowed;
    _propertyFilterBloc!.isCatAllowed = isCatAllowed;
    _propertyFilterBloc!.isFurnished = isFurnished;
    _propertyFilterBloc!.isUnfurnished = isUnfurnished;
    _propertyFilterBloc!.amenityIsAny = amenityIsAny;
    _propertyFilterBloc!.amenityIsLaundryAvailable = amenityIsLaundryAvailable;
    _propertyFilterBloc!.amenityIsACAvailable = amenityIsACAvailable;
    _propertyFilterBloc!.amenityIsHeatingAvailable = amenityIsHeatingAvailable;
    _propertyFilterBloc!.amenityIsParkingAvailable = amenityIsParkingAvailable;
    _propertyFilterBloc!.amenityIsGatedEntryAvailable =
        amenityIsGatedEntryAvailable;
    _propertyFilterBloc!.amenityIsDoormanAvailable = amenityIsDoormanAvailable;
    _propertyFilterBloc!.amenityIsGymAvailable = amenityIsGymAvailable;
    _propertyFilterBloc!.amenityIsPoolAvailable = amenityIsPoolAvailable;
    _propertyFilterBloc!.amenityIsDishwasherAvailable =
        amenityIsDishwasherAvailable;
  }
}

class ChipData {
  final String? name;
  final bool? isSelected;
  final String? variableName;

  ChipData({this.name, this.isSelected, this.variableName});
}

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final String selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                selectedItem,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 22),
            color: Colors.grey[700],
            onPressed: deleteSelectedItem,
          ),
        ],
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                SlydoAppIcon.search,
                color: darkGrey,
                size: 14,
              ),
              onPressed: () {},
            ),
            hintText: "Search",
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefix: Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          SlydoAppIcon.search,
          size: 20,
          color: blackFont,
        ),
        const SizedBox(width: 10),
        Text(
          "No Items Found",
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
          ),
        ),
      ],
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final String item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        item,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
