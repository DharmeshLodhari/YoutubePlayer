import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_add_on_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_variants_tile.dart';
import 'package:Slydo/screens/user_profile/forms/add_edit_shipping_address.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/validation.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductAdvancedOptions extends StatefulWidget {
  ProductAdvancedOptions(
      {super.key,
      required this.isEdit,
      this.productId,
      required this.currentProduct});

  bool isEdit;
  String? productId;
  final Product currentProduct;

  @override
  State<ProductAdvancedOptions> createState() => _ProductAdvancedOptionsState();
}

class _ProductAdvancedOptionsState extends State<ProductAdvancedOptions> {
  UserBloc? userBloc;

  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  Product? currentProduct;
  bool isAvailability = false;
  bool isMeasurement = false;
  bool isDiscount = false;
  bool isTrackInventory = false;
  bool isSeoKeyword = false;
  DateTime? productAvailableFrom = DateTime.now();
  List<String> pickedMeasurementList = [];

  List<String> weightSi = ['Grams', 'Kilograms'];
  List<String> widthSi = ['Centimetres', 'Metres'];
  List<String> heightSi = ['Centimetres', 'Metres'];

  List<String> measurementList = ['Weight', 'Height', 'Width'];
  Map<String, bool> measurementCheckMark = {};

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();
  TextEditingController searchKeywordController = TextEditingController();

  double weight = 0.0;
  double width = 0.0;
  double height = 0.0;
  String selectedWeight = "";
  String selectedHeight = "";
  String selectedWidth = "";

  String? discountId;
  bool isLoading = false;

  bool isEmpty = false;
  int? discountItemCount = 0;
  String? discountNext = "";
  String? discountPrevious = "";
  bool isDiscountLoading = false;
  List<DiscountModel> discountList = [];
  List<DiscountModel> discountListCopy = [];
  bool noItemInList = false;
  DiscountModel? pressedDiscount;
  DiscountModel? selectedDiscount;
  String discountName = "";

  int inventoryCount = 1;
  String? searchKeyword = "";

  ShippingAddress? defaultAddress;
  List<Variant> productVariantList = [];
  List<AddOns> productAddOnsList = [];
  ScrollController scrollControllerVariant = ScrollController();

  @override
  void initState() {
    isLoading = true;
    currentProduct = widget.currentProduct;
    if (mounted) setState(() {});
    Future.delayed(const Duration(seconds: 2), () {
      if (!widget.isEdit) getDiscountList();
      getAddressList();
    });

    inventoryController.text = "1";
    isAvailability = currentProduct?.isAvailable ?? false;
    productAvailableFrom = currentProduct?.availableFrom ?? DateTime.now();
    weight = currentProduct?.weight ?? 0;
    selectedWeight = currentProduct?.weightSiUnit == 'g'
        ? 'Grams'
        : currentProduct?.weightSiUnit == ''
            ? ''
            : 'Kilograms';
    height = currentProduct?.height ?? 0;
    selectedHeight = currentProduct?.heightSiUnit == 'cm'
        ? 'Centimetres'
        : currentProduct?.heightSiUnit == ""
            ? ''
            : 'Metres';
    width = currentProduct?.width ?? 0;
    selectedWidth = currentProduct?.widthSiUnit == 'cm'
        ? 'Centimetres'
        : currentProduct?.widthSiUnit == ""
            ? ''
            : 'Metres';
    weightController.text = currentProduct?.weight != 0.0
        ? currentProduct?.weight.toString() ?? ""
        : '';
    heightController.text = currentProduct?.height != 0.0
        ? currentProduct?.height.toString() ?? ""
        : '';
    widthController.text = currentProduct?.width != 0.0
        ? currentProduct?.width.toString() ?? ""
        : '';
    if (weight != 0.0) {
      pickedMeasurementList.add('Weight');
    }

    if (height != 0.0) {
      pickedMeasurementList.add('Height');
    }

    if (width != 0.0) {
      pickedMeasurementList.add('Width');
    }
    isMeasurement = pickedMeasurementList.isEmpty ? false : true;
    isDiscount = currentProduct?.discountIsActive ?? false;
    discountId = currentProduct?.discountId;
    getDiscountList(discountId: discountId);
    isTrackInventory = currentProduct?.trackInventory ?? false;
    inventoryCount = currentProduct?.quantity ?? 1;
    inventoryController.text = inventoryCount.toString();
    if (currentProduct?.searchKeywords != null) {
      isSeoKeyword = true;
      searchKeyword =
          messageDecoderWithEmoji(currentProduct?.searchKeywords?.join(", "));
      searchKeywordController.text =
          messageDecoderWithEmoji(currentProduct?.searchKeywords?.join(", ")) ??
              "";
    }
    productVariantList = currentProduct?.variantModels ?? [];
    productAddOnsList = currentProduct?.addOnsModels ?? [];

    super.initState();
  }

