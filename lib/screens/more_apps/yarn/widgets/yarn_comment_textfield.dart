import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../models/Topics/YarnTopic.dart';
import 'ask_enable_comment_payment.dart';

class YarnCommentTextField extends StatelessWidget {
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
  final Yarn? yarn;
  final String? userImage;
  final VoidCallback? onPressed;
  final bool? isLoading;
  final bool? enableComment;
  final bool? enablePayment;
  final Function(bool?) onTapEnableComment;
  final Function(bool?) onTapEnablePayment;

  const YarnCommentTextField({
    Key? key,
    required this.controller,
    this.hint,
    this.validator,
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
    required this.onTapEnableComment,
    required this.onTapEnablePayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: CustomShape(),
      child: Container(
        padding: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: blackFont.withOpacity(0.1), width: 2),
        ),
        child: Column(
          children: [
            // Container(
            //   padding: EdgeInsets.only(left: 16, right: 8),
            //   child: Row(
            //     children: [
            //       _buildEnableComment(),
            //       SizedBox(
            //         width: 4,
            //       ),
            //       _buildEnablePayme()
            //     ],
            //   ),
            // ),
            // Divider(color: greySecondaryYarn,),
            Container(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   height: 25,
                  //   width: 25,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: navyBlue,
                  //   ),
                  //   child: Icon(
                  //     Icons.add_outlined,
                  //     color: white,
                  //     size: 15,
                  //   ),
                  // ),
                  // SizedBox(width: 12,),
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userImage!,
                        fit: BoxFit.cover,
                        errorWidget: imageErrorWidget,
                      ),
                    ),
                  ),
                  Expanded(
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
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: hint ?? '',
                          hintStyle:
                          TextStyle(fontSize: 14, color: HexColor("#808080")),
                          suffixIcon: suffixIcon ?? const SizedBox.shrink()),
                    ),
                  ),
                  isLoading!
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
                    onPressed: onPressed,
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

  Widget _buildEnableComment() {
    return AskEnableCommentAndPayment(
      onTap: onTapEnableComment,
      title: (enableComment ?? false) ? "comment enabled" : "enable comment",
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
      onTap: onTapEnablePayment,
      title: (enablePayment ?? false) ? "payment enabled" : "enable payment",
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
