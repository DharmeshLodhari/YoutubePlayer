import 'package:Slydo/screens/more_apps/movies/custom_slider_thumb_circle_for_range_slider.dart';
import 'package:Slydo/screens/more_apps/property/property_dashboard_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import 'property_tile.dart';

// ignore: must_be_immutable
class SearchProperty extends StatefulWidget {
  var arguments;

  SearchProperty({this.arguments});

  @override
  _SearchPropertyState createState() => _SearchPropertyState();
}

class _SearchPropertyState extends State<SearchProperty> {
  List<String> imgList = [
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
  ];

  GlobalKey _key = LabeledGlobalKey("searchType");
  CustomizedPopUpMenu searchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;

    setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  String selectedMovieCategory;
  String selectedMovieYear;
  int selectedRating;
  RangeValues selectedPriceValue = RangeValues(5, 56);

  /// type of property filter variables
  bool typeIsAny = false;
  bool typeIsApartment = false;
  bool typeIsCondo = false;
  bool typeIsDuplex = false;
  bool typeIsHouse = false;
  bool typeIsTownHouse = false;

  /// duration of property filter variables
  bool durationAtLeastAYear = false;
  bool durationAtFewMonths = false;
  bool durationAtFewWeeks = false;

  /// Roommates property filter variables
  bool roommatesNeeded = false;
  bool roommatesDoesNotNeeded = false;

  /// Bedrooms property filter variables
  bool bedroomIsStudio = false;
  bool bedroomIs1 = false;
  bool bedroomIs2 = false;
  bool bedroomIs3 = false;
  bool bedroomIs4Plus = false;

  /// Bathroom property filter variables
  bool bathroomIs1 = false;
  bool bathroomIs2 = false;
  bool bathroomIs3 = false;
  bool bathroomIs4 = false;
  bool bathroomIs5Plus = false;

  /// Pet Policy property filter variables
  bool isDogAllowed = false;
  bool isCatAllowed = false;

  /// Furniture property filter variables
  bool isFurnished = false;
  bool isUnfurnished = false;

  /// Amenities property filter variables
  bool amenityIsAny = false;
  bool amenityIsLaundryAvailable = false;
  bool amenityIsACAvailable = false;
  bool amenityIsHeatingAvailable = false;
  bool amenityIsParkingAvailable = false;
  bool amenityIsGatedEntryAvailable = false;
  bool amenityIsDoormanAvailable = false;
  bool amenityIsGymAvailable = false;
  bool amenityIsPoolAvailable = false;
  bool amenityIsDishwasherAvailable = false;

  PropertyFilterBloc _propertyFilterBloc;

  @override
  void initState() {
    _propertyFilterBloc = widget.arguments["filterBloc"];
    setFilterProperty();
    super.initState();
  }

  void setFilterProperty() {
    typeIsAny = _propertyFilterBloc.typeIsAny;
    typeIsApartment = _propertyFilterBloc.typeIsApartment;
    typeIsCondo = _propertyFilterBloc.typeIsCondo;
    typeIsDuplex = _propertyFilterBloc.typeIsDuplex;
    typeIsHouse = _propertyFilterBloc.typeIsHouse;
    typeIsTownHouse = _propertyFilterBloc.typeIsTownHouse;
    durationAtLeastAYear = _propertyFilterBloc.durationAtLeastAYear;
    durationAtFewMonths = _propertyFilterBloc.durationAtFewMonths;
    durationAtFewWeeks = _propertyFilterBloc.durationAtFewWeeks;
    roommatesNeeded = _propertyFilterBloc.roommatesNeeded;
    roommatesDoesNotNeeded = _propertyFilterBloc.roommatesDoesNotNeeded;
    bedroomIsStudio = _propertyFilterBloc.bedroomIsStudio;
    bedroomIs1 = _propertyFilterBloc.bedroomIs1;
    bedroomIs2 = _propertyFilterBloc.bedroomIs2;
    bedroomIs3 = _propertyFilterBloc.bedroomIs3;
    bedroomIs4Plus = _propertyFilterBloc.bedroomIs4Plus;
    bathroomIs1 = _propertyFilterBloc.bathroomIs1;
    bathroomIs2 = _propertyFilterBloc.bathroomIs2;
    bathroomIs3 = _propertyFilterBloc.bathroomIs3;
    bathroomIs4 = _propertyFilterBloc.bathroomIs4;
    bathroomIs5Plus = _propertyFilterBloc.bathroomIs5Plus;
    isDogAllowed = _propertyFilterBloc.isDogAllowed;
    isCatAllowed = _propertyFilterBloc.isCatAllowed;
    isFurnished = _propertyFilterBloc.isFurnished;
    isUnfurnished = _propertyFilterBloc.isUnfurnished;
    amenityIsAny = _propertyFilterBloc.amenityIsAny;
    amenityIsLaundryAvailable = _propertyFilterBloc.amenityIsLaundryAvailable;
    amenityIsACAvailable = _propertyFilterBloc.amenityIsACAvailable;
    amenityIsHeatingAvailable = _propertyFilterBloc.amenityIsHeatingAvailable;
    amenityIsParkingAvailable = _propertyFilterBloc.amenityIsParkingAvailable;
    amenityIsGatedEntryAvailable =
        _propertyFilterBloc.amenityIsGatedEntryAvailable;
    amenityIsDoormanAvailable = _propertyFilterBloc.amenityIsDoormanAvailable;
    amenityIsGymAvailable = _propertyFilterBloc.amenityIsGymAvailable;
    amenityIsPoolAvailable = _propertyFilterBloc.amenityIsPoolAvailable;
    amenityIsDishwasherAvailable =
        _propertyFilterBloc.amenityIsDishwasherAvailable;
  }

