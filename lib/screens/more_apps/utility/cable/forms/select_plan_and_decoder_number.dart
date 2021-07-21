import 'package:Slydo/screens/more_apps/utility/cable/model/CablePlan.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class SelectPlanAndDecoderNumber extends StatefulWidget {
  Map<String, dynamic> arguments;

  SelectPlanAndDecoderNumber({this.arguments});
  @override
  _SelectPlanAndDecoderNumberState createState() =>
      _SelectPlanAndDecoderNumberState();
}

class _SelectPlanAndDecoderNumberState
    extends State<SelectPlanAndDecoderNumber> {
  List<Map<String, dynamic>> plans = [
    {"name": "DStv Premium", "price": "₦18,400"},
    {"name": "DStv Compact Plus", "price": "₦12,400"},
    {"name": "DStv Compact", "price": "₦18,400"},
    {"name": "DStv Confam", "price": "₦4,615"},
    {"name": "DStv Yanga", "price": "₦2,565"},
    {"name": "DStv Padi", "price": "₦1,850"},
  ];

  Map<String, dynamic> provider;

  CablePlan selectedPlan;

  @override
  void initState() {
    provider = widget.arguments['provider'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar(),
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
        "Cable",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(
          height: 20,
        ),
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: getProvider()),
                    Divider(
                      color: dividerColor,
                      thickness: 1.5,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: selectPlanDropDown()),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: getDecoderNumber()),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: submitButton(),
        )
      ],
    ));
  }

  Widget getProvider() {
    return Row(
      children: [
        Image.asset(
          provider['image'],
          fit: BoxFit.fill,
          height: 80,
          width: 80,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          provider['name'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
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
        SizedBox(
          height: 6,
        ),
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
            title: Row(
              children: [
                Text(
                  selectedPlan != null ? selectedPlan.name : "",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Expanded(
                    child: SizedBox(
                  width: 2,
                )),
                Text(
                  selectedPlan != null ? selectedPlan.price : "",
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Roborto"),
                )
              ],
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () async {
              // selectPlan();
              var plan =
                  await Navigator.of(context).pushNamed("/select-cable-plan");
              if (plan != null) {
                if (plan is CablePlan) {
                  selectedPlan = plan;
                  if (mounted) setState(() {});
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget getDecoderNumber() {
    return CustomizedTextFormField(
      labelText: "Decoder Number",
      keyboardType: TextInputType.number,
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();

        await Future.delayed(Duration(milliseconds: 500));

        BottomSheetPassCode(
            context: context,
            isValidCallback: () async {
              showDialog(
                  context: context,
                  builder: (context) =>
                      Center(child: CircularLoadingIndicator()));

              await Future.delayed(Duration(seconds: 2)).then((value) {
                Toast.show("Payment Completed Successfully !", context,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    duration: Toast.LENGTH_LONG);

                Navigator.popUntil(
                    context, ModalRoute.withName("/utility-dashboard"));
                Navigator.of(context).pushNamed("/cable-plan-payment-detail",
                    arguments: {"plan": selectedPlan});
              });
            },
            cancelCallBack: () {
              Navigator.pop(context);
            });
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Pay",
    );
  }
}
