import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'more_apps/user_profile/user_auth.dart';

class SearchModule extends StatefulWidget {
  final arguments;

  SearchModule({this.arguments});

  @override
  _SearchModuleState createState() => _SearchModuleState();
}

class _SearchModuleState extends State<SearchModule> {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic>? searchedResult;
  late CustomerProfileBloc customerProfileBloc;
  UserBloc? userBloc;
  static String hint = "Find Users";

  final _auth = AuthService();
  SlidableController? slidableController;
  SlidableController? slidableController1;
  SlidableController? slidableController2;

  List<Widget> results = [];

  GlobalKey textFormField = GlobalKey();
  TextEditingController searchItemTextController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();

  //pagination variables
  int? count = 0;
  String? next = "";
  String? previous = "";
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noItemInList = false;

  GlobalKey _key = LabeledGlobalKey("searchTypeSelectionKey");
  late CustomizedPopUpMenu searchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  bool usingOutsideOfDashboard = false;

  @override
  void initState() {
    if (widget.arguments != null) {
      usingOutsideOfDashboard = widget.arguments["show_back_button"] ?? false;
    }

    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
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
      autoCompleteSearchText = searchItemTextController.text;

      setState(() {
        count = 0;
        next = "";
        previous = "";
        results.clear();
        noItemInList = false;
        getList();
      });

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

    searchItemTextController.text = "";
    count = 0;
    next = "";
    previous = "";
    results.clear();
    noItemInList = false;

    setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    searchTypeSelectionMenu = CustomizedPopUpMenu(
        buttonKey: _key,
        context: context,
        hasIcon: true,
        children: [
          CustomizedPopUpMenuItemWithIcon(
              title: "User", value: "Users", icon: SlydoAppIcon.user),
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
      appBar: appBar() as PreferredSizeWidget?,
      body: Column(
        children: [
          SizedBox(
            height: 6,
          ),
          searchBox(),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: _buildResultList(),
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Theme(
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
            decoration: InputDecoration(
              hintText: "Search here",
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              prefixIcon: searchTypeSelection(),
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
              ),
              suffixIcon: searchIcon(),
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
                count = 0;
                next = "";
                previous = "";
                results.clear();
                noItemInList = false;
                setState(() {});
                getList();
                FocusScope.of(context).unfocus();
              }
            },
          ),
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
    if (selectedMenuItemIndex == 2) {
      return SlydoAppIcon.note_2;
    } else if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.product;
    }
    return SlydoAppIcon.user;
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        if (mounted) {
          count = 0;
          next = "";
          previous = "";
          results.clear();
          noItemInList = false;
          setState(() {});
          getList();
          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget appBar() {
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
        "Search",
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
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
                        debugPrint(error.toString());
                      }
                    }
                    return _buildIndicator();
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

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }
        Map<String, dynamic>? result = await _auth
            .searchEndpointPagination(
                getSearchUrl(searchItemTextController.text), next, previous)
            .catchError((error) {
          debugPrint("ERROR:- $error");
        });
        if (result == null) {
          isLoading = false;
          if (mounted) setState(() {});
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List? tempList = result['results'];
        if (mounted) {
          isLoading = false;
          try {
            tempList!.forEach((result) {
              results.add(getResultTile(result));
            });
          } catch (e) {}
          setState(() {});
        }
      }
      if (results.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && results.length > 6) {
        _scaffoldSearchKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  // ignore: missing_return
  Widget getResultTile(var result) {
    switch (selectedMenuItemIndex) {
      case 0:
        return getUserTile(result);

      case 1:
        return getProductTile(result);

      case 2:
        return getServiceTile(result);
      default:
        return Container();
    }
  }

  String getSearchUrl(String searchedText) {
    switch (selectedMenuItemIndex) {
      case 0:
        return AppConfig.baseUrl +
            "/api/v1/search/users/?search=" +
            searchedText;
      case 1:
        return AppConfig.baseUrl +
            "/api/v1/search/products/?search=" +
            searchedText;
      case 2:
        return AppConfig.baseUrl +
            "/api/v1/search/services/?search=" +
            searchedText;
      default:
        return AppConfig.baseUrl +
            "/api/v1/search/users/?search=" +
            searchedText;
    }
  }

  Widget getUserTile(var object) {
    CustomerProfile user = CustomerProfile(
        avatar: object["avatar"],
        fullName: object["full_name"],
        qrCode: object["qr_code"],
        userName: object["username"],
        type: object['type'] ?? 'user');

    if (user.userName.toString().toLowerCase() == "slydo" ||
        user.userName.toString().toLowerCase() == "slydo_envelope") {
      return Container();
    }

    return _getSlidableWithLists(context, userCard(user), user);
  }

  Widget userCard(CustomerProfile user) {
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
                  title: Text(
                    user.displayName()!,
                    maxLines: 1,
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  subtitle: Text(
                    user.userName!,
                    maxLines: 1,
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  leading: getUserLeading(user),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getUserLeading(CustomerProfile user) {
    Color borderColor = getUserTypeColor(user: user);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/photo-viewer", arguments: user.avatar);
      },
      child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              border: Border.all(color: borderColor, width: 2)),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.avatar == "" ? defaultImage : user.avatar!,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
              errorWidget: imageErrorWidget,
              height: double.infinity,
              filterQuality: FilterQuality.high,
              placeholder: (context, _) => CachedNetworkImage(
                imageUrl: defaultImage,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
              ),
            ),
          )),
    );
  }

  Widget getProductTile(var object) {
    Product product = Product();
    product.name = object['name'];
    product.id = object['id'];
    product.shortDescription = object['short_description'];
    product.description = "";
    product.condition = object['condition'];
    product.currency = object['currency'];
    product.price = object['price'].toString();
    product.availableFrom = DateTime.parse(object['available_from']);
    product.isAvailable = object['is_available'];
    product.qrCode = object['qr_code'];
    product.seller = object['seller'];
    product.manufacturer = object['manufacturer'];
    product.serverImages = [];

    return _getSlidableWithLists1(
        context, productCard(product, object), product);
  }

  Widget productCard(Product product, var object) {
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
                  leading: getLeading(product, object),
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

  Widget getLeading(Product product, var object) {
    var imageUrl;

    try {
      imageUrl = object["cover"];
    } catch (e) {}
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/photo-viewer", arguments: imageUrl);
      },
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 48,
          width: 48,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          errorWidget: productAndServiceErrorWidget,
          placeholder: (context, url) =>
              imageUrl == "" ? Icon(Icons.person) : CircularLoadingIndicator(),
        ),
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
          worldCurrencies[product.currency!]!,
          style: TextStyle(
              fontFamily: "Roboto",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(product.price.toString())),
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
          product.seller!,
          maxLines: 1,
          style: TextStyle(color: darkGrey, fontSize: 10),
        ),
      ],
    );
  }

  Widget getServiceTile(var object) {
    Service service = Service();
    service.name = object['name'];
    service.id = object['id'];
    service.shortDescription = object['short_description'];
    service.currency = object['currency'];
    service.price = object['price'].toString();
    service.isAvailable = object['is_available'];
    service.qrCode = object['qr_code'];
    service.provider = object['provider'];
    service.serverImages = [];
    service.currency = "NGN";
    service.description = "";
    service.availableFrom = DateTime.now();

    return _getSlidableWithLists2(
        context, getServiceCard(service, object), service);
  }

  Widget getServiceCard(Service service, var object) {
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
                  leading: getLeadingService(service, object),
                  title: Text(
                    messageDecoderWithEmoji(object["name"]) ?? "",
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

  Widget getLeadingService(Service service, var object) {
    var imageUrl;
    try {
      imageUrl = object["cover"];
    } catch (e) {}

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/photo-viewer", arguments: imageUrl);
      },
      child: ClipOval(
        child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: productAndServiceErrorWidget,
            placeholder: (context, url) => imageUrl == ""
                ? Icon(Icons.person)
                : CircularLoadingIndicator()),
      ),
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
          messageDecoderWithEmoji(service.shortDescription) ?? "",
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
              fontFamily: "Roboto",
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

  void loadUsers(List data) {
    switch (selectedMenuItemIndex) {
      case 0:
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getUserTile(item));
            });
          }
        });
        break;
      case 1:
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getProductTile(item));
            });
          }
        });
        break;
      case 2:
        data.forEach((item) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getServiceTile(item));
            });
          }
        });
        break;
    }
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
                color: blackFont,
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

  Widget _getSlidableWithLists(
      BuildContext context, Widget searchCard, CustomerProfile user) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(searchCard, user),
      actions: listActionSlideActions(user),
      secondaryActions: listSecondaryActions(user),
    );
  }

  List<Widget> listSecondaryActions(CustomerProfile user) {
    return [
      SlideActionButton(
        icon: SlydoAppIcon.send,
        onTap: () async {
          customerProfileBloc.customer =
              await UserAuth().fetchCustomerProfile(user.userName);
          Navigator.of(context)
              .pushNamed('/send-payment', arguments: <String, bool>{
            'isFromProfile': false,
          });
        },
        title: AppLocalization.of(context)!.send,
        backgroundColor: naturalGreen,
        slideController: slidableController,
      ),
    ];
  }

  List<Widget> listActionSlideActions(CustomerProfile user) {
    return [
      SlideActionButton(
        icon: SlydoAppIcon.receive,
        onTap: () async {
          customerProfileBloc.customer =
              await UserAuth().fetchCustomerProfile(user.userName);
          Navigator.of(context).pushNamed('/request-payment',
              arguments: <String, bool>{
                'isFromProfile': false,
                'isRequest': true
              });
        },
        title: AppLocalization.of(context)!.request,
        backgroundColor: navyBlue,
        slideController: slidableController,
      ),
    ];
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
    return [
      SlideActionButton(
        icon: SlydoAppIcon.cart,
        onTap: () async {
          customerProfileBloc.customer =
              await UserAuth().fetchCustomerProfile(product.seller);
          Navigator.of(context).pushNamed('/send-payment',
              arguments: {'isFromProfile': false, 'product': product});
        },
        title: AppLocalization.of(context)!.buy,
        backgroundColor: naturalGreen,
        slideController: slidableController1,
      ),
    ];
  }

  List<Widget> listActionSlideActions1(Product product) {
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
    return [
      SlideActionButton(
          title: AppLocalization.of(context)!.buy,
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
    return [
      SlideActionButton(
        title: AppLocalization.of(context)!.message,
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

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  void handleSlideAnimationChanged1(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged1(bool? isOpen) {}

  void handleSlideAnimationChanged2(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged2(bool? isOpen) {}

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
