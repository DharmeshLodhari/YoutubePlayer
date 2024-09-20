import 'dart:io';

import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/blog/user_post/models/user_post.dart';
import 'package:Slydo/screens/messaging/chat/models/gif_model/gif_model.dart';
import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/screens/moments/screens/trimmer_view.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/service_hub/models/jobs.dart';
import 'package:Slydo/screens/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/yarn/tiles/yarn_blog_post_tile.dart';
import 'package:Slydo/screens/yarn/tiles/yarn_customer_post_tile.dart';
import 'package:Slydo/screens/yarn/tiles/yarn_product_tile.dart';
import 'package:Slydo/screens/yarn/tiles/yarn_quote_preview.dart';
import 'package:Slydo/screens/yarn/tiles/yarn_service_tile.dart';
import 'package:Slydo/screens/yarn/utils/utils.dart';
import 'package:Slydo/screens/yarn/widgets/ask_enable_adult_viewers_advice.dart';
import 'package:Slydo/screens/yarn/widgets/ask_enable_comment_payment.dart';
import 'package:Slydo/screens/yarn/widgets/ask_mention_view.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/screens/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/storage_permission.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'models/Topics/yarn_model.dart';
import 'models/ask_categories_model.dart';
import 'models/share_as_yarn_model.dart';

class ShareAsYarnScreen extends StatefulWidget {
  String? appTitle;
  List<YarnCategories>? askCategories;
  List<ShareAsYarnModel>? shareAsYarnModel;
  YarnCategories? askCategory;
  bool? isYarn = false;
  bool? enableText = false; //TODO: this attribute should be deprecated
  bool isShare = true;
  Yarn? yarnTopic;
  CustomerProfile? userProfile;
  Service? serviceModel;
  Product? productModel;
  JobModel? jobModel;

  UserPost? blogPost;

  Function(Yarn params) callback;
  ShareAsYarnScreen(
      {super.key,
      this.askCategories,
      this.shareAsYarnModel,
      this.appTitle,
      this.isYarn,
      this.enableText, //TODO: this attribute should be deprecated
      this.askCategory,
      this.isShare = true,
      required this.callback,
      this.yarnTopic,
      this.userProfile,
      this.serviceModel,
      this.jobModel,
      this.blogPost,
      this.productModel});

  @override
  State<ShareAsYarnScreen> createState() => _ShareAsYarnScreenState();
}

class _ShareAsYarnScreenState extends State<ShareAsYarnScreen> {
  final yarnController = TextEditingController();

  final textController = TextEditingController();
  late FocusNode textFieldTagFocusNode;
  List<YarnMedia> newMediaList = [];
  List<YarnMedia> existingMediaList = [];
  int imageCount = 5;
  YarnCategories? selectedAskCategory;
  ShareAsYarnModel? _shareAsYarnModel;
  YarnCategories? pressedAskCategory;
  List<YarnCategories>? askCategoriesCopy;
  String askCategory = "";
  List<String> userTags = [];
  late UserBloc userBloc;
  bool enableCommenting = true;
  bool enablePayMe = false;
  String? videoPath;
  String? imagePath;
  bool isVideoLoading = false;
  VideoPlayerController? videoPlayerController;
  String? generatedVideoThumbnail;
  bool isAPILoading = false;
  bool isMentionName = false;
  String? searchString;

  List<ShareAsYarnModel>? shareAsYarnModelCopy;
  bool _isAdultContent = false;
  bool _isSensitiveContent = false;

  /// variables for GIF Message
  List<GIFModel> _gifs = [];
  bool _isMessageIsGIFOrSticker = false;
  bool _isMessageIsSticker = false;
  bool _isGIFLoading = false;
  final TextEditingController _gifController = TextEditingController();

