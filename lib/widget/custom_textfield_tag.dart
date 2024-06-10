import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

// ignore: must_be_immutable
class CustomTextFieldTag extends StatefulWidget {
  final List<String>? initialTags;
  final bool readOnly;
  final TextfieldTagsController textFieldTagsController;
  final Function(String) onTap;

  CustomTextFieldTag({
    super.key,
    this.initialTags,
    this.readOnly = true,
    required this.textFieldTagsController,
    required this.onTap,
  });

  @override
  _CustomTextFieldTagState createState() => _CustomTextFieldTagState();
}

class _CustomTextFieldTagState extends State<CustomTextFieldTag> {
  @override
  Widget build(BuildContext context) {
    return TextFieldTags(
        validator: (value) {
          return null;
        },
        initialTags: widget.initialTags,
        textfieldTagsController: widget.textFieldTagsController,
        inputFieldBuilder: (context, inputFieldValues) {
          return TextField(
            readOnly: widget.readOnly,
            controller: inputFieldValues.textEditingController,
            focusNode: inputFieldValues.focusNode,
            decoration: InputDecoration(
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: greyBorderColor,
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
              helperText: '',
              hintText: '',
              errorText: '',
              prefixIcon: inputFieldValues.tags.isNotEmpty
                  ? SingleChildScrollView(
                      // controller: sc,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: _buildCustomTags(inputFieldValues.tags)),
                    )
                  : null,
            ),
            // onChanged: onChanged,
            // onSubmitted: onSubmitted,
          );
        });
  }

  List<Widget> _buildCustomTags(List<dynamic> tags) {
    return tags.map((dynamic tag) {
      final String tagName = tag.toString(); // Ensure tag is a string
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
          border: Border.all(color: Colors.grey, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 3.0),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              child: Text(
                tagName,
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                debugPrint("$tagName selected");
              },
            ),
            const SizedBox(width: 4.0),
            InkWell(
              child: const Icon(
                Icons.cancel,
                size: 14.0,
                color: Colors.grey,
              ),
              onTap: () {
                widget.onTap(tagName);
              },
            ),
          ],
        ),
      );
    }).toList();
  }
}
