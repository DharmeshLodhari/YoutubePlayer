import 'package:Slydo/screens/more_apps/movies/custom_slider_thumb_circle_for_range_slider.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import 'property_tile.dart';

class SearchProperty extends StatefulWidget {
  @override
  _SearchPropertyState createState() => _SearchPropertyState();
}

class _SearchPropertyState extends State<SearchProperty> {
  List<String> movieCategoryList = ["Comedy", "Fantasy", "Sci-fi", "Action"];
  List<String> movieYearList = [
    "2001",
    "2002",
    "2003",
    "2004",
    "2005",
    "2006",
    "2007"
  ];

  String selectedMovieCategory;
  String selectedMovieYear;
  int selectedRating;
  RangeValues selectedPriceValue = RangeValues(5, 56);

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

  /// type of property filter variables
  bool typeIsAny = false;
  bool typeIsApartment = false;
  bool typeIsCondo = false;
  bool typeIsDuplex = false;
  bool typeIsHouse = false;
  bool typeIsTownHouse = false;

  @override
  Widget build(BuildContext context) {
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
          autofocus: true,
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
                                  getPropertyType(
                                    bottomSheetSetState,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Duration",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {
                                        "name": "At least a year",
                                        "isSelected": true
                                      },
                                      {
                                        "name": "At few months",
                                        "isSelected": false
                                      },
                                      {
                                        "name": "At few weeks",
                                        "isSelected": false
                                      },
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Roommates",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {
                                        "name": "I need a roommate",
                                        "isSelected": false
                                      },
                                      {
                                        "name": "I don't want roommate",
                                        "isSelected": true
                                      },
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Bedrooms",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {"name": "Studio", "isSelected": false},
                                      {"name": "1 bed", "isSelected": false},
                                      {"name": "2 bed", "isSelected": true},
                                      {"name": "3 bed", "isSelected": false},
                                      {"name": "4+", "isSelected": false},
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Bathrooms",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {"name": "1 bath", "isSelected": false},
                                      {"name": "2 bath", "isSelected": true},
                                      {"name": "3 bath", "isSelected": false},
                                      {"name": "4 bath", "isSelected": false},
                                      {"name": "5+", "isSelected": false},
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Pet Policy",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {
                                        "name": "Dogs allowed",
                                        "isSelected": true
                                      },
                                      {
                                        "name": "Cats allowed",
                                        "isSelected": false
                                      },
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Furniture",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {"name": "Furnished", "isSelected": true},
                                      {
                                        "name": "Unfurnished",
                                        "isSelected": false
                                      },
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  getChipsList(
                                    title: "Amenities",
                                    bottomSheetSetState: bottomSheetSetState,
                                    children: [
                                      {"name": "Any", "isSelected": false},
                                      {"name": "Laundry", "isSelected": true},
                                      {"name": "A/C", "isSelected": false},
                                      {"name": "Heating", "isSelected": false},
                                      {"name": "Parking", "isSelected": true},
                                      {
                                        "name": "Gated entry",
                                        "isSelected": false
                                      },
                                      {"name": "Doorman", "isSelected": false},
                                      {"name": "Gym", "isSelected": true},
                                      {"name": "Pool", "isSelected": true},
                                      {
                                        "name": "Dishwasher",
                                        "isSelected": false
                                      },
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
      List<Map<String, dynamic>> children}) {
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
                    title: element["name"],
                    bottomSheetSetState: bottomSheetSetState,
                    isSelected: element["isSelected"]))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget getPropertyType(StateSetter bottomSheetSetState) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type",
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
            children: [
              selectionCard(
                  title: "Any",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: true),
              selectionCard(
                  title: "Apartment",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: typeIsApartment),
              selectionCard(
                  title: "Condo",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: typeIsCondo),
              selectionCard(
                  title: "Duplex",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: typeIsDuplex),
              selectionCard(
                  title: "House",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: typeIsHouse),
              selectionCard(
                  title: "Townhouse",
                  bottomSheetSetState: bottomSheetSetState,
                  isSelected: typeIsTownHouse),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectionCard(
      {String title, StateSetter bottomSheetSetState, bool isSelected}) {
    return InkWell(
      onTap: () {
        debugPrint("is Selected:- $isSelected");
        isSelected = !isSelected;

        setState(() {});
        bottomSheetSetState(() {});
        debugPrint("is Selected:- $isSelected");
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
            color: isSelected ? navyBlue : Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            border: new Border.all(
                color: isSelected ? navyBlue : lightGrey,
                width: 1.0,
                style: BorderStyle.solid),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : blackFont,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget getMovieYearDropDown(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Year",
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
              selectedMovieYear != null ? selectedMovieYear : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: blackFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectYear(bottomSheetSetState);
            },
          ),
        ),
      ],
    );
  }

  void selectYear(StateSetter bottomSheetSetState) async {
    final pressedMovieYear = await showDialog<String>(
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
                        children: movieYearList.map<Widget>((year) {
                          if (selectedMovieYear == year) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  year,
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
                                  Navigator.pop(context, year);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              year,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, year);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedMovieYear != null) {
      selectedMovieYear = pressedMovieYear;
      bottomSheetSetState(() {});
    }
  }

  Widget getMovieRatingSelection(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rating",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: List.generate(5, (index) {
            if (selectedRating != null) {
              return Expanded(
                child: Row(
                  children: [
                    movieRatingButton(
                      bottomSheetSetState,
                      isSelected: selectedRating == index,
                      index: index,
                    ),
                  ],
                ),
              );
            }
            return Expanded(
              child: Row(
                children: [
                  movieRatingButton(
                    bottomSheetSetState,
                    index: index,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget movieRatingButton(StateSetter bottomSheetSetState,
      {bool isSelected = false, int index}) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:
              isSelected ? selectedListItemBackgroundBlue : HexColor("F8F9FA"),
        ),
        child: Row(
          children: [
            Text(
              (index + 1).toString(),
              style: TextStyle(
                  color: isSelected ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 2,
            ),
            Icon(
              SlydoAppIcon.star,
              size: 10,
              color: isSelected ? navyBlue : blackFont,
            )
          ],
        ),
      ),
      onTap: () {
        selectedRating = index;
        bottomSheetSetState(() {});
      },
    );
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
      onPressed: () {},
      text: "Submit",
      textColor: Colors.white,
    );
  }
}
