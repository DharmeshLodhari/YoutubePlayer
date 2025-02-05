import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/screens/currency/add_edit_currency.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/customized_textform_field_for_foreign_currency.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../shopping_auth.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;
  ServiceCategory? pressedCategory;
  ServiceCategory? selectedServiceCategory;
  ProductCondition? selectedProductCondition;

  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> serviceImages = [];
  String serviceName = "";
  String serviceShortDescription = "";
  String serviceDescription = "";
  String serviceCategory = "";
  String serviceCondition = "";
  String servicePrice = "";
  String foreignPrice = "";
  String searchKeyword = "";
  bool serviceIsAvailable = false;
  DateTime serviceAvailableFrom = DateTime.now();
  List<ServiceCategory>? serviceCategories;
  List<ServiceCategory>?
      serviceCategoriesCopy; //To hold the full service category at all times.

  bool isLoading = false;
  bool isAPILoading = false;

  List<CurrencyModel>? currencyList;
  List<CurrencyModel>? currencyListCopy;
  int? currencyItemCount = 0;
  String? currencyNext = "";
  String? currencyPrevious = "";
  final TextEditingController amountController = TextEditingController();
  final TextEditingController foreignController = TextEditingController();
  String? selectedCurrency;
  String? selectedCurrencyId;
  int? selectedCurrencyRate;
  String? pressedCurrency;
  ForeignPrice? foreignPriceModel;
  bool currencyView = false;

  bool isDiscountAvailable = false;
  bool isDiscountLoading = false;
  int? discountItemCount = 0;
  String? discountNext = "";
  String? discountPrevious = "";
  List<DiscountModel> discountList = [];
  List<DiscountModel> discountListCopy = [];
  bool noItemInList = false;
  DiscountModel? pressedDiscount;
  DiscountModel? selectedDiscount;
  String discountName = "";
  bool _isKeyboardVisible = false;
  bool _isServiceDescriptionVisible = false;
  double? bottomInset;
  final FocusNode _focusNodeDescription = FocusNode();
  final QuillController _quillController = QuillController.basic();
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
    getCurrencyList();
    getCategories();
    getDiscountList();
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

  Future<void> getCurrencyList() async {
    final Map<String, dynamic> result =
        await UserAuth().getCurrency(currencyNext, currencyPrevious);
    if (result == null) {
      isLoading = false;
      noItemInList = true;
      return;
    }

    currencyList = [];
    currencyItemCount = result['count'];
    currencyNext = result['next'];
    currencyPrevious = result['previous'];
    final tempList = result['results'];

    currencyList?.addAll(tempList);
    currencyListCopy = currencyList;
    if (currencyList?.isNotEmpty ?? false) {
      selectedCurrency = currencyList?[0].currency;
      selectedCurrencyId = currencyList?[0].id;
      selectedCurrencyRate = currencyList?[0].rate;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        noItemInList = false;
      });
    }

    if (currencyList?.isEmpty ?? false) {
      if (mounted) {
        setState(() {
          noItemInList = true;
          currencyList = [];
          currencyListCopy = [];
        });
      }
    } else if (currencyNext == null && currencyList!.length > 6) {
      _messengerScaffoldKey.currentState?.showSnackBar(SnackBar(
        content:
            Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        duration: const Duration(milliseconds: 500),
      ));
    }
  }

  void getCategories() async {
    isLoading = true;
    if (mounted) setState(() {});

    try {
      serviceCategories = await ShoppingAuthService().getServiceCategories();
      serviceCategoriesCopy = serviceCategories;
    } catch (e) {
      serviceCategories = [];
      serviceCategoriesCopy = [];
    }

    isLoading = false;
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = (bottomInset ?? 0) > 0;
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
    //
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        "Add service",
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
                            addImages(),
                            const SizedBox(
                              height: 10,
                            ),
                            addTitleField(),
                            const SizedBox(
                              height: 10,
                            ),
                            getAmountField(),
                            const SizedBox(height: 10),
                            getForeignCurrencyFieldAndInfo(),
                            if (currencyView) ...[
                              const SizedBox(height: 10),
                              getForeignCurrencyPriceField(),
                              const SizedBox(height: 5),
                              addNewCurrencyRate(),
                            ],
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

  Widget addImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: serviceImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index != serviceImages.length
              ? showImage(index)
              : serviceImages.length != imageCount
                  ? addImageButton()
                  : null,
        ),
      ),
    );
  }

  Widget addNewCurrencyRate() {
    return GestureDetector(
      onTap: () async {
        final result = await NavigationUtil.push(
          context,
          screen: AddEditCurrency(
            currencyList: currencyList,
          ),
        );
        if (result != null && result == true) {
          await getCurrencyList();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Currency Rate',
            style: TextStyle(
              fontSize: 12,
              color: navyBlue,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
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

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 0,
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

          serviceImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
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
                    File(serviceImages[index].path),
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
                serviceImages.removeAt(index);
              });
            },
          ),
        )
      ],
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: "Service name",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterServiceName;
      },
      onTap: () async {},
      onChanged: (val) {
        serviceName = val;
      },
    );
  }

  Widget getServiceShortDescription() {
    return CustomizedTextFormField(
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onTap: () async {},
      onChanged: (val) {
        serviceShortDescription = val;
      },
    );
  }

  Widget getSearchEngineKeyword() {
    return Column(
      children: [
        CustomizedTextFormField(
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
  //     textCapitalization: TextCapitalization.sentences,
  //     labelText: AppLocalization.of(context)!.description,
  //     onChanged: (val) {
  //       serviceDescription = val;
  //     },
  //     validator: (val) {
  //       if (val.isNotEmpty) {
  //         return null;
  //       }
  //       return AppLocalization.of(context)!.descriptionMustNotEmpty;
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
            borderRadius: BorderRadius.circular(5),
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

  Widget getForeignCurrencyField() {
    return CustomizedCheckBoxField(
      onTap: () {
        currencyView = !currencyView;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: currencyView,
      title: AppLocalization.of(context)!.setPriceWithForeignCurrency,
    );
  }

  Widget getForeignCurrencyPriceField() {
    return CustomizedTextFormFieldForForeignCurrency(
      labelText: AppLocalization.of(context)!.priceForeignCurrency,
      controller: foreignController,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      selectedCurrencySymbol:
          selectedCurrency != null ? worldCurrencies[selectedCurrency] : "-",
      onTapCurrency: () {
        currencyAndroidSheet();
      },
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            foreignPrice = double.parse(val.replaceAll(',', '')).toString();

            final price = getForeignPrice(double.parse(val.replaceAll(',', '')),
                    selectedCurrencyRate) ??
                "";
            servicePrice = price.replaceAll(',', '');
            amountController.text = servicePrice;
          } catch (e) {
            showToast(message: e.toString());
          }
        } else {
          amountController.clear();
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
          // selectItemCategory();
          categoryAndroidSheet();
        },
      ),
    );
  }

  void currencyAndroidSheet() {
    currencyList = currencyListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                CustomizedTextFormField(
                  hintText: 'Search currency',
                  onChanged: (value) {
                    if (value.toString().isNotEmpty) {
                      currencyList = currencyListCopy!
                          .where((element) =>
                              element.currency?.startsWith(value.toString()) ??
                              false)
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      currencyList = currencyListCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (currencyList?.isNotEmpty ?? false)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currencyList?.length,
                      itemBuilder: (context, index) {
                        final String currency =
                            currencyList?[index].currency ?? "-";
                        if (selectedCurrency == currency) {
                          return Container(
                            color: selectedListItemBackgroundBlue,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                currencyNameAndSymbol(currency),
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
                                Navigator.pop(context);
                                pressedCurrency = currency;
                                if (pressedCurrency != null) {
                                  amountController.clear();
                                  foreignController.clear();
                                  servicePrice = "";
                                  foreignPrice = "";
                                  selectedCurrency = pressedCurrency;
                                  selectedCurrencyId = currencyList?[index].id;
                                  selectedCurrencyRate =
                                      currencyList?[index].rate;
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        }
                        return ListTile(
                          title: Text(
                            currencyNameAndSymbol(currency),
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
                            Navigator.pop(context);
                            pressedCurrency = currency;
                            if (pressedCurrency != null) {
                              amountController.clear();
                              foreignController.clear();
                              servicePrice = "";
                              foreignPrice = "";
                              selectedCurrency = pressedCurrency;
                              selectedCurrencyId = currencyList?[index].id;
                              selectedCurrencyRate = currencyList?[index].rate;
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: NoItemInList(
                      msg: 'No Rate Found',
                      isButtonShow: true,
                      buttonTitle: 'Add New Currency Rate',
                      onTap: () async {
                        Navigator.of(context).pop();
                        final result = await NavigationUtil.push(
                          context,
                          screen: AddEditCurrency(
                            currencyList: currencyList,
                          ),
                        );
                        if (result != null && result == true) {
                          await getCurrencyList();
                        }
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

  void categoryAndroidSheet() {
    serviceCategories = serviceCategoriesCopy;
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
                      serviceCategories = serviceCategoriesCopy!
                          .where((element) => element.name
                              .toLowerCase()
                              .startsWith(value.toString().toLowerCase()))
                          .toList();
                      changeState(
                          () {}); // To upgrade the product categories in the bottom sheet.
                    } else {
                      serviceCategories = serviceCategoriesCopy;
                      changeState(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: serviceCategories!.length,
                    itemBuilder: (context, index) {
                      final ServiceCategory category =
                          serviceCategories![index];
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
                              pressedCategory = category;
                              Navigator.pop(context);
                              if (serviceCategories != null) {
                                selectedServiceCategory = pressedCategory;
                                serviceCategory = selectedServiceCategory!.name;
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
                            selectedServiceCategory = pressedCategory;
                            serviceCategory = selectedServiceCategory!.name;
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
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    Navigator.pop(context, category);
                                  },
                                );
                              }).toList() ??
                              []),
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
      controller: amountController,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      isReadOnly: currencyView ? true : false,
      labelText: AppLocalization.of(context)!.priceLocalCurrency,
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
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addService();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Add service",
      isLoading: isAPILoading,
    );
  }

  Future<void> addService() async {
    if (_formKey.currentState!.validate()) {
      if (serviceImages.isNotEmpty) {
        if (validateDropdown()) {
          final Service service = Service();
          service.localImages =
              serviceImages.map((file) => File(file.path)).toList();
          service.name = serviceName;
          service.shortDescription = serviceShortDescription;
          service.description =
              jsonEncode(_quillController.document.toDelta().toJson());
          // service.description = serviceDescription;
          service.category = serviceCategory;
          service.price = moneyInputNormalizer(servicePrice).toString();
          service.availableFrom = serviceAvailableFrom;
          service.isAvailable = serviceIsAvailable;
          if (isDiscountAvailable) {
            service.discountId = selectedDiscount?.id;
          } else {
            service.discountId = "";
          }
          service.searchKeywords = searchKeyword.split(", ");

          await _auth.addService(service).then((value) {
            Navigator.pop(context);
            showToast(
                message: AppLocalization.of(context)!.serviceAddedSuccessfully);
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
        serviceIsAvailable = !serviceIsAvailable;
        removeQuillFocus();
        setState(() {});
      },
      isChecked: serviceIsAvailable,
      title: "Available",
    );
  }

  Widget getForeignCurrencyFieldAndInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: getForeignCurrencyField(),
        ),
        getCurrencyInfo(),
      ],
    );
  }

  Widget getCurrencyInfo() {
    return GestureDetector(
      onTap: () async {
        await showInfoDialog(
          context: context,
          title: 'Why set currency rate ?',
          description:
              'Setting a currency rate allows you to offer products in different currencies while ensuring accurate and up-to-date pricing.',
        );
      },
      child: Icon(
        Icons.info_outline_rounded,
        color: blackFont,
        size: 20,
      ),
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
            formatDate(serviceAvailableFrom),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
