import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTags extends StatefulWidget {
  AddTags({
    super.key,
    this.arguments,
  });

  var arguments;

  @override
  State<AddTags> createState() => _AddTagsState();
}

class _AddTagsState extends State<AddTags> {
  UserBloc? userBloc;
  bool isLoading = false;
  List<Tags> tagList = [];
  List<Tags>? tagListCopy;

  @override
  void initState() {
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

        await getProductTags(userBloc.userAbout!.industry!.id!);

        if (widget.arguments["tagList"] != null)
          for (Tags tags in tagList) {
            if (widget.arguments["tagList"].any((e) => e.id == tags.id)) {
              tags.isSelected = true;
            }
          }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar() as PreferredSizeWidget?,
        body: _buildBody(),
        floatingActionButton: _buildDoneBtn(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Tags",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget _buildBody() {
  //   return Container(
  //     width: double.infinity,
  //     height: 200,
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(width: 1, color: greyBorderColor),
  //         borderRadius: BorderRadius.circular(5)),
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: tagList.length,
  //       itemBuilder: (context, index) {
  //         return ListTile(
  //           title: Text(
  //             tagList[index].name,
  //             softWrap: false,
  //             overflow: TextOverflow.fade,
  //             style: TextStyle(
  //                 color: blackFont, fontSize: 16, fontWeight: FontWeight.w400),
  //           ),
  //           trailing: CustomizedCheckBoxField(
  //             onTap: () {
  //               // productIsAvailable = !productIsAvailable;
  //               setState(() {});
  //             },
  //             isChecked: false,
  //             title: "Is product available now?",
  //           ),
  //           dense: true,
  //           onTap: () {
  //             // String text = tagList[index]
  //             //     .name
  //             //     .replaceFirst(" ", "-");
  //             // setState(() {
  //             //   myController.text = text + " ";
  //             //
  //             //   myController.selection =
  //             //       TextSelection.collapsed(
  //             //           offset: text.length);
  //             //   userTags.add({
  //             //     "id": tagList[index].id!,
  //             //     "name": tagList[index].name
  //             //   });
  //             //   userTags = userTags.toSet().toList();
  //             // });
  //             // FocusScope.of(context).requestFocus();
  //             //
  //             // // print(userTags);print("______________");
  //             // userTags.removeWhere((tag) => tag.isEmpty);
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search tags',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      tagList = tagListCopy!
                          .where((element) => element.name!
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      if (mounted) setState(() {});
                    } else {
                      tagList = tagListCopy ?? [];
                      if (mounted) setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tagList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: selectedListItemBackgroundBlue),
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          shadowColor: boxShadowTwo,
                          color: white,
                          child: Container(
                            decoration: decorateBox(),
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: _buildTagList(index),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
  }

  Future<void> getProductTags(id) async {
    if (mounted) setState(() {});
    try {
      List<Tags> result = await ShoppingAuthService().getProductTags(id);
      tagList = result;
      tagListCopy = tagList;
    } catch (e) {
      tagList = [];
      tagListCopy = [];
    }
    isLoading = false;
    if (mounted) setState(() {});
  }

  Widget _buildTagList(int index) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(
        tagList[index].name ?? "",
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: blackFont,
          fontFamily: "Inter",
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      activeColor: navyBlue,
      checkColor: Colors.white,
      value: tagList[index].isSelected,
      onChanged: (bool? value) {
        tagList[index].isSelected = value!;
        setState(() {});
      },
    );
  }

  Widget _buildDoneBtn() {
    return tagList.any((tag) => tag.isSelected)
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CurvedButton(
              onPressed: tagList.isNotEmpty
                  ? () {
                      Navigator.pop(context, tagList);
                    }
                  : null,
              backgroundColor: navyBlue,
              textColor: white,
              text: 'Done',
            ),
          )
        : Container();
  }
}
