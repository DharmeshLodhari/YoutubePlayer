import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function onSubmit;
  final String hintText;

  SearchTextField(
      {@required this.textEditingController,
      @required this.onSubmit,
      @required this.hintText});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getSearchTextField();
  }

  Widget getSearchTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionHandleColor: navyBlue,
            ),
            child: TextFormField(
              controller: widget.textEditingController,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
              ),
              cursorWidth: 1.5,
              cursorColor: navyBlue,
              decoration: InputDecoration(
                hintText: widget.hintText,
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefix: Padding(
                  padding: EdgeInsets.only(left: 12),
                ),
                suffix: Padding(
                  padding: EdgeInsets.only(right: 36),
                ),
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
                widget.onSubmit();
              },
            ),
          ),
          Positioned(
            child: searchIcon(),
            right: 0,
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
      onPressed: widget.onSubmit,
    );
  }
}
