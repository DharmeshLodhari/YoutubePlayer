import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/screens/more_apps/ask/ask_auth.dart';
import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/ask/models/ask_categories_model.dart';
import 'package:Slydo/screens/more_apps/ask/utils/utils.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/ask_mention_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../utils/util.dart';
import '../../../widget/CustomBoxShadow.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_dropdown_field.dart';
import '../../../widget/customized_textform_field.dart';
import '../../../widget/image_crop.dart';
import '../../moments/screens/trimmer_view.dart';
import '../messaging/chat/utils.dart';
import 'ask_viewmodel.dart';

class AddTopicScreen extends StatefulWidget {
  List<AskCategories>? askCategories;
  AskCategories? askCategory;
  bool? isYarn = false;
  AddTopicScreen({this.askCategories, this.isYarn, this.askCategory});

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final yarnController = TextEditingController();

  final textController = TextEditingController();
  late FocusNode textFieldTagFocusNode;
  ScrollController _scrollController = ScrollController();
  List<PickedFile> selectedImages = [];
  List<AddMediaForYarn> selectedMedia = [];
  List<Map<String, dynamic>> selectedImagesList = [];
  int imageCount = 5;
  AskCategories? selectedAskCategory;
  AskCategories? pressedAskCategory;
  List<AskCategories>? askCategoriesCopy;
  String askCategory = "";
  List<String> userTags = [];
  late UserBloc userBloc;
  bool enableCommenting = true;
  bool enablePayme = false;
  String? videoPath;
  String? imagePath;
  bool isVideoLoading = false;
  VideoPlayerController? videoPlayerController;
  String? generatedVideoThumbnail;
  bool isAPILoading = false;
  bool isMentionName = false;
  String? searchString;

