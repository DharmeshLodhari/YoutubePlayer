import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/screens/currency/add_edit_currency.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/validation.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/customized_textform_field_for_foreign_currency.dart';
import 'package:Slydo/widget/delete_product_and_service_confirm_alert.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEditService extends StatefulWidget {
  final dynamic arguments;

  const AddEditService({super.key, this.arguments});

  @override
  State<AddEditService> createState() => _AddEditServiceState();
}

class _AddEditServiceState extends State<AddEditService> {
  final _auth = ShoppingAuthService();
  UserBloc? userBloc;
  final _formKey = GlobalKey<FormState>();

  bool isEdit = false;
  String? serviceId;
  Service currentService = Service();

  int imageCount = 5;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> serviceLocalImages = [];
  List<String?> serviceImagesFromServer = [];
  String? serviceName = "";
  // String? serviceDescription = "";
  String? serviceCategory = "";
  String? serviceShortDescription = "";
  String? searchKeyword = "";
  String? servicePrice = "";
  String foreignPrice = "";
  ServiceCategory? selectedServiceCategory;
  bool? serviceIsAvailable = false;
  DateTime? serviceAvailableFrom = DateTime.now();
  ServiceCategory? pressedCategory;

  // //text editing controllers for the edit fields
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescriptionController = TextEditingController();
  TextEditingController serviceShortDescriptionController =
      TextEditingController();
  TextEditingController servicePriceController = TextEditingController();
  TextEditingController searchKeywordController = TextEditingController();
  TextEditingController foreignController = TextEditingController();
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
  bool currencyView = false;
  String? selectedCurrency;
  String? selectedCurrencyId;
  int? selectedCurrencyRate;
  String? pressedCurrency;
  ForeignPrice? foreignPriceModel;

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

    if (serviceId != null) {
      isEdit = true;
    }
    getCurrencyList();
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
    if ((currencyList?.isNotEmpty ?? false)) {
      if (selectedCurrency == null || (selectedCurrency?.isEmpty ?? false)) {
        selectedCurrency = currencyList?[0].currency;
        selectedCurrencyId = currencyList?[0].id;
        selectedCurrencyRate = currencyList?[0].rate;
      }
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

    if (isEdit) {
      await fetchService();
    }

    isLoading = false;
    if (mounted) setState(() {});
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

            if (isEdit && discountId != null) {
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

  Future<void> fetchService() async {
    // assigning the dropdown
    serviceCategories?.forEach((catagory) {
      if (catagory.name == currentService.category) {
        selectedServiceCategory = catagory;
      }
    });

    //fetchProductFrom id to edit
    await _auth.getService(serviceId!).then((value) async {
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

      if (currentService.foreignPrice != null) {
        currencyView = true;
        foreignController.text =
            moneyNormalizer(currentService.foreignPrice?.price ?? 0);
        selectedCurrencyId = currentService.foreignPrice?.userCurrencyRate;

        final CurrencyModel result =
            await UserAuth().fetchCurrency(selectedCurrencyId ?? "");
        selectedCurrency = result.currency;
        selectedCurrencyRate = result.rate;
      }

      // serviceDescription = currentService.description;
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
        if (isEdit) {
          return await getExitDialog(context);
        } else {
          return true;
        }
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
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () async {
          if (isEdit) {
            await getExitDialog(context);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        isEdit
            ? AppLocalization.of(context)!.editService
            : AppLocalization.of(context)!.addService,
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
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            if (isEdit) editImages() else addLocalImages(),
                            const SizedBox(height: 10),
                            addTitleField(),
                            const SizedBox(height: 10),
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
              ? showImage(index)
              : serviceLocalImages.length != imageCount
                  ? addImageButton()
                  : null,
        ),
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

          serviceLocalImages.add(PickedFile(croppedImage));
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
              setState(() {
                serviceLocalImages.removeAt(index);
              });
            },
          ),
        )
      ],
    );
  }

  Widget editImages() {
    return Column(
      children: [
        if (serviceImagesFromServer.isNotEmpty)
          checkImageLimitForServerImage() ? viewServerImages() : Container(),
        if (checkImageLimitForServerImage())
          const SizedBox(height: 8)
        else
          Container(),
        if (checkImageLimitForLocalImage()) addLocalImages() else Container(),
      ],
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

  Widget getAmountField() {
    return CustomizedTextFormField(
      controller: servicePriceController,
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
            servicePriceController.text = servicePrice!;
          } catch (e) {
            showToast(message: e.toString());
          }
        } else {
          servicePriceController.clear();
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
                                  servicePriceController.clear();
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
                              servicePriceController.clear();
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

  Widget getSubmitButton() {
    return Row(
      children: <Widget>[
        if (isEdit)
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
        if (isEdit) const SizedBox(width: 8),
        Expanded(
          child: CurvedButton(
            textColor: Colors.white,
            text: isEdit ? AppLocalization.of(context)!.update : "Add service",
            backgroundColor: navyBlue,
            onPressed: isAPILoading
                ? () {}
                : () async {
                    FocusScope.of(context).unfocus();
                    isAPILoading = true;
                    if (mounted) setState(() {});

                    await addEditService();

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

  Future<void> addEditService() async {
    if (_formKey.currentState!.validate()) {
      if (serviceLocalImages.isNotEmpty || serviceImagesFromServer.isNotEmpty) {
        if (validateDropdown()) {
          // setting updated value
          currentService.name = serviceName;
          // currentService.description = serviceDescription;
          currentService.description =
              jsonEncode(_quillController.document.toDelta().toJson());
          currentService.localImages =
              serviceLocalImages.map((file) => File(file.path)).toList();
          currentService.serverImages = serviceImagesFromServer;
          currentService.category = messageDecoderWithEmoji(serviceCategory);
          currentService.shortDescription = serviceShortDescription;
          currentService.price = moneyInputNormalizer(servicePrice!).toString();
          if (currencyView) {
            foreignPriceModel ??= ForeignPrice();
            foreignPriceModel?.price = moneyInputNormalizer(foreignPrice);
            foreignPriceModel?.userCurrencyRate = selectedCurrencyId;

            currentService.foreignPrice = foreignPriceModel;
          }
          currentService.isAvailable = serviceIsAvailable;
          currentService.availableFrom = serviceAvailableFrom;
          if (isDiscountAvailable) {
            currentService.discountId = selectedDiscount?.id;
          } else {
            currentService.discountId = "";
          }
          currentService.searchKeywords =
              commaSeparatedStringToList(searchKeyword ?? "");

          if (isEdit) {
            await _auth.editService(currentService).then((value) {
              showToast(
                message: AppLocalization.of(context)!.serviceEditedSuccessfully,
              );
              Navigator.pop(context, "update_item");
            }).catchError((error) {
              showToast(message: error.toString());
            });
          } else {
            await _auth.addService(currentService).then((value) {
              Navigator.pop(context);
              showToast(
                  message:
                      AppLocalization.of(context)!.serviceAddedSuccessfully);
            }).catchError((error) {
              showToast(message: error.toString());
            });
          }
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
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
        await addEditService();
      },
    );
  }

  bool validateDropdown() {
    if (selectedServiceCategory != null) {
      return true;
    } else {
      showToast(message: AppLocalization.of(context)!.selectCategory);
      return false;
    }
  }

  void removeQuillFocus() {
    _focusNodeDescription.unfocus();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
