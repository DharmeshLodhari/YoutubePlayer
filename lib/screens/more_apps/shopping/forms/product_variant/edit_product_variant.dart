import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../widget/rounded_background_icon.dart';
import '../../shopping_auth.dart';

class EditProductVariant extends StatefulWidget {
  final dynamic arguments;

  const EditProductVariant({this.arguments, super.key});

  @override
  State<EditProductVariant> createState() => _EditProductVariantState();
}

class _EditProductVariantState extends State<EditProductVariant> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;
  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  TextEditingController inventoryController = TextEditingController();
  List<PickedFile> productLocalImages = [];
  List<String?> productImagesFromServer = [];
  List<String> croppedImageList = [];
  String size = "";
  String variantPrice = "";
  String comparePrice = "";
  String color = "";
  bool productIsAvailable = false;
  bool inventoryIsAvailable = false;
  bool trackInventory = false;
  DateTime todayDate = DateTime.now();
  String? productAvailableFrom;
  bool isLoading = false;
  bool isAPILoading = false;
  int inventoryCount = 1;

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
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  List<VariantTypes> typeList = [
    VariantTypes.Size,
    VariantTypes.Color,
    VariantTypes.ColorAndSize
  ];
  VariantTypes? selectedType;
  String title = "";
  String value = "";
  String id = "";
  Variant? variant;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController comparePriceController = TextEditingController();
  final TextEditingController availableFromController = TextEditingController();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    variant = widget.arguments["variant"];

    // debugPrint('Fola varaint::: ${variant!.toJson()}');

    id = variant!.id.toString();
    selectedType = variant?.type;
    titleController.text = variant!.title.toString();
    sizeController.text = variant!.value.toString();
    colorController.text = variant!.colour.toString();
    priceController.text =
        moneyNormalizer(int.parse(variant!.price ?? "0")).toString();
    availableFromController.text = variant!.availableFrom.toString();
    productIsAvailable = variant!.isAvailable ?? false;
    isDiscountAvailable = variant!.discountIsActive ?? false;
    inventoryIsAvailable = variant!.trackInventory ?? false;
    inventoryCount = variant!.quantity ?? 1;
    inventoryController.text = variant!.quantity.toString();
    if (variant != null && variant!.availableFrom != null) {
      productAvailableFrom = DateFormat('dd/MM/yyyy')
          .format(DateFormat('yyyy-MM-dd').parse(variant!.availableFrom!));
    } else {
      productAvailableFrom = DateFormat('dd/MM/yyyy').format(todayDate);
    }
    productImagesFromServer.addAll(variant!.serverImages!);

    discountId = variant!.discountId.toString();
    title = variant!.title.toString();
    size = variant!.value.toString();
    color = variant!.colour.toString();
    variantPrice = moneyNormalizer(int.parse(variant!.price ?? "0")).toString();
    // productIsAvailable = variant!.isAvailable!;
    // inventoryIsAvailable = variant!.trackInventory!;
    // inventoryCount = variant!.quantity!;

    getDiscountList(discountId);

    super.initState();
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
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
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)?.updateVariant ?? "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (productImagesFromServer.isNotEmpty)
                        checkImageLimitForServerImage()
                            ? viewServerImages()
                            : Container(),

                      const SizedBox(height: 10),
                      if (checkImageLimitForLocalImage())
                        addLocalImages()
                      else
                        Container(),
                      // addImages(),

                      const SizedBox(height: 10),
                      addTitleField(),
                      const SizedBox(height: 10),
                      getTypeField(),

                      if (selectedType == VariantTypes.Size) ...[
                        const SizedBox(height: 10),
                        addSizeField(),
                      ],
                      if (selectedType == VariantTypes.Color) ...[
                        const SizedBox(height: 10),
                        getColorField(),
                      ],
                      if (selectedType == VariantTypes.ColorAndSize) ...[
                        const SizedBox(height: 10),
                        getColorField(),
                        const SizedBox(height: 10),
                        addSizeField(),
                      ],

                      const SizedBox(
                        height: 10,
                      ),
                      getAmountField(),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // getComparePriceField(),
                      const SizedBox(height: 16),
                      getDiscountField(),
                      const SizedBox(height: 16),
                      if (isDiscountAvailable == true) ...[
                        getDiscountListField(),
                        const SizedBox(height: 16),
                      ],
                      getIsAvailableField(),
                      const SizedBox(height: 16),
                      if (productIsAvailable == true) ...[
                        getAvailableFromField(),
                        const SizedBox(height: 16),
                      ],
                      getInventoryFormField(),
                      const SizedBox(height: 16),
                      getIsInventoryAvailableField(),

                      const SizedBox(height: 30),
                      getSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
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

  String getDiscountDisplayName(DiscountModel? discount) {
    String name = '';
    if (discount?.type?.toValue() == "percentage") {
      name = '${discount?.name} (${discount?.value}%)';
    } else {
      name =
          '${discount?.name} (${worldCurrencies[userBloc?.user.currency]}${discount?.value})';
    }
    return name;
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
              ? messageDecoderWithEmoji(
                      getDiscountDisplayName(selectedDiscount)) ??
                  selectedDiscount?.merchant ??
                  ""
              : "",
          style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          discountAndroidSheet();
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
                              messageDecoderWithEmoji(
                                      getDiscountDisplayName(discount)) ??
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
                          messageDecoderWithEmoji(
                                  getDiscountDisplayName(discount)) ??
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

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  // Widget addImages() {
  //   return Container(
  //     height: 100,
  //     child: ListView.builder(
  //       controller: _scrollController,
  //       scrollDirection: Axis.horizontal,
  //       itemCount: croppedImageList.length + 1,
  //       itemBuilder: (context, index) => Container(
  //         padding: const EdgeInsets.only(right: 6),
  //         child: index != croppedImageList.length
  //             ? showImage(index)
  //             : croppedImageList.length != imageCount
  //             ? addImageButton()
  //             : null,
  //       ),
  //     ),
  //   );
  // }

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
                  SlydoAppIcon.addImage,
                  color: darkGrey,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: darkGrey, fontSize: 14),
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

          croppedImageList.add(croppedImage);
          // productLocalImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  // Widget showImage(int index) {
  //   return SizedBox(
  //     height: 100,
  //     child: Stack(
  //       children: <Widget>[
  //         Card(
  //           elevation: 2,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           shadowColor: dividerColor,
  //           margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
  //           child: Container(
  //             width: 100,
  //             // decoration: BoxDecoration(
  //             //   borderRadius: BorderRadius.circular(10),
  //             //   image: DecorationImage(
  //             //       image: FileImage(
  //             //         File(productLocalImages[index].path),
  //             //       ),
  //             //       fit: BoxFit.fill),
  //             // ),
  //             child: Image.asset(
  //               croppedImageList[index],
  //               width: 100,
  //               height: 100,
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           right: 0,
  //           top: 0,
  //           child: IconButton(
  //             padding: const EdgeInsets.only(right: 6, top: 6),
  //             alignment: Alignment.topRight,
  //             icon: Container(
  //               padding: const EdgeInsets.all(2.0),
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
  //                 croppedImageList.removeAt(index);
  //               });
  //             },
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget viewServerImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImagesFromServer.length,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: showServerImage(index),
        ),
      ),
    );
  }

  Widget showServerImage(int index) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: <Widget>[
          CustomBoxShadow(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: boxShadowTwo,
              margin:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: NetworkImage(
                        productImagesFromServer[index]!,
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
              onPressed: () async {
                final imageId =
                    variant?.getImageId(productImagesFromServer[index]) ?? "";
                // debugPrint("imageId:- $imageId");
                _auth.deleteProductOrServiceImage(imageId).then((value) {
                  if (value) {
                    if (mounted) {
                      setState(() {
                        productImagesFromServer.removeAt(index);
                      });
                    }
                  }
                }).catchError((error) {
                  debugPrint("ERROR $error");
                });
              },
            ),
          )
        ],
      ),
    );
  }

  bool checkImageLimitForServerImage() {
    if (croppedImageList.length + productImagesFromServer.length !=
            imageCount ||
        productImagesFromServer.isNotEmpty) {
      return true;
    }
    return false;
  }

  // decide that localImage List is need to be show or not
  bool checkImageLimitForLocalImage() {
    if (croppedImageList.length + productImagesFromServer.length !=
            imageCount ||
        croppedImageList.isNotEmpty) {
      return true;
    }
    return false;
  }

  Widget addLocalImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: croppedImageList.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != croppedImageList.length
              ? showLocalImage(index)
              : croppedImageList.length + productImagesFromServer.length !=
                      imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
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
          child: SizedBox(
            width: 100,
            child: Image.file(
              File(croppedImageList[index]),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
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
                  croppedImageList.removeAt(index);
                });
              }
            },
          ),
        )
      ],
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.title,
      controller: titleController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterTitle;
      },
      onChanged: (val) {
        title = val;
      },
    );
  }

  Widget addSizeField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.size,
      controller: sizeController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterSize;
      },
      onChanged: (val) {
        value = val;
      },
    );
  }

  Widget getColorField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.color,
      controller: colorController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterColor;
      },
      onChanged: (val) {
        color = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.price,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      controller: priceController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            variantPrice = double.parse(val.replaceAll(',', '')).toString();
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
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getComparePriceField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.comparePrice,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            comparePrice = double.parse(val.replaceAll(',', '')).toString();
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
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  bool validateDropdown() {
    if (selectedType != null) {
      return true;
    } else {
      showToast(message: AppLocalization.of(context)!.pleaseSelectCategory);
      return false;
    }
  }

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable;
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Is product available now?",
    );
  }

  Widget getEnableInSuperStoreField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventory = !trackInventory;
        setState(() {});
      },
      isChecked: trackInventory,
      title: AppLocalization.of(context)!.enableInSuperStore,
    );
  }

  Widget getAvailableFromField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          final DateTime selectedDate =
              DateTime(value!.year, value.month, value.day);

          // productAvailableFrom = DateFormat('yyyy-MM-dd').format(selectedDate);
          productAvailableFrom = DateFormat('dd/MM/yyyy').format(selectedDate);
          // productAvailableFrom = DateTime(value!.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: ListTile(
          dense: true,
          title: Text(
            productAvailableFrom ?? "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
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

  Widget getInventoryFormField() {
    return CustomizedDropDownField(
      title: "Inventory (Available Quantity)",
      child: SizedBox(
        height: 55,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            dense: true,
            title: Center(
              // child: Container(
              //   decoration: BoxDecoration(
              //       border: Border.all(
              //         color: greyBorderColor,
              //       ),
              //       borderRadius: const BorderRadius.all(Radius.circular(10))),
              //   child: Padding(
              //     padding: const EdgeInsets.only(
              //         left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
              //     child: Text(
              //       inventoryCount.toString(),
              //       style: TextStyle(
              //         color: blackFont,
              //         fontWeight: FontWeight.w600,
              //         fontSize: 16,
              //       ),
              //     ),
              //   ),
              // ),
              child: SizedBox(
                width: 50,
                child: TextField(
                  controller: inventoryController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(5),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: greyBorderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: greyBorderColor,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    // if (value.isEmpty) {
                    //   inventoryController.text = '1';
                    // }
                    inventoryCount = int.parse(inventoryController.text);
                  },
                ),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: RoundedBackgroundIcon(
                  backgroundColor: greyBorderColor,
                  icon: Icon(
                    SlydoAppIcon.plus,
                    color: blackFont,
                    size: 14,
                  ),
                  onTap: () => addInventory()),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: RoundedBackgroundIcon(
                  backgroundColor: greyBorderColor,
                  icon: Icon(
                    SlydoAppIcon.minus,
                    color: blackFont,
                    size: 2,
                  ),
                  onTap: () => subtractInventory()),
            ),
          ),
        ),
      ),
    );
  }

  void addInventory() {
    setState(() {
      inventoryCount++;
      inventoryController.text = inventoryCount.toString();
    });
  }

  void subtractInventory() {
    if (inventoryCount > 0) {
      setState(() {
        inventoryCount--;
        inventoryController.text = inventoryCount.toString();
      });
    }
  }

  Widget getIsInventoryAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        inventoryIsAvailable = !inventoryIsAvailable;
        setState(() {});
      },
      isChecked: inventoryIsAvailable,
      title:
          "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 10.0,
      maxLines: 2,
    );
  }

  Widget getTypeField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.type,
      child: ListTile(
        dense: true,
        title: Text(
          selectedType != null ? selectedType?.toName() ?? "" : "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                Text(
                  'Select Category',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: typeList.length,
                    itemBuilder: (context, index) {
                      final category = typeList[index];
                      if (selectedType == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category.toName(),
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
                              selectedType = category;
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category.toName(),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          selectedType = category;
                          Navigator.pop(context);
                          setState(() {});
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

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await updateVariant();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update",
      isLoading: isAPILoading,
    );
  }

  Future<void> updateVariant() async {
    if (_formKey.currentState!.validate()) {
      if (croppedImageList.isNotEmpty || productImagesFromServer.isNotEmpty) {
        if (validateDropdown()) {
          final Variant variant = Variant();
          variant.id = id;
          // variant.localImages = productLocalImages.map((file) => File(file.path)).toList();
          variant.localImages =
              croppedImageList.map((filePath) => File(filePath)).toList();
          variant.title = title;
          variant.colour = color;
          variant.value = value;
          variant.quantity = inventoryCount;
          variant.type = selectedType;
          variant.price = moneyInputNormalizer(variantPrice).toString();
          // variant.discount = selectedDiscount;
          if (isDiscountAvailable) {
            variant.discountId = selectedDiscount?.id;
          } else {
            variant.discountId = "";
          }
          // Convert date format for server
          if (productAvailableFrom != null) {
            final DateTime dateForServer =
                DateFormat('dd/MM/yyyy').parse(productAvailableFrom!);
            variant.availableFrom =
                DateFormat('yyyy-MM-dd').format(dateForServer);
          }
          variant.isAvailable = productIsAvailable;
          // variant.availableFrom = productAvailableFrom;
          variant.trackInventory = inventoryIsAvailable;
          variant.currency = 'NGN';

          await _auth.updateVariant(variant, id).then((value) {
            Navigator.pop(context, variant);
            return true;
          }).catchError((error) {
            debugPrint(error.toString());
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    inventoryController.dispose();
    super.dispose();
  }
}
