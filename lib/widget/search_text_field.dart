import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final Function onSubmit;
  final String hintText;
  TextStyle? textStyle;
  TextStyle? hintStyle;
  bool isDisabled;

  SearchTextField(
      {super.key,
      required this.textEditingController,
      required this.onSubmit,
      required this.hintText,
      this.textStyle,
      this.hintStyle,
      this.isDisabled = false});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return getSearchTextField();
  }

  Widget getSearchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: navyBlue,
              ),
            ),
            child: TextFormField(
              controller: widget.textEditingController,
              style: widget.textStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                  ),
              cursorWidth: 1.5,
              cursorColor: navyBlue,
              enabled: !widget.isDisabled,
              decoration: InputDecoration(
                  hintText: widget.hintText,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 36),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: dividerColor,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
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
                  hintStyle: widget.hintStyle),
              onFieldSubmitted: (val) {
                widget.onSubmit();
              },
            ),
          ),
          Positioned(
            right: 0,
            child: searchIcon(),
          )
        ],
      ),
    );
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: widget.onSubmit as void Function()?,
    );
  }
}
