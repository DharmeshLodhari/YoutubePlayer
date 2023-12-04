import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class JobsSearchFilter extends StatefulWidget {
  const JobsSearchFilter({Key? key}) : super(key: key);

  @override
  State<JobsSearchFilter> createState() => _JobsSearchFilterState();
}

class _JobsSearchFilterState extends State<JobsSearchFilter> {
  String? selectedFilter;
  List list = ['Photography', 'Baby Care', 'Plumber'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              // width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xfffafbff),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0c31378c),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      color: Color(0xff75818f),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  FilterDropdown(
                    selectedFilter: selectedFilter,
                    hintText: "Choose category",
                    list: list,
                    onChangedCallback: (value) {
                      selectedFilter = value.toString();
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  FilterDropdown(
                    selectedFilter: selectedFilter,
                    hintText: "Sort by",
                    list: list,
                    onChangedCallback: (value) {
                      selectedFilter = value.toString();
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Price",
                    style: TextStyle(
                      color: Color(0xff75818f),
                      fontSize: 12,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        "Filter",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    Key? key,
    required this.selectedFilter,
    required this.list,
    required this.onChangedCallback,
    required this.hintText,
  }) : super(key: key);

  final String? selectedFilter;
  final List list;
  final void Function(String?) onChangedCallback;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xffdce0e7),
          width: 1,
        ),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: selectedFilter,
          icon: Icon(Icons.keyboard_arrow_down),
          hint: Text(
            hintText,
            style: TextStyle(
              color: Color(0xff75818f),
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
          items: list.map((val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChangedCallback,
        ),
      ),
    );
  }
}
