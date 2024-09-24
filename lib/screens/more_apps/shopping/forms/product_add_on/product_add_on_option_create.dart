import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/utils.dart';
import 'package:Slydo/screens/user_profile/models/currency_model.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/customized_textform_field_for_foreign_currency.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../shopping_auth.dart';

class ProductAddOnOptionCreate extends StatefulWidget {
  final dynamic arguments;

  const ProductAddOnOptionCreate({this.arguments, super.key});

  @override
  State<ProductAddOnOptionCreate> createState() =>
      _ProductAddOnOptionCreateState();
}

class _ProductAddOnOptionCreateState extends State<ProductAddOnOptionCreate> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _messengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  UserBloc? userBloc;

  int imageCount = 1;
  final ScrollController _scrollController = ScrollController();
  List<PickedFile> productImages = [];
  List<String> croppedImageList = [];
  String price = "";
  String foreignPrice = "";
  bool isAvailable = false;
  bool isLoading = false;
  bool isAPILoading = false;
  String name = "";
  String description = "";
  // String optionOnWhatToDo = "";
  AddOnOption addOnOption = AddOnOption();

  List<CurrencyModel>? currencyList;
  int? currencyItemCount = 0;
  String? currencyNext = "";
  String? currencyPrevious = "";
  bool noItemInList = false;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController foreignController = TextEditingController();
  String? selectedCurrency;
  String? selectedCurrencyId;
  int? selectedCurrencyRate;
  String? pressedCurrency;
  ForeignPrice? foreignPriceModel;
  bool currencyView = false;

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    //get value if its form edit or add product
    // optionOnWhatToDo = widget.arguments["option"];
    getCurrencyList();
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
      centerTitle: false,
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
        AppLocalization.of(context)!.option,
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
                      const SizedBox(height: 10),
                      addImages(),
                      const SizedBox(height: 10),
                      addTitleField(),
                      const SizedBox(height: 10),
                      getDescription(),
                      const SizedBox(
                        height: 10,
                      ),
                      getAmountField(),
                      const SizedBox(height: 10),
                      getForeignCurrencyField(),
                      if (currencyView) ...[
                        const SizedBox(height: 10),
                        getForeignCurrencyPriceField(),
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
          // croppedImageList.add(croppedImage);
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
      hasLabel: false,
      controller: foreignController,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      selectedCurrencySymbol:
          selectedCurrency != null ? worldCurrencies[selectedCurrency] : "",
      onTapCurrency: () {
        selectCurrency();
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
            amountController.text = price;
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

  void selectCurrency() async {
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  children: currencyList!.map((CurrencyModel model) {
                    if (selectedCurrency == model.currency) {
                      return Container(
                        color: selectedListItemBackgroundBlue,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            currencyNameAndSymbol(model.currency),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: navyBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            SlydoAppIcon.checked,
                            color: navyBlue,
                            size: 12,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            pressedCurrency = model.currency;
                            if (pressedCurrency != null) {
                              amountController.clear();
                              foreignController.clear();
                              price = "";
                              foreignPrice = "";
                              selectedCurrency = pressedCurrency;
                              selectedCurrencyId = model.id;
                              selectedCurrencyRate = model.rate;
                              setState(() {});
                            }
                          },
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(
                        currencyNameAndSymbol(model.currency),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontFamily: "Inter",
                            color: blackFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context);
                        pressedCurrency = model.currency;
                        if (pressedCurrency != null) {
                          amountController.clear();
                          foreignController.clear();
                          price = "";
                          foreignPrice = "";
                          selectedCurrency = pressedCurrency;
                          selectedCurrencyId = model.id;
                          selectedCurrencyRate = model.rate;
                          setState(() {});
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.title,
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
      // controller: groupDescriptionController,
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
      controller: amountController,
      isReadOnly: currencyView ? true : false,
      labelText: AppLocalization.of(context)!.priceLocalCurrency,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
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
        isAvailable = !isAvailable;
        setState(() {});
      },
      isChecked: isAvailable,
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

              await createAddOnOption();
              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
      isLoading: isAPILoading,
    );
  }

  Future<void> createAddOnOption() async {
    if (_formKey.currentState!.validate()) {
      addOnOption.name = name;
      addOnOption.description = description;
      addOnOption.price = moneyInputNormalizer(price).toString();
      addOnOption.isAvailable = isAvailable;

      await _auth
          .createAddOnOption(addOnOption, widget.arguments["productId"])
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