  @override
  void initState() {
    Future.microtask(() => context.read<AskViewModel>().init());
    textFieldTagFocusNode = FocusNode();
    askCategoriesCopy = widget.askCategories;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<AskViewModel>(builder: (context, model, child) {
        return ListView(
          padding: EdgeInsets.all(15),
          children: [_buildYarnOrQuestionForm(model)],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        widget.isYarn! ? "Create Yarn" : "Ask Question",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate_rounded,
            color: HexColor("#000000"),
            size: 26,
          ),
          onPressed: () {
            if (selectedImages.length == 4) {
              showToast(message: "You can select only 4 images or videos");
            } else {
              pickFileFromMedia();
              // pickImage();
            }
          },
        ),
      ],
    );
  }

  Widget _buildYarnOrQuestionForm(AskViewModel model) {
    if (widget.isYarn!) {
      return _buildYarnForm(model);
    }
    return _buildQuestionForm(model);
  }

  Widget _buildYarnForm(AskViewModel model) {
    return Column(
      children: [
        if (selectedImages.isNotEmpty) ...[
          _buildAddImages(),
          SizedBox(
            height: 20,
          ),
        ],
        _buildTextFiled(),
        if (isMentionName) ...[
          _buildUserNameContainer(),
        ],
        getCategoryField(),
        SizedBox(
          height: 20,
        ),
        _buildSwitchOptions(),
        SizedBox(
          height: 50,
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildQuestionForm(AskViewModel model) {
    return Column(
      children: [
        if (selectedImages.isNotEmpty) ...[
          _buildAddImages(),
          SizedBox(
            height: 20,
          ),
        ],
        _buildYarnField(),
        SizedBox(
          height: 20,
        ),
        _buildTextFiled(),
        SizedBox(
          height: 20,
        ),
        if (isMentionName) ...[
          _buildUserNameContainer(),
          SizedBox(
            height: 20,
          ),
        ],
        getCategoryField(),
        SizedBox(
          height: 20,
        ),
        _buildSwitchOptions(),
        SizedBox(
          height: 50,
        ),
        _buildSubmitButton(),
      ],
    );
  }

  // Widget _buildAddImages() {
  //   return Container(
  //     height: 100,
  //     child: ListView.builder(
  //       controller: _scrollController,
  //       scrollDirection: Axis.horizontal,
  //       itemCount: selectedImages.length + 1,
  //       itemBuilder: (context, index) => Container(
  //         padding: EdgeInsets.only(right: 6),
  //         child: index != selectedImages.length
  //             ? showImage(index)
  //             : selectedImages.length != imageCount
  //             ? addImageButton()
  //             : null,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAddImages() {
    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: selectedImagesList.length + 1,
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.only(right: 6),
          child: index != selectedImagesList.length
              ? showImage(index)
              : selectedImagesList.length != imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
  }

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  SlydoAppIcon.add_image,
                  color: darkGrey,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: darkGrey, fontSize: 14),
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

  // Widget showImage(int index) {
  //   return Container(
  //     height: 100,
  //     child: Stack(
  //       children: <Widget>[
  //         Card(
  //           elevation: 2,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           shadowColor: dividerColor,
  //           margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
  //           child: Container(
  //             width: 100,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //               image: DecorationImage(
  //                   image: FileImage(
  //                     File(selectedImages[index].path),
  //                   ),
  //                   fit: BoxFit.fill),
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           right: 0,
  //           top: 0,
  //           child: IconButton(
  //             padding: EdgeInsets.only(right: 6, top: 6),
  //             alignment: Alignment.topRight,
  //             icon: Container(
  //               padding: EdgeInsets.all(2.0),
  //               decoration: BoxDecoration(
  //                 color: iconBtnGrey,
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               child: Icon(
  //                 SlydoAppIcon.remove,
  //                 color: blackFont,
  //                 size: 15,
  //               ),
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 selectedImagesList.removeAt(index);
  //                 selectedImages.removeAt(index);
  //               });
  //             },
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget showImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: selectedImagesList[index]['mediaType'] == 'image'
                    ? DecorationImage(
                        image: FileImage(
                          File(selectedImagesList[index]['file'].path),
                        ),
                        fit: BoxFit.fill)
                    : DecorationImage(
                        image: MemoryImage(
                          selectedImagesList[index]['file'],
                        ),
                        fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: iconBtnGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  SlydoAppIcon.remove,
                  color: blackFont,
                  size: 15,
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedImagesList.removeAt(index);
                  selectedImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildYarnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isYarn! ? 'Yarn' : 'Question',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
        ),
        SizedBox(
          height: 7,
        ),
        TopicTextField(
          height: 50,
          controller: yarnController,
          hint: 'Ask Something',
        ),
      ],
    );
  }

  Widget _buildTextFiled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isYarn! ? "Yarn" : 'Text',
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
        ),
        SizedBox(
          height: 7,
        ),
        TopicTextField(
          height: 140,
          controller: textController,
          hint: widget.isYarn! ? "Yarn Something" : "",
          onChanged: onValueChange,
        ),
      ],
    );
  }

  void onValueChange(String value) {
    List<String> listOfWords = value.split(" ");

    if (listOfWords.isNotEmpty) {
      if ((listOfWords.last.contains("@") &&
          !value.endsWith(" ") &&
          !value.endsWith("@"))) {
        isMentionName = true;
        List<String> mentionString = getAllMentions(value);

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
    print("SERACHED STRING  ${searchString}");
    return AskMentionView(
      searchText: searchString,
      key: UniqueKey(),
      onTap: (String? tappedUser) {
        if (tappedUser != null) {
          textController.text = textController.text.replaceRange(
            (textController.text.length - (searchString?.length ?? 0)),
            textController.text.length,
            tappedUser,
          );
          textController.selection = TextSelection.fromPosition(TextPosition(
            offset: textController.text.length,
          ));
          searchString = "";
          if (mounted) setState(() {});
        }
      },
    );
  }

  // Widget _buildTags(AskViewModel model) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Tags',
  //         style: TextStyle(
  //           fontSize: 14,
  //           color: darkGrey,
  //         ),
  //       ),
  //       SizedBox(height: 7,),
  //       Focus(
  //         focusNode: textFieldTagFocusNode,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(11),
  //             border: Border.all(
  //               color: blackFont.withOpacity(0.1),
  //               width: 2,
  //             ),
  //           ),
  //           child: TextFieldTags(
  //             initialTags: userTags,
  //             tagsStyler: textFieldTagStyler,
  //             validator: (value) {
  //               return null;
  //             },
  //             textFieldStyler: TextFieldStyler(
  //               helperText: '',
  //               hintText: '',
  //               textFieldBorder: InputBorder.none,
  //             ),
  //             onTag: (tag) {
  //               setState(() {
  //                 model.userTags.add(tag);
  //                 model.userTags = model.userTags.toSet().toList();
  //                 userTags = model.userTags;
  //               });
  //               model.userTags.removeWhere((tag) => tag.isEmpty);
  //               userTags.removeWhere((tag) => tag.isEmpty);
  //             },
  //             onDelete: (tag) {
  //               setState(() {
  //                 model.userTags.remove(tag);
  //                 userTags.remove(tag);
  //               });
  //               model.userTags.removeWhere((tag) => tag.isEmpty);
  //               userTags.removeWhere((tag) => tag.isEmpty);
  //             },
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget getCategoryField() {
    if (widget.askCategory != null) {
      selectedAskCategory = widget.askCategory;
      pressedAskCategory = widget.askCategory;
    }
    return Column(
      children: [
        SizedBox(
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
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
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

  // Widget getAmountField() {
  //   return CustomizedTextFormField(
  //     labelText: "Amount",
  //     keyboardType: Platform.isIOS
  //         ? TextInputType.numberWithOptions(decimal: true)
  //         : TextInputType.number,
  //     isAmountField: true,
  //     borderWidth: 2.0,
  //     onChanged: (val) {
  //       if (val.isNotEmpty) {
  //         try {
  //           // productPrice = double.parse(val.replaceAll(',', '')).toString();
  //         } catch (e) {
  //           showToast(message: e.toString());
  //         }
  //       }
  //     },
  //     validator: (val) {
  //       // if (val.isNotEmpty) {
  //       //   try {
  //       //     double.parse(val.replaceAll(',', ''));
  //       //     return null;
  //       //   } catch (e) {
  //       //     return AppLocalization.of(context)!.invalidAmount;
  //       //   }
  //       // }
  //       // return AppLocalization.of(context)!.pleaseEnterValidAmout;
  //     },
  //   );
  // }
  //
  // Widget _buildExpiresField() {
  //   return CustomizedDropDownField(
  //     title: "Expire",
  //     borderWidth: 2.0,
  //     child: ListTile(
  //       dense: true,
  //       title: Text(
  //         selectedAskCategory != null ? selectedAskCategory!.name! : "",
  //         style: TextStyle(
  //             color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //       trailing: Icon(
  //         Icons.keyboard_arrow_down,
  //         color: darkGrey,
  //       ),
  //       onTap: () {
  //         expiresAndroidSheet();
  //       },
  //     ),
  //   );
  // }

  Widget _buildSwitchOptions() {
    return Column(
      children: [
        _buildPreviewYarnSwitchOption(
          title: "Enable Commenting",
          description: 'Enable this to allow others comment on your post',
          switchBtn: Switch(
            value: enableCommenting,
            onChanged: (value) {
              setState(() {
                enableCommenting = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _buildPreviewYarnSwitchOption(
          title: "Enable Payment",
          description:
              "Enable this to allow other users to support your work by making a donation.",
          switchBtn: Switch(
            value: enablePayme,
            onChanged: (value) {
              setState(() {
                enablePayme = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewYarnSwitchOption({
    required String title,
    required String description,
    required Switch switchBtn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            SizedBox(height: 30, child: switchBtn),
          ],
        ),
        Text(
          description,
          style: TextStyle(
            color: blackFont.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 60),
      child: CurvedButton(
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Submit",
        isLoading: isAPILoading,
        onPressed: isAPILoading
            ? () {}
            : () async {
                isAPILoading = true;
                if (mounted) setState(() {});
                await addYarnAndQuestion();
                isAPILoading = false;
                if (mounted) setState(() {});
              },
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalization.of(context)!.selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.gallery),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().pickImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          selectedImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
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
        if (mounted) setState(() {});
      }
    }
    debugPrint("SELECTED IMAGES:- $selectedImages");
  }

  void setUpVideoPlayer() async {
    isVideoLoading = true;
    if (mounted) setState(() {});

    // videoPlayerController = VideoPlayerController.file(File(widget.filePath))
    //   ..initialize().then((_) => videoPlayerController?.play())
    //   ..setLooping(false);

    videoPlayerController = VideoPlayerController.file(
      File(videoPath!),
    );

    await videoPlayerController?.initialize();
    await videoPlayerController?.setLooping(false);

    await videoPlayerController?.play();

    // debugPrint("path=> ${File(widget.filePath)}");
    // videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    // await videoPlayerController!.initialize();

    // _chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController!,
    //   aspectRatio: videoPlayerController?.value.aspectRatio,
    //   allowedScreenSleep: false,
    //   autoPlay: false,
    //   allowFullScreen: false,
    //   systemOverlaysAfterFullScreen: SystemUiOverlay.values,
    //   // showControls: false,
    //   materialProgressColors: ChewieProgressColors(
    //     playedColor: navyBlue,
    //     handleColor: Colors.white,
    //     backgroundColor: dividerColor,
    //     bufferedColor: Colors.white30,
    //   ),
    //   autoInitialize: true,
    // );

    isVideoLoading = false;
    if (mounted) setState(() {});
  }

  void categoryAndroidSheet() {
    widget.askCategories = askCategoriesCopy;
    debugPrint("CATEGORIES:- ${widget.askCategories}");
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
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.askCategories!.length,
                    itemBuilder: (context, index) {
                      AskCategories category = widget.askCategories![index];
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
    AddYarnAndQuestion addYarnAndQuestion = AddYarnAndQuestion();
    addYarnAndQuestion.localImages = selectedMedia;
    addYarnAndQuestion.tags = userTags;
    addYarnAndQuestion.title =
        widget.isYarn! ? textController.text : yarnController.text;
    addYarnAndQuestion.body = textController.text;
    addYarnAndQuestion.categoryId = selectedAskCategory!.id;
    addYarnAndQuestion.isQuestion = !widget.isYarn! ? true : false;
    addYarnAndQuestion.author = userBloc.user.userName;
    addYarnAndQuestion.enablePayme = enablePayme;
    addYarnAndQuestion.enableCommenting = enableCommenting;

    await AskAuth().addYarnAndQuestion(addYarnAndQuestion).then((value) {
      if (widget.isYarn!) {
        Navigator.pop(context, Types.Yarn);
      } else if (!widget.isYarn!) {
        Navigator.pop(context, Types.Question);
      }
      showToast(
          message: widget.isYarn!
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
    Key? key,
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
  }) : super(key: key);

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
