import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/job_location_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
// import 'package:Slydo/screens/more_apps/service_hub/screens/jobs_job_detail.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../routes/route_constants.dart';

// ignore: list_remove_unrelated_type
class JobsSearchFilter extends StatefulWidget {
  const JobsSearchFilter({Key? key});

  @override
  State<JobsSearchFilter> createState() => _JobsSearchFilterState();
}

class _JobsSearchFilterState extends State<JobsSearchFilter> {
  String productPrice = "";
  String priceFrom = "";
  String priceTo = "";
  String? selectedSorting;
  List<String> sortByList = [
    "Oldest",
    "Most Recent",
    "Price Low to High",
    "Price High to Low"
  ];
  bool isSelected = false;
  String? selected;
  String? selectedCategory;
  String? displayCategory;
  String? selectedState;
  String? displayState;
  bool isCategoryLoading = false;
  bool isLocationLoading = false;
  String? categoryNext = "";
  String? locationNext = "";
  String? categoryPrevious = "";
  String? locationPrevious = "";
  bool noCatinList = false;
  bool noLocinList = false;
  int? categoryCount = 0;
  int? locationCount = 0;
  List<CategoryListData?> categoriesList = [];
  List<CategoryListData?> categoriesListCopy = [];
  List<LocationData?> locationsList = [];
  List<LocationData?> locationsListCopy = [];
  List<String> pickedStateList = [];
  List<String> pickedStateListSlug = [];
  Map<String, bool> stateCheckMark = {};

  List<String> categoriesNameList = [];
  final GlobalKey<ScaffoldMessengerState> _filterScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final ScrollController _categoriesScrollController = ScrollController();
  final ScrollController _locationScrollController = ScrollController();

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  List<LocationData> selectedItems = [];
  Map<String, dynamic> filterMap = {
    'category': "",
    'sortby': "",
    'priceFrom': '',
    'priceTo': '',
    'location': ''
  };

  List<String?> listStates = [];

