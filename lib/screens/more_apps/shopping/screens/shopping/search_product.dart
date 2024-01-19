import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/util.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../../user_profile/models/search_user_item_with_filter.dart';
import '../../models/store.dart';

class SearchProduct extends StatefulWidget {
  dynamic arguments;
  SearchProduct({Key? key, this.arguments}) : super(key: key);

  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  List<String> stateList = [
    "Lagos",
    "Ogun",
  ];
  List<String> stateListCopy = [
    "Lagos",
    "Ogun",
  ];

  String? selectedRating;

  List<String> sortByMenuItems = [
    'Best match',
    'Highest price',
    'Lowest price'
  ];
  List<Product> products = [];

  GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;

  //pagination variables
  int? count = 0;
  String? next = "";
  String? previous = "";
  ScrollController _scrollController = new ScrollController();
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";
  ProductCategory? pressedCategory;
  ProductCategory? selectedProductCategory;
  List<ProductCategory>? productCategories;
  List<ProductCategory>? productCategoriesCopy;
  String productCategory = "";
  int? minAmount;
  int? maxAmount;
  String? sortBy;
  String? sortByMenuItemValue = 'Best match';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getCategories();
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
      if (products.isNotEmpty || searchController.text.length != 0) {
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

  _refreshList() {
    count = 0;
    next = "";
    previous = "";
    products.clear();
    noItemInList = false;
    getList();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }
        String url = widget.arguments != null
            ? "&${widget.arguments!.keys.first}=${widget.arguments!.values.first}"
            : "";
        Map<String, dynamic>? result =
            await ShoppingAuthService().searchUsersProductsInSuperStore(
          next,
          previous,
          filterOptions: SearchItemWithFilterModelForSuperStore(
            sortBy: sortBy,
            searchedText: searchController.text,
            minPrice: minAmount,
            maxPrice: maxAmount,
            rating: selectedRating != null
                ? (int.parse(selectedRating!) + 1).toString()
                : null,
            categories: pickedCategoryList,
          ),
          query: url,
        );

        // Map<String, dynamic>? result =
        //     await ShoppingAuthService().searchShoppingProductsInSuperStore(
        //   searchController.text,
        //   next,
        //   previous,
        // );

        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List? tempList = result['results'];
        debugPrint('TEMP LIST --> $tempList');
        if (mounted) {
          isLoading = false;
          try {
            tempList!.forEach((result) {
              products.add(result);
            });
          } catch (e) {
            debugPrint("error adding products $e");
          }
          setState(() {});
          debugPrint("ALL $products");
        }
      }
      if (products.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && products.length > 6) {
        _scaffoldMessengerSearchKey.currentState!.showSnackBar(
          SnackBar(
            content: Text(
                AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  List<String> pickedStateList = [];
  List<String> pickedCategoryList = [];
  Map<String, bool> categoryCheckMark = {};
  Map<String, bool> stateCheckMark = {"Lagos": false, "Ogun": false};

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      productCategories = await ShoppingAuthService().getProductCategories();
      productCategoriesCopy = productCategories;

      productCategoriesCopy!.forEach((element) {
        categoryCheckMark[element.name] = false;
      });
    } catch (e) {
      productCategories = [];
      productCategoriesCopy = [];
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
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        products.isNotEmpty
            ? RoundedBackgroundIcon(
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
            : SizedBox.shrink(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          showSortByBox ? sortByDropDown() : SizedBox.shrink(),
          SizedBox(height: 6),
          searchBox(),
          SizedBox(height: 12),
          isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
          isSearchIsEmpty
              ? Expanded(
                  child: NoItemInList(
                    msg: AppLocalization.of(context)!
                        .pleaseTypeSomethingToGetResult,
                    isResult: false,
                  ),
                )
              : noItemInList
                  ? Expanded(
                      child: NoItemInList(
                        msg: AppLocalization.of(context)!.noResultFound,
                      ),
                    )
                  : Expanded(
                      child: ListView(
                          children: products
                              .map(
                                (product) => Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: ShoppingTileWithHeartWithProduct(
                                    product: product,
                                  ),
                                ),
                              )
                              .toList()),
                    ),
        ],
      ),
    );
  }

  Widget sortByDropDown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton2(
            isExpanded: true,
            underline: SizedBox.shrink(),
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            value: sortByMenuItemValue,
            items: sortByMenuItems.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue == 'Best match') {
                sortBy = null;
                setState(() {
                  sortByMenuItemValue = newValue;
                });
                _refreshList();
                return;
              }
              String firstWord = newValue!.split(' ')[0];
              String secondWord = newValue.split(' ')[1];
              sortBy = "$firstWord-$secondWord".toLowerCase();

              setState(() {
                sortByMenuItemValue = newValue;
              });
              _refreshList();
            },
          ),
        ),
      ),
    );
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
          controller: searchController,
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                products.clear();
                noItemInList = false;
                getList();
              });
            }
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
                Icons.filter_alt_rounded,
                color: navyBlue,
                size: 20,
              ),
              onPressed: () {
                showFilterProductSheet();
              },
            ),
            hintText: "Search name, manufacturer, categories",
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

  void showFilterProductSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
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
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
                    SizedBox(height: 40),
                    getCategoryField(bottomSheetSetState),
                    SizedBox(height: 8),
                    getPikedCategoryNames(),
                    SizedBox(height: 20),
                    getProductRatingSelection(bottomSheetSetState),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: getPriceRange(bottomSheetSetState),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(child: getClearAllBtn()),
                        SizedBox(width: 20),
                        Expanded(child: getFilterSubmitBtn()),
                      ],
                    ),
                    SizedBox(height: 10),
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
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget getPikedCategoryNames() {
    return SizedBox(
      height: pickedCategoryList.isEmpty ? 0 : 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pickedCategoryList
            .map(
              (e) => Container(
                margin: EdgeInsets.all(6),
                padding: EdgeInsets.all(12),
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
                SizedBox(height: 20),
                InkWell(
                  onTap: () {},
                  child: Text(
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
                      ProductCategory category = productCategories![index];
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
                              fontWeight: FontWeight.w400),
                        ),
                      );

                      if (selectedProductCategory == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category.name,
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
                              pressedCategory = category;
                              Navigator.pop(context);
                              if (pressedCategory != null) {
                                selectedProductCategory = pressedCategory;
                                productCategory = selectedProductCategory!.name;
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }

                      return ListTile(
                        title: Text(
                          category.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedCategory = category;
                          Navigator.pop(context);
                          if (pressedCategory != null) {
                            selectedProductCategory = pressedCategory;
                            productCategory = selectedProductCategory!.name;
                            // setState(() {});
                            bottomSheetSetState(() {});
                          }
                        },
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
          selectedProductCategory != null ? selectedProductCategory!.name : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
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
                      stateList = ['Ogun'];
                      changeState(() {});
                    } else {
                      stateList = stateListCopy;
                      changeState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {},
                  child: Text(
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
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                  ),
                ),
                CurvedButton(
                  text: 'Pick',
                  onPressed: () {
                    debugPrint('PICKED CAT ---> $pickedStateList');
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

  Widget getProductRatingSelection(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rating",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        Row(
          children: List.generate(5, (index) {
            if (selectedRating != null) {
              return Expanded(
                child: Row(
                  children: [
                    productRatingButton(
                      bottomSheetSetState,
                      index: index,
                      isSelected: int.parse(selectedRating!) == index,
                    ),
                  ],
                ),
              );
            }
            return Expanded(
              child: Row(
                children: [
                  productRatingButton(
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

  Widget productRatingButton(StateSetter bottomSheetSetState,
      {bool isSelected = false, required int index}) {
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
            SizedBox(width: 2),
            Icon(
              SlydoAppIcon.star,
              size: 10,
              color: isSelected ? navyBlue : blackFont,
            )
          ],
        ),
      ),
      onTap: () {
        selectedRating = index.toString();
        bottomSheetSetState(() {});
      },
    );
  }

  Widget getPriceRange(bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price Range",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomizedTextFormField(
                labelText: 'From',
                initialValue:
                    minAmount == null ? '' : (minAmount! ~/ 100).toString(),
                onChanged: (value) {
                  minAmount = int.parse(value) * 100;
                },
                isNumberOnlyInput: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomizedTextFormField(
                labelText: 'To',
                initialValue:
                    maxAmount == null ? '' : (maxAmount! ~/ 100).toString(),
                onChanged: (value) {
                  maxAmount = int.parse(value) * 100;
                },
                isNumberOnlyInput: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget getClearAllBtn() {
    return CurvedButton(
      backgroundColor: Colors.grey,
      onPressed: () {
        Navigator.pop(context);
        pickedCategoryList.clear();
        categoryCheckMark.clear();
        selectedRating = null;
        minAmount = null;
        maxAmount = null;
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
