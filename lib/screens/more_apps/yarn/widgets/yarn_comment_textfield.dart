import 'dart:io';
import 'dart:typed_data';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/GIFModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_search.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/CustomBoxShadow.dart';
import '../../../../widget/customized_textform_field.dart';
import '../../../moments/screens/trimmer_view.dart';
import '../../messaging/chat/utils.dart';
import '../models/Topics/yarn_model.dart';
import '../models/share_as_yarn_model.dart';
import 'ask_enable_adult_viewers_advice.dart';
import 'ask_enable_comment_payment.dart';

class YarnCommentTextField extends StatefulWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget leading;
  final double height;
  final Function()? function;
  final Function(String)? onChanged;
  final String? hint;
  final VoidCallback? onTap;
  final bool suffix;
  final Widget? suffixIcon;
  final Yarn? yarn;
  final String? userImage;
  final VoidCallback? onPressed;
  final bool? isLoading;
  bool? enableComment;
  bool? enablePayment;
  ScrollController? scrollController;
  bool? enableAdult;
  bool? viewerAdvice;
  var ageRating;
  List<ShareAsYarnModel>? shareAsYarnModel;
  final Function(bool?) onTapEnableComment;
  final Function(int?) onTapAgeRestriction;
  final Function(bool?) onTapEnablePayment;
  final Function(bool?) onTapEnableAdult;
  final Function(bool?) onTapViewerAdvice;
  final Function(List<YarnMedia>)? addedSelectedMedia;
  final Function(bool)? resetScrollingValue;
  bool isScrolling;

  YarnCommentTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.viewerAdvice,
    this.scrollController,
    this.shareAsYarnModel,
    this.height = 60,
    this.isScrolling = false,
    this.function,
    this.ageRating,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.yarn,
    this.leading = const SizedBox(
      width: 0,
      height: 0,
    ),
    this.onTap,
    this.suffix = true,
    this.suffixIcon,
    this.userImage,
    this.onPressed,
    this.isLoading = false,
    this.enableComment,
    this.enablePayment,
    this.enableAdult,
    this.addedSelectedMedia,
    required this.onTapEnableComment,
    required this.onTapEnablePayment,
    required this.onTapEnableAdult,
    required this.onTapViewerAdvice,
    this.onChanged,
    required this.onTapAgeRestriction,
    this.resetScrollingValue,
  }) : super(key: key);

  @override
  State<YarnCommentTextField> createState() =>
      YarnCommentTextFieldState(key: key);
}

class YarnCommentTextFieldState extends State<YarnCommentTextField> {
  Key? key;
  YarnCommentTextFieldState({this.key});
  List<Map<String, dynamic>> selectedImagesList = [];
  List<YarnMedia> selectedMedia = [];
  List<PickedFile> selectedImages = [];
  String? videoPath;
  String? imagePath;
  List<ShareAsYarnModel>? shareAsYarnModelCopy;
  ShareAsYarnModel? _shareAsYarnModel;

  var ageRating;
  bool isShowExtension = false;
  bool onFocus = true;

  ///variable for message actions
  bool showMoreAction = false;

  /// variables for GIF Message
  List<GIFModel> _gifs = [];
  bool _isMessageIsGIFOrSticker = false;
  bool _isMessageIsSticker = false;
  bool _isGIFLoading = false;
  TextEditingController _gifController = TextEditingController();

  /// variables for product or service search
  bool isProductSearch = true;
  bool isServiceSearch = false;
  bool isCurrentUsersProductOrService = false;
  List searchedProductAndService = [];
  StateSetter? bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;

  bool isItemLoading = false;
  int? productOrServiceCount = 0;
  String? productOrServiceNext = "";
  String? productOrServicePrevious = "";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = new ScrollController();