  void getCategoriesList() async {
    if (!isCategoryLoading) {
      if (categoryNext != null && !isCategoryLoading) {
        isCategoryLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService()
            .getListOfCategories(categoryNext, categoryPrevious);

        if (result == null) {
          noCatinList = true;

          isCategoryLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        categoryCount = result.count;
        categoryNext = result.next;
        categoryPrevious = result.previous;
        final tempList = result.results;
        if (mounted) {
          setState(() {
            noCatinList = false;
            isCategoryLoading = false;
            categoriesList.addAll(tempList!);
            categoriesListCopy = categoriesList;
            tempList.forEach((element) {
              categoriesNameList.add(element.name!);
            });
          });
        }
      }
      if (categoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noCatinList = true;
          });
        }
      } else if (categoryNext == null && categoriesList.length > 6) {
        // _filterScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: const Duration(milliseconds: 500),
        // ));
        return null;
      }
    }
  }

  Future<void> getLocationList() async {
    if (!isLocationLoading) {
      if (locationNext != null && !isLocationLoading) {
        isLocationLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService()
            .getJobLocation(locationNext, locationPrevious);

        if (result == null) {
          noLocinList = true;

          isLocationLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        locationCount = result.count;
        locationNext = result.next;
        locationPrevious = result.previous;
        final tempList = result.results;

        if (mounted) {
          setState(() {
            noLocinList = false;
            isLocationLoading = false;
            locationsList.addAll(tempList!);
            locationsListCopy = locationsList;
            tempList.forEach((element) {
              listStates.add(element.name!);
            });
          });
        }
        locationsListCopy.forEach((element) {
          stateCheckMark[element!.name!] = false;
        });
      }
      if (locationsList.isEmpty) {
        if (mounted) {
          setState(() {
            noLocinList = true;
          });
        }
      } else if (locationNext == null && locationsList.length > 6) {
        // _filterScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: const Duration(milliseconds: 500),
        // ));
      }
    }
  }

  @override
  void initState() {
    getCategoriesList();
    getLocationList();
    _categoriesScrollController.addListener(() {
      if (_categoriesScrollController.position.pixels ==
              _categoriesScrollController.position.maxScrollExtent &&
          _categoriesScrollController.position.pixels != 0) {
        getCategoriesList();
      }
    });
    _locationScrollController.addListener(() {
      if (_locationScrollController.position.pixels ==
              _locationScrollController.position.maxScrollExtent &&
          _locationScrollController.position.pixels != 0) {
        getLocationList();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _filterScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              getFilterField(context),
              if (isCategoryLoading)
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: greyBorderColor,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 14,
                      mainAxisExtent: 180,
                      crossAxisSpacing: 15,
                      maxCrossAxisExtent: 200,
                    ),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox.shrink(),
              Visibility(
                visible: !isCategoryLoading && categoriesList.isEmpty,
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/no_moment_lottie.json'),
                      const SizedBox(height: 20),
                      const Text('No items at the moment'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getFilterField(BuildContext context) {
    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }
    return categoryNext == "" && isCategoryLoading
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(22.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getCategoryField(),
                const SizedBox(
                  height: 18,
                ),
                FilterDropdown(
                  selectedFilter: selectedSorting,
                  hintText: "Sort by",
                  list: sortByList,
                  onChangedCallback: (value) {
                    selectedSorting = value.toString();
                    filterMap['sortby'] = selectedSorting!;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  AppLocalization.of(context)!.price,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 20,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                getPriceFieldRow(),
                const SizedBox(
                  height: 22.0,
                ),
                getStateDropDownField(),
                const SizedBox(height: 8),
                getPickedStates(),
                const SizedBox(
                  height: 30,
                ),
                getBtnRow(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            // ),
          );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.categories,
      titleColor: blackFont,
      fontSize: 20,
      height: 20,
      fontWeight: FontWeight.w600,
      child: ListTile(
        dense: true,
        title: Text(
          displayCategory != null ? displayCategory! : "",
          style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    categoriesList = categoriesListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Choose category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      categoriesList = categoriesListCopy
                          .where((element) => element!.name!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      categoriesList = categoriesListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        final bool isTop = metrics.pixels == 0;
                        if (!isTop) {
                          debugPrint('At the bottom');
                          changeState(() {});
                        }
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _categoriesScrollController,
                      shrinkWrap: true,
                      itemCount: categoriesList.length,
                      itemBuilder: (context, index) {
                        final CategoryListData category =
                            categoriesList[index]!;

                        return ListTile(
                          title: Text(
                            "${category.name}",
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 16,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400),
                          ),
                          dense: true,
                          onTap: () {
                            selectedCategory = category.slug;
                            displayCategory = category.name;
                            filterMap['category'] = category.slug;
                            Navigator.pop(context);
                            setState(() {});
                            // }
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (isCategoryLoading)
                  SpinKitRing(
                    size: 30,
                    lineWidth: 3,
                    color: darkGreyYarn,
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row getPriceFieldRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: getAmountFromField(),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          flex: 1,
          child: getAmountToField(),
        ),
      ],
    );
  }

  Widget getStateDropDownField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.state,
      titleColor: blackFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      child: ListTile(
        dense: true,
        title: Text(
          "",
          style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          popUpStateBottomSheet();
        },
      ),
    );
  }

  Future<void> popUpStateBottomSheet() async {
    await getLocationList();
    stateBottomSheet();
  }

  void stateBottomSheet() {
    locationsList = locationsListCopy;
    androidBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomizedTextFormField(
                  hintText: 'Search state',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      locationsList = locationsListCopy
                          .where((element) => element!.name!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(() {});
                    } else {
                      locationsList = locationsListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    '',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locationsList.length,
                    // controller: _locationScrollController,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: stateCheckMark[locationsList[index]!.name],
                        onChanged: (isChecked) {
                          setState(() {
                            changeState(() {
                              stateCheckMark[locationsList[index]!.name!] =
                                  isChecked!;
                            });
                            if (pickedStateList
                                .contains(locationsList[index]!.name)) {
                              pickedStateList
                                  .remove(locationsList[index]!.name);
                              pickedStateListSlug
                                  .remove(locationsList[index]!.slug);
                            } else {
                              pickedStateList.add(locationsList[index]!.name!);
                              pickedStateListSlug
                                  .add(locationsList[index]!.slug!);
                            }
                          });
                        },
                        title: Text(
                          messageDecoderWithEmoji(locationsList[index]?.name) ??
                              "",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                  ),
                ),
                CurvedButton(
                  text: 'Pick',
                  onPressed: () {
                    filterMap['location'] = pickedStateListSlug;
                    Navigator.pop(context);
                    // bottomSheetSetState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getPickedStates() {
    return SizedBox(
      height: pickedStateList.isEmpty ? 0 : 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pickedStateList
            .map(
              (e) => Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: greyBorderColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  e,
                  style: TextStyle(color: blackFont),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Row getBtnRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CurvedButton(
            onPressed: () {
              filterMap = {
                'category': "",
                'sortby': "",
                'priceFrom': '',
                'priceTo': '',
                'location': ''
              };
              selectedCategory = null;
              selectedSorting = null;
              priceFrom = '';
              priceTo = '';
              selectedItems.clear();
              setState(() {});
            },
            text: "Clear All",
            backgroundColor: const Color(0xfff4f5f6),
            textColor: blackFont,
          ),
        ),
        const SizedBox(
          width: 25,
        ),
        Expanded(
          flex: 1,
          child: CurvedButton(
            onPressed: () {
              debugPrint("$filterMap");

              Navigator.pushNamed(context, Routes.JOBS_SEARCH,
                  arguments: {'filterMap': filterMap});
              // Navigator.pop(context, filterMap);
            },
            text: "Apply",
          ),
        ),
        const SizedBox(
          height: 70,
        ),
      ],
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
          fontFamily: "Inter",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget getAmountFromField() {
    return CustomizedTextFormField(
      // labelText: AppLocalization.of(context)!.from,
      hintText: AppLocalization.of(context)!.from,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            priceFrom = double.parse(val.replaceAll(',', '')).toString();
            filterMap['priceFrom'] = moneyInputNormalizer(priceFrom).toString();
            setState(() {});
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getAmountToField() {
    return CustomizedTextFormField(
      hintText: AppLocalization.of(context)!.to,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            priceTo = double.parse(val.replaceAll(',', '')).toString();
            filterMap['prictTo'] = moneyInputNormalizer(priceTo).toString();
            setState(() {});
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }
}

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.list,
    required this.onChangedCallback,
    required this.hintText,
  });

  final String? selectedFilter;
  final List list;
  final void Function(String?) onChangedCallback;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffdce0e7),
          width: 1,
        ),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down),
          hint: Text(
            hintText,
            style: const TextStyle(
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
