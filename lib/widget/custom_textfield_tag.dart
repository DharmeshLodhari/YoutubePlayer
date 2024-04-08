import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

// ignore: must_be_immutable
class CustomTextFieldTag extends StatefulWidget {
  final List<String>? initialTags;
  final TextfieldTagsController? textfieldTagsController;
  final Function(String) onTap;

  CustomTextFieldTag({
    Key? key,
    this.initialTags,
    required this.textfieldTagsController,
    required this.onTap,
  }) : super(key: key);

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
      // initialTags: (userTags).map((e) => jsonEncode(e.toJson())).toList(),
      initialTags: widget.initialTags,
      textfieldTagsController: widget.textfieldTagsController,
      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
        return ((context, sc, tags, onTagDelete) {
          return TextField(
            readOnly: true,
            controller: tec,
            focusNode: fn,
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
              errorText: error,
              prefixIcon: tags.isNotEmpty
                  ? SingleChildScrollView(
                      controller: sc,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: tags.map((String tag) {
                        // Map<String, dynamic> tagData = jsonDecode(tag);
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            border: Border.all(color: darkGrey, width: 1.0),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Text(
                                  '$tag',
                                  // tagData['name'],
                                  style: TextStyle(color: blackFont),
                                ),
                                onTap: () {
                                  debugPrint("$tag selected");
                                },
                              ),
                              const SizedBox(width: 4.0),
                              InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 14.0,
                                  color: darkGrey,
                                ),
                                onTap: () {
                                  onTagDelete(tag);
                                  widget.onTap(tag);
                                },
                              )
                            ],
                          ),
                        );
                      }).toList()),
                    )
                  : null,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          );
        });
      },
    );
  }
}
