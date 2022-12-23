import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../../../../widget/customized_textform_field.dart';
import '../models/Topics/YarnTopic.dart';
import '../models/global_field.dart';
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
  final bool? enableComment;
  final bool? enablePayment;
  final bool? enableAdult;
  final bool? viewerAdvice;

  List<ShareAsYarnModel>? shareAsYarnModel;
  final Function(bool?) onTapEnableComment;
  final Function(bool?) onTapEnablePayment;
  final Function(bool?) onTapEnableAdult;
  final Function(bool?) onTapViewerAdvice;

  YarnCommentTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
    this.viewerAdvice,
    this.shareAsYarnModel,
    this.height = 60,
    this.function,
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
    required this.onTapEnableComment,
    required this.onTapEnablePayment,
    required this.onTapEnableAdult,
    required this.onTapViewerAdvice,
    this.onChanged,
  }) : super(key: key);

  @override
  State<YarnCommentTextField> createState() => _YarnCommentTextFieldState();
}

class _YarnCommentTextFieldState extends State<YarnCommentTextField> {
  @override
  void initState() {
    shareAsYarnModelCopy = widget.shareAsYarnModel;
    _shareAsYarnModel = widget.shareAsYarnModel?.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: CustomShape(),
      child: Container(
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
              ],
            ),
            Divider(
              color: greySecondaryYarn,
            ),
            Container(
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
                      onTap: widget.onTap,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: widget.hint ?? '',
                          hintStyle: TextStyle(
                              fontSize: 14, color: HexColor("#808080")),
                          suffixIcon:
                              widget.suffixIcon ?? const SizedBox.shrink()),
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(navyBlue),
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
            ),
          ],
        ),
      ),
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

  List<ShareAsYarnModel>? shareAsYarnModelCopy;

  ShareAsYarnModel? _shareAsYarnModel;

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
      onTap: (value) {
        isSensitiveContent = value ?? false;
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
    return AskEnableCommentAndPayment(
      onTap: (value) {
        isAdultContent = value ?? false;
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
