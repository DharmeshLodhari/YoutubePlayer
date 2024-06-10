import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/fee_structure.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_loading_screen.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/search_user.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/cached_video_player/cached_video_player.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SlydoSlydoTransfer extends StatefulWidget {
  final dynamic arguments;
  final Function(bool)? callback;

  SlydoSlydoTransfer({this.arguments, this.callback});

  // Declare a field that holds the userData.
  @override
  _SlydoSlydoTransferState createState() => _SlydoSlydoTransferState();
}

class _SlydoSlydoTransferState extends State<SlydoSlydoTransfer> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late TextEditingController _referenceController;
  final FocusNode _recipientFocus = FocusNode();
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  final _sendPaymentScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();
  CustomerProfile? _payee;
  late UserBloc userBloc;
  late CustomerProfileBloc customerProfileBloc;

  //for Product payment
  Product? product;

  //for Service payment
  Service? service;

  bool? isFromProfile = false;
  bool isFromChat = false;
  bool? isFromYarn = false;
  bool? isFromMoment = false;
  bool isValidPayee = false;
  double? amount = 0.0;
  String reference = "";
  String category = "";
  String errorMessage = "";
  String? recipient;
  final locationService = LocationService();

  String? conversationId;

  //variables for categories
  bool isLoading = true;
  bool isBalanceLoading = true;
  List<String?> paymentCategories = [];
  String? selectedCategory;
  late BasketBloc basketBloc;

  //variables for shopping cart
  int? itemIndex;

  bool sendMoneyAnonymous = false;

  bool showMoreOption = false;
  VirtualAccount? virtualAccount;
  late CachedVideoPlayerController controller;
  int? currentBalance = 0;
  bool isBalanceHidden = true;

  @override
  void initState() {
    final String? defaultReferenceText =
        widget.arguments['defaultReferenceText'];
    _referenceController = TextEditingController(text: defaultReferenceText);
    reference = _referenceController.text;

    isFromProfile = widget.arguments != null
        ? widget.arguments['isFromProfile'] ?? false
        : false;
    isFromChat = widget.arguments != null
        ? widget.arguments['isFromChat'] ?? false
        : false;
    isFromYarn = widget.arguments != null
        ? widget.arguments['isFromYarn'] ?? false
        : false;
    isFromMoment = widget.arguments != null
        ? widget.arguments['isFromMoment'] ?? false
        : false;
    conversationId =
        widget.arguments != null ? widget.arguments['conversationId'] : null;
    product = widget.arguments != null ? widget.arguments['product'] : null;
    service = widget.arguments != null ? widget.arguments['service'] : null;
    itemIndex = widget.arguments != null ? widget.arguments['itemIndex'] : null;

    if (product != null) {
      setAllFieldProduct();
    }
    if (service != null) {
      setAllFieldService();
    }
    _recipientFocus.addListener(() {
      if (!_recipientFocus.hasFocus) {
        if (mounted) {
          setState(() {
            _recipientController.text = _recipientController.text;
          });
        }
      }
    });
    getRecipientProfileAndGetCategory();
    getBankAccountDetail();
    super.initState();
  }

  void getRecipientProfileAndGetCategory() async {
    if (widget.arguments['recipient'] != null) {
      Provider.of<CustomerProfileBloc>(context, listen: false).customer =
          await UserAuth().fetchCustomerProfile(widget.arguments['recipient']);
      fetchCategory();
    } else {
      fetchCategory();
    }
  }

  void getBankAccountDetail() async {
    isBalanceLoading = true;
    setState(() {});
    await getAccountBalance();
    virtualAccount = await DatabaseHelper().getVirtualAccount();
    isBalanceLoading = false;
    setState(() {});
  }

  Future<void> getAccountBalance() async {
    await _auth.getAccountBalance().then((value) {
      final data = value!;
      final spendableBalance = data["spendable_balance"];
      if (mounted) {
        setState(() {
          currentBalance = spendableBalance;
        });
      }
    });
  }

  void setAllFieldProduct() {
    _amountController.text =
        moneyDisplayNormalizer(int.parse(product!.price.toString()))
            .replaceAll(",", "");

    amount = double.parse(_amountController.text.replaceAll(',', ''));
    _referenceController.text = product?.name ?? "";
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void setAllFieldService() {
    _amountController.text =
        moneyDisplayNormalizer(int.parse(service!.price.toString()));
    amount = double.parse(_amountController.text.replaceAll(',', ''));
    _referenceController.text = service!.name!;
    reference = _referenceController.text;
    selectedCategory = "Shopping";
    isValidPayee = true;
  }

  void initializeDisplayCard() {
    // if (!isFromProfile && product != null) {
    if (!isFromProfile!) {
      if (customerProfileBloc.customer != null) {
        if (mounted) {
          setState(() {
            _payee = customerProfileBloc.customer;
            recipient = _payee!.userName;
            if (recipient != null) {
              _recipientController.text = recipient!;
            } else {
              _recipientController.text = '';
            }
            UserAuth().fetchCustomerProfile(recipient).then((customerProfile) {
              if (customerProfile != null) {
                if (mounted) {
                  setState(() {
                    _payee = customerProfile;
                    isValidPayee = _payee!.userName != userBloc.user.userName;
                  });
                }
              }
            });
          });
        }
      }
    }
  }

  void fetchCategory() async {
    _auth.getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          final List categoriesList = result["results"]["data"];
          for (var data in categoriesList) {
            paymentCategories.add(data["name"]);
          }
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    return ScaffoldMessenger(
      key: _sendPaymentScaffoldMessenger,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _sendPaymentScaffold,
        resizeToAvoidBottomInset: true,
        body: scaffoldBody(),
      ),
    );
  }

  Widget userProfileIcon() {
    if (_payee != null || isValidPayee) {
      return RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          SlydoAppIcon.circle_user,
          size: 16,
          color: blackFont,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": _payee!.userName});
        },
        backgroundColor: iconBtnGrey,
        enableMargin: true,
      );
    }
    return const SizedBox(
      height: 10,
      width: 10,
    );
  }

  Widget scaffoldBody() {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTransferForm(),
                  _buildFormFields(),
                  _buildSendPayment(),
                ],
              ),
            ),
          );
  }

  Widget _buildTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Transfer From",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            shadowColor: iconBtnGrey,
            color: greyDarkBackground,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: iconBtnGrey, width: 1)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "@${userBloc.user.userName}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                        fontFamily: "Inter",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isBalanceLoading == true)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularLoadingIndicator(color: naturalGreen),
                          )
                        else
                          Row(
                            children: [
                              Text(
                                "Transferable Balance : ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: navyBlue,
                                  fontFamily: "Inter",
                                ),
                              ),
                              if (isBalanceHidden)
                                Container()
                              else
                                Text(
                                  worldCurrencies[userBloc.user.currency] ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: navyBlue,
                                    fontFamily: "Inter",
                                  ),
                                ),
                              Text(
                                isBalanceHidden
                                    ? generateAsteriskMask(
                                        moneyDisplayNormalizer(currentBalance))
                                    : moneyDisplayNormalizer(currentBalance),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: navyBlue,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        InkWell(
                          onTap: () {
                            toggleBalanceVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Icon(
                              isBalanceHidden
                                  ? SlydoAppIcon.eye
                                  : SlydoAppIcon.eye_close,
                              color: navyBlue,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  String generateAsteriskMask(String amount) {
    // Determine the length of the amount
    final int amountLength = amount.length;

    // Generate a string of asterisks of the same length as the amount
    final String asteriskMask = '*' * amountLength;

    // Trim the trailing space and return the asterisk mask
    return asteriskMask.trim();
  }

  void toggleBalanceVisibility() {
    if (isBalanceHidden) {
      if (userBloc.chatMessageSettings.accountBalanceVisibility == false) {
        BottomSheetPassCode(
          context: context,
          isValidCallback: () {
            getAccountBalance();
            isBalanceHidden = false;
            setState(() {});
          },
          cancelCallBack: () {
            Navigator.pop(context);
          },
        );
      } else {
        getAccountBalance();
        isBalanceHidden = false;
        setState(() {});
      }
    } else {
      isBalanceHidden = !isBalanceHidden;
      setState(() {});
    }
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: iconBtnGrey,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconBtnGrey, width: 1)),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              getDisplayCard(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    getRecipientField(),
                    const SizedBox(
                      height: 20,
                    ),
                    displayAmountField(),
                    const SizedBox(
                      height: 20,
                    ),
                    if (isFromYarn == true || isFromMoment == true) ...[
                      const SizedBox()
                    ] else ...[
                      if (showMoreOption) getMoreOption() else Container(),
                      getMoreOptionTrigger(),
                    ],
                    if (errorMessage == "")
                      Container()
                    else
                      Text(
                        errorMessage,
                        style: TextStyle(
                            color: mateRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    if (errorMessage == "")
                      Container()
                    else
                      const SizedBox(
                        height: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendPayment() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        if (amount == 0.0) ...[
          getSubmitButton()
        ] else ...[
          if (canDoSlydoTransfer(amount!, currentBalance?.toDouble() ?? 0))
            getSubmitButton()
          else
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text.rich(TextSpan(
                        text: AppLocalization.of(context)!.minimumTransfer,
                        style: TextStyle(
                            fontSize: 12,
                            color: blackFont,
                            fontWeight: FontWeight.w600),
                        children: <InlineSpan>[
                          TextSpan(
                            text: worldCurrencies[userBloc.user.currency!]! +
                                moneyDisplayNormalizer(availableTransfer()),
                            style: TextStyle(
                                fontSize: 12,
                                color: blackFont,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600),
                          )
                        ])))),
        ],

        // getSubmitButton(),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget getMoreOption() {
    return Column(
      children: [
        getCategoryDropDown(),
        const SizedBox(
          height: 20,
        ),
        getReferenceField(),
        const SizedBox(
          height: 20,
        ),
        if (isFromChat) Container() else sendMoneyAnonymouslySwitch(),
      ],
    );
  }

  Widget getMoreOptionTrigger() {
    return GestureDetector(
      onTap: () {
        showMoreOption = !showMoreOption;
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              showMoreOption
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: darkGrey,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              showMoreOption ? "less options" : "more options",
              style: TextStyle(
                  color: darkGrey, fontSize: 14, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  Widget getUserProfileIcon() {
    if (_payee != null || isValidPayee) {
      return IconButton(
        icon: const Icon(Icons.person),
        onPressed: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": _payee!.userName});
        },
      );
    }
    return const SizedBox(
      height: 1,
      width: 1,
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        _payee = null;
        Navigator.pop(context);
      },
    );
  }

  Widget getDisplayCard() {
    initializeDisplayCard();

    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      final Color borderColor = getUserTypeColor(user: _payee!);

      avatarImage = Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed("/photo-viewer", arguments: _payee!.avatar);
          },
          child: ClipOval(
            child: _payee!.avatar != null
                ? CachedNetworkImage(
                    imageUrl: _payee!.avatar!,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    errorWidget: imageErrorWidget,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      );
      setState(() {
        isValidPayee = true;
      });

      qrCodeImage = GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed("/photo-viewer", arguments: _payee!.qrCode);
        },
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: _payee!.qrCode ?? "",
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          errorWidget: imageErrorWidget,
        ),
      );
    }

    return _payee == null
        ? Container()
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: userNameWithVerifiedIcon(
                    name: _payee!.displayName() != null
                        ? _payee!.displayName()!
                        : '',
                    isVerified: _payee!.isVerified,
                    lengthToTruncateAt: 20,
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Text(
                    _payee!.userName != null ? _payee!.userName! : '',
                    style: TextStyle(fontSize: 14, color: darkGrey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  leading: checkImage(),
                  trailing: qrCodeImage,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUserName": _payee!.userName});
                  },
                ),
              ),
              Divider(
                color: dividerColor,
                height: 1,
                thickness: 1,
              ),
            ],
          );
  }

  Widget getRecipientField() {
    return CustomizedTextFormField(
      isReadOnly: true,
      labelText: AppLocalization.of(context)!.recipient,
      controller: _recipientController,
      focusNode: _recipientFocus,
      enabled: isFromProfile,
      validator: (value) {
        if (!isFromProfile! && value != _payee!.userName) {
          return AppLocalization.of(context)!.invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (!isFromProfile! && _payee != null) {
              recipient = _payee!.userName;
            } else {
              recipient = val;
            }
          });
        }
      },
      onTap: () async {
        final CustomerProfile? userFound =
            await NavigationUtil.push(context, screen: const SearchUser());

        if (userFound != null) {
          _payee = userFound;
          _recipientController.text = _payee!.userName!;
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      enabled: product == null && service == null,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        final double? value = double.tryParse(val.replaceAll(',', ''));

        if (value != null) {
          amount = value;
          if (mounted) setState(() {});
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            final double amount = double.parse(val.replaceAll(',', ''));
            if (amount >= 1.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return "Please enter an amount greater than ₦1";
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
      onTap: () async {
        isValidPayee = false;
        if (mounted) setState(() {});
        if (recipient != null) {
          recipient = recipient!.trim();

          _recipientController.text = recipient!;
          if (mounted) setState(() {});

          final customerProfile =
              await UserAuth().fetchCustomerProfileWithAuth(recipient);

          _payee = customerProfile;
          isValidPayee = _payee!.userName != userBloc.user.userName;

          _recipientController.text = customerProfile.userName!;

          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget getCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.category,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: IgnorePointer(
            ignoring: product != null || service != null,
            child: ListTile(
              dense: true,
              title: Text(
                selectedCategory != null ? selectedCategory! : "",
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
              ),
              onTap: () {
                selectCategory();
              },
            ),
          ),
        ),
      ],
    );
  }

  void selectCategory() async {
    final pressedCategory = await showDialog<String>(
        barrierDismissible: false,
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
                        children: paymentCategories.map<Widget>((category) {
                          if (selectedCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category!,
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
                              category!,
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
      selectedCategory = pressedCategory;
      debugPrint("selected category $selectedCategory");
      setState(() {});
    }
  }

  Widget checkImage() {
    final Color borderColor = getUserTypeColor(user: _payee!);
    String url = "";
    url = _payee!.avatar.toString();

    final String imageUrl = url.replaceAll('https//', 'https://');
    if (_payee!.avatar == "" ||
        _payee!.avatar ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(_payee!.fullName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed("/photo-viewer", arguments: imageUrl);
          },
          child: ClipOval(
            child: _payee!.avatar != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    errorWidget: imageErrorWidget,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      );
    }
  }

  Widget getReferenceField() {
    return CustomizedTextFormField(
      maxLines: 5,
      maxLength: 255,
      labelText: AppLocalization.of(context)!.reference,
      textCapitalization: TextCapitalization.sentences,
      controller: _referenceController,
      enabled: product == null && service == null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            reference = val;
          });
        }
      },
    );
  }

  Widget sendMoneyAnonymouslySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Send money anonymously",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        Switch(
          value: sendMoneyAnonymous,
          onChanged: (value) {
            sendMoneyAnonymous = value;
            setState(() {});
            if (value) sendMoneyAnonymousAlert();
          },
          activeTrackColor: navyBlueLight,
          activeColor: navyBlue,
          inactiveTrackColor: navyBlueLight,
        ),
      ],
    );
  }

  void sendMoneyAnonymousAlert() async {
    final FeeStructure? feeStructure = await DatabaseHelper().getFeeStructure();

    if (feeStructure == null) return;

    final String anonymousFee =
        feeStructure.getFeeWithTax(type: FeesType.ANONYMOUS_TRANSACTION_FEE);

    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, rentDurationStateSetter) {
        return AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
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
                    child: Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "Note",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Text(
                                    "This transaction will be done anonymously. Recipient will not see the sender information. This service will cost you ₦$anonymousFee.",
                                    style: TextStyle(
                                        color: blackFont,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Inter"),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text("OK",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 100) / 2,
                top: -30,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: dividerColor, width: 1.5),
                        borderRadius: BorderRadius.circular(60)),
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Image.asset(
                        "assets/images/anonymous.png",
                        height: 45,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget getSubmitButton() {
    return PermissionProtectionWidget(
      permissionName: ProtectionPermission.transaction,
      isLockForRead: '1',
      child: CurvedButton(
        onPressed: onSubmit,
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Send Payment",
      ),
    );
  }

  void onSubmit() async {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    if (hasPermission == PermissionType.WRITE) {
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (!isValidPayee) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.invalidRecipient;
          return;
        });
      }

      if (_recipientController.text == _payee!.userName) {
        if (!isValidPayee) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.invalidRecipient;
            return;
          });
        }

        if (isValidPayee &&
            _formKey.currentState!.validate() &&
            validateDropdown()) {
          if (userBloc.user.userName != recipient) {
            var userLocation;
            Map deviceData;
            try {
              BottomSheetPassCode(
                  context: context,
                  isValidCallback: () async {
                    showDialog(
                        context: context,
                        builder: (context) => const Center(child: SizedBox()));
                    // Center(child: CircularLoadingIndicator()));

                    try {
                      if (Platform.isIOS) {
                        try {
                          userLocation =
                              await locationService.getLocationEndless();
                        } catch (e) {
                          Navigator.pop(context);
                          debugPrint(e.toString());
                          showToast(message: e.toString());
                          return;
                        }
                      }

                      // double currentBalance = await getAccountBalance();
                      // double transactionalAmount = double.parse(amount.toString());

                      //show loading screen
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentLoadingScreen(
                                  text: 'Sending Payment...',
                                  imagePath: 'assets/images/app_logo.png',
                                )),
                      );

                      await Future.delayed(const Duration(seconds: 3));

                      deviceData = await getDeviceInfo();

                      const String description = 'General Payment';
                      final data = {
                        "from_customer": userBloc.user.userName,
                        "to_customer": _recipientController.text.trim(),
                        "currency": userBloc.user.currency,
                        "amount": moneyInputNormalizer(amount.toString()),
                        "category": selectedCategory?.trim(),
                        "notes":
                            reference.isEmpty ? description : reference.trim(),
                        "description":
                            reference.isEmpty ? description : reference.trim(),
                        "latitude": Platform.isIOS ? userLocation.latitude : "",
                        "longitude":
                            Platform.isIOS ? userLocation.longitude : "",
                        "deviceData": deviceData,
                        "is_anonymous": sendMoneyAnonymous,
                        "made_from_chat": isFromChat,
                      };
                      bool updateYarnSupporter = false;
                      bool updateMomentSupporter = false;

                      if (isFromYarn == true) {
                        data['category'] = "Gift";
                        data['description'] = "Merchandise Payment in Yarn";
                      }

                      if (isFromMoment == true) {
                        data['category'] = "Gift";
                        data['description'] = "Merchandise Payment in Moment";
                      }

                      if (conversationId != null) {
                        data["conversation_id"] = conversationId;
                      }

                      await _auth.makePayment(data).then((value) async {
                        debugPrint(
                            "status code:- ${value.statusCode}  body:- ${value.body}");

                        response = value;

                        try {
                          handleServerErrors(response);
                        } catch (e) {
                          return Future.error(response.body);
                        }

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          try {
                            popFromShoppingCart(product);
                            //Pop Circular Progress Indicator

                            ///check if page is from yarn
                            if (isFromYarn == true) {
                              final jsonData = json.decode(response.body);

                              updateYarnSupporter =
                                  await _auth.updateYarnSupporter(
                                      widget.arguments['yarnId'],
                                      jsonData['transaction_id']);

                              if (updateYarnSupporter == false) {
                                showToast(
                                    message: 'Unable to update yarn payment');
                              } else {
                                widget.callback?.call(true);
                                // Navigator.pop(context);
                                //Pop send payment page
                                Navigator.pop(context);
                                return;
                              }
                            }

                            ///check if page is from moment
                            if (isFromMoment == true) {
                              final jsonData = json.decode(response.body);

                              updateMomentSupporter =
                                  await _auth.updateMomentSupporter(
                                      widget.arguments['momentId'],
                                      jsonData['transaction_id']);

                              if (updateMomentSupporter == false) {
                                showToast(
                                    message: 'Unable to update moment payment');
                              } else {
                                widget.callback?.call(true);
                                Navigator.pop(context);
                                //Pop send payment page
                                Navigator.pop(context);
                                return;
                              }
                            }

                            Navigator.pop(context);
                            //Pop send payment page
                            Navigator.pop(context);

                            debugPrint(" isFromChat:- $isFromChat");

                            if (!isFromChat) {
                              Navigator.of(context).pushNamed(
                                  Routes.TRANSACTIONS,
                                  arguments: {'page': 0});
                            }
                          } catch (e) {
                            debugPrint("Error : $e");
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pop(context);
                          if (response.statusCode == 406) {
                            errorMessage = jsonDecode(value.body)[0];
                            showToast(message: errorMessage);
                            setState(() {});
                          } else {
                            debugPrint("ERROR:- ${response.body}");
                            setState(() {
                              errorMessage = AppLocalization.of(context)!
                                  .somethingWentWrong;
                              showToast(message: errorMessage);
                            });
                          }
                        }
                      });
                    } catch (e) {
                      debugPrint(e.toString());
                      showToast(message: e.toString());
                    }
                  },
                  cancelCallBack: () {
                    Navigator.pop(context);
                    _sendPaymentScaffoldMessenger.currentState
                        ?.showSnackBar(SnackBar(
                      content:
                          Text(AppLocalization.of(context)!.invalidPassword),
                    ));
                  });
            } catch (e) {
              debugPrint(e.toString());
              showToast(message: e.toString());
            }
          } else {
            showToast(message: AppLocalization.of(context)!.invalidRecipient);
          }
        }
      } else {
        final msg = AppLocalization.of(context)!.invalidRecipient;
        showToast(message: msg);
      }
    } else {
      showSnackbar(context,
          message: AppLocalization.of(context)?.doNotPermission ?? "");
    }
  }

  void popFromShoppingCart(Product? product) {
    if (itemIndex != null) {
      try {
        basketBloc.removeItemFromCart(basketBloc.items[itemIndex!]);
      } catch (e) {
        debugPrint("SendPayment PopFromShopping cart : $e");
      }
    }
  }

  bool validateDropdown() {
    if (selectedCategory != null) {
      return true;
    } else {
      selectedCategory = "General";
      return true;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _recipientFocus.dispose();
    super.dispose();
  }

  /// TODO: this function maybe deleted in future
  void checkForUserDailyLimit() {
    if (amount! >=
        int.parse(
            virtualAccount!.accountTier!.dailyCumulativeTransactionLimit!)) {
      Navigator.pop(context);

      errorMessage =
          "you cannot exceed your payment limit of ${virtualAccount!.accountTier!.dailyCumulativeTransactionLimit} per transactions.";
      setState(() {});
      showToast(message: errorMessage);
      return;
    }
  }

  bool canDoSlydoTransfer(double amount, double balance) {
    if (balance > amount + 10.0) {
      return true;
    }
    return false;
  }

  int availableTransfer() {
    int value = 0;
    value = currentBalance!.toInt() * 100 - 1000;

    if (value < 0) {
      // debugPrint("The number is negative.");
      return 0;
    } else {
      // debugPrint("The number is non-negative.");
      return value;
    }
  }
}
