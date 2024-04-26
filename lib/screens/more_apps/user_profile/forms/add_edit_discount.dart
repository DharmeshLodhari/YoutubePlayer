import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list_for_discount.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';

class AddEditDiscount extends StatefulWidget {
  AddEditDiscount({Key? key, this.discountModel}) : super(key: key);

  final DiscountModel? discountModel;

  @override
  _AddEditDiscountState createState() => _AddEditDiscountState();
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
  bool isSelectAll = false;
  bool isItemSelected = false;

  @override
  void initState() {
    if (widget.discountModel != null) {
      isEdit = true;
    }
    discountModel = widget.discountModel?.copyWith() ?? DiscountModel();

    // TODO: CHECK
    // discountModel.merchant ??= widget.user.userName ?? "";
    startFrom = discountModel.startDate;
    endTo = discountModel.endDate;
    startTimeFrom = discountModel.onlyFrom;
    endTimeTo = discountModel.onlyTo;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
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
              content: Container(
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
                      isDeleteLoading = true;
                      if (mounted) setState(() {});

                      await deleteItem();

                      isDeleteLoading = false;
                      if (mounted) setState(() {});
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

  Future<void> addEditItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      //the api call will first create the product then use the id from the
      //response to save the variant

      await ShoppingAuthService()
          .addUpdateDiscount(discountModel, isEdit: isEdit)
          .then((value) async {
        Navigator.pop(context, true);
        showToast(
          message: isEdit
              ? "Discount updated successfully"
              : "Discount added successfully",
        );
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
                discountModel.addProductsToDiscount(result["ids"]);
                selectedProducts = result["products"];
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
                "This discount will apply on ${isSelectAll ? "all" : isEdit ? (discountModel.consumables?.product?.length ?? 0) : selectedProducts.length} items",
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
        child: Container(
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
        child: Container(
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
        child: Container(
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
      ),
    );
  }
}
