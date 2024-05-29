import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/util.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../widget/item_display_card.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/user_profile/models/search_user_item_with_filter.dart';
import '../more_apps/user_profile/models/user.dart';
import '../more_apps/yarn/utils/yarn_enum.dart';

class SearchNearByBusiness extends StatefulWidget {
  @override
  _SearchNearByBusinessState createState() => _SearchNearByBusinessState();
}

class _SearchNearByBusinessState extends State<SearchNearByBusiness> {
  String? selectedRating;
  String? state;
  String? lga;
  List<CustomerProfile> nearByBusiness = [];

  final GlobalKey<ScaffoldState> _scaffoldSearchKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;

  //pagination variables
  int? count = 0;
  String? next = "";
  String? previous = "";
  final ScrollController _scrollController = ScrollController();
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  ProductCategory? pressedCategory;
  ProductCategory? selectedProductCategory;
  List<ProductCategory>? productCategories;
  List<ProductCategory>? productCategoriesCopy;
  List<String> stateList = [];
  List<String> stateListCopy = [];
  List<String> lgaList = [];
  List<String> lgaListCopy = [];
  String productCategory = "";

  TextEditingController searchController = TextEditingController();
  List<String> pickedStateList = [];
  List<String> pickedLgaList = [];
  List<String> pickedCategoryList = [];
  Map<String, bool> categoryCheckMark = {};
  Map<String, bool> stateCheckMark = {};
  Map<String, bool> lgaCheckMark = {};

