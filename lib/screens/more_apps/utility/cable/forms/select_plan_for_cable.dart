import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class SelectPlanForCable extends StatefulWidget {
  Map<String, dynamic> arguments;

  SelectPlanForCable({this.arguments});
  @override
  _SelectPlanForCableState createState() => _SelectPlanForCableState();
}

class _SelectPlanForCableState extends State<SelectPlanForCable> {
  List<Map<String, dynamic>> plans = [
    {"name": "DStv Premium", "price": "₦18,400"},
    {"name": "DStv Compact Plus", "price": "₦12,400"},
    {"name": "DStv Compact", "price": "₦18,400"},
    {"name": "DStv Confam", "price": "₦4,615"},
    {"name": "DStv Yanga", "price": "₦2,565"},
    {"name": "DStv Padi", "price": "₦1,850"},
  ];
  List<String> toPlace = ["Abuja"];
  List<String> classes = ["A", "B"];

  Map<String, dynamic> provider;

  Map<String, dynamic> selectedPlan;

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

  Widget getFromPlace() {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          underline: Divider(
            color: Colors.transparent,
          ),
          hint: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(AppLocalization.of(context).category),
              ),
            ],
          ),
          value: selectedPlan,
          onChanged: (Map<String, dynamic> value) {
            setState(() {
              selectedPlan = value;
            });
          },
          items: plans.map((Map<String, dynamic> category) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: category,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  children: [
                    Text(
                      category['name'],
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      category['price'],
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
                  selectedPlan != null ? selectedPlan['name'] : "",
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
                  selectedPlan != null ? selectedPlan['price'] : "",
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
            onTap: () {
              selectPlan();
            },
          ),
        ),
      ],
    );
  }

  void selectPlan() async {
    final pressedCategory = await showDialog<Map<String, dynamic>>(
        barrierDismissible: false,
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
                        children: plans.map<Widget>((category) {
                          if (selectedPlan == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category['name'],
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Text(
                                  category['price'],
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Roborto"),
                                ),
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category['name'],
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: Text(
                              category['price'],
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Roborto"),
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
      selectedPlan = pressedCategory;
      setState(() {});
    }
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
        Toast.show("Payment Completed Successfully !", context,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            duration: Toast.LENGTH_LONG);

        await Future.delayed(Duration(seconds: 2)).then((value) {
          Navigator.popUntil(
              context, ModalRoute.withName("/utility-dashboard"));
          Navigator.of(context).pushNamed("/cable-plan-payment-detail");
        });
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Pay",
    );
  }
}
