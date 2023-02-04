import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_search.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_enable_adult_viewers_advice.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_enable_comment_payment.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/ask_mention_view.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';
import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../main.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/CustomBoxShadow.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_dropdown_field.dart';
import '../../../widget/customized_textform_field.dart';
import '../../moments/screens/trimmer_view.dart';
import '../messaging/chat/utils.dart';
import 'models/Topics/yarn_model.dart';
import 'models/ask_categories_model.dart';
import 'models/share_as_yarn_model.dart';
import 'yarn_dashboard_bloc.dart';

class AddOrEditYarn extends StatefulWidget {
  List<YarnCategories>? askCategories;
  YarnCategories? askCategory;
  bool? isYarn = false;
  Yarn? yarn;
  String? passedCategory;

  List<ShareAsYarnModel>? shareAsYarnModel;
  AddOrEditYarn(
      {this.askCategories,
      this.isYarn,
      this.askCategory,
      this.yarn,
      this.shareAsYarnModel,
      this.passedCategory});

  @override
  State<AddOrEditYarn> createState() => _AddOrEditYarnState();
}

class _AddOrEditYarnState extends State<AddOrEditYarn> {
  final yarnController = TextEditingController();

  TextEditingController? textController = TextEditingController();
  late FocusNode textFieldTagFocusNode;
  List<YarnMedia> newMediaList = [];
  List<YarnMedia> existingMediaList = [];
  int imageCount = 5;
  YarnCategories? selectedAskCategory;
  YarnCategories? pressedAskCategory;
  YarnCategories? categoryPicked;
  List<YarnCategories>? askCategoriesCopy;
  String askCategory = "";
  List<String> userTags = [];
  late UserBloc userBloc;
  bool enableCommenting = true;
  bool enablePayMe = true;
  String? videoPath;
  String? imagePath;
  bool isVideoLoading = false;
  VideoPlayerController? videoPlayerController;
  String? generatedVideoThumbnail;
  bool isAPILoading = false;
  bool isMentionName = false;
  String? searchString;
  Map<String, dynamic>? yarn;

  List<ShareAsYarnModel>? shareAsYarnModelCopy;

  ShareAsYarnModel? _shareAsYarnModel;

  bool isSensitiveContent = false;
  bool isAdultContent = false;
  var ageRating;

  ///variable for message actions
  bool showMoreAction = false;
  bool isShowExtension = false;

  /// variables for product or service search
  bool isBlogSearch = false;
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
  bool editMode = false;

  @override
  void initState() {
    shareAsYarnModelCopy = widget.shareAsYarnModel;
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    ageRating = _shareAsYarnModel?.name?.substring(9);
    yarn = widget.yarn?.toJson();

    searchItemTextController = TextEditingController();
    editMode = true;

    if (widget.passedCategory.toString().isNotEmpty) {
      selectedAskCategory = widget.askCategory;
    } else {
      selectedAskCategory = yarn?['category'] == null
          ? YarnCategories()
          : YarnCategories.fromJson(yarn?['category'].toJson());
      pressedAskCategory = yarn?['category'] == null
          ? YarnCategories()
          : YarnCategories.fromJson(yarn?['category'].toJson());
    }

    if (yarn?['body'].toString() == 'null') {
      textController!.text = '';
    } else {
      textController!.text = messageDecoderWithEmoji(yarn?['body']) ?? '';
    }

    Future.microtask(() => context.read<YarnDashboardBloc>().init());
    textFieldTagFocusNode = FocusNode();
    askCategoriesCopy = widget.askCategories;
    fillExistingYarnMedia();
    super.initState();
  }

