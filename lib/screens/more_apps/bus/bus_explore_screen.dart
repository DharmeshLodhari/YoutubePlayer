import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusExploreScreen extends StatefulWidget {
  @override
  _BusExploreScreenState createState() => _BusExploreScreenState();
}

class _BusExploreScreenState extends State<BusExploreScreen> {
  List<String> fromPlace = ["Lagos"];
  List<String> toPlace = ["Abuja"];
  List<String> classes = ["A", "B"];

  String selectedTripType = "One way";

  var selectedFromPlace;
  var selectedToPlace;
  var selectedClass;

  DateTime departureDate = DateTime.now();
  DateTime arrivalDate = DateTime.now();

  late BusDashboardBloc _busDashboardBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
          _busDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Bus",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    _busDashboardBloc = Provider.of<BusDashboardBloc>(context);
    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: iconBtnGrey,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconBtnGrey, width: 1)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    getTripType(),
                    SizedBox(
                      height: 20,
                    ),
                    getFromPlaceDropDown(),
                    SizedBox(
                      height: 20,
                    ),
                    getToPlaceDropDown(),
                    SizedBox(
                      height: 20,
                    ),
                    getDateField(),
                    SizedBox(
                      height: 20,
                    ),
                    getClassDropDown(),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: submitButton(),
        )
      ],
    ));
  }

  Widget getTripType() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                child: Row(
                  children: [
                    Icon(
                      selectedTripType == "One way"
                          ? Icons.radio_button_checked_sharp
                          : Icons.radio_button_off_sharp,
                      color: selectedTripType == "One way"
                          ? navyBlue
                          : dividerColor,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "One way",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: selectedTripType == "One way"
                              ? navyBlue
                              : blackFont,
                          fontSize: 14.0,
                          fontWeight: selectedTripType == "One way"
                              ? FontWeight.w600
                              : FontWeight.w400),
                    )
                  ],
                ),
                onTap: () {
                  selectedTripType = "One way";
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: InkWell(
                child: Row(
                  children: [
                    Icon(
                      selectedTripType == "Round trip"
                          ? Icons.radio_button_checked_sharp
                          : Icons.radio_button_off_sharp,
                      color: selectedTripType == "Round trip"
                          ? navyBlue
                          : dividerColor,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Round trip",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: selectedTripType == "Round trip"
                              ? navyBlue
                              : blackFont,
                          fontSize: 14.0,
                          fontWeight: selectedTripType == "Round trip"
                              ? FontWeight.w600
                              : FontWeight.w400),
                    )
                  ],
                ),
                onTap: () {
                  selectedTripType = "Round trip";
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getDateField() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                lastDate: DateTime(2101),
              ).then((value) {
                departureDate = DateTime(value!.year, value.month, value.day);
                setState(() {});
              }).catchError((error) {});
            },
            child: CustomizedDropDownField(
              title: "Departure date",
              child: Container(
                child: ListTile(
                  dense: true,
                  title: Text(
                    formatDateInDigit(departureDate),
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
        selectedTripType == "Round trip"
            ? SizedBox(
                width: 10,
              )
            : Container(),
        selectedTripType == "Round trip"
            ? Expanded(
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
                      arrivalDate =
                          DateTime(value!.year, value.month, value.day);
                      setState(() {});
                    }).catchError((error) {});
                  },
                  child: CustomizedDropDownField(
                    title: "Arrival date",
                    child: Container(
                      child: ListTile(
                        dense: true,
                        title: Text(
                          formatDateInDigit(arrivalDate),
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
            : Container(),
      ],
    );
  }

  Widget getFromPlace() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<String>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context)!.category),
              ),
            ],
          ),
          value: selectedFromPlace,
          onChanged: (String? value) {
            setState(() {
              selectedFromPlace = value;
            });
          },
          items: fromPlace.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getFromPlaceDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "From",
          style: TextStyle(color: darkGrey, fontSize: 14),
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
              selectedFromPlace != null ? selectedFromPlace : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectFromPlace();
            },
          ),
        ),
      ],
    );
  }

  void selectFromPlace() async {
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
                        children: fromPlace.map<Widget>((category) {
                          if (selectedFromPlace == category) {
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
      selectedFromPlace = pressedCategory;
      setState(() {});
    }
  }

  Widget getToPlace() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<String>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context)!.category),
              ),
            ],
          ),
          value: selectedFromPlace,
          onChanged: (String? value) {
            setState(() {
              selectedFromPlace = value;
            });
          },
          items: toPlace.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getToPlaceDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "To",
          style: TextStyle(color: darkGrey, fontSize: 14),
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
              selectedToPlace != null ? selectedToPlace : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectToPlace();
            },
          ),
        ),
      ],
    );
  }

  void selectToPlace() async {
    final pressedPlace = await showDialog<String>(
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
                        children: toPlace.map<Widget>((category) {
                          if (selectedToPlace == category) {
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
    if (pressedPlace != null) {
      selectedToPlace = pressedPlace;
      setState(() {});
    }
  }

  Widget getClass() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<String>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context)!.category),
              ),
            ],
          ),
          value: selectedClass,
          onChanged: (String? value) {
            setState(() {
              selectedClass = value;
            });
          },
          items: classes.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget getClassDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Class service",
          style: TextStyle(color: darkGrey, fontSize: 14),
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
              selectedClass != null ? selectedClass : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectClass();
            },
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/search-bus");
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Search",
    );
  }

  void selectClass() async {
    final pressedPlace = await showDialog<String>(
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
                        children: classes.map<Widget>((category) {
                          if (selectedToPlace == category) {
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
    if (pressedPlace != null) {
      selectedClass = pressedPlace;
      setState(() {});
    }
  }
}