  TextEditingController? searchItemTextController;
  GlobalKey _key = LabeledGlobalKey("itemSearchTypeSelectionKey");
  CustomizedPopUpMenu? itemSearchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  GlobalKey searchItemTextFormField = GlobalKey();
  int bottomSheetSearchIndex = 0;
  bool noSearchedItem = false;
  var productServicePreview;
  Product? productMode;
  Service? serviceMode;
  YarnDashboardBloc? yarnDashboardBloc;

  FocusNode _focus = FocusNode();

  void _onFocusChange() {
    if (_focus.hasFocus) {
      isShowExtension = true;
      setState(() {});
    } else {
      isShowExtension = false;
      setState(() {});
    }
  }

  void onAPICall() {
    setState(() {
      selectedImages.clear();
      selectedMedia.clear();
      selectedImagesList.clear();
      widget.addedSelectedMedia!(selectedMedia);
    });
  }

  @override
  void initState() {
    shareAsYarnModelCopy = widget.shareAsYarnModel;
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    _focus.addListener(_onFocusChange);

    searchItemTextController = TextEditingController();
    _gifController.addListener(searchGiFListener);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getProductOrServiceList();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    return Expanded(
        child: ClipRect(
            clipper: CustomShape(),
            child: Align(
                alignment: Alignment.bottomCenter,
                // heightFactor: 1.5,
                child: getCommentBoxWithOptions())));
  }

