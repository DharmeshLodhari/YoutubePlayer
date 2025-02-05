import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/screens/currency/add_edit_currency.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/customized_textform_field_for_foreign_currency.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../shopping_auth.dart';

class ProductAddOnOptionUpdate extends StatefulWidget {
  final dynamic arguments;

  const ProductAddOnOptionUpdate({this.arguments, super.key});

  @override
  State<ProductAddOnOptionUpdate> createState() =>
      _ProductAddOnOptionUpdateState();
}

class _ProductAddOnOptionUpdateState extends State<ProductAddOnOptionUpdate> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  UserBloc? userBloc;
  int imageCount = 1;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> productImages = [];
  List<String?> productImagesFromServer = [];
  String price = "";
  String foreignPrice = "";
  bool productIsAvailable = false;
  bool isLoading = false;
  bool isAPILoading = false;
  String name = "";
  String value = "";
  int id = 0;
  String description = "";
  String picture = "";
  Variant? variant;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController comparePriceController = TextEditingController();
  final TextEditingController isAvailableController = TextEditingController();
  final TextEditingController foreignController = TextEditingController();

  List<CurrencyModel>? currencyList;
  List<CurrencyModel>? currencyListCopy;
  int? currencyItemCount = 0;
  String? currencyNext = "";
  String? currencyPrevious = "";
  bool noItemInList = false;
  bool currencyView = false;
  String? selectedCurrency;
  String? selectedCurrencyId;
  int? selectedCurrencyRate;
  String? pressedCurrency;
  ForeignPrice? foreignPriceModel;
  AddOnOption addOnOption = AddOnOption();

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    addOnOption = widget.arguments["addOnOption"];

    // debugPrint('Fola varaint::: ${variant!.toJson()}');

    id = addOnOption.id!;
    nameController.text = addOnOption.name!.toString();
    descriptionController.text = addOnOption.description!.toString();
    priceController.text =
        moneyNormalizer(int.parse(addOnOption.price!)).toString();
    productIsAvailable = addOnOption.isAvailable!;

    picture = addOnOption.picture!;
    name = addOnOption.name!.toString();
    description = addOnOption.description!.toString();
    price = moneyNormalizer(int.parse(addOnOption.price!)).toString();

    getCurrencyList();

    if (addOnOption.foreignPrice != null) {
      currencyView = true;
      foreignController.text =
          moneyNormalizer(addOnOption.foreignPrice?.price ?? 0);
      selectedCurrencyId = addOnOption.foreignPrice?.userCurrencyRate;

      getCurrencyData();
    }

    super.initState();
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
    if ((currencyList?.isNotEmpty ?? false) &&
        (selectedCurrency?.isEmpty ?? false)) {
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

  void getCurrencyData() async {
    final CurrencyModel result =
        await UserAuth().fetchCurrency(selectedCurrencyId ?? "");
    selectedCurrency = result.currency;
    selectedCurrencyRate = result.rate;
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
      titleSpacing: 20,
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
        AppLocalization.of(context)!.updateOption,
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
                      if (picture.isNotEmpty)
                        showServerImage()
                      else
                        Container(),
                      if (picture.isEmpty) ...[
                        const SizedBox(height: 10),
                        addImages(),
                      ],
                      const SizedBox(height: 10),
                      addTitleField(),
                      const SizedBox(height: 10),
                      getDescription(),
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
                      const SizedBox(height: 40),
                      getIsAvailableField(),
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

          productImages.add(PickedFile(croppedImage));
          addOnOption.picture = croppedImage;
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
                  addOnOption.picture = "";
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget showServerImage() {
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
                        picture,
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
                picture = "";
                if (mounted) setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.title,
      controller: nameController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterTitle;
      },
      onChanged: (val) {
        name = val;
      },
    );
  }

  Widget getDescription() {
    return CustomizedTextFormField(
      maxLines: 3,
      labelText: "Description",
      textCapitalization: TextCapitalization.sentences,
      controller: descriptionController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.descriptionMustNotEmpty;
      },
      onChanged: (val) {
        description = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      isReadOnly: currencyView ? true : false,
      labelText: AppLocalization.of(context)!.priceLocalCurrency,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      controller: priceController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            price = double.parse(val.replaceAll(',', '')).toString();
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

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable;
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Available",
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

              await updateAddOnOption();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update",
      isLoading: isAPILoading,
    );
  }

  Widget getForeignCurrencyField() {
    return CustomizedCheckBoxField(
      onTap: () {
        currencyView = !currencyView;
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

            final amount = getForeignPrice(
                    double.parse(val.replaceAll(',', '')),
                    selectedCurrencyRate) ??
                "";
            price = amount.replaceAll(',', '');
            priceController.text = price;
          } catch (e) {
            showToast(message: e.toString());
          }
        } else {
          priceController.clear();
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
                                  priceController.clear();
                                  foreignController.clear();
                                  price = "";
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
                              priceController.clear();
                              foreignController.clear();
                              price = "";
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

  Future<void> updateAddOnOption() async {
    if (_formKey.currentState!.validate()) {
      if (productImages.isNotEmpty || picture.isNotEmpty) {
        addOnOption.name = name;
        addOnOption.description = description;
        addOnOption.price = moneyInputNormalizer(price).toString();
        addOnOption.isAvailable = productIsAvailable;
        addOnOption.picture =
            picture.isNotEmpty ? picture : addOnOption.picture;
        if (currencyView) {
          foreignPriceModel ??= ForeignPrice();
          foreignPriceModel?.price = moneyInputNormalizer(foreignPrice);
          foreignPriceModel?.userCurrencyRate = selectedCurrencyId;

          addOnOption.foreignPrice = foreignPriceModel;
        }

        await _auth
            .updateAddOnOption(addOnOption, widget.arguments["productId"])
            .then((value) async {
          Navigator.pop(context, value);
        }).catchError((error) {
          debugPrint("ERROR While createAddOnOption :- $error");
          isAPILoading = false;
          if (mounted) setState(() {});
          showToast(message: "$error");
        });
      } else {
        isAPILoading = false;
        if (mounted) setState(() {});
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
