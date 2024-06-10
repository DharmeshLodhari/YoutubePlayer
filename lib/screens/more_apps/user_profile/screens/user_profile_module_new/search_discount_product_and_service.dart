import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/item_display_product_for_discount.dart';
import 'package:Slydo/widget/item_display_service_for_discount.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchDiscountProductAndService extends StatefulWidget {
  final dynamic arguments;
  SearchDiscountProductAndService({required this.arguments});

  @override
  _SearchDiscountProductAndServiceState createState() =>
      _SearchDiscountProductAndServiceState();
}

class _SearchDiscountProductAndServiceState
    extends State<SearchDiscountProductAndService> {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic>? searchedResult;

  late UserBloc userBloc;
  static String filterValue = "Products";

  GlobalKey textFormField = GlobalKey();
  TextEditingController searchItemTextController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldState> _scaffoldSearchKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formFieldKey = GlobalKey<FormState>();

  int? count = 0;
  String? next = "";
  String? previous = "";
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool noItemInList = false;
  List itemList = [];

  bool isCategoryLoading = false;
  int? categoryCount = 0;
  String? categoryNext = "";
  String? categoryPrevious = "";
  bool noCategoryInList = false;
  List<String> categoryList = [];
  List<ProductCategory> productCategoryList = [];

  bool isManufacturerLoading = false;
  int? manufacturerCount = 0;
  String? manufacturerNext = "";
  String? manufacturerPrevious = "";
  bool noManufacturerInList = false;
  List<String> manufacturerList = [];

  bool isSubCategoryLoading = false;
  int? subCategoryCount = 0;
  String? subCategoryNext = "";
  String? subCategoryPrevious = "";
  bool noSubCategoryInList = false;
  List<String> subCategoryList = [];
  List<ProductCategory> productSubCategoryList = [];
  List<String> customCategoryList = [];
  List<ProductCategory> productCustomCategoryList = [];
  ProductCondition? selectedProductCondition;
  String? selectedRating;

  final GlobalKey _key = LabeledGlobalKey("searchTypeSelectionKey");
  late CustomizedPopUpMenu searchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  String hint = "Search here";

  DiscountModel? items;

  SearchItemWithFilterModel filterModel = SearchItemWithFilterModel();

  bool showFilterOptions = false;

  bool isFilterApplied = false;

  TextEditingController minAmountTextController = TextEditingController();
  TextEditingController maxAmountTextController = TextEditingController();

  @override
  void initState() {
    items = widget.arguments["item"];

    if (widget.arguments["filter"] != null) {
      filterValue = widget.arguments["filter"];
      filterValue == "Services"
          ? selectedMenuItemIndex = 1
          : selectedMenuItemIndex = 0;
      getSearchTypeIcon();

      if (mounted) setState(() {});
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      updateCategoryList();

      getList();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _scrollController.position.pixels != 0) {
          if (next != null) {
            getList();
          }
        }
      });
    });

    super.initState();
  }

  Future<void> obtainCustomCategory() async {
    try {
      productCustomCategoryList = await ShoppingAuthService()
          .obtainCustomCategory(userBloc.user.userName!);

      if (productCustomCategoryList.isNotEmpty) {
        customCategoryList =
            productCustomCategoryList.map((e) => e.name).toList();
        customCategoryList.insert(0, 'All');
      }
    } catch (e) {
      productCustomCategoryList = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> getProductAPI() async {
    await merchantProductCategoryList();
    await obtainCustomCategory();
    await getManufacturerList();
  }

  Future<void> merchantProductCategoryList() async {
    if (!isCategoryLoading) {
      if (categoryNext != null && !isCategoryLoading) {
        isCategoryLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .getMerchantProductCategories(userBloc.user.userAbout?.industry?.id,
                categoryNext, categoryPrevious);

        if (result == null) {
          isCategoryLoading = false;
          noCategoryInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        categoryCount = result['count'];
        categoryNext = result['next'];
        categoryPrevious = result['previous'];
        final tempList = result['results'];

        noCategoryInList = false;
        isCategoryLoading = false;

        for (int i = 0; i < tempList.length; i++) {
          productCategoryList.add(
              ProductCategory(tempList[i]['name']!, id: tempList[i]['id']));
        }

        // updateCategoryList();
      }
      if (productCategoryList.isEmpty) {
        if (mounted) {
          setState(() {
            noCategoryInList = true;
          });
        }
      } else if (categoryNext == null && productCategoryList.length > 6) {
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Future<void> getManufacturerList() async {
    manufacturerList.clear();
    if (!isManufacturerLoading) {
      if (manufacturerNext != null && !isManufacturerLoading) {
        isManufacturerLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .getManufacturerList(
                userBloc.user.userName, manufacturerNext, manufacturerPrevious);

        if (result == null) {
          isManufacturerLoading = false;
          noManufacturerInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        manufacturerCount = result['count'];
        manufacturerNext = result['next'];
        manufacturerPrevious = result['previous'];
        final tempList = result['results'];

        noManufacturerInList = false;
        isManufacturerLoading = false;

        for (int i = 0; i < tempList.length; i++) {
          manufacturerList.add(tempList[i]['manufacturer']);
        }
        manufacturerList.insert(
          0,
          'All',
        );

        // updateCategoryList();
      }
      if (manufacturerList.isEmpty) {
        if (mounted) {
          setState(() {
            noManufacturerInList = true;
          });
        }
      } else if (manufacturerNext == null && manufacturerList.length > 6) {
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Future<void> merchantProductSubCategoryList({int? categoryId}) async {
    productSubCategoryList.clear();
    subCategoryList.clear();
    if (!isSubCategoryLoading) {
      if (subCategoryNext != null && !isSubCategoryLoading) {
        isSubCategoryLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .getMerchantSubProductCategories(
                categoryId, subCategoryNext, subCategoryPrevious);

        if (result == null) {
          isSubCategoryLoading = false;
          noSubCategoryInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        subCategoryCount = result['count'];
        subCategoryNext = result['next'];
        subCategoryPrevious = result['previous'];
        final tempList = result['results'];

        noSubCategoryInList = false;
        isSubCategoryLoading = false;

        for (int i = 0; i < tempList.length; i++) {
          productSubCategoryList.add(
              ProductCategory(tempList[i]['name']!, id: tempList[i]['id']));
        }

        filterModel.subCategory = "";
        subCategoryList = productSubCategoryList.map((e) => e.name).toList();
        subCategoryList.insert(0, 'All');
      }
      if (productSubCategoryList.isEmpty) {
        if (mounted) {
          setState(() {
            noSubCategoryInList = true;
          });
        }
      } else if (subCategoryNext == null && productSubCategoryList.length > 6) {
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;

    updateCategoryList();

    searchItemTextController.text = "";
    count = 0;
    next = "";
    previous = "";
    itemList.clear();
    noItemInList = false;
    filterValue = value;

    setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  Future<void> updateCategoryList() async {
    // filterModel.category = "All categories";
    if (selectedMenuItemIndex == 0) {
      // filterModel.customCategory = "";
      // filterModel.subCategory = "";
      // filterModel.condition = "";
      // selectedProductCondition = null;
      // filterModel.rating = "";
      // filterModel.manufacturer = "";
      // filterModel.minAmount = null;
      // minAmountTextController.clear();
      // filterModel.maxAmount = null;
      // maxAmountTextController.clear();
      // selectedRating = "";
      await getProductAPI();
      categoryList = productCategoryList.map((e) => e.name).toList();
      categoryList.insert(0, 'All categories');
    } else if (selectedMenuItemIndex == 1) {
      categoryList = serviceCategoryList;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    searchTypeSelectionMenu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      hasIcon: true,
      childList: [
        CustomizedPopUpMenuItemWithIcon(
            title: "Product", value: "Products", icon: SlydoAppIcon.product),
        CustomizedPopUpMenuItemWithIcon(
            title: "Service", value: "Services", icon: SlydoAppIcon.note_2),
      ],
      selectedIndex: selectedMenuItemIndex,
      left: 16,
      arrowPosition: Alignment.topLeft,
      arrowLeftPadding: 16,
      top: 14,
    );
    searchTypeSelectionMenu.onChange = menuItemSelectionChange;
    searchTypeSelectionMenu.menuState = menuStateChange;

    userBloc = Provider.of<UserBloc>(context);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          filterValue = "Products";
          return;
        }
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerSearchKey,
        child: Scaffold(
          key: _scaffoldSearchKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: Form(
            key: _formFieldKey,
            child: Column(
              children: [
                const SizedBox(height: 6),
                searchBox(),
                const SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: _buildResultList(),
                ),
              ],
            ),
          ),
          floatingActionButton: floatingActionBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget getCategoryField() {
    return StatefulBuilder(builder: (context, changeState) {
      return CustomizedDropDownField(
        title: AppLocalization.of(context)!.category,
        child: ListTile(
          dense: true,
          title: Text(
            messageDecoderWithEmoji(filterModel.category) ?? "",
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
            selectItemCategory(changeState);
          },
        ),
      );
    });
  }

  Widget getSubCategoryField() {
    return StatefulBuilder(builder: (context, changeState) {
      return CustomizedDropDownField(
        title: 'Sub-category',
        child: ListTile(
          dense: true,
          title: Text(
            messageDecoderWithEmoji(filterModel.subCategory) ?? "",
            maxLines: 1,
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
            selectItemSubCategory(changeState);
          },
        ),
      );
    });
  }

  Widget getCustomCategoryField() {
    return StatefulBuilder(builder: (context, changeState) {
      return CustomizedDropDownField(
        title: 'Custom category',
        child: ListTile(
          dense: true,
          title: Text(
            messageDecoderWithEmoji(filterModel.customCategory) ?? "",
            maxLines: 1,
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
            selectItemCustomCategory(changeState);
          },
        ),
      );
    });
  }

  Widget getConditionField() {
    return StatefulBuilder(builder: (context, changeState) {
      return CustomizedDropDownField(
        title: 'Condition',
        child: ListTile(
          dense: true,
          title: Row(
            children: [
              Text(
                selectedProductCondition != null
                    ? messageDecoderWithEmoji(selectedProductCondition!.name) ??
                        ""
                    : "",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  selectedProductCondition != null
                      ? " (${selectedProductCondition!.description})"
                      : "",
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                  ),
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
          ),
          onTap: () {
            selectItemCondition(changeState);
          },
        ),
      );
    });
  }

  Widget getManufacturerField() {
    return StatefulBuilder(builder: (context, changeState) {
      return CustomizedDropDownField(
        title: 'Manufacturer',
        child: ListTile(
          dense: true,
          title: Text(
            messageDecoderWithEmoji(filterModel.manufacturer) ?? "",
            maxLines: 1,
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
            selectItemManufacturer(changeState);
          },
        ),
      );
    });
  }

  Future<String?> buildCardListWidget(List<String> list, String category) {
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 25,
                          width: 25,
                          margin: const EdgeInsets.only(right: 10, top: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                            border: Border.all(
                              width: 1,
                              color: black,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Icon(
                            Icons.close_outlined,
                            color: black,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: list.map<Widget>((item) {
                        if (category == item) {
                          return Container(
                            color: selectedListItemBackgroundBlue,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                item == 'All' ? 'All' : item,
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
                                Navigator.pop(context, item);
                              },
                            ),
                          );
                        }
                        return ListTile(
                          title: Text(
                            item,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          dense: true,
                          onTap: () {
                            Navigator.pop(context, item);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void selectItemCategory(StateSetter changeState) async {
    if (categoryList.isNotEmpty) {
      final pressedCategory =
          await buildCardListWidget(categoryList, filterModel.category);
      if (pressedCategory != null) {
        subCategoryList = [];
        productSubCategoryList = [];
        filterModel.subCategoryId = null;
        filterModel.subCategory = "";
        subCategoryNext = "";

        filterModel.category = pressedCategory;
        if (pressedCategory == 'All categories') {
          await merchantProductSubCategoryList();
        } else {
          if (selectedMenuItemIndex == 0) {
            final ProductCategory category = productCategoryList
                .where((element) => element.name == pressedCategory)
                .toList()
                .first;
            filterModel.categoryId = category.id;
            await merchantProductSubCategoryList(categoryId: category.id);
          }
        }
        debugPrint("sub category === >${filterModel.subCategory}");
        debugPrint("sub category ID === >${filterModel.subCategoryId}");
        changeState(() {});
        setState(() {});
      }
    } else {
      showToast(message: "No category Found..");
    }
  }

  void selectItemSubCategory(StateSetter changeState) async {
    if (subCategoryList.isNotEmpty) {
      final pressedSubCategory =
          await buildCardListWidget(subCategoryList, filterModel.subCategory);
      if (pressedSubCategory != null) {
        setState(() {
          filterModel.subCategory = pressedSubCategory;
          if (filterModel.subCategory != "All") {
            final ProductCategory category = productSubCategoryList
                .where((element) => element.name == pressedSubCategory)
                .toList()
                .first;
            filterModel.subCategoryId = category.id;
          } else {
            filterModel.subCategoryId = null;
          }
          changeState(() {});
        });
      }
    } else {
      showToast(message: "No sub category Found..");
    }
  }

  void selectItemCustomCategory(StateSetter changeState) async {
    if (customCategoryList.isNotEmpty) {
      final pressedCustomCategory = await buildCardListWidget(
          customCategoryList, filterModel.customCategory);
      if (pressedCustomCategory != null) {
        setState(() {
          filterModel.customCategory = pressedCustomCategory;
          if (filterModel.customCategory != "All") {
            final ProductCategory category = productCustomCategoryList
                .where((element) => element.name == pressedCustomCategory)
                .toList()
                .first;
            filterModel.customCategoryId = category.id;
          } else {
            filterModel.customCategoryId = null;
          }
          changeState(() {});
        });
      }
    } else {
      showToast(message: "No custom category Found..");
    }
  }

  void selectItemCondition(StateSetter changeState) async {
    final pressedCondition = await showDialog<ProductCondition>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 25,
                                width: 25,
                                margin:
                                    const EdgeInsets.only(right: 10, top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(35)),
                                  border: Border.all(
                                    width: 1,
                                    color: black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_outlined,
                                  color: black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: conditions.map<Widget>((condition) {
                              if (filterModel.condition == condition) {
                                return Container(
                                  color: selectedListItemBackgroundBlue,
                                  child: ListTile(
                                    dense: true,
                                    title: Row(
                                      children: [
                                        Text(
                                          condition.name,
                                          style: TextStyle(
                                              color: navyBlue,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Expanded(
                                          child: Text(
                                            selectedProductCondition != null
                                                ? " (${selectedProductCondition!.description})"
                                                : "",
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: "Inter",
                                                color: navyBlue),
                                            softWrap: false,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, condition);
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      condition.name,
                                      style: TextStyle(
                                          color: blackFont,
                                          fontSize: 16,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Expanded(
                                      child: Text(
                                        " (${condition.description})",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: blackFont,
                                          fontFamily: "Inter",
                                        ),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                dense: true,
                                onTap: () {
                                  Navigator.pop(context, condition);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      selectedProductCondition = pressedCondition;
      filterModel.condition = selectedProductCondition?.name ?? "";
      changeState(() {});
    }
  }

  void selectItemManufacturer(StateSetter changeState) async {
    if (manufacturerList.isNotEmpty) {
      final pressedManufecturer =
          await buildCardListWidget(manufacturerList, filterModel.manufacturer);
      if (pressedManufecturer != null) {
        setState(() {
          filterModel.manufacturer = pressedManufecturer;
          changeState(() {});
        });
      }
    } else {
      showToast(message: "No manufacturer Found..");
    }
  }

  Widget getPriceRange() {
    return Row(
      children: <Widget>[
        Expanded(child: displayMinAmount()),
        const SizedBox(
          width: 16,
        ),
        Expanded(child: displayMaxAmount()),
      ],
    );
  }

  Widget displayMinAmount() {
    return CustomizedTextFormField(
      labelText: "Min amount",
      isAmountField: true,
      controller: minAmountTextController,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) {
        if (val.toString() == "") {
          filterModel.minAmount = null;
          return;
        }
        try {
          final int minAmount =
              int.parse(val.replaceAll(',', '').replaceAll('.', ''));
          filterModel.minAmount = minAmount;
        } catch (e) {}
      },
      validator: (val) {
        if (val.toString().isEmpty) {
          return null;
        }
        try {
          final int amount =
              int.parse(val.replaceAll(',', '').replaceAll('.', ''));
          if (amount > 0) {
            return null;
          } else {
            return AppLocalization.of(context)!.invalidAmount;
          }
        } catch (e) {
          return AppLocalization.of(context)!.invalidAmount;
        }
      },
    );
  }

  Widget displayMaxAmount() {
    return CustomizedTextFormField(
      labelText: "Max amount",
      controller: maxAmountTextController,
      isAmountField: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) {
        if (val.toString() == "") {
          filterModel.maxAmount = null;
          return;
        }
        try {
          final int maxAmount =
              int.parse(val.replaceAll(',', '').replaceAll('.', ''));
          filterModel.maxAmount = maxAmount;
        } catch (e) {}
      },
      validator: (val) {
        if (val.toString().isEmpty) {
          return null;
        }
        try {
          final int amount =
              int.parse(val.replaceAll(',', '').replaceAll('.', ''));
          if (amount > 0) {
            return null;
          } else {
            return AppLocalization.of(context)!.invalidAmount;
          }
        } catch (e) {
          return AppLocalization.of(context)!.invalidAmount;
        }
      },
    );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionHandleColor: navyBlue,
                ),
              ),
              child: TextFormField(
                key: textFormField,
                controller: searchItemTextController,
                style: TextStyle(
                  fontSize: 16,
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                ),
                cursorWidth: 1.5,
                cursorColor: navyBlue,
                onChanged: (value) {
                  if (value.length >= 3) {
                    searchItems();

                    if (itemList.isNotEmpty ||
                        searchItemTextController.text.isNotEmpty) {
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
                  } else if (value.isEmpty) {
                    setState(() {
                      isSearchIsEmpty = true;
                      itemList.clear();
                      autoCompleteSearchText = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: selectedMenuItemIndex == 0
                      ? "Search product"
                      : "Search service",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: widget.arguments["hidePreIcon"] == true
                      ? null
                      : searchTypeSelection(),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 36),
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
                onFieldSubmitted: (val) {
                  if (mounted) {
                    if (val.length >= 3) {
                      searchItems();
                    }
                  }
                  // searchItems();
                },
              ),
            ),
            Positioned(
              right: 0,
              child: searchIcon(),
            )
          ],
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget searchTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
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
    if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.note_2;
    }
    return SlydoAppIcon.product;
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: searchItems,
    );
  }

  void searchItems() {
    if (mounted) {
      count = 0;
      next = "";
      previous = "";
      itemList.clear();
      noItemInList = false;
      isLoading = false;

      if (mounted) setState(() {});
      getList();
      // FocusScope.of(context).unfocus();
    }
  }

  Widget appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: Colors.white,
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
        centerTitle: false,
        title: Text(
          "Search",
          style: TextStyle(
            color: blackFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [filterItemBtn(), const SizedBox(width: 8)]);
  }

  Widget filterItemBtn() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Expanded(
                child: RoundedBackgroundIcon(
                  height: 34,
                  width: 34,
                  icon: Icon(
                    Icons.filter_alt_rounded,
                    size: 16,
                    color: blackFont,
                  ),
                  onTap: () async {
                    showFilterOptions = !showFilterOptions;
                    if (mounted) setState(() {});
                    updateCategoryList();
                    checkForFilterAppliedOrNot();
                    await Future.delayed(const Duration(milliseconds: 100))
                        .then((value) => showFilterProductSheet());
                  },
                  backgroundColor: iconBtnGrey,
                  enableMargin: true,
                ),
              ),
            ],
          ),
        ),
        if (isFilterApplied)
          Positioned(
            top: 10,
            right: 6,
            child: ClipOval(
              child: Container(
                height: 8,
                width: 8,
                color: naturalGreen,
              ),
            ),
          )
        else
          Container()
      ],
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
                child: selectedMenuItemIndex == 1
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Filter",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w700,
                                color: blackFont),
                          ),
                          const SizedBox(height: 40),
                          getCategoryField(),
                          const SizedBox(
                            height: 8,
                          ),
                          getPriceRange(),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(child: getClearAllBtn()),
                              const SizedBox(width: 20),
                              Expanded(child: getFilterSubmitBtn()),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      )
                    : Column(
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
                          getCategoryField(),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: getSubCategoryField(),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(child: getCustomCategoryField()),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: getConditionField(),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(child: getManufacturerField()),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          getPriceRange(),
                          const SizedBox(
                            height: 15,
                          ),
                          getProductRatingSelection(bottomSheetSetState),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(child: getClearAllBtn()),
                              const SizedBox(width: 20),
                              Expanded(child: getFilterSubmitBtn()),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
              ),
            ),
          );
        });
  }

  Widget getClearAllBtn() {
    return CurvedButton(
      backgroundColor: Colors.grey,
      onPressed: () {
        Navigator.pop(context);

        filterModel.category = "";
        filterModel.categoryId = null;
        filterModel.subCategoryId = null;
        filterModel.subCategory = "";
        subCategoryNext = "";
        filterModel.customCategory = "";
        filterModel.condition = "";
        selectedProductCondition = null;
        filterModel.manufacturer = "";
        filterModel.rating = "";
        selectedRating = "";
        filterModel.maxAmount = null;
        filterModel.minAmount = null;
        searchItems();
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
        searchItems();
      },
      text: "Apply",
      textColor: Colors.white,
    );
  }

  Widget getProductRatingSelection(StateSetter bottomSheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rating",
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            if (selectedRating != "" && selectedRating != null) {
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
                  fontFamily: "Inter",
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
        filterModel.rating = (index + 1).toString();
        bottomSheetSetState(() {});
      },
    );
  }

  void checkForFilterAppliedOrNot() {
    if (filterModel.category != "") {
      isFilterApplied = true;
      if (mounted) setState(() {});
      return;
    }
    if (filterModel.subCategory != "") {
      isFilterApplied = true;
      if (mounted) setState(() {});
      return;
    }
    if (filterModel.minAmount != null) {
      isFilterApplied = true;
      if (mounted) setState(() {});
      return;
    }
    if (filterModel.maxAmount != null) {
      isFilterApplied = true;
      if (mounted) setState(() {});
      return;
    }
    isFilterApplied = false;
    if (mounted) setState(() {});
    return;
  }

  Widget _buildResultList() {
    return isSearchIsEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context)!.noResultFound,
              )
            : isLoading && itemList.isEmpty
                ? buildLoadingIndicator(isLoading: isLoading)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 70),
                    //+1 for progressbar
                    itemCount: itemList.length + 1,
                    // ignore: missing_return
                    itemBuilder: (BuildContext context, int index) {
                      if (index == itemList.length) {
                        return buildJumpingLoadingIndicator(
                            isLoading: isLoading);
                      } else {
                        if (filterValue == "Services") {
                          return DisplayServiceForDiscount(
                            service: itemList[index],
                            onChange: (bool value) {
                              itemList[index].isChecked = value;
                              if (mounted) setState(() {});
                            },
                            isSelected: itemList[index].isChecked,
                          );
                        } else {
                          return DisplayProductForDiscount(
                            product: itemList[index],
                            onChange: (bool value) {
                              itemList[index].isChecked = value;
                              if (mounted) setState(() {});
                            },
                            isSelected: itemList[index].isChecked,
                          );
                        }
                      }
                    },
                    controller: _scrollController,
                  );
  }

  Future<Map<String, dynamic>?> getSearchApi() async {
    filterModel.searchedText = searchItemTextController.text;
    switch (filterValue) {
      case "Products":
        if (items?.id != null) {
          return await ShoppingAuthService().searchOfDiscountedProduct(
              next, previous, items?.id,
              filterOptions: filterModel);
        } else {
          return await ShoppingAuthService().searchListOfProduct(
              next, previous, userBloc.user.userName,
              filterOptions: filterModel);
        }
      case "Services":
        if (items?.id != null) {
          return await ShoppingAuthService().searchOfDiscountedServices(
              next, previous, items?.id,
              filterOptions: filterModel);
        } else {
          return await ShoppingAuthService().searchListOfService(
              next, previous, userBloc.user.userName,
              filterOptions: filterModel);
        }
      default:
        if (items?.id != null) {
          return await ShoppingAuthService().searchOfDiscountedProduct(
              next, previous, items?.id,
              filterOptions: filterModel);
        } else {
          return await ShoppingAuthService().searchListOfProduct(
              next, previous, userBloc.user.userName,
              filterOptions: filterModel);
        }
    }
  }

  void getList() async {
    // if (!_formFieldKey.currentState!.validate()) {
    //   /// open filters when user has some error in filter fields validation
    //   showFilterOptions = true;
    //   if (mounted) setState(() {});
    //   return;
    // }

    /// close filter when user press search button
    showFilterOptions = false;
    if (mounted) setState(() {});
    checkForFilterAppliedOrNot();

    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }
        final Map<String, dynamic>? result = await getSearchApi();
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          isLoading = false;
          itemList.addAll(tempList);
          setState(() {});
        }
      }

      if (itemList.isNotEmpty) {
        isSearchIsEmpty = false;
        if (mounted) setState(() {});
      }
      if (itemList.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && itemList.length > 6) {
        _scaffoldMessengerSearchKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  String getSearchUrl(String searchedText) {
    switch (filterValue) {
      case "Products":
        return "${AppConfig.baseUrl}/api/v1/search/products/byseller=$searchedText";
      case "Services":
        return "${AppConfig.baseUrl}/api/v1/search/services/?search=$searchedText";
      default:
        return "${AppConfig.baseUrl}/api/v1/search/products/?search=$searchedText";
    }
  }

  Widget productCard(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  leading: getLeading(product),
                  title: getTitle(product),
                  trailing: product.price.toString().length > 6
                      ? null
                      : getTrailingProduct(product),
                  subtitle: getSubtitleProduct(product),
                  onTap: () {
                    Navigator.pushNamed(context, '/product',
                        arguments: {"product": product});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeading(Product product) {
    var imageUrl = "";
    try {
      imageUrl = product.cover ?? defaultProductAndServiceImage;
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = defaultProductAndServiceImage;
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 48,
        errorWidget: imageErrorWidget,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => imageUrl == ""
            ? const Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle(Product product) {
    return Text(
      messageDecoderWithEmoji(product.name) ?? "",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailingProduct(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency!]!,
          style: TextStyle(
              fontFamily: "Inter",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(product.discountedPrice != null
              ? (product.checkProductDiscount()
                  ? product.discountedPrice
                  : product.price!)
              : product.price!),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubtitleProduct(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 2,
        ),
        Text(
          messageDecoderWithEmoji(product.shortDescription) ?? "",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        const SizedBox(
          height: 2,
        ),
        if (product.price.toString().length > 6)
          getTrailingProduct(product)
        else
          Container(),
        getSellerNameProduct(product)
      ],
    );
  }

  Widget getSellerNameProduct(Product product) {
    return Row(
      children: <Widget>[
        Text(
          product.seller!,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }

  // Widget getServiceTile(Service service) {
  //   return DisplayServiceForDiscount(
  //     service: service,
  //     onChange: (bool value) {
  //       service.isChecked = value;
  //       if (mounted) setState(() {});
  //     },
  //     isSelected: service.isChecked,
  //   );
  // }

  Widget getServiceCard(Service service) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  leading: getLeadingService(service),
                  title: Text(
                    messageDecoderWithEmoji(service.name) ?? "",
                    maxLines: 1,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: getSubtitleService(service),
                  trailing: service.price.toString().length > 6
                      ? null
                      : getTrailingService(service),
                  onTap: () {
                    Navigator.of(context).pushNamed('/service-detail',
                        arguments: {"service": service});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeadingService(Service service) {
    var imageUrl = "";
    try {
      imageUrl = service.cover ?? defaultImage;
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = defaultImage;
    }
    return ClipOval(
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 48,
          width: 48,
          errorWidget: imageErrorWidget,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => imageUrl == ""
              ? const Icon(Icons.person)
              : CircularLoadingIndicator()),
    );
  }

  Widget getSubtitleService(Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 2,
        ),
        Text(
          messageDecoderWithEmoji(service.shortDescription) ?? "",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        const SizedBox(
          height: 2,
        ),
        if (service.price.toString().length > 6)
          getTrailingService(service)
        else
          Container(),
        getProviderNameService(service)
      ],
    );
  }

  Widget getProviderNameService(Service service) {
    return Row(
      children: <Widget>[
        Text(
          service.provider!,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }

  Widget getTrailingService(Service service) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[service.currency!]!,
          style: TextStyle(
              fontFamily: "Inter",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(service.price.toString())),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 15.0),
        child: getSubmitButton(),
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        Map<String, dynamic>? items;
        final List<Product> productList = [];
        final List<Service> serviceList = [];

        for (var item in itemList) {
          if (item is Product && item.isChecked) {
            productList.add(item);
          } else if (item is Service && item.isChecked) {
            serviceList.add(item);
          }
        }

        if (filterValue == "Services") {
          // final List<Service> selectedServices =
          //     (itemList as List<Service>).where((e) => e.isChecked).toList();

          items = {
            "services": serviceList,
            "ids": serviceList.map((e) => e.id).toList(),
            "isAllServiceSelected": false,
          };
        } else {
          // final List<Product> selectedProducts =
          //     (itemList as List<Product>).where((e) => e.isChecked).toList();

          items = {
            "products": productList,
            "ids": productList.map((e) => e.id).toList(),
            "isAllProductSelected": false
          };
        }
        Navigator.pop(context, items);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
    );
  }

  @override
  void dispose() {
    searchItemTextController.dispose();
    _scrollController.dispose();
    filterValue = "Products";
    super.dispose();
  }
}