  Widget getCommentBoxWithOptions() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: blackFont.withOpacity(0.1), width: 2),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 8, top: 3.6),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'Replying to ',
                          style: TextStyle(
                              fontFamily: "Roboto",
                              color: blackFont,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      TextSpan(
                          text: '@${widget.yarn!.author}',
                          style: TextStyle(
                            color: blackFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ))
                    ]),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Divider(
                  color: greySecondaryYarn,
                ),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () async {
                              if (selectedImages.length == 4) {
                                showToast(
                                    message:
                                        "You can select only 4 images or videos");
                              } else {
                                pickFileFromMedia();
                              }
                            },
                            child: SvgPicture.asset("yarn/images".toSVG())),
                        SizedBox(
                          width: 8,
                        ),
                        _buildRatingCategory(),
                        SizedBox(width: 8),
                        _buildEnableComment(),
                        SizedBox(width: 8),
                        _buildEnablePayme(),
                        SizedBox(width: 8),
                        _buildEnableViewerAdvice(),
                        SizedBox(width: 8),
                        _buildEnableAdultsOnly(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.4,
                ),
                if (selectedImages.isNotEmpty) ...[
                  Divider(
                    color: greySecondaryYarn,
                  ),
                  _buildAddImages(),
                  // SizedBox(
                  //   height: 5,
                  // ),
                ],
                if (yarnDashboardBloc!.productService != null) ...[
                  checkIfProductService(),
                ],
              ],
            ),
            Divider(
              color: greySecondaryYarn,
            ),
            getCommentBox()
          ],
        ),
      ),
    );
  }

  Widget getCommentBox() {
    return messageActionBar();
  }

  Widget getPreviewContainer() {
    //display services
    if (productServicePreview.runtimeType.toString() == 'Service') {
      return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
        child: YarnServiceTile(
          service: serviceMode,
          tileRenderPlace: TileRenderPlace.YarnProductService,
        ),
      );
    }
    //display product
    else if (productServicePreview.runtimeType.toString() == 'Product') {
      return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
        child: YarnProductTile(
          product: productMode,
          tileRenderPlace: TileRenderPlace.YarnProductService,
        ),
      );
    } else {
      return Container();
    }
  }

  Widget messageActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: getSearchBarLayout(),
    );
  }

  Widget getSearchBarLayout() {
    return Column(
      children: getSearchBarItems(),
    );
  }

  List<Widget> getSearchBarItems() {
    List<Widget> items = [];

    if (_isMessageIsGIFOrSticker) {
      items.add(Container(
        constraints: BoxConstraints(minHeight: 54, maxHeight: 100),
        child: Row(
          children: <Widget>[
            getSearchGIFCancelBtn(),
            Expanded(
              child: searchGIFTextField(),
            ),
            searchGIFBtn(),
          ],
        ),
      ));
      items.add(gifPreviewList());
      return items;
    }

    items.add(Container(
      constraints: BoxConstraints(minHeight: 40, maxHeight: 100),
      child: Row(
        children: <Widget>[
          moreActionBtn(),
          Expanded(
            child: textMessageField(),
          ),
          sendMessageBtn(),
        ],
      ),
    ));

    if (showMoreAction) {
      items.add(moreActionsBtn());
    }

    return items;
  }

  Widget getSearchGIFCancelBtn() {
    return IconButton(
        icon: Icon(
          SlydoAppIcon.close_2,
          color: navyBlue,
          size: 20,
        ),
        onPressed: () async {
          _gifController.clear();
          _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
          _isMessageIsSticker = false;
          if (mounted) setState(() {});
        });
  }

  Widget searchGIFTextField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: chatBackgroundColor,
        child: Theme(
            data: ThemeData(highlightColor: navyBlue.withOpacity(0.3)),
            child: Scrollbar(
              radius: Radius.circular(12),
              thickness: 2.5,
              child: TextFormField(
                controller: _gifController,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.multiline,
                onFieldSubmitted: (value) {
                  getGIFs();
                },
                cursorColor: blackFont,
                cursorWidth: 1,
                cursorHeight: 20,
                maxLines: null,
                cursorRadius: Radius.circular(16),
                decoration: InputDecoration(
                  hintText: "Search ${_isMessageIsSticker ? "Sticker" : "GIF"}",
                  hintStyle: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 16),
                  ),
                  suffix: Padding(
                    padding: EdgeInsets.only(right: 36),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: chatBackgroundColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget searchGIFBtn() {
    return InkWell(
      onTap: getGIFs,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(
              SlydoAppIcon.search,
              color: navyBlue,
              size: 22,
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget gifPreviewList() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: _isGIFLoading
          ? Center(child: CircularLoadingIndicator())
          : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // sendGIFToSocket(
                    //     urlOfGIF: _gifs[index].images!.original!.url);
                    _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
                    _isMessageIsSticker = false;
                    _gifController.clear();
                    if (mounted) setState(() {});
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width / 2,
                      imageUrl: _gifs[index].images!.previewGif!.url!,
                      fit: BoxFit.fill,
                      errorWidget: imageErrorWidget,
                      placeholder: (context, url) => Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Center(child: CircularLoadingIndicator())),
                    ),
                  ),
                );
              },
              itemCount: _gifs.length,
            ),
    );
  }

  Widget moreActionBtn() {
    return IconButton(
        icon: Icon(
          showMoreAction ? SlydoAppIcon.close_2 : SlydoAppIcon.add,
          color: navyBlue,
          size: showMoreAction ? 22 : 20,
        ),
        onPressed: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            Future.delayed(Duration(milliseconds: 100)).then((value) {
              showMoreAction = !showMoreAction;
              if (mounted) setState(() {});
            });
          } else {
            showMoreAction = !showMoreAction;
            if (mounted) setState(() {});
          }
        });
  }

  Widget moreActionsBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 45,
        runSpacing: 20,
        children: [
          assignTitleToAction(
              text: "Product/ Service", child: searchProductAndServiceBtn()),
          assignTitleToAction(text: "GIF", child: sendGIFButton()),
          assignTitleToAction(text: "", child: Container()),
          assignTitleToAction(text: "", child: Container()),
        ],
      ),
    );
  }

  Widget assignTitleToAction({required String text, required Widget child}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 60),
      child: Column(
        children: [
          child,
          SizedBox(height: 10),
          Center(
            child: Text(text,
                style: TextStyle(
                  color: blackFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }

  Widget sendGIFButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        Icons.gif_rounded,
        color: blackFont,
        size: 38,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
        getGIFs(isRandom: true);
        if (mounted) setState(() {});
        // pickGIF();
      },
    );
  }

  void getGIFs({bool isRandom = false}) async {
    _isGIFLoading = true;
    if (mounted) setState(() {});

    List<GIFModel> results;
    if (isRandom) {
      results = await MessageAuth()
          .searchGIF(isRandom: true, isSticker: _isMessageIsSticker)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });
    } else {
      results = await MessageAuth()
          .searchGIF(
              query: _gifController.text.trim(), isSticker: _isMessageIsSticker)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });
    }

    _isGIFLoading = false;
    if (mounted) setState(() {});

    if (results.isNotEmpty) {
      _gifs.clear();
      _gifs = results;
      if (mounted) setState(() {});
    }
  }

  Widget searchProductAndServiceBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.search,
        color: blackFont,
        size: 18,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        if (mounted) setState(() {});
        showSearchProductAndServiceBottomSheet();
      },
    );
  }

  void showSearchProductAndServiceBottomSheet() async {
    var result = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, StateSetter bottomSheetStateSetter) {
            bottomSheetStateSetterGlobal = bottomSheetStateSetter;
            bottomSheetMounted = true;

            return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: searchBox()),
                      SizedBox(height: 8),
                      Expanded(child: bottomSheetTabBar())
                    ],
                  ),
                ));
          });
        });
    bottomSheetMounted = false;
    if (result == null) {
      if (itemSearchTypeSelectionMenu!.isMenuOpen) {
        itemSearchTypeSelectionMenu!.closeMenu();
      }
    }
  }

  Widget searchBox() {
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme:
              TextSelectionThemeData().copyWith(selectionHandleColor: navyBlue),
        ),
        child: TextFormField(
          key: searchItemTextFormField,
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
              FocusScope.of(context).unfocus();
              searchProductOrService();
            }
          },
        ),
      ),
    );
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
          if (itemSearchTypeSelectionMenu!.isMenuOpen) {
            itemSearchTypeSelectionMenu!.closeMenu();
          } else {
            itemSearchTypeSelectionMenu!.openMenu();
          }
        },
      ),
    );
  }

  IconData getSearchTypeIcon() {
    if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.note_2;
    } else if (selectedMenuItemIndex == 0) {
      return SlydoAppIcon.product;
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
      onPressed: () {
        FocusScope.of(context).unfocus();
        searchProductOrService();
      },
    );
  }

  void searchProductOrService() {
    clearSearchedListItems();
    getProductOrServiceList();
  }

  void clearSearchedListItems() {
    searchedProductAndService.clear();
    productOrServiceCount = 0;
    productOrServiceNext = "";
    productOrServicePrevious = "";
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
      bottomSheetStateSetterGlobal!(() {});
    if (mounted) setState(() {});
  }

  void getProductOrServiceList() async {
    String url = getSearchUrl();

    if (!isItemLoading) {
      if (productOrServiceNext != null && !isItemLoading) {
        isItemLoading = true;

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await MessageAuth()
            .searchProductAndServiceOfUser(
                url, productOrServiceNext, productOrServicePrevious);
        if (result == null) {
          isItemLoading = false;
          return;
        }
        productOrServiceCount = result['count'];
        productOrServiceNext = result['next'];
        productOrServicePrevious = result['previous'];
        List tempList = result['results'];

        isItemLoading = false;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});

        tempList.forEach((item) {
          if (isProductSearch) {
            searchedProductAndService.add(Product.fromJson(item));
          } else if (isServiceSearch) {
            searchedProductAndService.add(Service.fromJson(item));
          }
        });

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});
      }
      if (searchedProductAndService.isEmpty) {
        noSearchedItem = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});
      }
    }
  }

  String getSearchUrl() {
    if (isProductSearch) {
      return AppConfig.baseUrl +
          "/api/v1/search/products/?search=name__wildcard|*" +
          searchItemTextController!.text +
          "*";
    }
    if (isServiceSearch) {
      return AppConfig.baseUrl +
          "/api/v1/search/services/?search=name__wildcard|*" +
          searchItemTextController!.text +
          "*";
    }
    return "";
  }

  void searchGiFListener() {
    if (_gifController.text != "") {
      getGIFs();
    }
  }

  Widget bottomSheetTabBar() {
    return Column(
      children: [
        // Container(
        //     padding: EdgeInsets.symmetric(horizontal: 20),
        //     child: bottomSheetTabBars()),
        SizedBox(
          height: 8,
        ),
        Expanded(child: bottomSheetTabViews())
      ],
    );
  }

  Widget bottomSheetTabBars() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 0;
                clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});
                setState(() {});
                searchProductOrService();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  color: bottomSheetSearchIndex == 0
                      ? navyBlue.withOpacity(0.1)
                      : Colors.white,
                ),
                child: Text(
                  "From partner",
                  style: TextStyle(
                    color: bottomSheetSearchIndex == 0 ? navyBlue : blackFont,
                    fontSize: 14,
                    fontWeight: bottomSheetSearchIndex == 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 1;
                clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});
                setState(() {});
                searchProductOrService();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  color: bottomSheetSearchIndex == 1
                      ? navyBlue.withOpacity(0.1)
                      : Colors.white,
                ),
                child: Text(
                  "From Mine",
                  style: TextStyle(
                    color: bottomSheetSearchIndex == 1 ? navyBlue : blackFont,
                    fontSize: 14,
                    fontWeight: bottomSheetSearchIndex == 1
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget bottomSheetTabViews() {
    return pullToRefresh();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        productOrServiceCount = 0;
        productOrServiceNext = "";
        productOrServicePrevious = "";
        searchedProductAndService = [];
        noSearchedItem = false;
        getProductOrServiceList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
  }

  Widget pullToRefresh() {
    return searchItemTextController!.text.isEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: buildProductOrServiceList(),
          );
  }

  Widget buildProductOrServiceList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: searchedProductAndService.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == searchedProductAndService.length) {
                return _buildIndicatorForProductAndService();
              } else {
                return GestureDetector(
                    onTap: () {
                      productServicePreview = searchedProductAndService[index];

                      if (productServicePreview.runtimeType.toString() ==
                          'Product') {
                        Product product = searchedProductAndService[index];
                        var attachment = {'product': product.toJson()};
                        yarnDashboardBloc!.productService = attachment;
                        productMode = searchedProductAndService[index];
                      } else {
                        Service service = searchedProductAndService[index];
                        var attachment = {'service': service.toJson()};
                        yarnDashboardBloc!.productService = attachment;
                        serviceMode = searchedProductAndService[index];
                      }

                      isShowExtension = true;
                      if (mounted) setState(() {});
                      Navigator.pop(context);

                      FocusScope.of(context).requestFocus();
                    },
                    child: getResultTile(searchedProductAndService[index]));
              }
            },
            controller: _scrollController,
          );
  }

  Widget getResultTile(var result) {
    if (isProductSearch) {
      if (result is Product) {
        return SearchProductTile(
          product: result,
        );
      }
      return Container();
    }
    if (isServiceSearch) {
      if (result is Service) {
        return SearchServiceTile(
          service: result,
        );
      }
      return Container();
    }
    return Container();
  }

  Widget _buildIndicatorForProductAndService() {
    return Center(
      child: isItemLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            )
          : Container(),
    );
  }

  Widget _buildAddImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImagesList.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index == 0 ? addImageButton() : showImage(index),
        ),
      ),
    );
  }

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: HexColor("#E9E9E9"), width: 1.5)),
        shadowColor: boxShadowTwo,
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: HexColor("#E9E9E9"), width: 1.5)),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.camera_alt_outlined,
                  color: HexColor("#130F26"),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: HexColor("#000000"), fontSize: 14),
                ),
              ],
            ),
            onTap: () async {
              if (selectedImages.length == 4) {
                showToast(message: "You can select only 4 images or videos");
              } else {
                pickFileFromMedia();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: HexColor("#E9E9E9"), width: 1.5)),
            shadowColor: dividerColor,
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: HexColor("#E9E9E9"), width: 1.5),
                image: selectedImagesList[index - 1]['mediaType'] == 'image'
                    ? DecorationImage(
                        image: FileImage(
                          File(selectedImagesList[index - 1]['file'].path),
                        ),
                        fit: BoxFit.fill)
                    : DecorationImage(
                        image: MemoryImage(
                          selectedImagesList[index - 1]['file'],
                        ),
                        fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedImagesList.removeAt(index - 1);
                  selectedImages.removeAt(index - 1);
                  selectedMedia.removeAt(index - 1);
                  widget.addedSelectedMedia!(selectedMedia);
                });
              },
              child: Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 6, top: 6),
                decoration: BoxDecoration(
                    color: HexColor("#000000"), shape: BoxShape.circle),
                child: Icon(
                  Icons.close_outlined,
                  color: white,
                  size: 15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  pickFileFromMedia() async {
    List<Media>? res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.all,
      language: Language.System,
      maxTime: 900,
      cropOpt: CropOption(
        cropType: CropType.rect,
      ),
    );

    if (res == null || res.isEmpty) return;
    File file = File(res.first.path);
    String? mediaType = getFileTypeByPath(path: file.path);

    if (mediaType == null) return;

    if (mediaType == 'image') {
      imagePath = file.path;
      selectedImagesList.add({
        'mediaType': mediaType,
        'file': PickedFile(imagePath!),
      });
      selectedImages.add(PickedFile(imagePath!));
      selectedMedia
          .add(YarnMedia(mediaFile: File(imagePath!), mediaType: mediaType));

      if (widget.addedSelectedMedia != null)
        widget.addedSelectedMedia!(selectedMedia);
      if (mounted) setState(() {});
    } else if (mediaType == 'video') {
      var videoFilePath =
          await NavigationUtil.push(context, screen: TrimmerView(file: file));
      if (videoFilePath is String) {
        videoPath = videoFilePath;
        Uint8List? uInt8List = await getVideoThumbnailFromUrl(videoPath!);
        String? thumbnailImage =
            await generateThumbNailFromVideo(videoPath: videoPath!);
        // setUpVideoPlayer();
        // generateThumbNailFromVideo(videoPath: videoPath!).then((thumbnail) {
        //   if (thumbnail != null) {
        //     generatedVideoThumbnail = thumbnail;
        //     debugPrint('file path gen -> $generatedVideoThumbnail');
        //   }
        // });
        selectedImagesList.add({
          'mediaType': mediaType,
          'file': uInt8List,
          'imagePoster': thumbnailImage,
        });
        selectedImages.add(PickedFile(videoPath!));
        selectedMedia.add(YarnMedia(
            mediaFile: File(videoPath!),
            mediaType: mediaType,
            mediaPoster: thumbnailImage));
        // ignore: unnecessary_statements
        // if (widget.addedSelectedMedia != null)
        widget.addedSelectedMedia!(selectedMedia);
        if (mounted) setState(() {});
      }
    }
    debugPrint("SELECTED IMAGES:- $selectedImages");
  }

  void ratingCategory() {
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    widget.shareAsYarnModel = shareAsYarnModelCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: [
                CustomizedTextFormField(
                  hintText: 'Select age',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      widget.shareAsYarnModel = shareAsYarnModelCopy!
                          .where((element) => element.name!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      widget.shareAsYarnModel = shareAsYarnModelCopy;
                      changeState(() {});
                    }
                  },
                  onTap: widget.onTapAgeRestriction,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.shareAsYarnModel!.length,
                    itemBuilder: (context, index) {
                      ShareAsYarnModel category =
                          widget.shareAsYarnModel![index];

                      return ListTile(
                        title: Text(
                          category.name ?? '',
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          _shareAsYarnModel = category;
                          ageRating = _shareAsYarnModel?.name?.substring(9);
                          logger.d('message $ageRating');
                          widget.onTapAgeRestriction(int.parse(ageRating));
                          setState(() {});
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingCategory() {
    return InkWell(
      onTap: () => ratingCategory(),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: HexColor("#F8F8F8"),
            border: Border.all(color: HexColor("#E9E9E9")),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _shareAsYarnModel?.name ?? '',
              style: TextStyle(fontSize: 10, color: HexColor("#7A7A7A")),
            ),
            SizedBox(
              width: 4,
            ),
            Icon(Icons.expand_more_outlined,
                color: HexColor("#7A7A7A"), size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildEnableViewerAdvice() {
    return AskEnableAdultAndViewerAdvice(
      onTap: widget.onTapViewerAdvice,
      title: "Viewer Advice",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#F8BBD9"),
      highLightBorderColor: HexColor("#E96CAA"),
      highLightTextColor: HexColor("#E96CAA"),
    );
  }

  Widget _buildEnableAdultsOnly() {
    return AskEnableAdultAndViewerAdvice(
      onTap: widget.onTapEnableAdult,
      title: "Adults Only",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#D9B6FF"),
      highLightBorderColor: HexColor("#9F6BD8"),
      highLightTextColor: HexColor("#9F6BD8"),
    );
  }

  Widget _buildEnableComment() {
    return AskEnableCommentAndPayment(
      onTap: widget.onTapEnableComment,
      title:
          (widget.enableComment ?? true) ? "comment enabled" : "enable comment",
      image: "yarn/yarn_comment",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#000000"),
      highLightBorderColor: HexColor("#000000"),
      highLightTextColor: HexColor("#FFFFFF"),
    );
  }

  Widget _buildEnablePayme() {
    return AskEnableCommentAndPayment(
      onTap: widget.onTapEnablePayment,
      title:
          (widget.enablePayment ?? true) ? "payment enabled" : "enable payment",
      image: "yarn/send_money",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#D9E1FA"),
      highLightBorderColor: HexColor("#BBCBFF"),
      highLightTextColor: HexColor("#3F61DB"),
    );
  }

  sendMessageBtn() {
    return widget.isLoading!
        ? Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(navyBlue),
                  strokeWidth: 2.0,
                ),
              ),
            ),
          )
        : IconButton(
            padding: EdgeInsets.zero,
            onPressed: widget.onPressed,
            icon: Icon(
              Icons.send,
              color: darkGreyYarn,
            ),
          );
  }

  textMessageField() {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      onEditingComplete: widget.function,
      controller: widget.controller,
      onChanged: widget.onChanged,
      focusNode: _focus,
      cursorColor: blackFont,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
        fontWeight: FontWeight.w400,
      ),
      validator: widget.validator,
      keyboardType: TextInputType.multiline,
      maxLines: 10,
      minLines: 1,
      // autofocus: true,
      readOnly: widget.readOnly,
      onTap: widget.onTap ??
          () {
            if (widget.resetScrollingValue != null)
              widget.resetScrollingValue!(false);
          },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: InputBorder.none,
          hintText: widget.hint ?? '',
          hintStyle: TextStyle(fontSize: 14, color: HexColor("#808080")),
          suffixIcon: widget.suffixIcon ?? const SizedBox.shrink()),
    );
  }

  Widget checkIfProductService() {
    return Container(
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              getPreviewContainer(),
              Positioned(
                right: 20,
                top: 10,
                child: InkWell(
                  onTap: () {
                    yarnDashboardBloc!.productService = null;
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    height: 25,
                    width: 25,
                    margin: EdgeInsets.only(right: 6, top: 6),
                    decoration: BoxDecoration(
                        color: HexColor("#000000"), shape: BoxShape.circle),
                    child: Icon(
                      Icons.close_outlined,
                      color: white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomShape extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Offset(0, -2) & Size(size.width, size.height);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}
