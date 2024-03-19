import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class CancellationScreen extends StatefulWidget {
  const CancellationScreen({super.key});

  @override
  State<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends State<CancellationScreen> {
  bool isChecked = false;
  String? userChecked;

  List<String> reasons = [
    "I don’t want to share",
    "Can't contact the driver",
    "Driver is late",
    "The price is not reasonable",
    "Pickup address is incorrect",
    "Driver asked me to cancel",
    "Driver didn't match description",
    "Long pickup time",
    "Car didn't match description",
    "Wrong pickup location",
  ];

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: transparent,
        ),
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          persistentFooterButtons: [
            _buildSubmitButton(),
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCancellationText(),
                  SizedBox(height: 30),
                  _buildCancellationList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildCancellationText() {
    return Text(
      "Please select the reason\nfor cancellation:",
      style: TextStyle(
        fontFamily: "Inter",
        fontSize: 24,
        color: black,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCancellationList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: reasons.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(
              reasons[i],
              style: TextStyle(
                color: userChecked == reasons[i] ? blackFont : black,
                fontSize: 16,
                fontWeight: userChecked == reasons[i]
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            leading: Radio<String?>(
              value: reasons[i],
              activeColor: navyBlue,
              hoverColor: navyBlue,
              focusColor: navyBlue,
              visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity),
              onChanged: (val) {
                _onSelected(val);
              },
              groupValue: userChecked,
            ),
          );
        });
  }

  void _onSelected(String? dataName) {
    userChecked = dataName;
    if (mounted) setState(() {});
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 25, left: 25),
      child: CurvedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Submit",
      ),
    );
  }
}
