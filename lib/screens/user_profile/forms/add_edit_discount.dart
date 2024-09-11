import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_product_service_discount.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditDiscount extends StatefulWidget {
  const AddEditDiscount({super.key, this.discountModel});

  final DiscountModel? discountModel;

  @override
  State<AddEditDiscount> createState() => _AddEditDiscountState();
}

class _AddEditDiscountState extends State<AddEditDiscount> {
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
  List<Service> selectedServices = [];
  bool isAllProductSelected = false;
  bool isAllServiceSelected = false;
  bool isItemSelected = false;
  bool isTimeAvailable = false;

  List<PickedFile> discountImages = [];
  final ScrollController _scrollController = ScrollController();
  int imageCount = 1;
  String poster = "";
  int productCount = 0;
  int serviceCount = 0;

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
    serviceCount = discountModel.serviceCount ?? 0;

    if (startTimeFrom != null && endTimeTo != null) {
      isTimeAvailable = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: () async {
          await getExitDialog(context);
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
        padding: const EdgeInsets.all(16),
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
                    Expanded(child: startDate()),
                    const SizedBox(width: 16),
                    Expanded(child: endDate())
                  ],
                ),
                const SizedBox(height: 16),
                getIsTimeAvailableField(),
                const SizedBox(height: 16),
                if (isTimeAvailable == true) ...[
                  Row(
                    children: [
                      Expanded(child: startTime()),
                      const SizedBox(width: 16),
                      Expanded(child: endTime())
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: NetworkImage(
                        poster,
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
      initialValue: messageDecoderWithEmoji(discountModel.name) ?? "",
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

  Widget getIsTimeAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        isTimeAvailable = !isTimeAvailable;
        setState(() {});
      },
      isChecked: isTimeAvailable,
      title: "Schedule (Discount will only run during this time daily).",
    );
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
                      if (!isTimeAvailable) {
                        discountModel.onlyFrom = null;
                        discountModel.onlyTo = null;
                        startTimeFrom = null;
                        endTimeTo = null;
                      }
                      if (startTimeFrom != null) {
                        if (endTimeTo != null) {
                          if (isTimeAfter(startTimeFrom!, endTimeTo!)) {
                            isAPILoading = true;
                            if (mounted) setState(() {});

                            await addEditItem();

                            isAPILoading = false;
                            if (mounted) setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Start time cannot be greater than end time',
                                ),
                              ),
                            );
                          }
                        } else {
                          showToast(message: 'Select end time');
                        }
                      } else {
                        isAPILoading = true;
                        if (mounted) setState(() {});

                        await addEditItem();

                        isAPILoading = false;
                        if (mounted) setState(() {});
                      }
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
              if (!isTimeAvailable) {
                discountModel.onlyFrom = null;
                discountModel.onlyTo = null;
                startTimeFrom = null;
                endTimeTo = null;
              }
              if (startTimeFrom != null) {
                if (endTimeTo != null) {
                  if (isTimeAfter(startTimeFrom!, endTimeTo!)) {
                    isAPILoading = true;
                    if (mounted) setState(() {});

                    await addEditItem();

                    isAPILoading = false;
                    if (mounted) setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Start time cannot be greater than end time',
                        ),
                      ),
                    );
                  }
                } else {
                  showToast(message: 'Select end time');
                }
              } else {
                isAPILoading = true;
                if (mounted) setState(() {});

                await addEditItem();

                isAPILoading = false;
                if (mounted) setState(() {});
              }
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
        SizedBox(
          width: 40,
          height: 30,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch(
              onChanged: (value) {
                discountModel.isActive = !discountModel.isActive;
                setState(() {});
              },
              value: discountModel.isActive,
              thumbIcon: MaterialStateProperty.all(const Icon(null)),
              activeTrackColor: navyBlue,
              activeColor: Colors.white,
              inactiveTrackColor: darkGreyYarn,
              inactiveThumbColor: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          discountModel.isActive
              ? "Toggle to deactivate this discount"
              : "Toggle to activate this discount",
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
              screen: UserProductServiceDiscount(item: discountModel),
            );

            if (result != null && result is Map<String, dynamic>) {
              isItemSelected = true;
              if (result["isAllProductSelected"] != null &&
                  result["isAllProductSelected"] as bool == true) {
                discountModel.addProductsToDiscount(["*"]);
                isAllProductSelected = true;
              } else if (result["isAllServiceSelected"] != null &&
                  result["isAllServiceSelected"] as bool == true) {
                discountModel.addServicesToDiscount(["*"]);
                isAllServiceSelected = true;
              } else {
                if (result["products"] != null) {
                  discountModel.addProductsToDiscount(result["ids"]);
                  selectedProducts = result["products"];
                  selectedProducts = result["products"];
                  productCount = selectedProducts.length;
                } else if (result["services"] != null) {
                  discountModel.addServicesToDiscount(result["ids"]);
                  selectedServices = result["services"];
                  serviceCount = selectedServices.length;
                }
              }
              if (mounted) setState(() {});
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attach Items",
                style: TextStyle(
                    fontSize: 16,
                    color: blackFont,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Attach products or services to this discount",
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
                height: 10,
              ),
              Container(
                color: selectedListItemBackgroundBlue,
                child: ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                  leading: Text(
                    "Products",
                    style: TextStyle(
                      fontSize: 12,
                      color: navyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    "${isAllProductSelected ? "all" : productCount} item selected",
                    style: TextStyle(
                      fontSize: 12,
                      color: navyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: selectedListItemBackgroundBlue,
                child: ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                  leading: Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 12,
                      color: navyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    "${isAllServiceSelected ? "all" : serviceCount} item selected",
                    style: TextStyle(
                      fontSize: 12,
                      color: navyBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget startTime() {
    return GestureDetector(
      onTap: () {
        showTimePicker(
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true, // Forces 24-hour format
              ),
              child: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary:
                        navyBlue, // Sets the color for the time picker clock
                    onSurface:
                        Colors.black, // Sets the color for the time numbers
                  ),
                ),
                child: child!,
              ),
            );
          },
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          if (value != null) {
            setState(() {
              startTimeFrom = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                value.hour,
                value.minute,
              );
              discountModel.onlyFrom = startTimeFrom;
            });
          }
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
            startTimeFrom != null ? formatTime24hrs(startTimeFrom) : "",
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
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true, // Forces 24-hour format
              ),
              child: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary:
                        navyBlue, // Sets the color for the time picker clock
                    onSurface:
                        Colors.black, // Sets the color for the time numbers
                  ),
                ),
                child: child!,
              ),
            );
          },
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((value) {
          if (value != null) {
            setState(() {
              endTimeTo = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                value.hour,
                value.minute,
              );
              discountModel.onlyTo = endTimeTo;
            });
          }
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
            endTimeTo != null ? formatTime24hrs(endTimeTo) : "",
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 15,
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
            softWrap: false,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
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
            softWrap: false,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
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

  dynamic getExitDialog(BuildContext context) async {
    await showExitDialogBackButton(
      context: context,
      leftButtonOnPressed: () {
        Navigator.pop(context);
      },
      rightButtonOnPressed: () async {
        FocusScope.of(context).unfocus();
        if (!isTimeAvailable) {
          discountModel.onlyFrom = null;
          discountModel.onlyTo = null;
          startTimeFrom = null;
          endTimeTo = null;
        }
        if (startTimeFrom != null) {
          if (endTimeTo != null) {
            if (isTimeAfter(startTimeFrom!, endTimeTo!)) {
              await addEditItem();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Start time cannot be greater than end time',
                  ),
                ),
              );
            }
          } else {
            showToast(message: 'Select end time');
          }
        } else {
          await addEditItem();
        }
      },
    );
    //   if (result != null && result) {
    //     if (selectedProducts.isNotEmpty || selectedServices.isNotEmpty) {
    //       selectedProducts == null;
    //       selectedServices == null;
    //     }
    //     Navigator.of(context).pop();
    //   }
    //   return false;
    // } else {
    //   Navigator.of(context).pop();
    //   return true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
