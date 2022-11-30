import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../models/Topics/YarnTopic.dart';

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
  final YarnTopic? yarn;
  final String? userImage;
  final VoidCallback? onPressed;
  final bool? isLoading;

  const TopicTextField(
      {Key? key,
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
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(left: 16, right: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: blackFont.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 24,
            width: 24,
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
                  TextStyle(fontSize: 14, color: HexColor("#75818F")),
                  suffixIcon: suffixIcon ?? const SizedBox.shrink()),
            ),
          ),
          isLoading! ? Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(navyBlue), strokeWidth: 2.0,),
              ),
            ),
          ) : IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: Icon(
              Icons.send,
              color: HexColor("#3F61DB"),
            ),
          ),
        ],
      ),
    );
  }
}