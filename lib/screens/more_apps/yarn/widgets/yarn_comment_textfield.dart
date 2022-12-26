import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';

import '../../../../locale/app_localization.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/CustomBoxShadow.dart';
import '../../../../widget/customized_textform_field.dart';
import '../../../moments/screens/trimmer_view.dart';
import '../../messaging/chat/utils.dart';
import '../models/Topics/YarnTopic.dart';
import '../models/share_as_yarn_model.dart';
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
  final Function(List<AddMediaForYarn>)? addedSelectedMedia;
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
  State<YarnCommentTextField> createState() => _YarnCommentTextFieldState();
}

class _YarnCommentTextFieldState extends State<YarnCommentTextField> {
  List<Map<String, dynamic>> selectedImagesList = [];
  List<AddMediaForYarn> selectedMedia = [];
  List<PickedFile> selectedImages = [];
  String? videoPath;
  String? imagePath;
  List<ShareAsYarnModel>? shareAsYarnModelCopy;
  ShareAsYarnModel? _shareAsYarnModel;

  var ageRating;
  bool isShowExtension = false;
  bool onFocus = true;

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

  @override
  void initState() {
    shareAsYarnModelCopy = widget.shareAsYarnModel;
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        clipper: CustomShape(),
        child: !widget.isScrolling && isShowExtension
            ? getCommentBoxWithOptions()
            : getCommentBox());
  }

  Widget getCommentBoxWithOptions() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: blackFont.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.only(left: 16, right: 8),
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
                height: 10,
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
                          onTap: () {
                            if (selectedImages.length == 4) {
                              showToast(
                                  message:
                                      "You can select only 4 images or videos");
                            } else {
                              pickFileFromMedia();
                              // pickImage();
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
                SizedBox(
                  height: 10,
                ),
              ],
            ],
          ),
          Divider(
            color: greySecondaryYarn,
          ),
          getCommentBox()
        ],
      ),
    );
  }

  Widget getCommentBox() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: navyBlue,
            ),
            child: Icon(
              Icons.add_outlined,
              color: white,
              size: 15,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.userImage!,
                fit: BoxFit.cover,
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              onEditingComplete: widget.function,
              controller: widget.controller,
              onChanged: widget.onChanged,
              focusNode: _focus,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w400,
              ),
              validator: widget.validator,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              minLines: 1,
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
                  hintStyle:
                      TextStyle(fontSize: 14, color: HexColor("#808080")),
                  suffixIcon: widget.suffixIcon ?? const SizedBox.shrink()),
            ),
          ),
          widget.isLoading!
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
                ),
        ],
      ),
    );
  }

  Widget _buildAddImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        // controller: _scrollController,
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
            onTap: () {
              if (selectedImages.length == 4) {
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
      selectedMedia.add(
          AddMediaForYarn(mediaFile: File(imagePath!), mediaType: mediaType));

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
        selectedMedia.add(AddMediaForYarn(
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
    return AskEnableCommentAndPayment(
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
    return AskEnableCommentAndPayment(
      onTap: widget.onTapEnableAdult,
      // onTap: (value) {
      //   widget.enableAdult = value ?? false;
      //   if (mounted) setState(() {});
      // },
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
      title: (widget.enableComment ?? false)
          ? "comment enabled"
          : "enable comment",
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
      title: (widget.enablePayment ?? false)
          ? "payment enabled"
          : "enable payment",
      image: "yarn/send_money",
      baseBGColor: HexColor("#F8F8F8"),
      baseBorderColor: HexColor("#E9E9E9"),
      baseTextColor: HexColor("#ACAEB4"),
      highLightBGColor: HexColor("#D9E1FA"),
      highLightBorderColor: HexColor("#BBCBFF"),
      highLightTextColor: HexColor("#3F61DB"),
    );
  }
}

class CustomShape extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Offset(0, -2) & Size(size.width, size.height);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}
