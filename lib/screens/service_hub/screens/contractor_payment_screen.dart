import 'dart:convert';
import 'dart:io';

import 'package:Slydo/constant.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../../services/location_service.dart';
import '../../../../utils/util.dart';
import '../../../../widget/curved_btn.dart';
import '../../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../../../../widget/customized_textform_field.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../payment_and_banking/payment_and_banking_auth.dart';
import '../../user_profile/models/user.dart';
import '../../user_profile/user_auth.dart';
import '../auth/service_hub_auth.dart';
import '../models/jobs.dart';

class ContractorPaymentScreen extends StatefulWidget {
  const ContractorPaymentScreen({super.key, this.arguments});
  final dynamic arguments;

  @override
  State<ContractorPaymentScreen> createState() =>
      _ContractorPaymentScreenState();
}

class _ContractorPaymentScreenState extends State<ContractorPaymentScreen> {
  CustomerProfileBloc? customerProfileBloc;
  final _formKey = GlobalKey<FormState>();
  JobModel? jobmodel;
  // String? selectedCategory;
  List<String?> paymentCategories = [];
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _refNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  CustomerProfile? messageReceiver;
  late UserBloc userBloc;
  final FocusNode _recipientFocus = FocusNode();
  final FocusNode _refNumberFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  // double? amount;
  int? rateValue;
  bool? isLoading;
  final _auth = PaymentAndBankingAuth();
  String errorMessage = "";
  var userLocation;
  late http.Response response;

  final _sendPaymentScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

  final locationService = LocationService();

  double currentBalance = 0.0;

  @override
  void initState() {
    jobmodel = widget.arguments;
    getContractorDetail();
    getAccountBalanceDetail();
    super.initState();
  }

