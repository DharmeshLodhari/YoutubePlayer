import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_add_on_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/form_variants_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_edit_shipping_address.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/custom_textfield_tag.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../../routes/route_constants.dart';
import '../shopping_auth.dart';

class AddProduct extends StatefulWidget {
  final dynamic arguments;

  const AddProduct({super.key, this.arguments});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  ProductCategory? pressedCategory;
  ProductCategory? pressedSubCategory;
  ProductCategory? selectedProductCategory;
  ProductCategory? selectedSubCategory;
  ProductCondition? selectedProductCondition;
  ProductCondition? selectedDeliveryTimeCondition;
  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();

  final TextfieldTagsController _myController = TextfieldTagsController();
  TextEditingController inventoryController = TextEditingController();
  List<PickedFile> productImages = [];
  String productName = "";
  // String productDescription = "";
  String productShortDescription = "";
  String searchKeyword = "";
  String productCategory = "";
  String productSubCategory = "";
  String productCondition = "";
  String deliveryTimeCondition = "";
  String productPrice = "";
  String productManufacturer = "";
  String productCustomCategory = "";
  bool productIsAvailable = false;
  bool inventoryIsAvailable = false;
  bool productEnableInSuperStore = false;
  DateTime productAvailableFrom = DateTime.now();
  List<ProductCategory>? productCustomCategories;
  ProductCategory? pressedCustomCategory;

  List<ProductCategory>? productCustomCategoriesCopy;
  ProductCategory? selectedCustomCategory;
  List<ProductCategory>? customCategories;

  List<ProductCategory>? productCategories;
  List<ProductCategory>? subCategories;
  List<ProductCategory>?
      productCategoriesCopy; //To hold the full product category at all times.
  List<ProductCategory>?
      subCategoriesCopy; //To hold the full product category at all times.
  bool isLoading = false;
  bool isDiscountLoading = false;
  bool isAPILoading = false;
  int inventoryCount = 1;
  List<Variant> productVariantList = [];
  List<AddOns> productAddOnsList = [];
  List<String> weightSi = ['Grams', 'Kilograms'];
  List<String> widthSi = ['Centimetres', 'Metres'];
  List<String> heightSi = ['Centimetres', 'Metres'];
  List<String> measurementList = ['Weight', 'Height', 'Width'];
  Map<String, bool> measurementCheckMark = {};
  List<String> pickedMeasurementList = [];
  double weight = 0.0;
  double width = 0.0;
  double height = 0.0;
  String selectedWeight = "";
  String selectedHeight = "";
  String selectedWidth = "";
  bool trackInventory = false;

  // bool trackInventoryView = false;
  bool measurementView = false;
  bool isDiscountAvailable = false;
  List<Tags> userTags = [];
  ShippingAddress? defaultAddress;
  bool isEmpty = false;
  int? discountItemCount = 0;
  String? discountNext = "";
  String? discountPrevious = "";
  List<DiscountModel> discountList = [];
  List<DiscountModel> discountListCopy = [];
  bool noItemInList = false;
  DiscountModel? pressedDiscount;
  DiscountModel? selectedDiscount;
  String discountName = "";
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final FocusNode _focusNodeDescription = FocusNode();
  final QuillController _quillController = QuillController.basic();
  final ScrollController _textEditorScrollController = ScrollController();
  bool _isKeyboardVisible = false;
  bool _isProductDescriptionVisible = false;
  double? bottomInset;

  @override
  void deactivate() {
    CacheManager().deleteCache();

    super.deactivate();
  }

