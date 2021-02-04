import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/screens/more_apps/movies/custom_slider_thumb_circle_for_range_slider.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import 'event_auth.dart';
import 'models/PartialEventItem.dart';

class SearchEvent extends StatefulWidget {
  @override
  _SearchEventState createState() => _SearchEventState();
}

class _SearchEventState extends State<SearchEvent> {
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

  List<PartialEventItem> eventList = [];

  bool isLoading = false;
  // RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  void getResult() async {
    isLoading = true;
    eventList.clear();
    if (mounted) setState(() {});

    eventList = await EventAuthService().getPartialEventList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  // void _onRefresh() async {
  //   Connectivity().checkConnectivity().then((value) {
  //     var connectionResult = value;
  //     if (connectionResult == ConnectivityResult.wifi ||
  //         connectionResult == ConnectivityResult.mobile) {
  //       getResult();
  //       _refreshController.refreshCompleted();
  //     } else {
  //       Toast.show(
  //           AppLocalization.of(context).internetConnectionNotAvailable, context,
  //           gravity: Toast.BOTTOM, backgroundColor: navyBlue);
  //       _refreshController.refreshCompleted();
  //     }
  //   });
  // }

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
        filterMovieBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget filterMovieBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.filter,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showFilterMovieSheet();
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
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularLoadingIndicator(),
                  ),
                )
              : eventList.isEmpty
                  ? Expanded(child: searchBackground())
                  : Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: eventList
                              .map(
                                (element) => Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: EventTileWithHeart(
                                      partialEvent: element,
                                    )),
                              )
                              .toList(),
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

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionHandleColor: navyBlue,
        ),
        child: TextFormField(
          onFieldSubmitted: (val) {
            getResult();
          },
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

  void showFilterMovieSheet() {
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
                      padding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Filter",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: blackFont),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          getMovieCategoryDropDown(bottomSheetSetState),
                          SizedBox(
                            height: 20,
                          ),
                          getMovieYearDropDown(bottomSheetSetState),
                          SizedBox(
                            height: 20,
                          ),
                          getMovieRatingSelection(bottomSheetSetState),
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
                    )),
          );
        });
  }

  Widget getMovieCategoryDropDown(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context).category,
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
              selectedMovieCategory != null ? selectedMovieCategory : "",
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
              selectCategory(bottomSheetSetState);
            },
          ),
        ),
      ],
    );
  }

  void selectCategory(StateSetter bottomSheetSetState) async {
    final pressedCategory = await showDialog<String>(
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
                        children: movieCategoryList.map<Widget>((category) {
                          if (selectedMovieCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category,
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
                              category,
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
      selectedMovieCategory = pressedCategory;
      bottomSheetSetState(() {});
    }
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
          rangeThumbShape: CustomRangeThumbShapeForMovie(
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
        Navigator.pop(context);
        getResult();
      },
      text: "Submit",
      textColor: Colors.white,
    );
  }
}