  @override
  void didChangeDependencies() {
    userBloc = Provider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  void getDiscountList({String? discountId}) async {
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

  void getAddressList() async {
    if (mounted) setState(() {});

    final Map<String, dynamic>? result =
        await ShoppingAuthService().listOfDispatchAddress("", null);

    if (result == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final List<ShippingAddress> tempList = result['results'];

    if (mounted) {
      setState(() {
        isLoading = false;
        isEmpty = tempList.isEmpty;
        defaultAddress = tempList.firstWhere((element) => element.isDefault!);
      });
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
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.advancedOptions,
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
      actions: [
        CurvedButton(
            textColor: Colors.white,
            width: 70,
            height: 30,
            fontSize: 10,
            borderRadius: 20,
            backgroundColor: navyBlue,
            text: AppLocalization.of(context)!.save,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              saveProductData();
            }),
        const SizedBox(width: 16),
      ],
    );
  }

  void saveProductData() {
    currentProduct?.isAvailable = isAvailability;
    currentProduct?.availableFrom = productAvailableFrom;

    currentProduct?.weight = weight;
    currentProduct?.weightSiUnit = selectedWeight == 'Grams'
        ? 'g'
        : selectedWeight == 'Kilograms'
            ? 'kg'
            : '';
    currentProduct?.height = height;
    currentProduct?.heightSiUnit = selectedHeight == 'Centimetres'
        ? 'cm'
        : selectedHeight == 'Metres'
            ? 'm'
            : '';
    currentProduct?.width = width;
    currentProduct?.widthSiUnit = selectedWidth == 'Centimetres'
        ? 'cm'
        : selectedWidth == 'Metres'
            ? 'm'
            : '';
    if (isDiscount) {
      currentProduct?.discountId = selectedDiscount?.id;
    } else {
      currentProduct?.discountId = "";
    }
    currentProduct?.discountIsActive = isDiscount;
    currentProduct?.trackInventory = isTrackInventory;
    currentProduct?.quantity = inventoryCount;
    currentProduct?.addressId = defaultAddress?.id;
    currentProduct?.searchKeywords =
        commaSeparatedStringToList(searchKeyword ?? "");

    Navigator.pop(context, currentProduct);
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildAvailabilityStatus(),
                    getHorizontalDivider(),
                    _buildMeasurement(),
                    getHorizontalDivider(),
                    _buildDiscount(),
                    getHorizontalDivider(),
                    _buildTrackInventory(),
                    getHorizontalDivider(),
                    _buildSEOKeyword(),
                    getHorizontalDivider(),
                    _buildProductShowcase(),
                    getHorizontalDivider(),
                    _buildDispatchAddress(),
                    getHorizontalDivider(),
                    _buildProductVariation(),
                    getHorizontalDivider(),
                    _buildProductAddOns(),
                    getHorizontalDivider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityStatus() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Availability Status",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            "Indicate whether this product is currently in stock and ready for purchase.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: fontLightGrey,
              fontFamily: "Inter",
            ),
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isAvailability,
                onChanged: (bool value) async {
                  setState(() {
                    isAvailability = value;
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isAvailability) getAvailableFromField(),
      ],
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
              productAvailableFrom = DateTime(
                  value?.year ?? 0, value?.month ?? 0, value?.day ?? 0);
            });
          }
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: ListTile(
          dense: true,
          title: Text(
            formatDate1(productAvailableFrom),
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

  Widget _buildMeasurement() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Measurement",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            "Provide weight and dimensions to help users get size and shipping recommendations.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: fontLightGrey,
              fontFamily: "Inter",
            ),
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isMeasurement,
                onChanged: (bool value) async {
                  setState(() {
                    isMeasurement = value;
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isMeasurement) _buildMeasurementData(),
      ],
    );
  }

