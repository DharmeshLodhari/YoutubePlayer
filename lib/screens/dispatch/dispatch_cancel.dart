import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
class DisPatchCancelScreen extends StatefulWidget {
  const DisPatchCancelScreen({super.key});

  @override
  State<DisPatchCancelScreen> createState() => _DisPatchCancelScreenState();
}

class _DisPatchCancelScreenState extends State<DisPatchCancelScreen> {

  List<String> list = ['I don’t want to share','Can\'t contact the driver','Driver is late',
    'The price is not reasonable','Pickup address is incorrect','Driver asked me to cancel',
    'Driver didn\'t match description','Long pickup time','Car didn\'t match description',
    'Wrong pickup location'
  ];

  int _selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar() as PreferredSizeWidget?,
      body: _buildBody(),
    );
  }
  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
  Widget _buildBody(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Column(
        children: [
       //
          Text(
            "Please select the reason for cancellation:",
            style: TextStyle(
              fontSize: 24,
              color: black,
              fontWeight: FontWeight.w700,
              fontFamily: "Inter",
            ),
          ),
          Expanded(child: Container(
            child: ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context,index){

              return ListTile(
                leading: Radio<int>(
                  value: index,  // Set the value for this radio button
                  groupValue: _selectedValue,  // Check if the radio button is selected
                  onChanged: (int? value) {
                    _selectedValue = index;
                    setState(() {});

                  },
                ),
                title: Text(list[index]),  // Display the text for each item
              );
            }),
          )),
          CurvedButton(
            onPressed: () {


            },
            textColor: Colors.white,
            backgroundColor: navyBlue,
            text: "Submit",
          ),
        ],
      ),
    );
  }
}
