import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/moments/models/comment_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../widget/custom_slydo_usercard.dart';
import '../widget/dialog.dart';
import '../widget/rounded_background_icon.dart';
import '../widget/tab_selection.dart';
import 'connection_module/channels.dart';

class SearchModule extends StatefulWidget {
  final dynamic arguments;

  const SearchModule({super.key, this.arguments});

  @override
  State<SearchModule> createState() => _SearchModuleState();
}

class _SearchModuleState extends State<SearchModule>
    with SingleTickerProviderStateMixin {
  bool isValidSearch = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";

  List<dynamic>? searchedResult;
  late CustomerProfileBloc customerProfileBloc;
  UserBloc? userBloc;
  static String hint = "Search...";

  final _auth = AuthService();

  List<Widget> results = [];

  GlobalKey textFormField = GlobalKey();
  TextEditingController searchItemTextController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldSearchKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();

  //pagination variables
  int? count = 0;
  String? next = "";
  String? previous = "";
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool noItemInList = false;

  final GlobalKey _key = LabeledGlobalKey("searchTypeSelectionKey");
  late CustomizedPopUpMenu searchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  bool usingOutsideOfDashboard = false;
  List<String> userConnectionNames = [];
  AppConfigurationModel? appConfigurationModel;
  int currentIndex = 0;
  bool _tabsVisible = true;
  String? nextPageUrl;
  bool isSuggestionLoading = false;
  bool isFirstTime = true;
  bool noItemInSuggestionList = false;
  List<CustomerProfile> suggestionsList = [];
  BasePaginationModel<List<CustomerProfile>>? basePaginationModel;
  final ScrollController _scrollCtrl = ScrollController();
  final RefreshController _refreshCtrl =
      RefreshController(initialRefresh: false);
  bool isSuggestion = true;

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    getUserConnectionNames();

    if (widget.arguments != null) {
      usingOutsideOfDashboard = widget.arguments["show_back_button"] ?? false;
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getSearchUserList();
        }
      }
    });

    getListOfSuggestions();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
          _scrollCtrl.position.pixels != 0) {
        getListOfSuggestions();
      }
    });

    super.initState();
  }

  void getUserConnectionNames() async {
    userConnectionNames = await ConnectionListManager().listConnectionsFromDB();
    if (mounted) setState(() {});
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

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 20,
      centerTitle: false,
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: blackFont),
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
        getTabTitle(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar() as PreferredSizeWidget?,
    );
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Column(
        children: [
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
          TabSelection(
            onTap: (index) {
              currentIndex = index;
              _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentIndex,
            firstTab: AppLocalization.of(context)!.users,
            secondTab: AppLocalization.of(context)!.chatChannels,
          ),
          Divider(
            color: darkGrey.withOpacity(.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    searchTypeSelectionMenu = CustomizedPopUpMenu(
        buttonKey: _key,
        context: context,
        hasIcon: true,
        childList: [
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

    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    return DefaultTabController(
      length: 2,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerSearchKey,
        child: Scaffold(
          key: _scaffoldSearchKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: tabViews(),
        ),
      ),
    );
  }

  String getTabTitle() {
    return "Search";
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        searchTab(),
        const ChatChannels(),
      ],
    );
  }

  Widget searchTab() {
    return Column(
      children: [
        const SizedBox(height: 6),
        searchBox(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildResultList(),
        ),
      ],
    );
  }

  Widget searchBox() {
    try {
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
            key: textFormField,
            controller: searchItemTextController,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Inter",
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
            cursorWidth: 1.5,
            cursorColor: navyBlue,
            onChanged: (value) async {
              if (value.length >= 3) {
                autoCompleteSearchText = value;
                count = 0;
                next = "";
                previous = "";

                results.clear();
                isLoading = false;
                noItemInList = false;
                if (mounted) setState(() {});

                await getSearchUserList();

                if (results.isNotEmpty ||
                    searchItemTextController.text.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      isSearchIsEmpty = false;
                      isSuggestion = false;
                    });
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      isSearchIsEmpty = true;
                      isSuggestion = true;
                    });
                  }
                }
              } else if (value.isEmpty) {
                setState(() {
                  results.clear();
                  autoCompleteSearchText = value;
                  isSuggestion = true;
                });
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefix: const Padding(
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
                isLoading = false;

                if (val.length >= 3) {
                  setState(() {});
                  getSearchUserList();
                  FocusScope.of(context).unfocus();
                }
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
          // if (searchTypeSelectionMenu.isMenuOpen) {
          //   searchTypeSelectionMenu.closeMenu();
          // } else {
          //   searchTypeSelectionMenu.openMenu();
          // }
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
          isLoading = false;

          noItemInList = false;
          setState(() {});
          getSearchUserList();
          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget _buildResultList() {
    if (isSuggestion && results.isEmpty && autoCompleteSearchText.isEmpty) {
      return SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshCtrl,
          onRefresh: _onRefresh,
          child: noItemInSuggestionList
              ? NoItemInList(msg: AppLocalization.of(context)!.noSuggestions)
              : isSuggestionLoading && suggestionsList.isEmpty
                  ? buildLoadingIndicator(isLoading: isSuggestionLoading)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollCtrl,
                      itemCount: suggestionsList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == suggestionsList.length) {
                          return buildJumpingLoadingIndicator(
                              isLoading: isSuggestionLoading);
                        } else {
                          return CustomSlydoUserCard(
                              user: suggestionsList[index]);
                        }
                      },
                    ),
        ),
      );
    } else {
      return isSearchIsEmpty
          ? NoItemInList(
              msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
              isResult: false,
            )
          : noItemInList
              ? NoItemInList(
                  msg: AppLocalization.of(context)!.noResultFound,
                )
              : isLoading && results.isEmpty
                  ? buildLoadingIndicator(isLoading: isLoading)
                  : SlidableAutoCloseBehavior(
                      closeWhenOpened: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        //+1 for progressbar
                        itemCount: results.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == results.length) {
                            return buildJumpingLoadingIndicator(
                                isLoading: isLoading);
                          } else {
                            return results[index];
                          }
                        },
                        controller: _scrollController,
                      ),
                    );
    }
  }

  void getListOfSuggestions() {
    if (isFirstTime == false) {
      if (nextPageUrl == null || nextPageUrl!.isEmpty) return;
    }
    if (mounted) setState(() => isSuggestionLoading = true);

    UserAuth().getListOfSuggestions(nextUrl: nextPageUrl).then((value) {
      if (mounted) setState(() => isSuggestionLoading = false);

      basePaginationModel = value;
      suggestionsList.addAll(value.result);
      nextPageUrl = basePaginationModel!.next;
      isFirstTime = false;
      // debugPrint('NEXT PAGE URL -> ${basePaginationModel!.next}');

      if (suggestionsList.isEmpty) {
        if (mounted) setState(() => noItemInSuggestionList = true);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          isSuggestionLoading = false;
          noItemInSuggestionList = true;
        });
      }
      isFirstTime = false;
    });
  }

  void _onRefresh() {
    isFirstTime = true;
    suggestionsList.clear();
    nextPageUrl = null;
    getListOfSuggestions();
    _refreshCtrl.refreshCompleted();
  }

  Future<void> getSearchUserList() async {
    if (!isLoading) {
      // debugPrint('GET LIST ---------->');

      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }

        final Map<String, dynamic>? result = await _auth
            .searchEndpointPagination(
                getSearchUrl(autoCompleteSearchText), next, previous)
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
        final List? tempList = result['results'];

        // debugPrint('RESULT ::: $tempList');

        if (mounted) {
          isLoading = false;
          results.clear();

          try {
            for (var result in tempList!) {
              results.add(getResultTile(result));
            }
            // debugPrint('FINAL RESULT-> $results');
          } catch (e) {
            debugPrint('CANNOT SHOW SEARCH RESULT -> ${e.toString()}');
          }

          setState(() {});
        }
      }
      if (results.isNotEmpty) {
        noItemInList = false;
        setState(() {});
      } else if (results.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && results.length > 6) {
        _scaffoldMessengerSearchKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content:
        //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
        // _scaffoldSearchKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
      }
    }
  }

  // ignore: missing_return
  Widget getResultTile(var result) {
    switch (selectedMenuItemIndex) {
      case 0:
        // debugPrint('RESULT OKAY->');
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
        return "${AppConfig.baseUrl}/api/v1/search/users/?search=$searchedText";
      case 1:
        return "${AppConfig.baseUrl}/api/v1/search/products/?search=$searchedText";
      case 2:
        return "${AppConfig.baseUrl}/api/v1/search/services/?search=$searchedText";
      default:
        return "${AppConfig.baseUrl}/api/v1/search/users/?search=$searchedText";
    }
  }

  Widget getUserTile(var object) {
    final CustomerProfile user = CustomerProfile.fromJson(object);

    // if (user.userName.toString().toLowerCase() == "slydo" ||
    //     user.userName.toString().toLowerCase() == "slydo_envelope") {
    //   return Container();
    // }

    if (user.userName.toString().toLowerCase() == "slydo_envelope") {
      return Container();
    }

    return _getSlidableWithLists(context, userCard(user), user);
  }

  Widget userCard(CustomerProfile user) {
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
                  title: userNameWithVerifiedIcon(
                    name: user.fullName!,
                    isVerified: user.isVerified,
                  ),
                  subtitle: Text(
                    '@${user.userName!}',
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
    final String imageUrl = user.avatar != ""
        ? user.avatar!
        : getInitials(user.fullName!).toString().toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: imageUrl);
      },
      child: getUserProfilePic(user),
    );
  }

  Widget getUserProfilePic(CustomerProfile user) {
    final Color borderColor = getUserTypeColor(user: user);

    if (user.avatar == "" ||
        user.avatar ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(user.fullName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
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
        ),
      );
    }
  }

  Widget getProductTile(var object) {
    final Product product = Product();
    product.name = object['name'];
    product.id = object['id'];
    product.shortDescription = object['short_description'];
    product.description = "";
    product.condition = object['condition'];
    product.currency = object['currency'];
    product.price = object['price'];
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
                  leading: getLeading(product, object),
                  title: getTitle(product),
                  trailing: product.price.toString().length > 6
                      ? null
                      : getTrailingProduct(product),
                  subtitle: getSubtitleProduct(product),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.PRODUCT_DETAIL_PAGE,
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
    } catch (e) {
      debugPrint('Error : $e');
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: imageUrl);
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
              ? const Icon(Icons.person)
              : CircularLoadingIndicator(),
        ),
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

  Widget getServiceTile(var object) {
    final Service service = Service();
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
                    Navigator.of(context).pushNamed(Routes.SERVICE_DETAIL,
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
    } catch (e) {
      debugPrint('Error : $e');
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: imageUrl);
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
                ? const Icon(Icons.person)
                : CircularLoadingIndicator()),
      ),
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

  void loadUsers(List data) {
    switch (selectedMenuItemIndex) {
      case 0:
        for (var item in data) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getUserTile(item));
            });
          }
        }
        break;
      case 1:
        for (var item in data) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getProductTile(item));
            });
          }
        }
        break;
      case 2:
        for (var item in data) {
          if (mounted) {
            setState(() {
              if (data.isNotEmpty) {
                noItemInList = false;
              }
              results.add(getServiceTile(item));
            });
          }
        }
        break;
    }
  }

  // Widget autoComplete() {
  //   return Column(
  //     children: <Widget>[
  //       TextFormField(
  //         key: textFormField,
  //         controller: searchItemTextController,
  //         decoration: InputDecoration(
  //           contentPadding: EdgeInsets.all(10),
  //           hintText: hint,
  //           isDense: true,
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(
  //               color: Colors.white,
  //               width: 1,
  //             ),
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: BorderSide(
  //               color: blackFont,
  //               width: 1,
  //             ),
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           fillColor: Colors.white,
  //           filled: true,
  //         ),
  //         style: TextStyle(color: Colors.black, fontSize: 16),
  //         onFieldSubmitted: (val) {
  //           if (mounted) {
  //             setState(() {
  //               count = 0;
  //               next = "";
  //               previous = "";
  //               results.clear();
  //               noItemInList = false;
  //               getList();
  //             });
  //           }
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _getSlidableWithLists(
      BuildContext context, Widget searchCard, CustomerProfile user) {
    return Slidable(
      startActionPane: user.userName.toString().toLowerCase() == "slydo"
          ? null
          : ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.25,
              children: listSecondaryActions(user),
            ),
      endActionPane: user.userName.toString().toLowerCase() == "slydo"
          ? null
          : ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.25,
              children: listSecondaryActions(user),
            ),
      child: VerticalListItem(searchCard, user),
    );
  }

  List<Widget> listActionSlideActions(CustomerProfile user) {
    final bool isNotCurrentUser = user.userName != userBloc!.user.userName;
    return [
      if (isNotCurrentUser)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          icon: Icons.payments_rounded,
          onPressed: (con) async {
            if (appConfigurationModel?.enablePayment == true) {
              // customerProfileBloc.customer =
              //     await UserAuth().fetchCustomerProfile(user.userName);
              Navigator.of(context).pushNamed(
                Routes.REQUEST_PAYMENT,
                arguments: <String, dynamic>{
                  'isFromProfile': false,
                  'isRequest': true,
                  'recipient': user.userName,
                },
              );
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          },
          label: AppLocalization.of(context)!.request,
          backgroundColor: navyBlue,
        ),
      if (isNotCurrentUser)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          icon: Icons.payments_rounded,
          onPressed: (con) async {
            if (appConfigurationModel?.enablePayment == true) {
              // customerProfileBloc.customer =
              //     await UserAuth().fetchCustomerProfile(user.userName);
              Navigator.of(context)
                  .pushNamed(Routes.SEND_PAYMENT, arguments: <String, dynamic>{
                'isFromProfile': false,
                'recipient': user.userName,
              });
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          },
          label: AppLocalization.of(context)!.send,
          backgroundColor: naturalGreen,
        ),
    ];
  }

  List<Widget> listSecondaryActions(CustomerProfile user) {
    return [
      if (!userConnectionNames.contains(user.userName) &&
          user.userName != userBloc!.user.userName)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          icon: SlydoAppIcon.add,
          onPressed: (con) async {
            connectUserAlert(user);
          },
          label: 'Connect',
          backgroundColor: naturalGreen,
        ),
      if (userBloc!.user.userName != user.userName)
        SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          icon: SlydoAppIcon.block,
          onPressed: (con) async {
            blockUserAlert(user);
          },
          label: 'Block',
          backgroundColor: mateRed,
        ),
    ];
  }

  Widget _getSlidableWithLists1(
      BuildContext context, Widget searchCard, Product product) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions1(product),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions1(product),
      ),
      child: VerticalListItem1(searchCard, product),
    );
  }

  List<Widget> listSecondaryActions1(Product product) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        icon: SlydoAppIcon.cart,
        onPressed: (con) async {
          customerProfileBloc.customer =
              await UserAuth().fetchCustomerProfile(product.seller);
          Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
              arguments: {'isFromProfile': false, 'product': product});
        },
        label: AppLocalization.of(context)!.buy,
        backgroundColor: naturalGreen,
      ),
    ];
  }

  List<Widget> listActionSlideActions1(Product product) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        icon: SlydoAppIcon.textMessage,
        onPressed: (con) async {
          Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
            'recipient': product.seller,
            'subject': product.name,
          });
        },
        label: "Message",
        backgroundColor: navyBlue,
      ),
    ];
  }

  Widget _getSlidableWithLists2(
      BuildContext context, Widget searchCard, Service service) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions2(service),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions2(service),
      ),
      child: VerticalListItem2(searchCard, service),
    );
  }

  List<Widget> listSecondaryActions2(Service service) {
    return [
      SlideActionButton(
          borderRadius: BorderRadius.circular(5),
          padding: EdgeInsets.zero,
          label: AppLocalization.of(context)!.buy,
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.cart,
          onPressed: (con) async {
            customerProfileBloc.customer =
                await UserAuth().fetchCustomerProfile(service.provider);
            Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
                arguments: {'isFromProfile': false, 'service': service});
          }),
    ];
  }

  List<Widget> listActionSlideActions2(Service service) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        label: AppLocalization.of(context)!.message,
        backgroundColor: navyBlue,
        icon: SlydoAppIcon.textMessage,
        onPressed: (con) async {
          Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
            'recipient': service.provider,
            'subject': service.name,
          });
        },
      ),
    ];
  }

  void blockUserAlert(CustomerProfile user) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.block,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.block,
      description:
          "${AppLocalization.of(context)!.areYouSureWantToBlock} ${user.displayName()}",
      actionOneText: AppLocalization.of(context)!.block,
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      final bool done = await UserAuth().blockUser(user);
      if (done) {
        showSnackbar(context,
            message:
                "${user.displayName()} ${AppLocalization.of(context)!.isBlockedSuccessfully}");

        final ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);
        connectionListBloc.deleteChatConversation(
            conversationId: user.conversationId);

        // if (connectionsList.length <= 9) {
        //   getList();
        // }
        setState(() {});
      } else {
        showSnackbar(context, message: AppLocalization.of(context)!.error);
      }
    }
  }

  void connectUserAlert(CustomerProfile user) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.add,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      title: AppLocalization.of(context)!.connect,
      description:
          "Are you sure you want to add ${user.displayName()} to your list of friends",
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.connect,
      rightButtonOnPressed: () {
        showDialog(
            context: context,
            builder: (dialogLoadingContext) => LoadingIndicator());

        UserAuth().makeContactRequest(user).then((value) {
          Navigator.pop(context);
          if (value) {
            showToast(message: "Friends Request Sent !!");
          } else {
            showToast(message: "Request Not Sent.. ");
          }
        });
      },
    );
  }

  @override
  void dispose() {
    searchItemTextController.dispose();
    _scrollController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child, this.user, {super.key});

  final Widget child;
  CustomerProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": user.userName});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem1 extends StatelessWidget {
  VerticalListItem1(this.child, this.product, {super.key});

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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem2 extends StatelessWidget {
  VerticalListItem2(this.child, this.service, {super.key});

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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