  Widget _buildMeasurementData() {
    return Column(
      children: [
        getCategoryMeasurementField(),
        const SizedBox(height: 16),
        if (pickedMeasurementList.isNotEmpty) ...[
          if (containsWeight()) ...[
            //weight section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: getWeightField(),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  flex: 1,
                  child: getWeightSiUnitField(),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (containsHeight()) ...[
            //height section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: getHeightField(),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  flex: 1,
                  child: getHeightSiUnitField(),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (containsWidth()) ...[
            //width section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: getWidthField(),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  flex: 1,
                  child: getWidthSiUnitField(),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ]
        ],
      ],
    );
  }

  Widget getCategoryMeasurementField() {
    return CustomizedDropDownField(
      title: '',
      child: ListTile(
        dense: true,
        title: Text(
          pickedMeasurementList.isNotEmpty
              ? pickedMeasurementList.join(', ')
              : '',
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          measurementAndroidSheet();
        },
      ),
    );
  }

  bool containsWeight() {
    return pickedMeasurementList.contains('Weight');
  }

  bool containsHeight() {
    return pickedMeasurementList.contains('Height');
  }

  bool containsWidth() {
    return pickedMeasurementList.contains('Width');
  }

  Widget _buildCancelIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
              color: black,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementText() {
    return Text(
      "Measurement",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: blackFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void measurementAndroidSheet() {
    measurementCheckMark['Height'] = containsHeight() ? true : false;
    measurementCheckMark['Weight'] = containsWeight() ? true : false;
    measurementCheckMark['Width'] = containsWidth() ? true : false;

    androidBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCancelIcon(),
                const SizedBox(height: 10),
                _buildMeasurementText(),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: measurementList.length,
                    itemBuilder: (context, index) {
                      final String measurement = measurementList[index];
                      return CheckboxListTile(
                        value: measurementCheckMark[measurement] ?? false,
                        activeColor: navyBlue,
                        onChanged: (isChecked) {
                          changeState(() {
                            measurementCheckMark[measurement] = isChecked!;
                          });
                          if (pickedMeasurementList.contains(measurement)) {
                            pickedMeasurementList.remove(measurement);
                          } else {
                            pickedMeasurementList.add(measurement);
                          }
                          if (mounted) setState(() {});
                        },
                        title: Text(
                          measurement,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                  ),
                ),
                CurvedButton(
                  text: 'Save',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getWeightField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.weight,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: weightController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            weight = double.parse(val);
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val);
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidWeight;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidWeight;
      },
    );
  }

  Widget getWeightSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedWeight.isNotEmpty ? selectedWeight : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          weightSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getHeightSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedHeight.isNotEmpty ? selectedHeight : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          heightSiUnitAndroidSheet();
        },
      ),
    );
  }

  void heightSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Height SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: heightSi.length,
                    itemBuilder: (context, index) {
                      final height = heightSi[index];
                      if (selectedHeight == height) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              height,
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
                              selectedHeight = height;
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          height,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          selectedHeight = height;
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

  Widget getHeightField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.height,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: heightController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            height = double.parse(val);
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val);
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidHeight;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidHeight;
      },
    );
  }

  Widget getWidthSiUnitField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.siUnit,
      child: ListTile(
        dense: true,
        title: Text(
          selectedWidth.isNotEmpty ? selectedWidth : "",
          style: TextStyle(
            color: blackFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
          maxLines: 1,
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          widthSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getWidthField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.width,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: widthController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            width = double.parse(val);
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val);
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidWidth;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidWidth;
      },
    );
  }

  void widthSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Width SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widthSi.length,
                    itemBuilder: (context, index) {
                      final category = widthSi[index];
                      if (selectedWidth == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category,
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
                              selectedWidth = category;
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          selectedWidth = category;
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

  void weightSiUnitAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              children: [
                Text(
                  'Select Weight SI Unit',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: weightSi.length,
                    itemBuilder: (context, index) {
                      final category = weightSi[index];
                      if (selectedWeight == category) {
                        return Container(
                          color: selectedListItemBackgroundBlue,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              category,
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
                              selectedWeight = category;
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: Text(
                          category,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        dense: true,
                        onTap: () {
                          selectedWeight = category;
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

  Widget _buildDiscount() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Discount",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            "Apply a discount to your product for sales events or promotions.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: fontLightGrey,
              fontFamily: "Inter",
            ),
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isDiscount,
                onChanged: (bool value) async {
                  setState(() {
                    isDiscount = value;
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isDiscount) getDiscountListField(),
      ],
    );
  }

  Widget getDiscountListField() {
    return CustomizedDropDownField(
      title: '',
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

  Widget _buildTrackInventory() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Track Inventory",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            "Enable this option to automatically track and update product availability.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: fontLightGrey,
              fontFamily: "Inter",
            ),
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isTrackInventory,
                onChanged: (bool value) async {
                  setState(() {
                    isTrackInventory = value;
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isTrackInventory) getInventoryFormField(),
      ],
    );
  }

  Widget getTrackInventoryField() {
    return CustomizedCheckBoxField(
      onTap: () {
        isTrackInventory = !isTrackInventory;
        setState(() {});
      },
      isChecked: isTrackInventory,
      title:
          "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 12.0,
      maxLines: 2,
    );
  }

  Widget getInventoryFormField() {
    return CustomizedDropDownField(
      title: '',
      child: ListTile(
        dense: true,
        title: Center(
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

  Widget _buildSEOKeyword() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "SEO Keyword",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            "Add relevant keywords to improve your product's visibility in search results.",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: fontLightGrey,
              fontFamily: "Inter",
            ),
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isSeoKeyword,
                onChanged: (bool value) async {
                  setState(() {
                    isSeoKeyword = value;
                  });
                },
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
        ),
        if (isSeoKeyword) getSearchEngineKeyword(),
      ],
    );
  }

  Widget getSearchEngineKeyword() {
    return CustomizedTextFormField(
      controller: searchKeywordController,
      hasLabel: false,
      onChanged: (val) {
        if (val != null) {
          searchKeyword = val;
        }
      },
    );
  }

  Widget _buildProductShowcase() {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
      title: Text(
        "Product Showcase",
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      subtitle: Text(
        "Attach images or videos that showcase your product in use to engage customers.",
        style: TextStyle(
          color: lightBlackFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: "Inter",
        ),
      ),
      children: const <Widget>[
        // Column(
        //   children: [
        //     getCategoryField(),
        //     const SizedBox(height: 10),
        //     getSubCategoryField(),
        //     const SizedBox(height: 10),
        //     getCustomCategoryField(),
        //     const SizedBox(height: 5),
        //     addCustomCategory(),
        //   ],
        // )
      ],
      onExpansionChanged: (bool expanded) {
        // You can manage the icon color or perform any action based on expanded state if needed
      },
    );
  }

  Widget _buildDispatchAddress() {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
      title: Text(
        "Dispatch Address",
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      subtitle: Text(
        "Set the address from which the product will be shipped.",
        style: TextStyle(
          color: lightBlackFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: "Inter",
        ),
      ),
      children: <Widget>[
        address(),
      ],
      onExpansionChanged: (bool expanded) {
        // You can manage the icon color or perform any action based on expanded state if needed
      },
    );
  }

  Widget address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
          if (!isEmpty && defaultAddress == null)
            Text(
              "Add a dispatch Address",
              maxLines: 1,
              style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 14),
            ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!isEmpty && defaultAddress != null) {
              Navigator.of(context)
                  .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
                "isForSelection": true,
                "shippingAddress": defaultAddress,
                "onShippingAddressChange": (address) {
                  defaultAddress = address;
                  setState(() {});
                }
              });
            } else {
              NavigationUtil.push(
                context,
                screen: const AddEditShippingAddress(),
              ).whenComplete(() => getAddressList());
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  !isEmpty && defaultAddress != null
                      ? "${defaultAddress?.addressLineOne}, ${defaultAddress?.addressLineTwo}, ${defaultAddress?.city}, ${defaultAddress?.stateName}, ${defaultAddress?.country}, ${defaultAddress?.zip}"
                      : "",
                  maxLines: 2,
                  style: TextStyle(
                      color: isEmpty ? navyBlue : blackFont,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: blackFont,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductVariation() {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
      title: Text(
        "Product Variation",
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      subtitle: Text(
        "Define product variations like size, color, or material.",
        style: TextStyle(
          color: lightBlackFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: "Inter",
        ),
      ),
      children: <Widget>[
        if (productVariantList.isEmpty) ...[
          // getAddVariationFormField(),
          productVariation(),
        ] else ...[
          displaySelectedVariant(),
        ],
      ],
      onExpansionChanged: (bool expanded) {
        // You can manage the icon color or perform any action based on expanded state if needed
      },
    );
  }

  Widget _buildProductAddOns() {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.zero,
      title: Text(
        "Product Add-ons",
        style: TextStyle(
          color: blackFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
      subtitle: Text(
        "Add related items or extra options for this product.",
        style: TextStyle(
          color: lightBlackFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: "Inter",
        ),
      ),
      children: <Widget>[
        if (productAddOnsList.isEmpty) ...[
          productAddOns(),
        ] else ...[
          displaySelectedAddOn(),
        ],
      ],
      onExpansionChanged: (bool expanded) {
        // You can manage the icon color or perform any action based on expanded state if needed
      },
    );
  }

  Widget productVariation() {
    return GestureDetector(
      onTap: () async {
        //disable click if add-on is not empty
        if (productAddOnsList.isNotEmpty) {
          return;
        }
        final result;
        if (widget.isEdit) {
          result = await Navigator.of(context).pushNamed(
              Routes.ADD_EDIT_VARIANT,
              arguments: {'productId': widget.productId, 'option': 'edit'});
        } else {
          result = await Navigator.of(context)
              .pushNamed(Routes.ADD_EDIT_VARIANT, arguments: {
            'option': 'new',
            'productId': '',
          });
        }

        // Handle the result (map) received from Product Add New Option
        if (result != null && result is Variant) {
          //save the variant details for later use
          productVariantList.add(result);
          if (mounted) setState(() {});
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Product Variation',
            maxLines: 1,
            style: TextStyle(
                color: productAddOnsList.isNotEmpty ? darkGrey : navyBlue,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: blackFont,
          ),
        ],
      ),
    );
  }

  Widget displaySelectedVariant() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Variant',
              maxLines: 1,
              style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                  fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                if (widget.isEdit) {
                  final data = await Navigator.of(context)
                      .pushNamed(Routes.PRODUCT_VARIANT_LIST, arguments: {
                    'productId': widget.productId,
                  });

                  // Handle the result (map) received from PRODUCT_VARIANT_LIST
                  if (data != null && data is List<Variant>) {
                    //clear previous list, update the list

                    productVariantList = [];
                    // productVariantList = Variant.convertToVariantList(data);
                    productVariantList = data;

                    // variantData = data;
                    // productVariantList.add(data);
                    if (mounted) setState(() {});
                  }
                } else {
                  final result = await Navigator.of(context)
                      .pushNamed(Routes.ADD_EDIT_VARIANT, arguments: {
                    'option': 'new',
                    'productId': '',
                  });

                  // Handle the result (map) received from Product Add New Option
                  if (result != null && result is Variant) {
                    //save the variant details for later use
                    productVariantList.add(result);
                    if (mounted) setState(() {});
                  }
                }
              },
              child: Text(
                widget.isEdit ? 'See all' : 'Add more',
                maxLines: 1,
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        _buildProductVariantList(),
      ],
    );
  }

  Widget _buildProductVariantList() {
    return isLoading && productVariantList.isEmpty
        ? buildLoadingIndicator(isLoading: isLoading)
        : ListView.builder(
            padding: EdgeInsets.zero,
            controller: scrollControllerVariant,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                productVariantList.length >= 2 ? 2 : productVariantList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == productVariantList.length) {
                return buildJumpingLoadingIndicator(isLoading: isLoading);
              } else {
                return FormVariantsTile(
                    productVariantList: productVariantList,
                    index: index,
                    type: widget.isEdit ? 'edit' : 'add');
              }
            },
          );
  }

  Widget productAddOns() {
    return GestureDetector(
      onTap: () async {
        // //disable click if variant is not empty
        // // if (productVariantList.isNotEmpty) {
        // //   return;
        // // }
        //
        // final result;
        // if(isEdit) {
        // result = await Navigator.of(context)
        //     .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
        //   'productId': productId,
        //   'isForCheckboxSelection': true,
        // });
        // } else {
        // result = await Navigator.of(context)
        //     .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
        //   'productId': '',
        //   'isForCheckboxSelection': true,
        // });
        // }
        //
        // // Handle the result (map) received from PRODUCT_ADD_ON_LIST
        // if (result != null && result is List<AddOns>) {
        //   //save the add-on details
        //   productAddOnsList = result;
        //   if (mounted) setState(() {});
        // }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Product Add-ons',
            maxLines: 1,
            style: TextStyle(
                // color: productVariantList.isNotEmpty ? darkGrey : navyBlue,
                color: darkGrey,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
                fontSize: 14),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: blackFont,
          ),
        ],
      ),
    );
  }

  Widget displaySelectedAddOn() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Add-ons',
              maxLines: 1,
              style: TextStyle(
                color: darkGrey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            GestureDetector(
              onTap: () async {
                final data;
                if (widget.isEdit) {
                  data = await Navigator.of(context)
                      .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
                    'productId': widget.productId,
                    'isForCheckboxSelection': true,
                  });
                } else {
                  data = await Navigator.of(context)
                      .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
                    'productId': '',
                    'isForCheckboxSelection': true,
                  });
                }

                // Handle the result (map) received from PRODUCT_ADD_ON_LIST
                if (data != null && data is List<AddOns>) {
                  //save the add-on details
                  productAddOnsList = data;
                  if (mounted) setState(() {});
                }
              },
              child: Text(
                'See all',
                maxLines: 1,
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        _buildAddOnList(),
      ],
    );
  }

  Widget _buildAddOnList() {
    return isLoading && productAddOnsList.isEmpty
        ? buildLoadingIndicator(isLoading: isLoading)
        : SizedBox(
            // height: 200,
            height: 80 * productAddOnsList.length.toDouble(),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              //+1 for progressbar
              itemCount:
                  productAddOnsList.length >= 2 ? 2 : productAddOnsList.length,
              controller: scrollControllerVariant,
              itemBuilder: (BuildContext context, int index) {
                if (index == productAddOnsList.length) {
                  return buildJumpingLoadingIndicator(isLoading: isLoading);
                } else {
                  return FormAddOnTile(
                    productAddOnsList: productAddOnsList,
                    index: index,
                  );
                }
              },
            ),
          );
  }

  Widget getHorizontalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        height: 0,
        color: dividerColor,
        thickness: 1,
      ),
    );
  }

  @override
  void dispose() {
    inventoryController.dispose();
    super.dispose();
  }
}
