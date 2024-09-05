import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/src/widgets/quill/quill_controller.dart';
import 'package:flutter_quill/src/models/config/editor/editor_configurations.dart';
import 'package:flutter_quill/src/widgets/editor/editor.dart';
import 'package:flutter_quill/src/models/documents/document.dart';

import '../shopping_auth.dart';

// ignore: must_be_immutable
class EditService extends StatefulWidget {
  final dynamic arguments;

  const EditService({super.key, this.arguments});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final _auth = ShoppingAuthService();
  UserBloc? userBloc;
  final _formKey = GlobalKey<FormState>();

  String? serviceId;
  Service currentService = Service();

  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> serviceLocalImages = [];
  List<String?> serviceImagesFromServer = [];
  String? serviceName = "";
  String? serviceDescription = "";
  String? serviceCategory = "";
  String? serviceShortDescription = "";
  String? searchKeyword = "";
  String? servicePrice = "";
  ServiceCategory? selectedServiceCategory;
  bool? serviceIsAvailable = false;
  DateTime? serviceAvailableFrom = DateTime.now();

  //text editing controllers for the edit fields
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescriptionController = TextEditingController();
  TextEditingController serviceShortDescriptionController =
      TextEditingController();
  TextEditingController servicePriceController = TextEditingController();
  TextEditingController searchKeywordController = TextEditingController();
  List<ServiceCategory>? serviceCategories;
  bool isLoading = false;
  bool isAPILoading = false;

  bool isDiscountLoading = false;
  bool isDiscountAvailable = false;
  int? discountItemCount = 0;
  String? discountNext = "";
  String? discountPrevious = "";
  List<DiscountModel> discountList = [];
  List<DiscountModel> discountListCopy = [];
  bool noItemInList = false;
  DiscountModel? pressedDiscount;
  DiscountModel? selectedDiscount;
  String discountName = "";
  String? discountId;
  bool _isKeyboardVisible = false;
  bool _isServiceDescriptionVisible = false;
  double? bottomInset;
  dynamic serviceBodyTextJson;

