import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list_for_discount.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditDiscountOld extends StatefulWidget {
  AddEditDiscountOld({super.key, this.discountModel});

  final DiscountModel? discountModel;

  @override
  _AddEditDiscountOldState createState() => _AddEditDiscountOldState();
}

class _AddEditDiscountOldState extends State<AddEditDiscountOld> {
  final _formKey = GlobalKey<FormState>();

  List<DiscountTagCategory> discountTagCategory = [
    DiscountTagCategory("Percentage %"),
    DiscountTagCategory("Amount (₦)")
  ];

  DateTime? startFrom;
  DateTime? endTo;
  DateTime? startTimeFrom;
  DateTime? endTimeTo;
  bool isAPILoading = false;

  bool isDeleteLoading = false;

  late DiscountModel discountModel;
  bool isEdit = false;

  List<Product> selectedProducts = [];
  bool isSelectAll = false;
  bool isItemSelected = false;

  List<PickedFile> discountImages = [];
  final ScrollController _scrollController = ScrollController();
  int imageCount = 1;
  String poster = "";
  int productCount = 0;

  @override
  void initState() {
    if (widget.discountModel != null) {
      isEdit = true;
    }
    discountModel = widget.discountModel?.copyWith() ?? DiscountModel();
    poster = widget.discountModel?.poster ?? "";
    // TODO: CHECK
    // discountModel.merchant ??= widget.user.userName ?? "";
    startFrom = discountModel.startDate;
    endTo = discountModel.endDate;
    startTimeFrom = discountModel.onlyFrom;
    endTimeTo = discountModel.onlyTo;
    productCount = discountModel.productCount ?? 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0.5,
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
        "Discount",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      shadowColor: greySecondaryYarn,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (poster.isNotEmpty) showServerImage() else Container(),
                if (poster.isEmpty) ...[
                  const SizedBox(height: 20),
                  addImages(),
                ],
                const SizedBox(height: 20),
                addTitleField(),
                const SizedBox(
                  height: 16,
                ),
                discountTagType(),
                const SizedBox(
                  height: 16,
                ),
                valueField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: startTime()),
                    const SizedBox(width: 16),
                    Expanded(child: endTime())
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: startDate()),
                    const SizedBox(width: 16),
                    Expanded(child: endDate())
                  ],
                ),
                const SizedBox(height: 16),
                toggleActiveTag(),
                const SizedBox(height: 16),
                productSelection(),
                const SizedBox(height: 32),
                getSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showServerImage() {
    return SizedBox(
      height: 170,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width - 40,
                  imageUrl: poster,
                  fit: BoxFit.fill,
                  errorWidget: productAndServiceBigErrorWidget,
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
                poster = "";
                if (mounted) setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addImages() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: discountImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != discountImages.length
              ? showImage(index)
              : discountImages.length != imageCount
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
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
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
                      color: darkGrey, fontFamily: "Inter", fontSize: 14),
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

          discountImages.add(PickedFile(croppedImage));
          discountModel.poster = croppedImage;
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(discountImages[index].path),
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
                setState(() {
                  discountImages.removeAt(index);
                });
              },
            ),
          )
        ],
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

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Title",
      initialValue: discountModel.name ?? "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        discountModel.name = val;
      },
    );
  }

  Widget discountTagType() {
    return CustomizedDropDownField(
      title: "Discount Type",
      child: ListTile(
        dense: true,
        title: Text(
          discountModel.type?.toString() ?? "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
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
    final pressedCategory = await showDialog<DiscountTagCategory>(
        context: context,
        builder: (context) => AlertDialog(
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
                        children: discountTagCategory.map<Widget>((category) {
                          if (discountModel.type?.toString() ==
                              category.toString()) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category.toString(),
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
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category.toString(),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      discountModel.type = pressedCategory;
      setState(() {});
    }
  }

  Widget valueField() {
    return CustomizedTextFormField(
      labelText: "Value",
      initialValue: discountModel.value?.toString(),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        if (int.tryParse(val) == null) {
          return "Invalid value";
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
        discountModel.value = int.tryParse(val);
      },
    );
  }

  Widget getSubmitButton() {
    if (isEdit) {
      return Row(
        children: [
          Expanded(
            child: CurvedButton(
              onPressed: isDeleteLoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      deleteDiscountDialog();
                    },
              backgroundColor: red,
              textColor: Colors.white,
              text: "Delete",
              isLoading: isDeleteLoading,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: CurvedButton(
              onPressed: isAPILoading
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      isAPILoading = true;
                      if (mounted) setState(() {});

                      await addEditItem();

                      isAPILoading = false;
                      if (mounted) setState(() {});
                    },
              backgroundColor: navyBlue,
              textColor: Colors.white,
              text: "Update",
              isLoading: isAPILoading,
            ),
          )
        ],
      );
    }

    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addEditItem();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  void deleteDiscountDialog() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Discount',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this discount?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        isDeleteLoading = true;
        if (mounted) setState(() {});

        await deleteItem();

        isDeleteLoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> addEditItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      //the api call will first create the product then use the id from the
      //response to save the variant

      await ShoppingAuthService()
          .addUpdateDiscount(discountModel, isEdit: isEdit)
          .then((value) async {
        if (value != null) {
          Navigator.pop(context, true);
          showToast(
            message: isEdit
                ? "Discount updated successfully"
                : "Discount added successfully",
          );
        } else {
          showToast(
            message: "Error",
          );
        }
      }).catchError((error) {
        debugPrint("Product check::: ${error.toString()}");
        showToast(message: error.toString());
      });
    } else {
      showToast(message: "Please fill all the details");
    }
  }

  Future<void> deleteItem() async {
    await ShoppingAuthService()
        .deleteDiscount(discountModel.id!)
        .then((value) async {
      Navigator.pop(context, true);
      showToast(
        message: "Discount deleted successfully",
      );
    }).catchError((error) {
      debugPrint("Product check::: ${error.toString()}");
      showToast(message: error.toString());
    });
  }

  Widget toggleActiveTag() {
    return Row(
      children: [
        Switch(
          onChanged: (value) {
            discountModel.isActive = !discountModel.isActive;
            setState(() {});
          },
          value: discountModel.isActive,
          activeColor: Theme.of(context).primaryColor,
        ),
        Text(
          "Toggle to activate this discount",
          style: TextStyle(
              fontSize: 14, color: blackFont, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget productSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await NavigationUtil.push(
              context,
              screen: UserProductListForDiscount(item: discountModel),
            );

            if (result != null && result is Map<String, dynamic>) {
              isItemSelected = true;
              if (result["isSelectAll"] as bool == true) {
                discountModel.addProductsToDiscount(["*"]);
                isSelectAll = true;
              } else {
                discountModel.addServicesToDiscount(result["ids"]);
                selectedProducts = result["products"];
                productCount = selectedProducts.length;
              }
              if (mounted) setState(() {});
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Product",
                style: TextStyle(
                    fontSize: 16,
                    color: blackFont,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Attach product to this discount",
                      style: TextStyle(
                          fontSize: 14,
                          color: darkGrey,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: navyBlue,
                  )
                ],
              ),
            ],
          ),
        ),
        if (isItemSelected || isEdit)
          Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Text(
                // "This discount will apply on ${isSelectAll ? "all" : isEdit ? (discountModel.productCount ?? 0) : selectedProducts.length} items",
                "This discount will apply on ${isSelectAll ? "all" : productCount} items",
                style: TextStyle(
                    fontSize: 12, color: navyBlue, fontWeight: FontWeight.w600),
              ),
            ],
          )
      ],
    );
  }

  Widget startTime() {
    return GestureDetector(
      onTap: () {
        showTimePicker(
          builder: customThemeBuilder,
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          startTimeFrom = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, value!.hour, value.minute);
          discountModel.onlyFrom = startTimeFrom;
          setState(() {});
        }).catchError((error) {});

        // showDatePicker(
        //   builder: customThemeBuilder,
        //   context: context,
        //   initialDate: DateTime(DateTime.now().hour, DateTime.now().minute,
        //       DateTime.now().second),
        //   firstDate: DateTime(DateTime.now().hour, DateTime.now().minute,
        //       DateTime.now().second),
        //   lastDate: DateTime(2101),
        // ).then((value) {
        //   startTimeFrom = DateTime(value!.hour, value.minute, value.second);
        //   discountModel.onlyFrom = startTimeFrom;
        //   setState(() {});
        // }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Start Time",
        child: ListTile(
          dense: true,
          title: Text(
            startTimeFrom != null ? formatTime(startTimeFrom.toString()) : "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            SlydoAppIcon.clock,
            size: 16,
            color: darkGrey,
          ),
        ),
      ),
    );
  }

  Widget endTime() {
    return GestureDetector(
      onTap: () {
        showTimePicker(
          builder: customThemeBuilder,
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          endTimeTo = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, value!.hour, value.minute);
          discountModel.onlyTo = endTimeTo;
          setState(() {});
        }).catchError((error) {});

        // showDatePicker(
        //   builder: customThemeBuilder,
        //   context: context,
        //   initialDate: DateTime(DateTime.now().hour, DateTime.now().minute,
        //       DateTime.now().second),
        //   firstDate: DateTime(DateTime.now().hour, DateTime.now().minute,
        //       DateTime.now().second),
        //   lastDate: DateTime(2101),
        // ).then((value) {
        //   endTimeTo = DateTime(value!.hour, value.minute, value.second);
        //   discountModel.onlyTo = endTimeTo;
        //   setState(() {});
        // }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "End Time",
        child: ListTile(
          dense: true,
          title: Text(
            endTimeTo != null ? formatTime(endTimeTo.toString()) : "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            SlydoAppIcon.clock,
            size: 16,
            color: darkGrey,
          ),
        ),
      ),
    );
  }

  Widget startDate() {
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
          startFrom = DateTime(value!.year, value.month, value.day);
          discountModel.startDate = startFrom;
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Start Date",
        child: ListTile(
          dense: true,
          title: Text(
            startFrom != null ? formatDate(startFrom) : "",
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

  Widget endDate() {
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
          endTo = DateTime(value!.year, value.month, value.day);
          discountModel.endDate = endTo;

          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "End Date",
        child: ListTile(
          dense: true,
          title: Text(
            endTo != null ? formatDate(endTo) : "",
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
