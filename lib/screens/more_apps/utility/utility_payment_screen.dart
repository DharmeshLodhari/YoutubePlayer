import 'package:Slydo/screens/more_apps/utility/models/provider_product_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/services.dart';

import 'models/provider_model.dart';

import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/slydo_app_icon_icons.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_textform_field.dart';

class UtilityPaymentScreen extends StatefulWidget {
  final ProviderModel providerModel;
  const UtilityPaymentScreen({Key? key, required this.providerModel})
      : super(key: key);

  @override
  State<UtilityPaymentScreen> createState() => _UtilityPaymentScreenState();
}

class _UtilityPaymentScreenState extends State<UtilityPaymentScreen> {
  int? amount;
  bool lookUp = true;
  String? customerId;
  bool hasError = false;
  bool planSelected = false;
  bool referenceNumVerified = false;
  ProviderProductModel? selectedPlan;
  List<ProviderProductModel> utilityProviderDetails = [];
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController referenceNumCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountCtrl.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    getProviderListDetails();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  getProviderListDetails() {
    UtilityAuth()
        .getUtilityProviderProduct(providerId: widget.providerModel.providerId)
        .then(
      (providerDetails) {
        providerDetails.forEach((element) {
          utilityProviderDetails.add(element);
        });

        if (mounted) {
          setState(() {});
        }
      },
    ).catchError(
      (e) {
        hasError = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
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
        "Select plan",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
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
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: getProvider(),
                      ),
                      Divider(
                        color: dividerColor,
                        thickness: 1.5,
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: utilityProviderDetails.isNotEmpty
                            ? selectPlanDropDown()
                            : hasError
                                ? Text('Something went wrong, try again')
                                : CircularLoadingIndicator(),
                      ),
                      SizedBox(height: 20),
                      Visibility(
                        visible: planSelected,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: getReferenceNumber(),
                        ),
                      ),
                      Visibility(
                        visible: planSelected,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: getAmount(),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Visibility(
            visible: planSelected &&
                referenceNumVerified &&
                amountCtrl.text.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: submitButton(),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget getProvider() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Card(
            elevation: 8,
            shadowColor: Color(0XFF314167).withOpacity(0.08),
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CachedNetworkImage(
                width: 30,
                height: 30,
                imageUrl: widget.providerModel.avatar,
                placeholder: (context, url) => Center(
                  child: CircularLoadingIndicator(),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.providerModel.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectPlanDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Select a plan",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 6),
        // getPlanField(),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedPlan != null ? selectedPlan!.name : '',
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () async {
              selectPlan();
              // var plan =
              // await Navigator.of(context).pushNamed("/select-cable-plan");
              // if (plan != null) {
              //   if (plan is CablePlan) {
              //     selectedPlan = plan;
              //     if (mounted) setState(() {});
              //   }
              // }
            },
          ),
        ),
      ],
    );
  }

  void selectPlan() async {
    final pressedPlan = await showDialog<ProviderProductModel>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                        children: utilityProviderDetails.map<Widget>((plan) {
                          if (selectedPlan == plan) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  plan.name,
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
                                  Navigator.pop(context, plan);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              plan.name,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, plan);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedPlan != null) {
      selectedPlan = pressedPlan;
      lookUp = selectedPlan!.lookUp;
      amount = selectedPlan!.amount;
      amountCtrl.text = amount == null ? '' : moneyDisplayNormalizer(amount);
      planSelected = true;
      setState(() {});
    }
  }

  Widget getReferenceNumber() {
    if (lookUp) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomizedTextFormField(
            labelText: widget.providerModel.label,
            isNumberOnlyInput: true,
            controller: referenceNumCtrl,
            keyboardType: TextInputType.number,
            whenToVerifyInputFromServer: (val) {
              return true;
            },
            verifyInputFromServerFunc: () => verifyReferenceNumber(),
            extraFunctionWhenInputWasVerifiedFromServerSuccessfully: () {},
            extraFunctionWhenInputWasNotVerifiedFromServerSuccessfully: () {},
          ),
          SizedBox(height: 20),
        ],
      );
    }

    return SizedBox.shrink();
  }

  Future<bool> verifyReferenceNumber() async {
    await UtilityAuth()
        .verifyCustomerReferenceNumber(
            productId: selectedPlan!.productId,
            customerRefNum: referenceNumCtrl.text,
            providerId: widget.providerModel.providerId)
        .then(
      (value) {
        if (value != null) {
          customerId = value;

          referenceNumVerified = true;
        } else {
          referenceNumVerified = false;
        }
      },
    );
    if (mounted) {
      setState(() {});
    }

    return referenceNumVerified;
  }

  Widget getAmount() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      controller: amountCtrl,
      enabled: amount == null,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () async {
        Navigator.pushNamed(context, '/utility-history');

        // bool paidSuccessfully = await UtilityAuth().payUtilityBill(
        //   billPaymentModel: BillPaymentModel(
        //     customerId: customerId!,
        //     amount: int.parse(amountCtrl.text),
        //     productId: selectedPlan!.productId,
        //     customerRefNum: referenceNumCtrl.text,
        //     providerId: widget.providerModel.providerId,
        //   ),
        // );
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Pay",
    );
  }
}
