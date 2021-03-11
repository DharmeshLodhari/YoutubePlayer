import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SearchUsersProductAndService extends StatefulWidget {
  final arguments;
  SearchUsersProductAndService({@required this.arguments});

  @override
  _SearchUsersProductAndServiceState createState() =>
      _SearchUsersProductAndServiceState();
}

class _SearchUsersProductAndServiceState
    extends State<SearchUsersProductAndService> {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic> searchedResult;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  static var filterValue = "Products";

  SlidableController slidableController1;
  SlidableController slidableController2;

  List<Widget> results = [];

  GlobalKey textFormField = GlobalKey();
  TextEditingController searchItemTextController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formFieldKey = GlobalKey<FormState>();

  //pagination variables
  int count = 0;
  String next = "";
  String previous = "";
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noItemInList = false;

  GlobalKey _key = LabeledGlobalKey("searchTypeSelectionKey");
  CustomizedPopUpMenu searchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  List<String> categoryList = [];

  var hint = "Search here";

  CustomerProfile searchedUser;

  SearchItemWithFilterModel filterModel = SearchItemWithFilterModel();

  bool showFilterOptions = false;

  bool isFilterApplied = false;

  TextEditingController minAmountTextController = TextEditingController();
  TextEditingController maxAmountTextController = TextEditingController();

  @override
  void initState() {
    searchedUser = widget.arguments["searchedUser"];
    filterModel.searchedUser = searchedUser;

    updateCategoryList();

    slidableController1 = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged1,
      onSlideIsOpenChanged: handleSlideIsOpenChanged1,
    );
    slidableController2 = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged2,
      onSlideIsOpenChanged: handleSlideIsOpenChanged2,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getList();
        }
      }
    });

    searchItemTextController.addListener(() {
      if (searchItemTextController.text.length >= 5) {
        autoCompleteSearchText = searchItemTextController.text;

        setState(() {
          count = 0;
          next = "";
          previous = "";
          results.clear();
          noItemInList = false;
          getList();
        });
      }
      if (results.isNotEmpty || searchItemTextController.text.length != 0) {
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

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;

    updateCategoryList();

    searchItemTextController.text = "";
    count = 0;
    next = "";
    previous = "";
    results.clear();
    noItemInList = false;
    filterValue = value;

    setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  void updateCategoryList() {
    filterModel.category = "All categories";
    if (selectedMenuItemIndex == 0) {
      categoryList = productCategoryList;
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
        children: [
          CustomizedPopUpMenuItemWithIcon(
              title: "Product", value: "Products", icon: SlydoAppIcon.product),
          CustomizedPopUpMenuItemWithIcon(
              title: "Service", value: "Services", icon: SlydoAppIcon.note_2),
        ],
        selectedIndex: selectedMenuItemIndex,
        left: 16,
        arrowPosition: Alignment.topLeft,
        arrowLeftPadding: 16,
        top: 14);
    searchTypeSelectionMenu.onChange = menuItemSelectionChange;
    searchTypeSelectionMenu.menuState = menuStateChange;

    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldSearchKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Form(
        key: _formFieldKey,
        child: Column(
          children: [
            SizedBox(
              height: 6,
            ),
            searchBox(),
            showFilterOptions ? getFilterOptions() : Container(),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: _buildResultList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFilterOptions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          getCategoryField(),
          SizedBox(
            height: 8,
          ),
          getPriceRange()
        ],
      ),
    );
  }

  Widget getCategoryField() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: greyBorderColor)),
      margin: EdgeInsets.all(0),
      borderOnForeground: true,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
            alignedDropdown: true,
            child: ListTile(
              dense: true,
              title: Text(
                filterModel.category,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
              ),
              onTap: () {
                selectItemCategory();
              },
            )),
      ),
    );
  }

  void selectItemCategory() async {
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
                        children: categoryList.map<Widget>((category) {
                          if (filterModel.category == category) {
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
      filterModel.category = pressedCategory;
      setState(() {});
    }
  }

  Widget getPriceRange() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: displayMinAmount()),
          SizedBox(
            width: 16,
          ),
          Expanded(child: displayMaxAmount()),
        ],
      ),
    );
  }

  Widget displayMinAmount() {
    return CustomizedTextFormField(
      labelText: "Min amount",
      isAmount: true,
      controller: minAmountTextController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) {
        if (val.toString() == "") {
          filterModel.minAmount = null;
          return;
        }
        try {
          int minAmount = int.parse(val);
          filterModel.minAmount = minAmount;
        } catch (e) {}
      },
      validator: (val) {
        if (val.toString().isEmpty) {
          return null;
        }
        try {
          int amount = int.parse(val);
          if (amount > 0) {
            return null;
          } else {
            return AppLocalization.of(context).invalidAmount;
          }
        } catch (e) {
          return AppLocalization.of(context).invalidAmount;
        }
      },
    );
  }

  Widget displayMaxAmount() {
    return CustomizedTextFormField(
      labelText: "Max amount",
      controller: maxAmountTextController,
      isAmount: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (val) {
        if (val.toString() == "") {
          filterModel.maxAmount = null;
          return;
        }
        try {
          int maxAmount = int.parse(val);
          filterModel.maxAmount = maxAmount;
        } catch (e) {}
      },
      validator: (val) {
        if (val.toString().isEmpty) {
          return null;
        }
        try {
          int amount = int.parse(val);
          if (amount > 0) {
            return null;
          } else {
            return AppLocalization.of(context).invalidAmount;
          }
        } catch (e) {
          return AppLocalization.of(context).invalidAmount;
        }
      },
    );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                textSelectionHandleColor: navyBlue,
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
                decoration: InputDecoration(
                  hintText: "Search here",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: searchTypeSelection(),
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 12),
                  ),
                  suffix: Padding(
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
                  searchItems();
                },
              ),
            ),
            Positioned(
              child: searchIcon(),
              right: 0,
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
        borderRadius: BorderRadius.only(
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
      results.clear();
      noItemInList = false;
      if (mounted) setState(() {});
      FocusScope.of(context).unfocus();
      getList();
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
              color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [filterItemBtn(), SizedBox(width: 8)]);
  }

  Widget filterItemBtn() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Expanded(
                child: RoundedBackgroundIcon(
                  height: 34,
                  width: 34,
                  icon: Icon(
                    SlydoAppIcon.filter,
                    size: 16,
                    color: blackFont,
                  ),
                  onTap: () {
                    showFilterOptions = !showFilterOptions;
                    if (mounted) setState(() {});
                    checkForFilterAppliedOrNot();
                  },
                  backgroundColor: iconBtnGrey,
                  enableMargin: true,
                ),
              ),
            ],
          ),
        ),
        isFilterApplied
            ? Positioned(
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
            : Container()
      ],
    );
  }

  void checkForFilterAppliedOrNot() {
    if (filterModel.category != "All categories") {
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
            msg: AppLocalization.of(context).pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context).noResultFound,
              )
            : Container(
                child: ListView.builder(
                  //+1 for progressbar
                  itemCount: results.length + 1,
                  // ignore: missing_return
                  itemBuilder: (BuildContext context, int index) {
                    if (index == results.length) {
                      return _buildIndicator();
                    } else {
                      try {
                        return results[index];
                      } catch (error) {
                        debugPrint(error);
                      }
                    }
                  },
                  controller: _scrollController,
                ),
              );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getSearchApi() async {
    filterModel.searchedText = searchItemTextController.text;
    switch (filterValue) {
      case "Products":
        return await ShoppingAuthService()
            .searchUsersProducts(next, previous, filterOptions: filterModel);
      case "Services":
        return await ShoppingAuthService()
            .searchUsersServices(next, previous, filterOptions: filterModel);
      default:
        return await ShoppingAuthService()
            .searchUsersProducts(next, previous, filterOptions: filterModel);
    }
  }

  void getList() async {
    if (!_formFieldKey.currentState.validate()) {
      /// open filters when user has some error in filter fields validation
      showFilterOptions = true;
      if (mounted) setState(() {});
      return;
    }

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
        Map<String, dynamic> result = await getSearchApi();
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];
        if (mounted) {
          isLoading = false;
          try {
            tempList.forEach((result) {
              results.add(getResultTile(result));
            });
          } catch (e) {}
          setState(() {});
        }
      }

      if (results.isNotEmpty) {
        isSearchIsEmpty = false;
        if (mounted) setState(() {});
      }
      if (results.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && results.length > 6) {
        _scaffoldSearchKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  // ignore: missing_return
  Widget getResultTile(var result) {
    switch (filterValue) {
      case "Products":
        return getProductTile(result);
        break;
      case "Services":
        return getServiceTile(result);
        break;
    }
  }

  String getSearchUrl(String searchedText) {
    switch (filterValue) {
      case "Products":
        return baseUrl + "/api/v1/search/products/byseller=" + searchedText;
      case "Services":
        return baseUrl + "/api/v1/search/services/?search=" + searchedText;
      default:
        return baseUrl + "/api/v1/search/products/?search=" + searchedText;
    }
  }

  Widget getProductTile(Product product) {
    return _getSlidableWithLists1(context, productCard(product), product);
  }

  Widget productCard(Product product) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                padding: EdgeInsets.symmetric(vertical: 8),
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
      imageUrl = product.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) =>
            imageUrl == "" ? Icon(Icons.person) : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle(Product product) {
    return Text(
      "${product.name}",
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
          worldCurrencies[product.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          product.price.toString(),
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
        SizedBox(
          height: 2,
        ),
        Text(
          "${product.shortDescription}",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        SizedBox(
          height: 2,
        ),
        product.price.toString().length > 6
            ? getTrailingProduct(product)
            : Container(),
        getSellerNameProduct(product)
      ],
    );
  }

  Widget getSellerNameProduct(Product product) {
    return Row(
      children: <Widget>[
        Text(
          product.seller,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }

  Widget getServiceTile(Service service) {
    return _getSlidableWithLists2(context, getServiceCard(service), service);
  }

  Widget getServiceCard(Service service) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  leading: getLeadingService(service),
                  title: Text(
                    service.name,
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
      imageUrl = service.cover ??
          "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    } catch (e) {
      imageUrl = "";
    }
    if (imageUrl == "") {
      imageUrl = "https://homepages.cae.wisc.edu/~ece533/images/peppers.png";
    }
    return ClipOval(
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 48,
          width: 48,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) =>
              imageUrl == "" ? Icon(Icons.person) : CircularLoadingIndicator()),
    );
  }

  Widget getSubtitleService(Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        Text(
          "${service.shortDescription}",
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
        SizedBox(
          height: 2,
        ),
        service.price.toString().length > 6
            ? getTrailingService(service)
            : Container(),
        getProviderNameService(service)
      ],
    );
  }

  Widget getProviderNameService(Service service) {
    return Row(
      children: <Widget>[
        Text(
          service.provider,
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
          worldCurrencies[service.currency],
          style: TextStyle(
              fontFamily: "Roboto",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          service.price.toString(),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget autoComplete() {
    return Column(
      children: <Widget>[
        TextFormField(
          key: textFormField,
          controller: searchItemTextController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            hintText: hint,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: darkBlue(),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          style: TextStyle(color: Colors.black, fontSize: 16),
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                results.clear();
                noItemInList = false;
                getList();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _getSlidableWithLists1(
      BuildContext context, Widget searchCard, Product product) {
    return Slidable(
      controller: slidableController1,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem1(searchCard, product),
      actions: listActionSlideActions1(product),
      secondaryActions: listSecondaryActions1(product),
    );
  }

  List<Widget> listSecondaryActions1(Product product) {
    if (product.seller == userBloc.user.userName) {
      return [];
    }
    return [
      SlideActionButton(
        icon: SlydoAppIcon.cart,
        onTap: () async {
          customerProfileBloc.customer =
              await UserAuth().fetchCustomerProfile(product.seller);
          Navigator.of(context).pushNamed('/send-payment',
              arguments: {'isFromProfile': false, 'product': product});
        },
        title: AppLocalization.of(context).buy,
        backgroundColor: naturalGreen,
        slideController: slidableController1,
      ),
    ];
  }

  List<Widget> listActionSlideActions1(Product product) {
    if (product.seller == userBloc.user.userName) {
      return [];
    }

    return [
      SlideActionButton(
        icon: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': product.seller,
            'subject': product.name,
          });
        },
        title: "Message",
        backgroundColor: navyBlue,
        slideController: slidableController1,
      ),
    ];
  }

  Widget _getSlidableWithLists2(
      BuildContext context, Widget searchCard, Service service) {
    return Slidable(
      controller: slidableController2,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem2(searchCard, service),
      actions: listActionSlideActions2(service),
      secondaryActions: listSecondaryActions2(service),
    );
  }

  List<Widget> listSecondaryActions2(Service service) {
    if (service.provider == userBloc.user.userName) {
      return [];
    }
    return [
      SlideActionButton(
          title: AppLocalization.of(context).buy,
          backgroundColor: naturalGreen,
          slideController: slidableController2,
          icon: SlydoAppIcon.cart,
          onTap: () async {
            customerProfileBloc.customer =
                await UserAuth().fetchCustomerProfile(service.provider);
            Navigator.of(context).pushNamed('/send-payment',
                arguments: {'isFromProfile': false, 'service': service});
          }),
    ];
  }

  List<Widget> listActionSlideActions2(Service service) {
    if (service.provider == userBloc.user.userName) {
      return [];
    }
    return [
      SlideActionButton(
        title: AppLocalization.of(context).message,
        backgroundColor: navyBlue,
        slideController: slidableController2,
        icon: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': service.provider,
            'subject': service.name,
          });
        },
      ),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void handleSlideAnimationChanged1(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged1(bool isOpen) {}

  void handleSlideAnimationChanged2(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged2(bool isOpen) {}

  @override
  void dispose() {
    searchItemTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child, this.user);

  final Widget child;
  CustomerProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": user.userName});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem1 extends StatelessWidget {
  VerticalListItem1(this.child, this.product);

  final Widget child;
  Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, '/product',
            arguments: {"product": product});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem2 extends StatelessWidget {
  VerticalListItem2(this.child, this.service);

  final Widget child;
  Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, '/service-detail',
            arguments: {"service": service});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