  final FocusNode _focusNodeDescription = FocusNode();
  QuillController _quillController = QuillController.basic();
  final ScrollController _textEditorScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    serviceId = widget.arguments['serviceId'];
    getCategories();
    _focusNodeDescription.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateKeyboardVisibility();
    });
    super.initState();
  }

  void _handleFocusChange() {
    setState(() {
      _isServiceDescriptionVisible = _focusNodeDescription.hasFocus;
    });
    _updateKeyboardVisibility();
  }

  void _updateKeyboardVisibility() {
    bottomInset = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = (bottomInset ?? 0) > 0;
    });
  }

  void getDiscountList(String? discountId) async {
    if (!isDiscountLoading) {
      if (discountNext != null && !isDiscountLoading) {
        isDiscountLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfDiscounts(discountNext, discountPrevious);

        if (result == null) {
          isDiscountLoading = false;
          noItemInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        discountItemCount = result['count'];
        discountNext = result['next'];
        discountPrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isDiscountLoading = false;
            discountList.addAll(tempList);

            discountListCopy = discountList;

            if (discountId != null) {
              for (DiscountModel discount in discountList) {
                if (discount.id == discountId) {
                  selectedDiscount = discount;
                }
              }
            }
          });
        }
      }
      if (discountList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (discountNext == null && discountList.length > 6) {
        _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      serviceCategories = await ShoppingAuthService().getServiceCategories();
    } catch (e) {
      serviceCategories = [];
    }

    await fetchService();

    isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> fetchService() async {
    // assigning the dropdown
    serviceCategories?.forEach((catagory) {
      if (catagory.name == currentService.category) {
        selectedServiceCategory = catagory;
      }
    });

    //fetchProductFrom id to edit
    await _auth.getService(serviceId!).then((value) {
      currentService = value;
      // assigning to our edit controllers

      serviceTitleController.text = currentService.name!;

      try {
        serviceBodyTextJson = jsonDecode(
            messageDecoderWithEmoji(currentService.description) ?? "");

        _quillController = QuillController(
            document: Document.fromJson(serviceBodyTextJson),
            selection: const TextSelection.collapsed(offset: 0));
      } catch (e) {
        e.toString();
      }

      if (serviceBodyTextJson != null) {
        _quillController = QuillController(
            document: Document.fromJson(serviceBodyTextJson),
            selection: const TextSelection.collapsed(offset: 0));
      } else {
        final String plainTextDescription = currentService.description ?? "";

        if (plainTextDescription != null && plainTextDescription.isNotEmpty) {
          // Convert plain text into a Quill Document
          final doc = Document()..insert(0, plainTextDescription);

          _quillController = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        } else {
          // Handle the case where the description is empty or null
          _quillController = QuillController.basic();
        }
      }
      // serviceDescriptionController.text =
      //     messageDecoderWithEmoji(currentService.description) ?? "";
      servicePriceController.text =
          moneyNormalizer(int.parse(currentService.price!)).toString();
      serviceShortDescriptionController.text =
          messageDecoderWithEmoji(currentService.shortDescription) ?? "";

      serviceImagesFromServer.addAll(currentService.serverImages!);
      serviceName = currentService.name;
      serviceCategory = messageDecoderWithEmoji(currentService.category);
      servicePrice = moneyNormalizer(int.parse(currentService.price!));
      serviceDescription = currentService.description;
      serviceIsAvailable = currentService.isAvailable;
      serviceAvailableFrom = currentService.availableFrom;
      isDiscountAvailable = currentService.discountIsActive ?? false;
      discountId = currentService.discountId;
      serviceShortDescription = currentService.shortDescription;
      searchKeyword = messageDecoderWithEmoji(
              currentService.searchKeywords?.join(", ") ?? "") ??
          "";
      searchKeywordController.text = messageDecoderWithEmoji(
              currentService.searchKeywords?.join(", ") ?? "") ??
          "";

      getDiscountList(discountId);

      // assigning the dropdown from currentProduct
      serviceCategories?.forEach((catagory) {
        if (catagory.name == messageDecoderWithEmoji(currentService.category)) {
          selectedServiceCategory = catagory;
        }
      });
    }).catchError((error) {
      showToast(message: error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = (bottomInset ?? 0) > 0;
    return WillPopScope(
      onWillPop: () async {
        return await getExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar(context) as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        onPressed: () async {
          await getExitDialog(context);
        },
      ),
      title: Text(
        "Edit service",
        style: TextStyle(
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            if (serviceImagesFromServer.isNotEmpty)
                              checkImageLimitForServerImage()
                                  ? viewServerImages()
                                  : Container(),
                            if (checkImageLimitForServerImage())
                              const SizedBox(height: 8)
                            else
                              Container(),
                            if (checkImageLimitForLocalImage())
                              addLocalImages()
                            else
                              Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            addTitleField(),
                            const SizedBox(
                              height: 10,
                            ),
                            getAmountField(),
                            const SizedBox(height: 10),
                            getCategoryField(),
                            const SizedBox(height: 16),
                            getIsAvailableField(),
                            const SizedBox(height: 16),
                            if (serviceIsAvailable == true) ...[
                              getAvailableFromField(),
                              const SizedBox(height: 16),
                            ],
                            getDiscountField(),
                            const SizedBox(height: 16),
                            if (isDiscountAvailable == true) ...[
                              getDiscountListField(),
                              const SizedBox(height: 16),
                            ],
                            getServiceShortDescription(),
                            const SizedBox(height: 10),
                            getServiceDescription(),
                            const SizedBox(height: 10),
                            getSearchEngineKeyword(),
                            const SizedBox(height: 40),
                            getSubmitButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isKeyboardVisible &&
                  _isServiceDescriptionVisible &&
                  _focusNodeDescription.hasFocus)
                getEditor(_quillController)
              else
                const SizedBox.shrink()
            ],
          );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addLocalImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceLocalImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != serviceLocalImages.length
              ? showLocalImage(index)
              : serviceLocalImages.length + serviceImagesFromServer.length !=
                      imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
  }

  Widget viewServerImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceImagesFromServer.length,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: showServerImage(index),
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
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
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
                const SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 14,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
            onTap: () {
              pickImage();
            },
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
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
          final String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          serviceLocalImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showLocalImage(int index) {
    return Stack(
      children: <Widget>[
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: FileImage(
                    File(serviceLocalImages[index].path),
                  ),
                  fit: BoxFit.fill),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            padding: const EdgeInsets.only(right: 6, top: 6),
            alignment: Alignment.topRight,
            icon: Container(
              padding: const EdgeInsets.all(2.0),
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
              if (mounted) {
                setState(() {
                  serviceLocalImages.removeAt(index);
                });
              }
            },
          ),
        )
      ],
    );
  }

  Widget showServerImage(int index) {
    return Stack(
      children: <Widget>[
        CustomBoxShadow(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: boxShadowTwo,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(
                      serviceImagesFromServer[index]!,
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            padding: const EdgeInsets.only(right: 6, top: 6),
            alignment: Alignment.topRight,
            icon: Container(
              padding: const EdgeInsets.all(2.0),
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
              final imageId =
                  currentService.getImageId(serviceImagesFromServer[index]);
              _auth.deleteProductOrServiceImage(imageId).then((value) {
                if (value) {
                  if (mounted) {
                    setState(() {
                      serviceImagesFromServer.removeAt(index);
                    });
                  }
                }
              }).catchError((error) {
                debugPrint("ERROR$error");
              });
            },
          ),
        )
      ],
    );
  }

  // decide that serverImage List is need to be show or not
  bool checkImageLimitForServerImage() {
    if (serviceLocalImages.length + serviceImagesFromServer.length !=
            imageCount ||
        serviceImagesFromServer.isNotEmpty) {
      return true;
    }
    return false;
  }

  // decide that localImage List is need to be show or not
  bool checkImageLimitForLocalImage() {
    if (serviceLocalImages.length + serviceImagesFromServer.length !=
            imageCount ||
        serviceLocalImages.isNotEmpty) {
      return true;
    }
    return false;
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      controller: serviceTitleController,
      labelText: "Service name",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterServiceName;
      },
      onChanged: (val) {
        serviceName = val;
      },
    );
  }

  Widget getServiceShortDescription() {
    return CustomizedTextFormField(
      controller: serviceShortDescriptionController,
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onChanged: (val) {
        serviceShortDescription = val;
      },
    );
  }

  Widget getSearchEngineKeyword() {
    return Column(
      children: [
        CustomizedTextFormField(
          controller: searchKeywordController,
          labelText: "Search Keyword - SEO (Optional)",
          onChanged: (val) {
            searchKeyword = val;
          },
        ),
        Text(
          'These words will help customer see your service online when they search it.',
          style: TextStyle(
            color: darkGrey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        )
      ],
    );
  }

  // Widget getServiceDescription() {
  //   return CustomizedTextFormField(
  //     maxLines: 5,
  //     labelText: AppLocalization.of(context)!.description,
  //     controller: serviceDescriptionController,
  //     textCapitalization: TextCapitalization.sentences,
  //     onChanged: (val) {
  //       serviceDescription = val;
  //     },
  //   );
  // }
  Widget getServiceDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductDescriptionText(),
        const SizedBox(height: 5),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
                color: _focusNodeDescription.hasFocus
                    ? navyBlue
                    : greyBorderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 150,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: _focusNodeDescription.hasFocus ? null : navyBlue,
                ),
              ),
              child: QuillEditor(
                focusNode: _focusNodeDescription,
                scrollController: _textEditorScrollController,
                configurations: QuillEditorConfigurations(
                  autoFocus: false,
                  controller: _quillController,
                  scrollable: true,
                  expands: false,
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  placeholder: "",
                  scrollBottomInset: 20,
                  showCursor:
                      _isKeyboardVisible || _isServiceDescriptionVisible,
                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescriptionText() {
    return Text(
      AppLocalization.of(context)!.description,
      style: TextStyle(
        color: darkGrey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.category,
      child: ListTile(
        dense: true,
        title: Text(
          selectedServiceCategory != null ? selectedServiceCategory!.name : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectItemCategory();
        },
      ),
    );
  }

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ServiceCategory>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: serviceCategories?.map<Widget>((category) {
                              if (selectedServiceCategory == category) {
                                return Container(
                                  color: selectedListItemBackgroundBlue,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      category.name,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w600),
                                    ),
                                    trailing: Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, category);
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  category.name,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w400),
                                ),
                                dense: true,
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedServiceCategory = pressedCategory;
      serviceCategory = selectedServiceCategory!.name;
      setState(() {});
    }
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      controller: servicePriceController,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      labelText: "Price of service",
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            servicePrice = double.parse(val.replaceAll(',', '')).toString();
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getSubmitButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: CurvedButton(
              textColor: Colors.white,
              text: AppLocalization.of(context)!.delete,
              backgroundColor: mateRed,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                deleteServiceDialog();
              }),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: CurvedButton(
            textColor: Colors.white,
            text: AppLocalization.of(context)!.update,
            backgroundColor: navyBlue,
            onPressed: isAPILoading
                ? () {}
                : () async {
                    FocusScope.of(context).unfocus();
                    isAPILoading = true;
                    if (mounted) setState(() {});

                    await editService();

                    isAPILoading = false;
                    if (mounted) setState(() {});
                  },
            isLoading: isAPILoading,
          ),
        ),
      ],
    );
  }

  void deleteServiceDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Service',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this service?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () {
        deleteService();
      },
    );
  }

  Future<void> editService() async {
    if (_formKey.currentState!.validate()) {
      if (serviceLocalImages.length >= 0) {
        if (validateDropdown()) {
          // setting updated value
          currentService.name = serviceName;
          currentService.description = serviceDescription;
          currentService.localImages =
              serviceLocalImages.map((file) => File(file.path)).toList();
          currentService.serverImages = serviceImagesFromServer;
          currentService.category = messageDecoderWithEmoji(serviceCategory);
          currentService.shortDescription = serviceShortDescription;
          currentService.price = moneyInputNormalizer(servicePrice!).toString();
          currentService.isAvailable = serviceIsAvailable;
          currentService.availableFrom = serviceAvailableFrom;
          if (isDiscountAvailable) {
            currentService.discountId = selectedDiscount?.id;
          } else {
            currentService.discountId = "";
          }
          currentService.searchKeywords = searchKeyword?.split(", ");

          await _auth.editService(currentService).then((value) {
            showToast(
              message: AppLocalization.of(context)!.serviceEditedSuccessfully,
            );
            Navigator.pop(context, "update_item");
          }).catchError((error) {
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  bool validateDropdown() {
    if (selectedServiceCategory != null) {
      return true;
    } else {
      showToast(message: AppLocalization.of(context)!.selectCategory);
      return false;
    }
  }

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        serviceIsAvailable = !serviceIsAvailable!;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: serviceIsAvailable,
      title: "Available",
    );
  }

  void removeQuillFocus() {
    _focusNodeDescription.unfocus();
  }

  Widget getDiscountField() {
    return CustomizedCheckBoxField(
      onTap: () {
        isDiscountAvailable = !isDiscountAvailable;
        setState(() {});
      },
      isChecked: isDiscountAvailable,
      title: AppLocalization.of(context)!.discount,
    );
  }

  Widget getDiscountListField() {
    return CustomizedDropDownField(
      title: 'Discount',
      fontSize: 12,
      titleColor: blackFont,
      fontWeight: FontWeight.w400,
      child: ListTile(
        dense: true,
        title: Text(
          selectedDiscount != null
              ? messageDecoderWithEmoji(selectedDiscount?.name) ??
                  selectedDiscount?.merchant ??
                  ""
              : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          discountAndroidSheet();
          removeQuillFocus();
        },
      ),
    );
  }

  void discountAndroidSheet() {
    discountList = discountListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search discount',
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      discountList = discountListCopy
                          .where((element) =>
                              (messageDecoderWithEmoji(element.name) ??
                                      element.merchant ??
                                      "")
                                  .toLowerCase()
                                  .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      discountList = discountListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: discountList.length,
                    itemBuilder: (context, index) {
                      final DiscountModel discount = discountList[index];
                      if (selectedDiscount == discount) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              messageDecoderWithEmoji(discount.name) ??
                                  discount.merchant ??
                                  "",
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  color: navyBlue,
                                  fontSize: 16,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(
                              SlydoAppIcon.checked,
                              color: navyBlue,
                              size: 12,
                            ),
                            onTap: () {
                              pressedDiscount = discount;
                              Navigator.pop(context);
                              if (pressedDiscount != null) {
                                selectedDiscount = pressedDiscount;
                                discountName = messageDecoderWithEmoji(
                                        selectedDiscount?.name) ??
                                    selectedDiscount?.merchant ??
                                    "";
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          messageDecoderWithEmoji(discount.name) ??
                              discount.merchant ??
                              "",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          pressedDiscount = discount;
                          Navigator.pop(context);
                          if (pressedDiscount != null) {
                            selectedDiscount = pressedDiscount;
                            discountName = messageDecoderWithEmoji(
                                    selectedDiscount?.name) ??
                                selectedDiscount?.merchant ??
                                "";
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

  Widget getAvailableFromField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          context: context,
          builder: customThemeBuilder,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          if (mounted) {
            setState(() {
              serviceAvailableFrom =
                  DateTime(value!.year, value.month, value.day);
            });
          }
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: ListTile(
          dense: true,
          title: Text(
            formatDate(serviceAvailableFrom!),
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: "Inter",
            ),
            maxLines: 1,
          ),
          trailing: Icon(
            SlydoAppIcon.date,
            size: 16,
            color: darkGrey,
          ),
        ),
      ),
    );
  }

  void deleteService() async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => const ConfirmDelete(),
    );

    if (result != null && result) {
      await _auth.deleteService(currentService.id!).then((value) {
        Navigator.pop(context, "delete_item");
        showToast(
            message: AppLocalization.of(context)!.serviceDeletedSuccessfully);
      }).catchError((error) {
        showToast(message: error.toString());
      });
    }
  }

  dynamic getExitDialog(BuildContext context) async {
    await showExitDialogBackButton(
      context: context,
      leftButtonOnPressed: () {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        FocusScope.of(context).unfocus();
        await editService();
      },
    );
  }

  @override
  void dispose() {
    serviceTitleController.dispose();
    serviceDescriptionController.dispose();
    serviceShortDescriptionController.dispose();
    servicePriceController.dispose();
    _scrollController.dispose();
    searchKeywordController.dispose();
    _quillController.dispose();
    _focusNodeDescription.dispose();
    super.dispose();
  }
}
