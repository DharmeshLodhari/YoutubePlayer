import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/hotels/models/hotel_room_item.dart';
import 'package:Slydo/screens/more_apps/movies/custom_slider_thumb_circle_for_range_slider.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'hotel_auth.dart';
import 'hotel_tile.dart';

class SearchHotel extends StatefulWidget {
  const SearchHotel({super.key});

  @override
  State<SearchHotel> createState() => _SearchHotelState();
}

class _SearchHotelState extends State<SearchHotel> {
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

  String? selectedMovieCategory;
  String? selectedMovieYear;
  int? selectedRating;
  RangeValues selectedPriceValue = const RangeValues(5, 56);

  List<HotelRoomItem> hotelRooms = [];
  bool isLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

  Widget searchBackground() {
    return NoItemInList(
      msg: "Please type something to get results",
      isResult: false,
    );
  }

  void getResult() async {
    isLoading = true;
    hotelRooms.clear();
    if (mounted) setState(() {});

    hotelRooms = await HotelAuthService().getHotelRoomList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
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
        filterMovieBtn(),
        const SizedBox(
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
    return Column(
      children: [
        const SizedBox(
          height: 6,
        ),
        searchBox(),
        const SizedBox(
          height: 12,
        ),
        if (isLoading)
          Expanded(
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        else
          hotelRooms.isEmpty
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
                        children: hotelRooms
                            .map(
                              (element) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: HotelTileWithHeart(
                                    hotelRoom: element,
                                  )),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          autofocus: true,
          onFieldSubmitted: (test) {
            getResult();
          },
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
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefix: const Padding(
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
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
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
                          const SizedBox(
                            height: 40,
                          ),
                          getMovieCategoryDropDown(bottomSheetSetState),
                          const SizedBox(
                            height: 20,
                          ),
                          getMovieYearDropDown(bottomSheetSetState),
                          const SizedBox(
                            height: 20,
                          ),
                          getMovieRatingSelection(bottomSheetSetState),
                          const SizedBox(
                            height: 20,
                          ),
                          getPriceSelection(bottomSheetSetState),
                          const SizedBox(
                            height: 50,
                          ),
                          getFilerSubmitButton(),
                          const SizedBox(
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
          AppLocalization.of(context)!.category,
          style: TextStyle(color: blackFont, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedMovieCategory != null ? selectedMovieCategory! : "",
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
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
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
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedMovieYear != null ? selectedMovieYear! : "",
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
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
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
        const SizedBox(
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
      {bool isSelected = false, required int index}) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
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
            const SizedBox(
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

  Widget getPriceSelection(StateSetter bottomSheetSetState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Price",
        style: TextStyle(
            color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(
        height: 16,
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 1,
          rangeThumbShape: CustomRangeThumbShapeForMovie(
              selectedPriceValue.start.toInt(), selectedPriceValue.end.toInt()),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
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
        getResult();
      },
      text: "Submit",
      textColor: Colors.white,
    );
  }
}
