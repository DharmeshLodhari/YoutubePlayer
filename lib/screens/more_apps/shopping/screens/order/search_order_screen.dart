import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/no_order_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchOrderScreen extends StatefulWidget {
  final dynamic arguments;

  const SearchOrderScreen({super.key, this.arguments});

  @override
  _SearchOrderScreenState createState() => _SearchOrderScreenState();
}

class _SearchOrderScreenState extends State<SearchOrderScreen> {
  //list || Model
  List<Product> products = [];
  List<String> sortByMenuItems = [
    'Best match',
    'Highest price',
    'Lowest price'
  ];
  List<ProductCategory>? productCategoriesCopy;
  List<ProductCategory>? productCategories;
  List<String> pickedCategoryList = [];
  ProductCategory? selectedProductCategory;
  List orderList = [];

  // Controller
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldSearchKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();
  final ScrollController _scrollController = ScrollController();

  // variable
  Map<String, bool> categoryCheckMark = {};
  Map<String, bool> stateCheckMark = {"Lagos": false, "Ogun": false};
  bool showSortByBox = false;
  bool isLoading = false;
  bool isFirstTime = true;
  bool isSearchIsEmpty = true;
  bool noItemInList = false;
  bool isMerchant = true;
  int? count = 0;
  int? minAmount;
  int? maxAmount;
  String? next = "";
  String? previous = "";
  String? sortBy;
  String filterValue = "";
  String? selectedRating;
  String? sortByMenuItemValue = 'Best match';
  DateTimeRange? newDateTimeRange;

  @override
  void initState() {
    searchController.addListener(() {
      if (orderList.isNotEmpty || searchController.text.isNotEmpty) {
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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: scaffoldBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        "Search Order",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (orderList.isNotEmpty)
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
    return Column(
      children: [
        if (showSortByBox) sortByDropDown() else const SizedBox.shrink(),
        const SizedBox(height: 6),
        searchBox(),
        const SizedBox(height: 12),
        if (noItemInList)
          Expanded(
            child: NoOrderInList(
              title: AppLocalization.of(context)!.noOrdersToShow,
              msg: 'Browse product to make your first order.',
            ),
          )
        else
          isLoading && orderList.isEmpty
              ? buildLoadingIndicator(isLoading: isLoading)
              : ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  //+1 for progressbar
                  itemCount: orderList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == orderList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, Routes.ORDER_DETAIL_PAGE,
                              arguments: {"order": orderList[index]});
                        },
                        child: OrderTile(
                          order: orderList[index],
                          key: Key(
                            "Order:${orderList[index].id}",
                          ),
                        ),
                      );
                    }
                  },
                  controller: _scrollController,
                ),
      ],
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
            underline: const SizedBox.shrink(),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
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
              final String firstWord = newValue?.split(' ')[0] ?? "";
              final String secondWord = newValue?.split(' ')[1] ?? "";
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
                orderList.clear();
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
            hintText: "Search name, manufacturer, categories",
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
                          fontWeight: FontWeight.w700,
                          color: blackFont),
                    ),
                    const SizedBox(height: 40),
                    getCategoryField(bottomSheetSetState),
                    const SizedBox(height: 8),
                    getPikedCategoryNames(),
                    const SizedBox(height: 20),
                    getProductRatingSelection(bottomSheetSetState),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: getPriceRange(bottomSheetSetState),
                    ),
                    const SizedBox(height: 20),
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

  void _refreshList() {
    count = 0;
    next = "";
    previous = "";
    orderList.clear();
    noItemInList = false;
    getList();
  }

  void getList() async {
    final bool isNormalUser =
        Provider.of<UserBloc>(context, listen: false).user.type == 'User';
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        final result = await ShoppingAuthService().listOrders(
          next,
          previous,
          filterValue,
          newDateTimeRange,
          searchValue: searchController.text,
          isMerchant: isNormalUser ? false : isMerchant,
        );
        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        isLoading = false;
        orderList.addAll(tempList);
        // noItemInList = false;
        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (orderList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && orderList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        _scaffoldMessengerSearchKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget getCategoryField(StateSetter bottomSheetSetState) {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.category,
      child: ListTile(
        dense: true,
        title: Text(
          selectedProductCategory != null
              ? selectedProductCategory?.name ?? ""
              : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
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
                    itemCount: productCategories?.length,
                    itemBuilder: (context, index) {
                      final ProductCategory? category =
                          productCategories?[index];
                      return CheckboxListTile(
                        value: categoryCheckMark[category?.name] ?? false,
                        onChanged: (isChecked) {
                          changeState(() {
                            categoryCheckMark[category?.name ?? ""] =
                                isChecked!;
                          });
                          if (pickedCategoryList.contains(category?.name)) {
                            pickedCategoryList.remove(category?.name);
                          } else {
                            pickedCategoryList.add(category?.name ?? "");
                          }
                        },
                        title: Text(
                          category?.name ?? "",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      );

                      // if (selectedProductCategory == category) {
                      //   return Container(
                      //     color: selectedListItemBackgroundBlue,
                      //     child: ListTile(
                      //       dense: true,
                      //       title: Text(
                      //         category.name,
                      //         overflow: TextOverflow.fade,
                      //         softWrap: false,
                      //         style: TextStyle(
                      //             color: navyBlue,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w600),
                      //       ),
                      //       trailing: Icon(
                      //         SlydoAppIcon.checked,
                      //         color: navyBlue,
                      //         size: 12,
                      //       ),
                      //       onTap: () {
                      //         pressedCategory = category;
                      //         Navigator.pop(context);
                      //         if (pressedCategory != null) {
                      //           selectedProductCategory = pressedCategory;
                      //           productCategory = selectedProductCategory!.name;
                      //           setState(() {});
                      //         }
                      //       },
                      //     ),
                      //   );
                      // }
                      //
                      // return ListTile(
                      //   title: Text(
                      //     category.name,
                      //     softWrap: false,
                      //     overflow: TextOverflow.fade,
                      //     style: TextStyle(
                      //         color: blackFont,
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w400),
                      //   ),
                      //   dense: true,
                      //   onTap: () {
                      //     pressedCategory = category;
                      //     Navigator.pop(context);
                      //     if (pressedCategory != null) {
                      //       selectedProductCategory = pressedCategory;
                      //       productCategory = selectedProductCategory!.name;
                      //       // setState(() {});
                      //       bottomSheetSetState(() {});
                      //     }
                      //   },
                      // );
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

  Widget getProductRatingSelection(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rating",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
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

  Widget getPriceRange(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price Range",
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 12),
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

  Widget productRatingButton(StateSetter bottomSheetSetState,
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
            const SizedBox(width: 2),
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
}