  @override
  void initState() {
    isLoading = true;
    if (mounted) setState(() {});
    Future.delayed(const Duration(seconds: 2), () {
      getDiscountList();
      getCategories();
      obtainCustomCategory();
      getAddressList();
    });
    inventoryController.text = "1";
    _focusNodeDescription.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateKeyboardVisibility();
    });
    super.initState();
  }

  void _handleFocusChange() {
    setState(() {
      _isProductDescriptionVisible = _focusNodeDescription.hasFocus;
    });
    _updateKeyboardVisibility();
  }

  void _updateKeyboardVisibility() {
    bottomInset = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = (bottomInset ?? 0) > 0;
    });
  }

  void getDiscountList() async {
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
        defaultAddress = tempList.firstWhere((element) => element.is_default!);
      });
    }
  }

  @override
  void didChangeDependencies() {
    userBloc = Provider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  void getCategories() async {
    try {
      productCategories = await ShoppingAuthService()
          .obtainProductCategories(userBloc!.userAbout!.industry!.id!);

      productCategoriesCopy = productCategories;
    } catch (e) {
      productCategories = [];
      productCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void obtainCustomCategory() async {
    try {
      productCustomCategories = await ShoppingAuthService()
          .obtainCustomCategory(userBloc!.user.userName!);

      productCustomCategoriesCopy = productCustomCategories;
    } catch (e) {
      productCustomCategories = [];
      productCustomCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void getSubCategories(id) async {
    if (mounted) setState(() {});

    try {
      subCategories = await ShoppingAuthService().getProductSubCategories(id);

      subCategoriesCopy = subCategories;
    } catch (e) {
      subCategories = [];
      subCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = (bottomInset ?? 0) > 0;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: LayoutBuilder(builder: (context, constraint) {
        return Scaffold(
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: scaffoldBody(),
        );
      }),
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
        "Add product",
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
                            addImages(),
                            const SizedBox(height: 10),
                            addTitleField(),
                            const SizedBox(height: 10),
                            getManufacturerField(),
                            const SizedBox(height: 10),
                            getAmountField(),
                            const SizedBox(height: 10),
                            getCategoryField(),
                            const SizedBox(height: 10),
                            getSubCategoryField(),
                            const SizedBox(height: 10),
                            getCustomCategoryField(),
                            const SizedBox(height: 10),
                            getAddTagsField(),
                            getProductConditionField(),
                            const SizedBox(height: 10),
                            if (userBloc!.userAbout!.industry!.name! ==
                                    "Restaurant/Cafe" ||
                                userBloc!.userAbout!.industry!.name! ==
                                    "Pharmaceutical") ...[
                              getProductDeliveryTimeField(),
                              const SizedBox(height: 10),
                            ],
                            getProductShortDescription(),
                            const SizedBox(height: 10),
                            getProductDescription(),
                            const SizedBox(height: 10),
                            getSearchEngineKeyword(),
                            const SizedBox(height: 20),
                            getIsAvailableField(),
                            const SizedBox(height: 16),
                            if (productIsAvailable == true) ...[
                              getAvailableFromField(),
                              const SizedBox(height: 16),
                            ],
                            getMeasurementField(),
                            const SizedBox(height: 16),
                            if (measurementView == true) ...[
                              getCategoryMeasurementField(),
                              const SizedBox(height: 16),
                            ],
                            if (pickedMeasurementList.isNotEmpty &&
                                measurementView == true) ...[
                              if (containsWeight()) ...[
                                //weight section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                const SizedBox(height: 20),
                              ],
                              if (containsHeight()) ...[
                                //height section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                const SizedBox(height: 20),
                              ],
                              if (containsWidth()) ...[
                                //width section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                const SizedBox(height: 40),
                              ]
                            ],
                            getDiscountField(),
                            const SizedBox(height: 16),
                            if (isDiscountAvailable == true) ...[
                              getDiscountListField(),
                              const SizedBox(height: 16),
                            ],
                            getTrackInventoryViewField(),
                            if (trackInventory == true) ...[
                              const SizedBox(height: 16),
                              getInventoryFormField(),
                              const SizedBox(height: 16),
                              getTrackInventoryField(),
                              const SizedBox(height: 16),
                            ],
                            const SizedBox(height: 16),
                            getEnableInSuperStoreField(),
                            const SizedBox(height: 16),
                            if (productVariantList.isEmpty) ...[
                              // getAddVariationFormField(),
                              productVariation(),
                            ] else ...[
                              displaySelectedVariant(),
                            ],
                            const SizedBox(height: 16),
                            if (productAddOnsList.isEmpty) ...[
                              productAddOns(),
                            ] else ...[
                              displaySelectedAddOn(),
                            ],
                            const SizedBox(height: 16),
                            address(),
                            const SizedBox(height: 30),
                            getSubmitButton(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isKeyboardVisible &&
                  _isProductDescriptionVisible &&
                  _focusNodeDescription.hasFocus)
                getEditor(_quillController)
              else
                const SizedBox.shrink()
            ],
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

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != productImages.length
              ? showImage(index)
              : productImages.length != imageCount
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

          productImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
    return SizedBox(
      height: 100,
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
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(productImages[index].path),
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
                  productImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.productName,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterProductName;
      },
      onChanged: (val) {
        productName = val;
      },
    );
  }

  Widget getProductShortDescription() {
    return CustomizedTextFormField(
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onChanged: (val) {
        productShortDescription = val;
      },
    );
  }

  Widget getSearchEngineKeyword() {
    return Column(
      children: [
        // CustomTextFieldTag(
        //     textfieldTagsController: textfieldTagsController,
        //     readOnly: false,
        //     onTap: (String tag) {
        //       debugPrint("$tag");
        //     }),
        CustomizedTextFormField(
          labelText: "Search Keyword - SEO (Optional)",
          onChanged: (val) {
            searchKeyword = val;
          },
        ),
        Text(
          'These words will help customer see your product online when they search it.',
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

  Widget getProductDescription() {
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
                      _isKeyboardVisible || _isProductDescriptionVisible,
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
          selectedProductCategory != null
              ? selectedProductCategory?.name ?? ""
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
          categoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  // /api/v1/products/categories/?industry=userBloc!.userAbout!.industry!.id!&search=drink

  String getCustomCategoryLabel() {
    final String industryName = userBloc!.userAbout!.industry!.name!;
    switch (industryName) {
      case 'Electronics Store':
        return "Aisle";
      case 'Furniture':
        return "Aisle";
      case 'Grocery Store':
        return "Aisle";
      case 'Liquor Store':
        return "Aisle";
      case 'Pharmaceutical':
        return "Aisle";
      case 'Restaurant/Cafe':
        return "Menu";
      case 'Retail':
        return "Aisle";
      default:
        return "Custom Category";
    }
  }

  Widget getCustomCategoryField() {
    return CustomizedDropDownField(
      title: getCustomCategoryLabel(),
      child: ListTile(
        dense: true,
        title: Text(
          selectedCustomCategory != null
              ? selectedCustomCategory?.name ?? ""
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
          customCategoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  Widget getSubCategoryField() {
    return CustomizedDropDownField(
      title: "Sub-Category",
      child: ListTile(
        dense: true,
        title: Text(
          selectedSubCategory != null ? selectedSubCategory!.name : "",
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
          subCategoryAndroidSheet();
          // selectItemCategory();
        },
      ),
    );
  }

  void customCategoryAndroidSheet() {
    customCategories = productCustomCategoriesCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search  custom category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      customCategories = productCustomCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      customCategories = productCustomCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: customCategories?.isNotEmpty ?? false
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: customCategories?.length,
                          itemBuilder: (context, index) {
                            final ProductCategory category =
                                customCategories![index];
                            if (selectedCustomCategory == category) {
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Icon(
                                    SlydoAppIcon.checked,
                                    color: navyBlue,
                                    size: 12,
                                  ),
                                  onTap: () {
                                    pressedCustomCategory = category;
                                    Navigator.pop(context);
                                    if (pressedSubCategory != null) {
                                      selectedCustomCategory =
                                          pressedCustomCategory;
                                      productCustomCategory =
                                          selectedCustomCategory!.name;
                                      setState(() {});
                                    }
                                  },
                                ),
                              );
                            }
                            return ListTile(
                              title: Text(
                                category.name,
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
                                pressedCustomCategory = category;
                                Navigator.pop(context);
                                if (pressedCustomCategory != null) {
                                  selectedCustomCategory =
                                      pressedCustomCategory;
                                  productCustomCategory =
                                      selectedCustomCategory!.name;
                                  setState(() {});
                                }
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No Data",
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    productCategories = productCategoriesCopy;
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
                      productCategories = productCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      productCategories = productCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: productCategories?.isNotEmpty ?? false
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: productCategories?.length,
                          itemBuilder: (context, index) {
                            final ProductCategory category =
                                productCategories![index];
                            if (selectedProductCategory == category) {
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
                                    pressedCategory = category;
                                    Navigator.pop(context);
                                    if (pressedCategory != null) {
                                      selectedProductCategory = pressedCategory;
                                      productCategory =
                                          selectedProductCategory!.name;
                                      setState(() {});
                                    }
                                  },
                                ),
                              );
                            }
                            return ListTile(
                              title: Text(
                                category.name,
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
                                pressedCategory = category;
                                Navigator.pop(context);
                                if (pressedCategory != null) {
                                  getSubCategories(category.id);
                                  selectedProductCategory = pressedCategory;
                                  productCategory =
                                      selectedProductCategory!.name;
                                  productSubCategory = "";
                                  selectedSubCategory = null;
                                  setState(() {});
                                }
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No Data",
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void subCategoryAndroidSheet() {
    subCategories = subCategoriesCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search  sub category',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      subCategories = subCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      subCategories = subCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (subCategories == null)
                  const SizedBox()
                else
                  Expanded(
                    child: subCategories?.isNotEmpty ?? false
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: subCategories?.length,
                            itemBuilder: (context, index) {
                              final ProductCategory category =
                                  subCategories![index];
                              if (selectedSubCategory == category) {
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
                                      pressedSubCategory = category;
                                      Navigator.pop(context);
                                      if (pressedSubCategory != null) {
                                        selectedSubCategory =
                                            pressedSubCategory;
                                        productSubCategory =
                                            selectedSubCategory!.name;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  category.name,
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
                                  pressedCategory = category;
                                  Navigator.pop(context);
                                  if (pressedCategory != null) {
                                    selectedSubCategory = pressedCategory;
                                    productCategory = selectedSubCategory!.name;
                                    setState(() {});
                                  }
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "No Data",
                            ),
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ProductCategory>(
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
                        children: productCategories?.map<Widget>((category) {
                              if (selectedProductCategory == category) {
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
      selectedProductCategory = pressedCategory;
      productCategory = selectedProductCategory!.name;
      setState(() {});
    }
  }

  bool showDeliveryTime() {
    final List industry = ['Grocery Store', 'Liquor Store', 'Restaurant/Cafe'];
    if (industry.contains(userBloc!.userAbout!.industry!.name)) {
      return true;
    }
    return false;
  }

  Widget getProductConditionField() {
    return CustomizedDropDownField(
      title: "Product condition",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              selectedProductCondition != null
                  ? selectedProductCondition!.name
                  : "",
              style: TextStyle(
                color: blackFont,
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
            Expanded(
              child: Text(
                selectedProductCondition != null
                    ? " (${selectedProductCondition!.description})"
                    : "",
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectItemCondition();
        },
      ),
    );
  }

  Widget getAddTagsField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tag",
              style: TextStyle(
                  color: darkGrey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context).pushNamed(
                    Routes.ADD_TAGS,
                    arguments: {"tagList": userTags});
                if (result != null && result is List<Tags>) {
                  setState(() {
                    userTags = [];
                    _myController.clearTags();

                    for (var tags in result) {
                      if (tags.isSelected == true) {
                        _myController.addTag =
                            tags.name?.replaceAll(" ", "-").toLowerCase() ?? "";
                        // _myIntTagController.addTag(tags.name ?? "");
                        final Tags tagData = Tags(id: tags.id, name: tags.name);
                        userTags.add(tagData);
                      }
                    }
                  });
                }
              },
              child: Text(
                "Add Tags",
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        CustomTextFieldTag(
          // initialTags: ["Test"],
          textFieldTagsController: _myController,
          onTap: (String tag) {
            setState(() {
              userTags.removeWhere((e) => e.name == tag);
            });
            // userTags.removeWhere((tag) => tag.name!.isEmpty);
          },
        ),
      ],
    );
  }

  Widget getProductDeliveryTimeField() {
    return CustomizedDropDownField(
      title: "Preparation Time",
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Text(
              selectedDeliveryTimeCondition != null
                  ? selectedDeliveryTimeCondition!.description
                  : "",
              style: TextStyle(
                color: blackFont,
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectDeliveryTimeCondition();
        },
      ),
    );
  }

  void selectDeliveryTimeCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
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
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: deliverTimeCondition.map<Widget>((condition) {
                          if (selectedDeliveryTimeCondition == condition) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      condition.name,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedDeliveryTimeCondition != null
                                            ? selectedDeliveryTimeCondition!
                                                .description
                                            : "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                            color: navyBlue),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, condition);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    condition.description,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Inter",
                                        color: blackFont),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, condition);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      selectedDeliveryTimeCondition = pressedCondition;
      deliveryTimeCondition = selectedDeliveryTimeCondition!.name;
      setState(() {});
    }
  }

  void selectItemCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
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
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: conditions.map<Widget>((condition) {
                          if (selectedProductCondition == condition) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      condition.name,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProductCondition != null
                                            ? " (${selectedProductCondition!.description})"
                                            : "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Inter",
                                            color: navyBlue),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, condition);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  condition.name,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w400),
                                ),
                                Expanded(
                                  child: Text(
                                    " (${condition.description})",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: blackFont,
                                      fontFamily: "Inter",
                                    ),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, condition);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      selectedProductCondition = pressedCondition;
      productCondition = selectedProductCondition!.name;
      setState(() {});
    }
  }

  Widget getManufacturerField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.manufacturer,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterManufacturerName;
      },
      onChanged: (val) {
        productManufacturer = val;
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
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            productPrice = double.parse(val.replaceAll(',', '')).toString();
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
          weightSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getWeightField() {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.weight,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        // isAmountField: true,

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
          heightSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getHeightField() {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.height,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        // isAmountField: true,

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
      ),
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
          widthSiUnitAndroidSheet();
        },
      ),
    );
  }

  Widget getWidthField() {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.width,
        keyboardType: Platform.isIOS
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
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
                      fontFamily: "Inter",
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
                                  fontFamily: "Inter",
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
                              fontFamily: "Inter",
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
                      fontFamily: "Inter",
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
                                  fontFamily: "Inter",
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
                              fontFamily: "Inter",
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
                      fontFamily: "Inter",
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
                                  fontFamily: "Inter",
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
                              fontFamily: "Inter",
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

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addProduct();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add product",
      isLoading: isAPILoading,
    );
  }

  Future<void> addProduct() async {
    if (_formKey.currentState!.validate()) {
      if (productImages.isNotEmpty) {
        if (containsWeight() && selectedWeight.isEmpty && weight != 0.0) {
          showToast(message: AppLocalization.of(context)?.pleaseFillWeight);
          return;
        }
        if (containsHeight() && selectedHeight.isEmpty && height != 0.0) {
          showToast(message: AppLocalization.of(context)?.pleaseFillHeight);
          return;
        }
        if (containsWidth() && selectedWidth.isEmpty && width != 0.0) {
          showToast(message: AppLocalization.of(context)?.pleaseFillWidth);
          return;
        }

        if (validateDropdown()) {
          final Product product = Product();
          product.localImages =
              productImages.map((file) => File(file.path)).toList();
          product.name = productName;
          // product.description = messageDecoderWithEmoji(productDescription);
          product.description =
              jsonEncode(_quillController.document.toDelta().toJson());
          product.shortDescription =
              messageDecoderWithEmoji(productShortDescription);
          product.category = selectedProductCategory;
          product.subCategory = selectedSubCategory;
          product.customCategory = selectedCustomCategory;
          // product.tags = userTags.map((i) => Tags.fromJson(i)).toList();
          product.tags = userTags;
          if (selectedDeliveryTimeCondition != null) {
            product.preparationTime =
                int.parse(selectedDeliveryTimeCondition?.name ?? "");
          }
          product.condition = productCondition;
          product.price = moneyInputNormalizer(productPrice);
          product.isAvailable = productIsAvailable;
          product.manufacturer = productManufacturer;
          product.availableFrom = productAvailableFrom;
          product.enableInSuperStore = productEnableInSuperStore;

          product.weight = weight;
          product.weightSiUnit = selectedWeight == 'Grams'
              ? 'g'
              : selectedWeight == 'Kilograms'
                  ? 'kg'
                  : '';
          product.height = height;
          product.heightSiUnit = selectedHeight == 'Centimetres'
              ? 'cm'
              : selectedHeight == 'Metres'
                  ? 'm'
                  : '';
          product.width = width;
          product.widthSiUnit = selectedWidth == 'Centimetres'
              ? 'cm'
              : selectedWidth == 'Metres'
                  ? 'm'
                  : '';

          product.trackInventory = trackInventory;
          if (isDiscountAvailable) {
            product.discountId = selectedDiscount?.id;
          } else {
            product.discountId = "";
          }
          product.quantity = inventoryCount;
          product.addressId = defaultAddress?.id;
          product.searchKeywords = searchKeyword.split(", ");

          // product.variant = [];

          // the api call will first create the product then use the id from the
          // response to save the variant

          await _auth
              .addProduct(product, widget.arguments['channelUsername'] ?? "",
                  productAddOnsList)
              .then((value) async {
            final productId = value[1];

            if (productVariantList.isEmpty) {
              Navigator.pop(context);
              showToast(
                  message:
                      AppLocalization.of(context)!.productAddedSuccessfully);

              Navigator.pushNamed(context, Routes.PRODUCT,
                  arguments: {"productId": productId});
            } else {
              //loop and add all variant
              addVariants(productId);
              // for(var variantItem in productVariantList){
              //   await _auth.addVariant(variantItem, productId).then((value) {
              //     // backValue = true;
              //
              //   }).catchError((error) {
              //     debugPrint(error.toString());
              //     debugPrint("Product check variant::: ${error.toString()}");
              //     // showToast(message: error.toString());
              //   });
              // }
            }
          }).catchError((error) {
            debugPrint("Product check::: ${error.toString()}");
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  Future<void> addVariants(String productId) async {
    for (var variantItem in productVariantList) {
      // Make the API call for the current product variant
      await makeApiCallAddVariant(variantItem, productId);
    }

    // This will be executed after all API calls are completed
    debugPrint("All API calls are done!");
    Navigator.pop(context);
    showToast(message: AppLocalization.of(context)!.productAddedSuccessfully);

    Navigator.pushNamed(context, Routes.PRODUCT,
        arguments: {"productId": productId});
  }

  Future<void> makeApiCallAddVariant(
      Variant variantItem, String productId) async {
    await _auth.addVariant(variantItem, productId).then((value) {
      // backValue = true;
    }).catchError((error) {
      debugPrint(error.toString());
      debugPrint("Product check variant::: ${error.toString()}");
      // showToast(message: error.toString());
    });
  }

  bool validateDropdown() {
    if (selectedProductCategory != null && selectedProductCondition != null) {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectProductCategoryAndCondition);
      return false;
    }
  }

  void removeQuillFocus() {
    _focusNodeDescription.unfocus();
  }

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Is product available now?",
    );
  }

  Widget getTrackInventoryField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventory = !trackInventory;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: trackInventory,
      title:
          "Checking this field will automatically update the quantity when the product is purchased.",
      fontSize: 12.0,
      maxLines: 2,
    );
  }

  Widget getEnableInSuperStoreField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productEnableInSuperStore = !productEnableInSuperStore;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: productEnableInSuperStore,
      title: AppLocalization.of(context)!.enableInSuperStore,
    );
  }

  Widget getMeasurementField() {
    return CustomizedCheckBoxField(
      onTap: () {
        measurementView = !measurementView;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: measurementView,
      title: AppLocalization.of(context)!.measurement,
    );
  }

  Widget getDiscountField() {
    return CustomizedCheckBoxField(
      onTap: () {
        isDiscountAvailable = !isDiscountAvailable;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: isDiscountAvailable,
      title: AppLocalization.of(context)!.discount,
    );
  }

  Widget getTrackInventoryViewField() {
    return CustomizedCheckBoxField(
      onTap: () {
        trackInventory = !trackInventory;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: trackInventory,
      title: AppLocalization.of(context)!.trackInventoryView,
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
          productAvailableFrom = DateTime(value!.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Available from",
        child: ListTile(
          dense: true,
          title: Text(
            formatDate(productAvailableFrom),
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

  Widget getInventoryFormField() {
    return CustomizedDropDownField(
      title: "Inventory (Available Quantity)",
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
    // return CustomizedTextFormField(
    //   labelText: "Inventory (Available Quantity)",
    //   keyboardType: Platform.isIOS
    //       ? const TextInputType.numberWithOptions(decimal: false)
    //       : TextInputType.number,
    //   onChanged: (val) {
    //     if (val.isNotEmpty) {
    //       try {
    //         inventoryCount = int.parse(val);
    //       } catch (e) {
    //         showToast(message: e.toString());
    //       }
    //     }
    //   },
    //   validator: (val) {
    //     if (val.isNotEmpty) {
    //       try {
    //         val;
    //         return null;
    //       } catch (e) {
    //         return AppLocalization.of(context)!.invalidCount;
    //       }
    //     }
    //     return AppLocalization.of(context)!.pleaseEnterValidCount;
    //   },
    // );
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

  // Widget getAddVariationFormField() {
  //   return GestureDetector(
  //     onTap: () async {
  //       final result = await Navigator.of(context)
  //           .pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
  //         'option': 'new',
  //         'productId': '',
  //       });
  //
  //       // Handle the result (map) received from Product Add New Option
  //       if (result != null && result is Variant) {
  //         //save the variant details for later use
  //         productVariantList.add(result);
  //         if (mounted) setState(() {});
  //       }
  //     },
  //     child: CustomizedDropDownField(
  //       title: "Option",
  //       child: ListTile(
  //         dense: true,
  //         title: Center(
  //           child: Padding(
  //             padding: const EdgeInsets.only(top: 15.0),
  //             child: Text(
  //               'Add different variation like colour & size',
  //               style: TextStyle(
  //                 color: blackFont,
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 16,
  //                 fontFamily: "Inter",
  //               ),
  //             ),
  //           ),
  //         ),
  //         subtitle: Container(
  //           padding: const EdgeInsets.only(
  //               left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
  //           margin: const EdgeInsets.only(
  //               left: 10.0, top: 15.0, bottom: 15.0, right: 10.0),
  //           decoration: BoxDecoration(
  //               border: Border.all(
  //                 color: navyBlue,
  //               ),
  //               borderRadius: const BorderRadius.all(Radius.circular(10))),
  //           child: Center(
  //             child: Text(
  //               'Create Variant',
  //               style: TextStyle(
  //                 color: navyBlue,
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 16,
  //                 fontFamily: "Inter",
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                final result = await Navigator.of(context)
                    .pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
                  'option': 'new',
                  'productId': '',
                });

                // Handle the result (map) received from Product Add New Option
                if (result != null && result is Variant) {
                  //save the variant details for later use
                  productVariantList.add(result);
                  if (mounted) setState(() {});
                }
              },
              child: Text(
                'Add more',
                maxLines: 1,
                style: TextStyle(
                    color: navyBlue,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ListView.builder(
          padding: EdgeInsets.zero,
          // Use `physics` property to prevent nested scrolling
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              productVariantList.length >= 2 ? 2 : productVariantList.length,
          itemBuilder: (BuildContext context, int index) {
            return FormVariantsTile(
                productVariantList: productVariantList,
                index: index,
                type: 'add');
          },
        ),
      ],
    );
  }

  Widget getCategoryMeasurementField() {
    return CustomizedDropDownField(
      title: 'This will help user get recommended delivery options',
      fontSize: 12,
      titleColor: blackFont,
      fontWeight: FontWeight.w400,
      child: ListTile(
        dense: true,
        title: Text(
          pickedMeasurementList.isNotEmpty
              ? pickedMeasurementList.join(', ')
              : '',
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
          measurementAndroidSheet();
        },
      ),
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
                  child: discountList.isNotEmpty
                      ? ListView.builder(
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
                                      fontWeight: FontWeight.w600,
                                    ),
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
                        )
                      : const Text("No Found Discount Data"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void measurementAndroidSheet() {
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

  Widget productVariation() {
    return GestureDetector(
      onTap: () async {
        //disable click if add-on is not empty
        if (productAddOnsList.isNotEmpty) {
          return;
        }
        final result = await Navigator.of(context)
            .pushNamed(Routes.PRODUCT_NEW_OPTION, arguments: {
          'option': 'new',
          'productId': '',
        });

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

  Widget address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
          Text(
            !isEmpty && defaultAddress != null
                ? 'Dispatch Address'
                : "Add a dispatch Address",
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

  Widget productAddOns() {
    return GestureDetector(
      onTap: () async {
        //disable click if variant is not empty
        // if (productVariantList.isNotEmpty) {
        //   return;
        // }
        //
        // final result = await Navigator.of(context)
        //     .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
        //   'productId': '',
        //   'isForCheckboxSelection': true,
        // });
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
                  color: darkGrey, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context)
                    .pushNamed(Routes.PRODUCT_ADD_ON_LIST, arguments: {
                  'productId': '',
                  'isForCheckboxSelection': true,
                });

                // Handle the result (map) received from PRODUCT_ADD_ON_LIST
                if (result != null && result is List<AddOns>) {
                  //save the add-on details
                  productAddOnsList = result;
                  if (mounted) setState(() {});
                }
              },
              child: Text(
                'Add more',
                maxLines: 1,
                style: TextStyle(
                    color: navyBlue, fontWeight: FontWeight.w400, fontSize: 14),
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

  Widget dispatchAddress() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add a dispatch Address',
            maxLines: 1,
            style: TextStyle(
                color: productVariantList.isEmpty ? navyBlue : greyBorderColor,
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

  @override
  void dispose() {
    _scrollController.dispose();
    _myController.dispose();
    inventoryController.dispose();
    userTags = [];
    _quillController.dispose();
    _focusNodeDescription.dispose();
    super.dispose();
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
}