  @override
  Widget build(BuildContext context) {
    searchTypeSelectionMenu = CustomizedPopUpMenu(
        buttonKey: _key,
        context: context,
        hasIcon: true,
        children: [
          CustomizedPopUpMenuItemWithIcon(
              title: "Rent", value: "Users", icon: SlydoAppIcon.user),
          CustomizedPopUpMenuItemWithIcon(
              title: "Buy", value: "Products", icon: SlydoAppIcon.product),
          CustomizedPopUpMenuItemWithIcon(
              title: "Shortlet", value: "Services", icon: SlydoAppIcon.note_2),
        ],
        selectedIndex: selectedMenuItemIndex,
        left: 16,
        arrowPosition: Alignment.topLeft,
        arrowLeftPadding: 16,
        top: 14);
    searchTypeSelectionMenu.onChange = menuItemSelectionChange;
    searchTypeSelectionMenu.menuState = menuStateChange;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
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
        showFilterPropertySheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 6,
          ),
          searchBox(),
          SizedBox(
            height: 12,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: imgList
                    .map(
                      (element) => Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: PropertyImagesTile()),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionHandleColor: navyBlue,
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
            hintText: "Search here",
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefixIcon: searchTypeSelection(),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            suffixIcon: searchIcon(),
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
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {});

              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
    );
  }

  Widget searchTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        color: navyBlue,
      ),
      child: IconButton(
        key: _key,
        icon: Icon(
          getSearchTypeIcon(),
          color: Colors.white,
          size: 16,
        ),
        onPressed: () {
          if (searchTypeSelectionMenu.isMenuOpen) {
            searchTypeSelectionMenu.closeMenu();
          } else {
            searchTypeSelectionMenu.openMenu();
          }
        },
      ),
    );
  }

  IconData getSearchTypeIcon() {
    if (selectedMenuItemIndex == 2) {
      return SlydoAppIcon.note_2;
    } else if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.product;
    }
    return SlydoAppIcon.user;
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        if (mounted) {
          setState(() {});
          FocusScope.of(context).unfocus();
        }
      },
    );
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
                                  getChipsList(
                                    title: "Type",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      ChipData(
                                          name: "Any",
                                          isSelected: typeIsAny,
                                          variableName: "typeIsAny"),
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
                                  ),
                                  SizedBox(
                                    height: 20,
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
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Roommates",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      ChipData(
                                        name: "I need a roommate",
                                        isSelected: roommatesNeeded,
                                        variableName: "roommatesNeeded",
                                      ),
                                      ChipData(
                                        name: "I don't want roommate",
                                        isSelected: roommatesDoesNotNeeded,
                                        variableName: "roommatesDoesNotNeeded",
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
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
                                  SizedBox(
                                    height: 20,
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
                                  SizedBox(
                                    height: 20,
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
                                  SizedBox(
                                    height: 20,
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
                                  SizedBox(
                                    height: 20,
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
                                        variableName:
                                            "amenityIsLaundryAvailable",
                                      ),
                                      ChipData(
                                        name: "A/C",
                                        isSelected: amenityIsACAvailable,
                                        variableName: "amenityIsACAvailable",
                                      ),
                                      ChipData(
                                        name: "Heating",
                                        isSelected: amenityIsHeatingAvailable,
                                        variableName:
                                            "amenityIsHeatingAvailable",
                                      ),
                                      ChipData(
                                        name: "Parking",
                                        isSelected: amenityIsParkingAvailable,
                                        variableName:
                                            "amenityIsParkingAvailable",
                                      ),
                                      ChipData(
                                        name: "Gated entry",
                                        isSelected:
                                            amenityIsGatedEntryAvailable,
                                        variableName:
                                            "amenityIsGatedEntryAvailable",
                                      ),
                                      ChipData(
                                        name: "Parking",
                                        isSelected: amenityIsParkingAvailable,
                                        variableName:
                                            "amenityIsParkingAvailable",
                                      ),
                                      ChipData(
                                        name: "Doorman",
                                        isSelected: amenityIsDoormanAvailable,
                                        variableName:
                                            "amenityIsDoormanAvailable",
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
                                        isSelected:
                                            amenityIsDishwasherAvailable,
                                        variableName:
                                            "amenityIsDishwasherAvailable",
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
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

  Widget getChipsList(
      {String title,
      StateSetter bottomSheetSetState,
      List<ChipData> children}) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: blackFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 8,
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

  Widget selectionCard({ChipData chipData, StateSetter bottomSheetSetState}) {
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
            color: chipData.isSelected ? navyBlue : Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            border: new Border.all(
                color: chipData.isSelected ? navyBlue : lightGrey,
                width: 1.0,
                style: BorderStyle.solid),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            chipData.name,
            style: TextStyle(
              color: chipData.isSelected ? Colors.white : blackFont,
              fontSize: 14,
              fontWeight:
                  chipData.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void chipSelection({ChipData chipData, StateSetter bottomSheetSetState}) {
    switch (chipData.variableName) {
      case "typeIsAny":
        typeIsAny = !typeIsAny;
        bottomSheetSetState(() {});
        break;
      case "typeIsApartment":
        typeIsApartment = !typeIsApartment;
        bottomSheetSetState(() {});
        break;
      case "typeIsCondo":
        typeIsCondo = !typeIsCondo;
        bottomSheetSetState(() {});
        break;
      case "typeIsDuplex":
        typeIsDuplex = !typeIsDuplex;
        bottomSheetSetState(() {});
        break;
      case "typeIsHouse":
        typeIsHouse = !typeIsHouse;
        bottomSheetSetState(() {});
        break;
      case "typeIsTownHouse":
        typeIsTownHouse = !typeIsTownHouse;
        bottomSheetSetState(() {});
        break;
      case "durationAtLeastAYear":
        durationAtLeastAYear = !durationAtLeastAYear;
        bottomSheetSetState(() {});
        break;
      case "durationAtFewMonths":
        durationAtFewMonths = !durationAtFewMonths;
        bottomSheetSetState(() {});
        break;
      case "durationAtFewWeeks":
        durationAtFewWeeks = !durationAtFewWeeks;
        bottomSheetSetState(() {});
        break;
      case "roommatesNeeded":
        roommatesNeeded = !roommatesNeeded;
        bottomSheetSetState(() {});
        break;
      case "roommatesDoesNotNeeded":
        roommatesDoesNotNeeded = !roommatesDoesNotNeeded;
        bottomSheetSetState(() {});
        break;
      case "bedroomIsStudio":
        bedroomIsStudio = !bedroomIsStudio;
        bottomSheetSetState(() {});
        break;
      case "bedroomIs1":
        bedroomIs1 = !bedroomIs1;
        bottomSheetSetState(() {});
        break;
      case "bedroomIs2":
        bedroomIs2 = !bedroomIs2;
        bottomSheetSetState(() {});
        break;
      case "bedroomIs3":
        bedroomIs3 = !bedroomIs3;
        bottomSheetSetState(() {});
        break;
      case "bedroomIs4Plus":
        bedroomIs4Plus = !bedroomIs4Plus;
        bottomSheetSetState(() {});
        break;
      case "bathroomIs1":
        bathroomIs1 = !bathroomIs1;
        bottomSheetSetState(() {});
        break;
      case "bathroomIs2":
        bathroomIs2 = !bathroomIs2;
        bottomSheetSetState(() {});
        break;
      case "bathroomIs3":
        bathroomIs3 = !bathroomIs3;
        bottomSheetSetState(() {});
        break;
      case "bathroomIs4":
        bathroomIs4 = !bathroomIs4;
        bottomSheetSetState(() {});
        break;
      case "bathroomIs5Plus":
        bathroomIs5Plus = !bathroomIs5Plus;
        bottomSheetSetState(() {});
        break;
      case "isDogAllowed":
        isDogAllowed = !isDogAllowed;
        bottomSheetSetState(() {});
        break;
      case "isCatAllowed":
        isCatAllowed = !isCatAllowed;
        bottomSheetSetState(() {});
        break;
      case "isFurnished":
        isFurnished = !isFurnished;
        bottomSheetSetState(() {});
        break;
      case "isUnfurnished":
        isUnfurnished = !isUnfurnished;
        bottomSheetSetState(() {});
        break;
      case "amenityIsAny":
        amenityIsAny = !amenityIsAny;
        bottomSheetSetState(() {});
        break;
      case "amenityIsLaundryAvailable":
        amenityIsLaundryAvailable = !amenityIsLaundryAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsACAvailable":
        amenityIsACAvailable = !amenityIsACAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsHeatingAvailable":
        amenityIsHeatingAvailable = !amenityIsHeatingAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsParkingAvailable":
        amenityIsParkingAvailable = !amenityIsParkingAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsGatedEntryAvailable":
        amenityIsGatedEntryAvailable = !amenityIsGatedEntryAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsDoormanAvailable":
        amenityIsDoormanAvailable = !amenityIsDoormanAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsGymAvailable":
        amenityIsGymAvailable = !amenityIsGymAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsPoolAvailable":
        amenityIsPoolAvailable = !amenityIsPoolAvailable;
        bottomSheetSetState(() {});
        break;
      case "amenityIsDishwasherAvailable":
        amenityIsDishwasherAvailable = !amenityIsDishwasherAvailable;
        bottomSheetSetState(() {});
        break;
      default:
        bottomSheetSetState(() {});
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
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 1,
          rangeThumbShape: CustomRangeThumbShape(
              selectedPriceValue.start.toInt(), selectedPriceValue.end.toInt()),
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
          min: 0,
          max: 100,
          values: selectedPriceValue,
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
      },
      text: "Submit",
      textColor: Colors.white,
    );
  }

  void updateFilterValue() {
    _propertyFilterBloc.typeIsAny = typeIsAny;
    _propertyFilterBloc.typeIsApartment = typeIsApartment;
    _propertyFilterBloc.typeIsCondo = typeIsCondo;
    _propertyFilterBloc.typeIsDuplex = typeIsDuplex;
    _propertyFilterBloc.typeIsHouse = typeIsHouse;
    _propertyFilterBloc.typeIsTownHouse = typeIsTownHouse;
    _propertyFilterBloc.durationAtLeastAYear = durationAtLeastAYear;
    _propertyFilterBloc.durationAtFewMonths = durationAtFewMonths;
    _propertyFilterBloc.durationAtFewWeeks = durationAtFewWeeks;
    _propertyFilterBloc.roommatesNeeded = roommatesNeeded;
    _propertyFilterBloc.roommatesDoesNotNeeded = roommatesDoesNotNeeded;
    _propertyFilterBloc.bedroomIsStudio = bedroomIsStudio;
    _propertyFilterBloc.bedroomIs1 = bedroomIs1;
    _propertyFilterBloc.bedroomIs2 = bedroomIs2;
    _propertyFilterBloc.bedroomIs3 = bedroomIs3;
    _propertyFilterBloc.bedroomIs4Plus = bedroomIs4Plus;
    _propertyFilterBloc.bathroomIs1 = bathroomIs1;
    _propertyFilterBloc.bathroomIs2 = bathroomIs2;
    _propertyFilterBloc.bathroomIs3 = bathroomIs3;
    _propertyFilterBloc.bathroomIs4 = bathroomIs4;
    _propertyFilterBloc.bathroomIs5Plus = bathroomIs5Plus;
    _propertyFilterBloc.isDogAllowed = isDogAllowed;
    _propertyFilterBloc.isCatAllowed = isCatAllowed;
    _propertyFilterBloc.isFurnished = isFurnished;
    _propertyFilterBloc.isUnfurnished = isUnfurnished;
    _propertyFilterBloc.amenityIsAny = amenityIsAny;
    _propertyFilterBloc.amenityIsLaundryAvailable = amenityIsLaundryAvailable;
    _propertyFilterBloc.amenityIsACAvailable = amenityIsACAvailable;
    _propertyFilterBloc.amenityIsHeatingAvailable = amenityIsHeatingAvailable;
    _propertyFilterBloc.amenityIsParkingAvailable = amenityIsParkingAvailable;
    _propertyFilterBloc.amenityIsGatedEntryAvailable =
        amenityIsGatedEntryAvailable;
    _propertyFilterBloc.amenityIsDoormanAvailable = amenityIsDoormanAvailable;
    _propertyFilterBloc.amenityIsGymAvailable = amenityIsGymAvailable;
    _propertyFilterBloc.amenityIsPoolAvailable = amenityIsPoolAvailable;
    _propertyFilterBloc.amenityIsDishwasherAvailable =
        amenityIsDishwasherAvailable;
  }
}

class ChipData {
  final String name;
  final bool isSelected;
  final String variableName;

  ChipData({this.name, this.isSelected, this.variableName});
}