  void fillExistingYarnMedia() {
    if (widget.yarn != null && widget.yarn?.media != null) {
      widget.yarn?.media.forEach((element) {
        existingMediaList.add(element);
      });
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    if (editMode == true) {
      if (widget.yarn != null) {
        if (widget.yarn!.attachment.toString() != 'null') {
          if (widget.yarn!.attachmentType == 'product') {
            Product product = Product.fromJson(widget.yarn!.attachment);
            var attachment = {'product': product.toJson()};
            yarnDashboardBloc!.productService = attachment;
            productMode = product;
            productServicePreview = product;
          } else if (widget.yarn!.attachmentType == 'service') {
            Service service = Service.fromJson(widget.yarn!.attachment);
            var attachment = {'service': service.toJson()};
            yarnDashboardBloc!.productService = attachment;
            serviceMode = service;
            productServicePreview = service;
          }
        }

        if (mounted) setState(() {});
      }
      editMode = false;
      if (mounted) setState(() {});
    }

    itemSearchTypeSelectionMenu = CustomizedPopUpMenu(
        buttonKey: _key,
        context: context,
        hasIcon: true,
        children: [
          // CustomizedPopUpMenuItemWithIcon(
          //     title: "Blog", value: "Blog", icon: SlydoAppIcon.circle_user),
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
    itemSearchTypeSelectionMenu!.onChange = menuItemSelectionChange;
    itemSearchTypeSelectionMenu!.menuState = menuStateChange;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<YarnDashboardBloc>(builder: (context, model, child) {
        return Column(
          children: [_buildYarnForm(model)],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      shape: Border(bottom: BorderSide(color: HexColor("#D9D9D9"))),
      centerTitle: false,
      title: Text(
        widget.isYarn! ? "Yarn" : "Question",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0,
      titleSpacing: 0,
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          if (yarnDashboardBloc!.productService != null) {
            yarnDashboardBloc!.productService == null;
          }
        },
        child: Icon(
          Icons.keyboard_arrow_left,
          color: HexColor("#292929"),
          size: 26,
        ),
      ),
      actions: [
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildYarnForm(YarnDashboardBloc model) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!(widget.isYarn ?? false)) ...[
            _buildQuestionFiled(),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _buildTextField(),
            ),
          ),
          if (isMentionName) ...[
            _buildUserNameContainer(),
          ],
          _buildAddImages(),
          //check if product/services
          if (yarnDashboardBloc!.productService != null) ...[
            checkIfProductService(),
          ],
          _buildRowForMedia(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      // keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 1,
      controller: textController,
      style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HexColor("#151515")),
      onChanged: onValueChange,
      inputFormatters: [LengthLimitingTextInputFormatter(400)],
      decoration: InputDecoration(
        counterText:
            textController!.text.length.toString() + "/" + 400.toString(),
        hintText: "Leave your thought",
        hintStyle: TextStyle(
          fontSize: 13,
          color: HexColor("#7A7A7A"),
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildQuestionFiled() {
    return Container(
      height: 45,
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor("#D9D9D9"))),
      ),
      child: TextField(
        controller: yarnController,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: HexColor("#151515")),
        decoration: InputDecoration(
          hintText: "Ask a Question",
          hintStyle: TextStyle(
            fontSize: 12,
            color: HexColor("#7A7A7A"),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRowForMedia() {
    return Container(
      // height: 65,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: HexColor("#D9D9D9")),
              top: BorderSide(color: HexColor("#D9D9D9")))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 8, bottom: 20, top: 15),
        child: Row(
          children: [
            //check if image is not selected
            if (existingMediaList.isEmpty && newMediaList.isEmpty) ...[
              //add plus icon for product/services
              getAddLayout(),
            ],

            //check if product/service is selected
            if (yarnDashboardBloc!.productService == null) ...[
              InkWell(
                  onTap: () {
                    pickFileFromMedia();
                  },
                  child: SvgPicture.asset("yarn/images".toSVG())),
            ],

            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {}, child: SvgPicture.asset("yarn/yarn_gif".toSVG())),
            SizedBox(
              width: 8,
            ),
            _buildCategory(),
            SizedBox(
              width: 4,
            ),
            _buildRatingCategory(),
            SizedBox(
              width: 4,
            ),
            _buildEnableComment(),
            SizedBox(
              width: 4,
            ),
            _buildEnablePayme(),
            SizedBox(
              width: 4,
            ),
            _buildEnableViewerAdvice(),
            SizedBox(width: 4),
            _buildEnableAdultsOnly(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnableComment() {
    return AskEnableCommentAndPayment(
      onTap: (value) {
        enableCommenting = yarn?['enable_commenting'] ?? value ?? false;
        if (mounted) setState(() {});
      },
      title: enableCommenting ? "comment enabled" : "enable comment",
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
      onTap: (value) {
        enablePayMe = yarn?['enable_payme'] ?? value ?? false;
        if (mounted) setState(() {});
      },
      title: enablePayMe ? "payment enabled" : "enable payment",
      image: "yarn/send_money",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#D9E1FA"),
      highLightBorderColor: HexColor("#BBCBFF"),
      highLightTextColor: HexColor("#3F61DB"),
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
      onTap: (value) {
        isSensitiveContent = value ?? true;
        if (mounted) setState(() {});
      },
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
      onTap: (value) {
        isAdultContent = value ?? true;
        if (mounted) setState(() {});
      },
      title: "Adults Only",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#D9B6FF"),
      highLightBorderColor: HexColor("#9F6BD8"),
      highLightTextColor: HexColor("#9F6BD8"),
    );
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

  Widget _buildCategory() {
    return InkWell(
      onTap: () {
        categoryAndroidSheet();
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: HexColor("#F8F8F8"),
            border: Border.all(color: HexColor("#E9E9E9")),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checkCategory(),
              style: TextStyle(fontSize: 10, color: HexColor("#ACAEB4")),
            ),
            SizedBox(
              width: 4,
            ),
            Icon(Icons.expand_more_outlined,
                color: HexColor("#ACAEB4"), size: 12),
          ],
        ),
      ),
    );
  }

  String checkCategory() {
    // if (widget.passedCategory.toString().isNotEmpty) {
    //   selectedAskCategory!.name = widget.passedCategory.toString();
    // }
    if (selectedAskCategory!.name != null) {
      return selectedAskCategory!.name.toString();
    } else {
      return 'select category';
    }
  }

  Widget _buildAddImages() {
    if (existingMediaList.isEmpty && newMediaList.isEmpty) return Container();

    bool showAddMediaButton = false;

    if (existingMediaList.length + newMediaList.length < 4) {
      showAddMediaButton = true;
    } else {
      showAddMediaButton = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showAddMediaButton) ...[
                  addImageButton(),
                  SizedBox(
                    width: 8,
                  )
                ],
                _buildNewAddedMedia(),
                _buildExistingMedia(),
              ],
            ),
          ),
        ),

        // Container(
        //   height: 100,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: selectedImagesList.length + 1,
        //     itemBuilder: (context, index) => Container(
        //       padding: EdgeInsets.only(right: 6),
        //       child: index == 0 ? addImageButton() : showImage(index),
        //     ),
        //   ),
        // ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildNewAddedMedia() {
    if (newMediaList.isEmpty) {
      return Container();
    }

    return Row(
      children: newMediaList.map((e) => showLocalMedia(e)).toList(),
    );
  }

  Widget _buildExistingMedia() {
    if (existingMediaList.isEmpty) {
      return Container();
    }

    return Row(
      children: existingMediaList.map((e) => showServerMedia(e)).toList(),
    );
  }

  Widget showLocalMedia(YarnMedia e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
                    image: _buildLocalMediaView(e),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    newMediaList.remove(e);
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
              )
            ],
          ),
        ),
        SizedBox(
          width: 8,
        )
      ],
    );
  }

  Widget showServerMedia(YarnMedia e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
                    image: _buildServerMediaView(e),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    existingMediaList.remove(e);
                    if (mounted) setState(() {});

                    YarnAuth().deleteYarnMedia(e.id!).catchError((error) {
                      logger.e(error);
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
        ),
        SizedBox(
          width: 8,
        )
      ],
    );
  }

  DecorationImage _buildLocalMediaView(YarnMedia e) {
    File? file;

    if (e.mediaType == "image") {
      file = e.mediaFile!;
    } else {
      file = e.posterFile!;
    }

    return DecorationImage(
        image: FileImage(
          file,
        ),
        fit: BoxFit.fill);
  }

  DecorationImage _buildServerMediaView(YarnMedia e) {
    String imageUrl;

    if (e.mediaType == "image") {
      imageUrl = e.mediaUrl!;
    } else {
      imageUrl = e.mediaPoster!;
    }

    return DecorationImage(
        image: NetworkImage(
          imageUrl,
        ),
        fit: BoxFit.fill);
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
            onTap: () {
              if (existingMediaList.length + newMediaList.length == 4) {
                showToast(message: "You can select only 4 images or videos");
              } else {
                // pickImage();
                pickFileFromMedia();
              }
            },
          ),
        ),
      ),
    );
  }

  void onValueChange(String value) {
    List<String> listOfWords = value.split(" ");

    if (listOfWords.isNotEmpty) {
      if ((listOfWords.last.contains("@") &&
          !value.endsWith(" ") &&
          !value.endsWith("@"))) {
        isMentionName = true;
        List<String> mentionString = getAllMentions(value);

        if (mentionString.isNotEmpty) {
          searchString = mentionString.last.substring(1);
        }
      } else if (value.endsWith("@")) {
        isMentionName = true;

        searchString = "";
      } else {
        isMentionName = false;
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildUserNameContainer() {
    return AskMentionView(
      searchText: searchString,
      key: UniqueKey(),
      onTap: (String? tappedUser) {
        if (tappedUser != null) {
          textController!.text = textController!.text.replaceRange(
                (textController!.text.length - (searchString?.length ?? 0)),
                textController!.text.length,
                tappedUser,
              ) +
              " ";
          textController!.selection = TextSelection.fromPosition(TextPosition(
            offset: textController!.text.length,
          ));
          searchString = "";
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget getCategoryField() {
    if (widget.askCategory != null) {
      selectedAskCategory = widget.askCategory;
      pressedAskCategory = widget.askCategory;
    }
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        CustomizedDropDownField(
          title: "Categories",
          borderWidth: 2.0,
          child: ListTile(
            dense: true,
            title: Text(
              selectedAskCategory != null ? selectedAskCategory!.name! : "",
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
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
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return textController!.text.isNotEmpty && textController!.text.length <= 400
        ? Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 24),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 240),
            child: CurvedButton(
              height: 32,
              textColor: Colors.white,
              backgroundColor: navyBlue,
              text: "Submit",
              fontSize: 10,
              borderRadius: 20,
              isLoading: isAPILoading,
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      if (mounted) setState(() {});
                      if (yarn != null) {
                        isAPILoading = true;
                        await editYarnAndQuestion();
                      } else {
                        if (selectedAskCategory?.name == null ||
                            selectedAskCategory!.name.toString().isEmpty) {
                          showToast(message: 'Category is not selected');
                          return;
                        }

                        isAPILoading = true;
                        if (mounted) setState(() {});
                        await addYarnAndQuestion();
                      }
                      existingMediaList.clear();
                      newMediaList.clear();
                      textController!.clear();
                      yarnController.clear();
                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
            ),
          )
        : Container();
  }

  void pickFileFromMedia() async {
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
      newMediaList
          .add(YarnMedia(mediaFile: File(imagePath!), mediaType: mediaType));
      if (mounted) setState(() {});
    } else if (mediaType == 'video') {
      var videoFilePath =
          await NavigationUtil.push(context, screen: TrimmerView(file: file));
      if (videoFilePath is String) {
        videoPath = videoFilePath;
        File? thumbnailImage =
            await generateThumbnailFromVideo(videoPath: videoPath!);
        // setUpVideoPlayer();
        // generateThumbNailFromVideo(videoPath: videoPath!).then((thumbnail) {
        //   if (thumbnail != null) {
        //     generatedVideoThumbnail = thumbnail;
        //     debugPrint('file path gen -> $generatedVideoThumbnail');
        //   }
        // });
        newMediaList.add(YarnMedia(
          mediaFile: File(videoPath!),
          mediaType: mediaType,
          posterFile: thumbnailImage,
        ));
        if (mounted) setState(() {});
      }
    }
  }

  void categoryAndroidSheet() {
    widget.askCategories = askCategoriesCopy;
    debugPrint("CATEGORIES:- ${widget.askCategories}");
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      widget.askCategories = askCategoriesCopy!
                          .where((element) => element.name!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      widget.askCategories = askCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.askCategories!.length,
                    itemBuilder: (context, index) {
                      YarnCategories category = widget.askCategories![index];
                      if (selectedAskCategory == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category.name!,
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
                              pressedAskCategory = category;
                              Navigator.pop(context);
                              if (pressedAskCategory != null) {
                                selectedAskCategory = pressedAskCategory;
                                askCategory = selectedAskCategory!.name!;
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category.name!,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedAskCategory = category;
                          Navigator.pop(context);
                          if (pressedAskCategory != null) {
                            selectedAskCategory = pressedAskCategory;
                            askCategory = selectedAskCategory!.name!;
                            setState(() {});
                          }
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

  void expiresAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.17,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: expiresList.length,
              itemBuilder: (context, index) {
                // if (selectedAskCategory == category) {
                //   return Container(
                //     color: selectedListItemBackgroundBlue,
                //     child: ListTile(
                //       dense: true,
                //       title: Text(
                //         category.name!,
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
                //         pressedAskCategory = category;
                //         Navigator.pop(context);
                //         if (pressedAskCategory != null) {
                //           selectedAskCategory = pressedAskCategory;
                //           askCategory = selectedAskCategory!.name!;
                //           setState(() {});
                //         }
                //       },
                //     ),
                //   );
                // }
                return ListTile(
                  title: Text(
                    expiresList[index],
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  dense: true,
                  onTap: () {
                    // pressedAskCategory = category;
                    Navigator.pop(context);
                    // if (pressedAskCategory != null) {
                    //   selectedAskCategory = pressedAskCategory;
                    //   askCategory = selectedAskCategory!.name!;
                    //   setState(() {});
                    // }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> editYarnAndQuestion() async {
    Yarn yarnEdit = Yarn(media: existingMediaList + newMediaList);
    yarnEdit.id = yarn!['id'];
    yarnEdit.body = textController!.text;
    yarnEdit.enableCommenting = enableCommenting;
    yarnEdit.enablePayMe = enablePayMe;
    yarnEdit.title = yarnController.text;
    yarnEdit.category = selectedAskCategory;
    // yarnEdit.category?.id = selectedAskCategory?.id ?? "0";
    yarnEdit.isQuestion = widget.isYarn == true ? false : true;
    yarnEdit.author = userBloc.user.userName;
    // yarnEdit.media = yarn?['media'];
    yarnEdit.tags = userTags;

    if (yarnDashboardBloc!.productService != null) {
      yarnEdit.attachment = yarnDashboardBloc!.productService;
    }

    // debugPrint("YARN CATEGORY 000:- ${yarnEdit}");
    // debugPrint("YARN CATEGORY:- ${yarnEdit.category}");

    await YarnAuth().editYarnAndQuestion(yarnEdit).then((value) {
      debugPrint("EDIT YARN:- $value");
      if (value != null) {
        widget.yarn = Yarn.fromJson(value);
      }
      if (widget.isYarn == true) {
        Navigator.pop(context, [Types.Yarn, widget.yarn]);
      } else if (widget.isYarn == false) {
        Navigator.pop(context, Types.Question);
      }
      //set product/service to null after comment is successful
      yarnDashboardBloc!.productService = null;
      showToast(
          message: widget.isYarn == true
              ? "Yarn updated successfully"
              : "Question updated successfully");
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Future<void> addYarnAndQuestion() async {
    Yarn yarn = Yarn();
    yarn.media = newMediaList;
    yarn.tags = userTags;
    yarn.title = yarnController.text;
    yarn.body = textController!.text;
    yarn.category = selectedAskCategory;
    yarn.isQuestion = widget.isYarn == true ? false : true;
    yarn.author = userBloc.user.userName;
    yarn.enablePayMe = enablePayMe;
    yarn.enableCommenting = enableCommenting;
    yarn.ageRestriction = int.parse(ageRating);
    yarn.isAdultContent = isAdultContent;
    yarn.isSensitiveContent = isSensitiveContent;

    if (yarnDashboardBloc!.productService != null) {
      yarn.attachment = yarnDashboardBloc!.productService;
    }

    logger.d(yarn.toAddMap());

    await YarnAuth().addYarnAndQuestion(yarn).then((value) {
      if (widget.isYarn == true) {
        Navigator.pop(context, Types.Yarn);
      } else if (widget.isYarn == false) {
        Navigator.pop(context, Types.Question);
      }
      //set product/service to null after comment is successful
      yarnDashboardBloc!.productService = null;
      showToast(
          message: widget.isYarn == true
              ? "Yarn add successfully"
              : "Question add successfully");
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  Widget getAddLayout() {
    return Column(
      children: getPlusBarItems(),
    );
  }

  List<Widget> getPlusBarItems() {
    List<Widget> items = [];

    items.add(Container(
      constraints: BoxConstraints(minHeight: 40, maxHeight: 100),
      child: Row(
        children: <Widget>[
          moreActionBtn(),
        ],
      ),
    ));

    if (showMoreAction) {
      items.add(moreActionsBtn());
    }

    return items;
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;

    if (value == "Products") {
      isProductSearch = true;
      isServiceSearch = false;
      isBlogSearch = false;
    } else if (value == "Services") {
      isServiceSearch = true;
      isProductSearch = false;
      isBlogSearch = false;
    } else if (value == "Blog") {
      isBlogSearch = true;
      isServiceSearch = false;
      isProductSearch = false;
    }

    clearSearchedListItems();
    if (mounted) setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
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
        ],
      ),
    );
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
          // onChanged: (val) {
          //   if (val.length == 3) {
          //     if (mounted) {
          //       searchProductOrService();
          //     }
          //   } else if (val.length == 6) {
          //     if (mounted) {
          //       searchProductOrService();
          //     }
          //   }
          // },
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
          } else if (isBlogSearch) {
            searchedProductAndService.add(UserPost.fromJson(item));
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

                      debugPrint(
                          'checking attachment 011::: ${searchedProductAndService[index]}');
                      debugPrint('checking attachment 012::: ${serviceMode}');
                      debugPrint('checking attachment 013::: ${productMode}');
                      debugPrint(
                          'checking attachment 014::: ${productServicePreview}');

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
                    debugPrint('trying to remove product/service');

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
}

class TopicTextField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final Widget leading;
  final double height;
  final Function()? function;
  final String? hint;
  final VoidCallback? onTap;
  final bool suffix;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const TopicTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.height = 60,
    this.function,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.leading = const SizedBox(
      width: 0,
      height: 0,
    ),
    this.onChanged,
    this.onTap,
    this.suffix = true,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: blackFont.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        onEditingComplete: function,
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: blackFont,
          fontWeight: FontWeight.w400,
        ),
        validator: validator,
        keyboardType: TextInputType.multiline,
        maxLines: 10,
        minLines: 1,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          border: InputBorder.none,
          hintText: hint ?? '',
          hintStyle: const TextStyle(fontSize: 12),
          suffixIcon: suffixIcon ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