  @override
  void initState() {
    shareAsYarnModelCopy = widget.shareAsYarnModel;
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    Future.microtask(() => context.read<YarnDashboardBloc>().init());
    textFieldTagFocusNode = FocusNode();
    askCategoriesCopy = widget.askCategories;

    if (widget.yarnTopic == null) {
    } else {
      if (widget.yarnTopic!.category != null) {
        selectedAskCategory = widget.yarnTopic!.category;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: lightGrey,
      appBar: _buildAppBar(widget.appTitle ?? "Share As A Yarn"),
      body: Consumer<YarnDashboardBloc>(builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  _buildYarnForm(model),
                  messageActionBar(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget gifPreviewList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: _isGIFLoading
          ? Center(child: CircularLoadingIndicator())
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    //_gifs[index].images!.original!.url
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
                      placeholder: (context, url) => SizedBox(
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
              radius: const Radius.circular(12),
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
                cursorRadius: const Radius.circular(16),
                decoration: InputDecoration(
                  hintText: "Search ${_isMessageIsSticker ? "Sticker" : "GIF"}",
                  hintStyle: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16),
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 36),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
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

  Widget searchGIFBtn() {
    return InkWell(
      onTap: getGIFs,
      child: Container(
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(
              SlydoAppIcon.search,
              color: navyBlue,
              size: 22,
            ),
            const SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getSearchBarItems() {
    final List<Widget> items = [];

    if (_isMessageIsGIFOrSticker) {
      items.add(Container(
        constraints: const BoxConstraints(minHeight: 54, maxHeight: 100),
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

    return items;
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

  PreferredSizeWidget _buildAppBar(String? appTitle) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      shape: Border(bottom: BorderSide(color: HexColor("#D9D9D9"))),
      centerTitle: false,
      title: Text(
        appTitle!,
        style: TextStyle(
          fontSize: 18.5,
          fontWeight: FontWeight.w600,
          color: blackFont,
        ),
      ),
      elevation: 0,
      titleSpacing: 0,
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _buildTextField(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: getPreviewContainer(),
          ),
          if (isMentionName) ...[
            _buildUserNameContainer(),
          ],
          // if (selectedImages.isNotEmpty) ...[
          //   _buildAddImages(),
          //   SizedBox(height: 20),
          // ],
          _buildAddImages(),
          if (!_isMessageIsGIFOrSticker) _buildRowForMedia(),
        ],
      ),
    );
  }

  Widget getPreviewContainer() {
    //display yarn,
    if (widget.yarnTopic != null) {
      return YarnQuotePreview(
        yarn: widget.yarnTopic!,
      );
    }
    //display user profile,
    else if (widget.userProfile != null) {
      return YarnCustomerPostTile(
        customerProfile: widget.userProfile,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    }
    //display services
    else if (widget.serviceModel != null) {
      return YarnServiceTile(
        service: widget.serviceModel,
      );
    }
    //display product
    else if (widget.productModel != null) {
      return YarnProductTile(
        product: widget.productModel,
      );
    }
    //display blog post
    else if (widget.blogPost != null) {
      return YarnBlogPostTile(
        post: widget.blogPost,
        showAuthorDetails: true,
        onDeleteBlog: () {},
      );
    }
    //display job service
    else if (widget.jobModel != null) {
      return JobDescriptionCard(
        job: widget.jobModel,
      );
    } else {
      return Container();
    }
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
        hintText: "Leave your thought",
        hintStyle: TextStyle(
          fontSize: 12,
          color: HexColor("#7A7A7A"),
          fontWeight: FontWeight.w400,
        ),
        counterText: "${textController.text.length}/${400}",
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildRowForContents() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRatingCategory(),
            const SizedBox(width: 8),
            _buildEnableViewerAdvice(),
            const SizedBox(width: 8),
            _buildEnableAdultsOnly(),
          ]),
    );
  }

  Widget _buildRowForMedia() {
    return SafeArea(
      child: Container(
        // height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: HexColor("#D9D9D9")))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              if (!widget.isShare)
                InkWell(
                    onTap: () async {
                      if (await checkStoragePermission()) {
                        final bool isPermissionGranted =
                            await requestGalleryPermission();
                        if (isPermissionGranted) {
                          await pickFileFromMedia();
                        } else {
                          final bool isPermissionIsDenied =
                              await isPermanentlyDeniedPermission();
                          if (isPermissionIsDenied) {
                            await openAppSettings();
                          } else {
                            await openAppSettings();
                          }
                        }
                      }
                    },
                    child: SvgPicture.asset("yarn/images".toSVG())),
              if (!widget.isShare) const SizedBox(width: 8),
              if (!widget.isShare)
                InkWell(
                    onTap: () {
                      _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
                      getGIFs(isRandom: true);
                      if (mounted) setState(() {});
                    },
                    child: SvgPicture.asset("yarn/yarn_gif".toSVG())),
              if (!widget.isShare) const SizedBox(width: 8),
              _buildCategory(),
              const SizedBox(width: 8),
              if (widget.askCategories != null &&
                  widget.askCategories!.isNotEmpty)
                const SizedBox(width: 4),
              _buildEnableComment(),
              const SizedBox(
                width: 4,
              ),
              _buildEnablePayme(),
              const SizedBox(
                width: 4,
              ),
              _buildRowForContents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnableViewerAdvice() {
    return AskEnableAdultAndViewerAdvice(
      onTap: (value) {
        _isSensitiveContent = value ?? true;
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
        _isAdultContent = value ?? true;
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

  Widget _buildEnableComment() {
    return AskEnableCommentAndPayment(
      onTap: (value) {
        enableCommenting = value ?? false;
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
        enablePayMe = value ?? false;
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

  Widget _buildCategory() {
    return InkWell(
      onTap: () {
        categoryAndroidSheet();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: HexColor("#F8F8F8"),
            border: Border.all(color: HexColor("#E9E9E9")),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedAskCategory != null
                  ? (selectedAskCategory!.name ?? "select category")
                  : "select category",
              style: TextStyle(fontSize: 10, color: HexColor("#ACAEB4")),
            ),
            const SizedBox(
              width: 4,
            ),
            Icon(Icons.expand_more_outlined,
                color: HexColor("#ACAEB4"), size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCategory() {
    return InkWell(
      onTap: () => ratingCategory(),
      child: Container(
        padding: const EdgeInsets.all(8),
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
            const SizedBox(
              width: 4,
            ),
            Icon(Icons.expand_more_outlined,
                color: HexColor("#7A7A7A"), size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImages() {
    try {
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
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showAddMediaButton) ...[
                    addImageButton(),
                    const SizedBox(
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
          const SizedBox(
            height: 20,
          ),
        ],
      );
    } catch (e, s) {
      debugPrint("$e===========> $s");
    }

    return Container();
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

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: HexColor("#E9E9E9"), width: 1.5)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
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
                const SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: HexColor("#000000"), fontSize: 14),
                ),
              ],
            ),
            onTap: () async {
              if (existingMediaList.length + newMediaList.length == 4) {
                showToast(message: "You can select only 4 images or videos");
              } else {
                // pickImage();
                final bool isPermissionGranted =
                    await requestGalleryPermission();
                if (isPermissionGranted) {
                  await pickFileFromMedia();
                } else {
                  final bool isPermissionIsDenied =
                      await isPermanentlyDeniedPermission();
                  if (isPermissionIsDenied) {
                    await openAppSettings();
                  } else {
                    await openAppSettings();
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget showLocalMedia(YarnMedia e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: HexColor("#E9E9E9"), width: 1.5)),
                shadowColor: dividerColor,
                margin:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
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
                    margin: const EdgeInsets.only(right: 6, top: 6),
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
        const SizedBox(
          width: 8,
        )
      ],
    );
  }

  Widget showServerMedia(YarnMedia e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: HexColor("#E9E9E9"), width: 1.5)),
                shadowColor: dividerColor,
                margin:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
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
                    margin: const EdgeInsets.only(right: 6, top: 6),
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
        const SizedBox(
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

  void onValueChange(String value) {
    final List<String> listOfWords = value.split(" ");

    if (listOfWords.isNotEmpty) {
      if ((listOfWords.last.contains("@") &&
          !value.endsWith(" ") &&
          !value.endsWith("@"))) {
        isMentionName = true;
        final List<String> mentionString = getAllMentions(value);

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
          textController.text = "${textController.text.replaceRange(
            (textController.text.length - (searchString?.length ?? 0)),
            textController.text.length,
            tappedUser,
          )} ";
          textController.selection = TextSelection.fromPosition(TextPosition(
            offset: textController.text.length,
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
        const SizedBox(
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
              categoryAndroidSheet();
              // selectItemCategory();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 240),
      child: CurvedButton(
        height: 32,
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Submit",
        fontSize: 10,
        borderRadius: 20,
        isLoading: isAPILoading,
        onPressed: () {
          if (selectedAskCategory?.id == null) {
            showToast(message: 'Category is not selected');
            return;
          }

          final yarn = Yarn(
              media: newMediaList,
              body: messageDecoderWithEmoji(textController.text),
              category: selectedAskCategory,
              isQuestion: false, //widget.isYarn ?? false,
              author: userBloc.user.userName,
              enablePayMe: enablePayMe,
              enableCommenting: enableCommenting,
              isSensitiveContent: _isSensitiveContent,
              isAdultContent: _isAdultContent,
              ageRestriction: _shareAsYarnModel?.id);

          widget.callback(yarn);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> pickFileFromMedia() async {
    // List<Media>? res = await ImagesPicker.pick(
    //   count: 1,
    //   pickType: PickType.all,
    //   language: Language.System,
    //   maxTime: 900,
    //   cropOpt: CropOption(
    //     cropType: CropType.rect,
    //   ),
    // );

    final XFile? res = await selectSingleImageVideo();

    if (res == null) return;
    final File file = File(res.path);
    final String? mediaType = getFileTypeByPath(path: file.path);

    if (mediaType == null) return;

    if (mediaType == 'image') {
      imagePath = file.path;
      newMediaList
          .add(YarnMedia(mediaFile: File(imagePath!), mediaType: mediaType));
      if (mounted) setState(() {});
    } else if (mediaType == 'video') {
      final videoFilePath =
          await NavigationUtil.push(context, screen: TrimmerView(file: file));
      if (videoFilePath is String) {
        videoPath = videoFilePath;
        final File? thumbnailImage =
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
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.askCategories!.length,
                    itemBuilder: (context, index) {
                      final YarnCategories category =
                          widget.askCategories![index];
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

  void ratingCategory() {
    widget.shareAsYarnModel = shareAsYarnModelCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
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
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.shareAsYarnModel!.length,
                    itemBuilder: (context, index) {
                      final ShareAsYarnModel category =
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

  Future<void> addYarnAndQuestion() async {
    final Yarn yarn = Yarn();
    yarn.media = newMediaList;
    yarn.tags = userTags;
    yarn.title = messageDecoderWithEmoji(yarnController.text);
    yarn.body = messageDecoderWithEmoji(textController.text);
    yarn.category = selectedAskCategory;
    yarn.isQuestion = widget.isYarn == true ? false : true;
    yarn.author = userBloc.user.userName;
    yarn.enablePayMe = enablePayMe;
    yarn.enableCommenting = enableCommenting;

    await YarnAuth().addYarnAndQuestion(yarn, '', '').then((value) {
      if (widget.isYarn == true) {
        Navigator.pop(context, Types.Yarn);
      } else if (widget.isYarn == false) {
        Navigator.pop(context, Types.Question);
      }
      showToast(
          message: widget.isYarn == true
              ? "Yarn add successfully"
              : "Question add successfully");
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
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
    super.key,
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
  });

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