  void getContractorDetail() async {
    messageReceiver = await UserAuth().fetchCustomerProfile(jobmodel!.assignee);
    _refNumberController.text = '';
    _categoryController.text = 'Finance';
    _recipientController.text = jobmodel!.assignee!;
    _amountController.text =
        moneyDisplayNormalizer(int.parse(jobmodel!.pay.toString()));
    _refNumberController.text = jobmodel!.referenceNumber!;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
        appBar: _buildAppBar() as PreferredSizeWidget, body: scaffoldBody());
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
        child: Column(
      children: [
        Card(
          elevation: .8,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                    children: [
                      displayCard(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          getRecipientField(),
                          const SizedBox(
                            height: 20,
                          ),
                          displayAmountField(),
                          const SizedBox(
                            height: 20,
                          ),
                          getCategoryField(),
                          const SizedBox(
                            height: 20,
                          ),
                          getRefNumberField(),
                          const SizedBox(
                            height: 40,
                          ),
                        ]),
                      )
                    ],
                  ))),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: canDoSlydoTransfer(
                  moneyInputNormalizer2(jobmodel!.pay.toString()).toDouble(),
                  currentBalance)
              ? sendPayment()
              : Text(
                  "Insufficient Fund",
                  style: TextStyle(
                    color: red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                  ),
                ),
        ),
        const SizedBox(
          height: 60,
        ),
      ],
    ));
  }

  Widget getReferenceField() {
    return CustomizedTextFormField(
      maxLines: 3,
      hintText: AppLocalization.of(context)!.saySomething,
      textCapitalization: TextCapitalization.sentences,
      controller: _reviewController,
      // enabled: product == null && service == null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            // _reviewController.text = val;
          });
        }
      },
    );
  }

  Future<void> completedJobAlert() async {
    await showDialogBoxSuccess(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.cancel,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      title: "Job Completed Successful",
    );
  }

  void ratingAndReviewModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: .65,
          minChildSize: .25,
          maxChildSize: .65,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
                color: white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: ListView(
              controller: controller,
              children: <Widget>[
                const SizedBox(
                  height: 26,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Rate this  ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Inter",
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: "${jobmodel!.assigneeAvatar}",
                      imageBuilder: (context, imageProvider) => Container(
                        width: 20,
                        height: 20.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      errorWidget: productAndServiceBigErrorWidget,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    userNameWithVerifiedIcon(
                      name: jobmodel?.assignee ?? '',
                      isVerified: jobmodel!.isVerified,
                      verifiedIconColor: verifyGreen,
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          color: HexColor("#151515")),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        rateValue = rating.toInt();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                getReferenceField(),
                const SizedBox(
                  height: 30,
                ),
                submitRatingAndReviewButton(),
                const SizedBox(
                  height: 306,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void endJob() async {
    await ServiceHubAuthService().endJob(jobmodel!.id).then((value) {
      // debugPrint("$value");
      if (value == true) {
        makePayment();
      } else {
        showToast(message: 'Error trying to send payment to contractor');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  void submitRatingAndReview() async {
    await ServiceHubAuthService()
        .rateAndReviewContrator(jobId: jobmodel!.id, data: {
      "job_contractor": jobmodel!.assignee,
      "job_owner": jobmodel!.owner,
      "score": rateValue,
      "review": _reviewController.text,
      "job": jobmodel!.id,
      "job_owner_name": jobmodel!.ownerName,
      "job_contractor_name": jobmodel!.assignee
    }).then((value) {
      if (value == true) {
        completedJobAlert();
      } else {
        showToast(
            message:
                'Sorry you cannot rate and add a review to this contractor');
      }
    }).catchError((error) {
      debugPrint(error.toString());
      showToast(message: error.toString());
    });
  }

  void onSubmit() async {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    if (hasPermission == PermissionType.WRITE) {
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        BottomSheetPassCode(
            context: context,
            isValidCallback: () async {
              showDialog(
                  context: context,
                  builder: (context) => const Center(child: SizedBox()));
              makePayment();
              // endJob();
            },
            cancelCallBack: () {
              Navigator.pop(context);
              _sendPaymentScaffoldMessenger.currentState?.showSnackBar(SnackBar(
                content: Text(AppLocalization.of(context)!.invalidPassword),
              ));
            });
      } catch (e) {
        debugPrint(e.toString());
        showToast(message: e.toString());
      }
    } else {
      showSnackbar(context,
          message: AppLocalization.of(context)?.doNotPermission ?? "");
    }
  }

  void makePayment() async {
    if (Platform.isIOS) {
      userLocation = await locationService.getLocation();
    }
    const String description = 'General Payment';

    final data = {
      "from_customer": userBloc.user.userName,
      "to_customer": _recipientController.text.trim(),
      "currency": userBloc.user.currency,
      "amount": moneyInputNormalizer2(jobmodel!.pay.toString()),
      "category": _categoryController.text.trim(),
      "notes": '',
      "description": _refNumberController.text.isEmpty
          ? description
          : _refNumberController.text.trim(),
      "latitude": Platform.isIOS ? userLocation.latitude : "",
      "longitude": Platform.isIOS ? userLocation.longitude : "",
      "is_anonymous": false,
      "made_from_chat": false,
    };
    // debugPrint('ptrint data:::$data');

    await _auth.makePayment(data).then((value) async {
      // debugPrint("status code3333:- ${value.statusCode}  body:- ${value.body}");

      response = value;
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _auth
            .updateStatusPayment(
                jobId: jobmodel!.id, transactionId: jsonData['transaction_id'])
            .then((value) async {
          // debugPrint("status code:- ${value.statusCode}  body:- ${value.body}");
          if (value.statusCode == 200 || value.statusCode == 201) {
            ratingAndReviewModal();
          }
        });
      } else {
        Navigator.pop(context);
        if (response.statusCode == 406) {
          errorMessage = jsonDecode(value.body)[0];
          showToast(message: errorMessage);
          setState(() {});
        } else {
          debugPrint("ERROR:- ${response.body}");
          setState(() {
            errorMessage = AppLocalization.of(context)!.somethingWentWrong;
            showToast(message: errorMessage);
          });
        }
      }
    });
  }

  bool canDoSlydoTransfer(double amount, double balance) {
    if (balance > amount) {
      return true;
    }
    return false;
  }

  Widget sendPayment() {
    return PermissionProtectionWidget(
      permissionName: ProtectionPermission.transaction,
      isLockForRead: '1',
      child: CurvedButton(
        onPressed: onSubmit,
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: 'Send Payment',
      ),
    );
  }

  Widget submitRatingAndReviewButton() {
    return CurvedButton(
      onPressed: () => submitRatingAndReview(),
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: 'Submit',
    );
  }

  Widget displayCard() {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          leading: ClipOval(
            child: CachedNetworkImage(
              height: 50,
              width: 50,
              imageUrl: jobmodel!.assigneeAvatar!,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          ),
          trailing: messageReceiver == null
              ? const SizedBox.shrink()
              : CachedNetworkImage(
                  height: 48,
                  width: 48,
                  imageUrl: messageReceiver!.qrCode!,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  errorWidget: imageErrorWidget,
                ),
          title: Text(jobmodel!.assignee!,
              style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: blackFont)),
          subtitle: Text(jobmodel!.assignee!,
              style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: darkGrey)),
        ),
        Divider(
          color: greyBorderColor,
          thickness: .9,
        ),
        const SizedBox(
          height: 16.6,
        ),
      ],
    );
  }

  Widget _buildAppBar() {
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
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
          }
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        'Send Payment',
        style: TextStyle(
            fontFamily: "Inter",
            color: blackFont,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        iconAvatar(),
        const SizedBox(
          width: 26,
        )
      ],
    );
  }

  Widget iconAvatar() {
    return SizedBox(
      height: 21.6,
      width: 21.6,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/images/icon_avatar.svg',
        ),
      ),
    );
  }

  Widget getRecipientField() {
    return CustomizedTextFormField(
      isReadOnly: true,
      labelText: AppLocalization.of(context)!.recipient,
      controller: _recipientController,
      focusNode: _recipientFocus,
      validator: (value) {
        if (value.isEmpty || value == null) {
          return AppLocalization.of(context)!.invalidRecipient;
        }
        return null;
      },
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (jobmodel!.assignee != null) {
              _recipientController.text = jobmodel!.assignee!;
            } else {
              _recipientController.text = val;
            }
          });
        }
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedTextFormField(
      isReadOnly: true,
      labelText: AppLocalization.of(context)!.category,
      controller: _categoryController,
      focusNode: _categoryFocus,
    );
  }

  Widget getRefNumberField() {
    return CustomizedTextFormField(
      maxLines: 3,
      labelText: AppLocalization.of(context)!.jobRefNumber,
      controller: _refNumberController,
      focusNode: _refNumberFocus,
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      isReadOnly: true,
      labelText: "Amount",
      isAmountField: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {});
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            final double amount = double.parse(val.replaceAll(',', ''));
            if (amount > 0.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  void getAccountBalanceDetail() async {
    currentBalance = await getAccountBalance();
  }
}