  @override
  void initState() {
    getCategories();
    getStatesList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getList();
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.length >= 3) {
        setState(() {
          _refreshList();
        });
      }
      if (nearByBusiness.isNotEmpty || searchController.text.length != 0) {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = true;
          });
        }
      }
    });
    super.initState();
  }

  void _refreshList() {
    count = 0;
    next = "";
    previous = "";
    nearByBusiness.clear();
    noItemInList = false;
    getStatesList();
    getList();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }

        final Map<String, dynamic>? result =
            await ShoppingAuthService().searchMerchant(
          next,
          previous,
          filterOptions: SearchItemWithFilterModelForSuperStore(
            searchedText: searchController.text,
            state: pickedStateList,
            lga: pickedLgaList,
            categories: pickedCategoryList,
          ),
        );

        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final List? tempList = result['results'];
        debugPrint('TEMP LIST --> $tempList');
        if (mounted) {
          isLoading = false;
          try {
            for (var result in tempList!) {
              nearByBusiness.add(result);
            }
          } catch (e) {
            debugPrint("error adding products $e");
          }
          setState(() {});
          debugPrint("ALL $nearByBusiness");
        }
      }
      if (nearByBusiness.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && nearByBusiness.length > 6) {
        _scaffoldMessengerSearchKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
                AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      productCategories = await ShoppingAuthService().getProductCategories();
      productCategoriesCopy = productCategories;

      for (var element in productCategoriesCopy!) {
        categoryCheckMark[element.name] = false;
      }
    } catch (e) {
      productCategories = [];
      productCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void getStatesList() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      stateList = getAllStates();
      stateListCopy = stateList;

      for (var element in stateListCopy) {
        stateCheckMark[element] = false;
      }
    } catch (e) {
      stateList = [];
      stateListCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerSearchKey,
      child: Scaffold(
        key: _scaffoldSearchKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  bool showSortByBox = false;
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
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (nearByBusiness.isNotEmpty)
          RoundedBackgroundIcon(
            height: 34,
            width: 34,
            icon: Icon(
              SlydoAppIcon.filter,
              size: 16,
              color: blackFont,
            ),
            onTap: () {
              setState(() {
                showSortByBox = !showSortByBox;
              });
            },
            backgroundColor: iconBtnGrey,
            enableMargin: true,
          )
        else
          const SizedBox.shrink(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 6),
          searchBox(),
          const SizedBox(height: 12),
          if (isLoading)
            const CircularProgressIndicator()
          else
            const SizedBox.shrink(),
          if (isSearchIsEmpty)
            Expanded(
              child: NoItemInList(
                msg:
                    AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
                isResult: false,
              ),
            )
          else
            noItemInList
                ? Expanded(
                    child: NoItemInList(
                      msg: AppLocalization.of(context)!.noResultFound,
                    ),
                  )
                : Expanded(
                    child: ListView(
                        children: nearByBusiness
                            .map(
                              (product) => Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: FindBusiness(
                                    customerProfile: product,
                                    tileRenderPlace:
                                        TileRenderPlace.YarnProductService,
                                    callback: (username, value) {
                                      //create a list to edit
                                      final List<CustomerProfile>
                                          customerProfileList = nearByBusiness;
                                      // modify customerProfileList for the username and refresh the list
                                      // set the isFollowing for that particular user
                                      for (var customer
                                          in customerProfileList) {
                                        if (customer.userName == username) {
                                          customer.isFollowing =
                                              value; // Modify the isFollowing property
                                        }
                                      }

                                      nearByBusiness = [];
                                      nearByBusiness = customerProfileList;

                                      if (mounted) setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList()),
                  ),
        ],
      ),
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
          controller: searchController,
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                nearByBusiness.clear();
                noItemInList = false;
                getList();
              });
            }
          },
          autofocus: true,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.filter_alt_rounded,
                color: navyBlue,
                size: 20,
              ),
              onPressed: () {
                showFilterNearByBusinessSheet();
              },
            ),
            hintText: "Search Business Near by you",
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

  void showFilterNearByBusinessSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
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
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Filter",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          color: blackFont),
                    ),
                    const SizedBox(height: 40),
                    getCategoryField(bottomSheetSetState),
                    const SizedBox(height: 8),
                    getPickedCategoryNames(),
                    const SizedBox(height: 20),
                    getStateDropDownField(bottomSheetSetState),
                    const SizedBox(height: 8),
                    getPickedStates(),
                    const SizedBox(height: 24),
                    if (pickedStateList.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      getLgaDropDownField(bottomSheetSetState),
                      const SizedBox(height: 8),
                      getPickedLga(),
                    ],
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(child: getClearAllBtn()),
                        const SizedBox(width: 20),
                        Expanded(child: getFilterSubmitBtn()),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getCategoryField(StateSetter bottomSheetSetState) {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.category,
      child: ListTile(
        dense: true,
        title: Text(
          selectedProductCategory != null ? selectedProductCategory!.name : "",
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
          categoryAndroidSheet(bottomSheetSetState);
        },
      ),
    );
  }

  Widget getPickedCategoryNames() {
    return SizedBox(
      height: pickedCategoryList.isEmpty ? 0 : 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pickedCategoryList
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

  void categoryAndroidSheet(StateSetter bottomSheetSetState) {
    productCategories = productCategoriesCopy;
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
                  hintText: 'Search category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      productCategories = productCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      productCategories = productCategoriesCopy;
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
                    itemCount: productCategories!.length,
                    itemBuilder: (context, index) {
                      final ProductCategory category =
                          productCategories![index];
                      return CheckboxListTile(
                        value: categoryCheckMark[category.name] ?? false,
                        onChanged: (isChecked) {
                          changeState(() {
                            categoryCheckMark[category.name] = isChecked!;
                          });
                          if (pickedCategoryList.contains(category.name)) {
                            pickedCategoryList.remove(category.name);
                          } else {
                            pickedCategoryList.add(category.name);
                          }
                        },
                        title: Text(
                          category.name,
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
                    Navigator.pop(context);
                    bottomSheetSetState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getStateDropDownField(StateSetter bottomSheetSetState) {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.state,
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
          stateBottomSheet(bottomSheetSetState);
        },
      ),
    );
  }

  void stateBottomSheet(StateSetter bottomSheetSetState) {
    stateList = stateListCopy;
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
                      stateList = stateListCopy
                          .where((element) => element
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(() {});
                    } else {
                      stateList = stateListCopy;
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
                    itemCount: stateList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: stateCheckMark[stateList[index]],
                        onChanged: (isChecked) {
                          changeState(() {
                            stateCheckMark[stateList[index]] = isChecked!;
                          });
                          if (pickedStateList.contains(stateList[index])) {
                            pickedStateList.remove(stateList[index]);
                          } else {
                            pickedStateList.add(stateList[index]);
                          }
                        },
                        title: Text(
                          stateList[index],
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
                    // debugPrint('PICKED CAT ---> $pickedStateList');
                    Navigator.pop(context);
                    bottomSheetSetState(() {});
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

  Widget getLgaDropDownField(StateSetter bottomSheetSetState) {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.city,
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
          lgaList = [];
          lgaListCopy = [];
          lgaList = getLga(states: pickedStateList);
          lgaListCopy = lgaList;

          for (var element in lgaListCopy) {
            lgaCheckMark[element] = false;
          }
          bottomSheetSetState(() {});

          lgaBottomSheet(bottomSheetSetState);
        },
      ),
    );
  }

  void lgaBottomSheet(StateSetter bottomSheetSetState) {
    lgaList = lgaListCopy;
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
                  hintText: 'Search city',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      lgaList = lgaListCopy
                          .where((element) => element
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(() {});
                    } else {
                      lgaList = lgaListCopy;
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
                    itemCount: lgaList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: lgaCheckMark[lgaList[index]],
                        onChanged: (isChecked) {
                          changeState(() {
                            lgaCheckMark[lgaList[index]] = isChecked!;
                          });
                          if (pickedLgaList.contains(lgaList[index])) {
                            pickedLgaList.remove(lgaList[index]);
                          } else {
                            pickedLgaList.add(lgaList[index]);
                          }
                        },
                        title: Text(
                          lgaList[index],
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
                    debugPrint('PICKED CAT ---> $pickedLgaList');
                    Navigator.pop(context);
                    bottomSheetSetState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getPickedLga() {
    return SizedBox(
      height: pickedLgaList.isEmpty ? 0 : 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pickedLgaList
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

  Widget getClearAllBtn() {
    return CurvedButton(
      backgroundColor: Colors.grey,
      onPressed: () {
        Navigator.pop(context);
        pickedCategoryList.clear();
        pickedStateList.clear();
        pickedLgaList.clear();
        categoryCheckMark.clear();
        stateCheckMark.clear();
        lgaCheckMark.clear();

        _refreshList();
      },
      text: "Clear All",
      textColor: Colors.white,
    );
  }

  Widget getFilterSubmitBtn() {
    return CurvedButton(
      backgroundColor: navyBlue,
      onPressed: () {
        Navigator.pop(context);
        _refreshList();
      },
      text: "Apply",
      textColor: Colors.white,
    );
  }
}
