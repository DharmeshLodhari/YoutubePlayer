import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
class FindVehicleScreen extends StatefulWidget {
  const FindVehicleScreen({super.key});

  @override
  State<FindVehicleScreen> createState() => _FindVehicleScreenState();
}

class _FindVehicleScreenState extends State<FindVehicleScreen> {

  late CameraPosition _initialCameraPosition;
  GoogleMapController? googleMapController;
  List<VehicleDetails> vehicleList = [];
  List<PaymentOptions1> paymetnOptionList = [];
  int? selectIndex;
  bool? showPaymentOption =false;
  @override
  void initState() {
    _initialCameraPosition =
    const CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);
    vehicleList.add(VehicleDetails(
        'assets/images/dispatch/ic_bicycle.svg','₦ 1000','Bike','22min'
    ));
    vehicleList.add(VehicleDetails(
        'assets/images/dispatch/ic_bike.svg','₦ 1400','Motorcycle','12min'
    ));
    paymetnOptionList =[ PaymentOptions1('Pay Now','Pay from your slydo balance'),
      PaymentOptions1('Pay On Delivery','Scan to pay or One time payment method'),
      PaymentOptions1('Charge Another Slydo User ','Charge the recipient'),
    ];
    super.initState();
  }
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

  Widget _buildBody() {
    return Stack(
      children: [
        MapUI(),
        if(!showPaymentOption!)
        _buildVehicleOption(),
        if(showPaymentOption!)
        _buildPaymentOption(),
      ],
    );
  }
  Widget MapUI(){
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },

    );
  }
  Widget _buildVehicleOption() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.45,
      minChildSize: 0.45,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _buildText("Select Option"),
              ),
              _buildVehicletOptionList(),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CurvedButton(
            onPressed: () {
              if(selectIndex != null)
              {
                showPaymentOption = true;
                setState(() {});
              }

            },
            textColor: Colors.white,
            backgroundColor: navyBlue,
            text: "Proceed",
          ),
        ),
              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildVehicletOptionList() {
    return ListView.builder(
      itemCount: vehicleList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Card(
          child: GestureDetector(
            onTap: (){
              onVehicleSelect(index);
            },
            child: Container(
              decoration:new BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: vehicleList[index].isSelected! ?navyBlue:white,
                  width: 1.0, // Border width
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          vehicleList[index].imagePath!,
                          height: 43,
                          width: 61,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          vehicleList[index].vehicleName!,
                          style: TextStyle(
                            color: black,
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text(
                          vehicleList[index].amt!,
                          style: TextStyle(
                            fontSize: 20,
                            color: black,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          vehicleList[index].time!,
                          style: TextStyle(
                            fontSize: 12,
                            color: black,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildPaymentOption() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.45,
      minChildSize: 0.45,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 2,
                width: 12.0.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: greyBorderColor,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _buildText("Choose Payment Method"),
              ),
             // const SizedBox(height: 10,),
              _buildPaymentOptionList(),
              const SizedBox(height: 10,),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPaymentOptionList(){
    return ListView.builder(
      itemCount: paymetnOptionList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          decoration:new BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: greyTagColor,
              width: 1.0, // Border width
            ),
          ),
          child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed(Routes.PAYMENT_OPTION);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/app_logo_navyBlue.png',
                height: 24,
                  width: 24,
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymetnOptionList[index].title!,
                        style: TextStyle(
                          color: black,
                          fontSize: 14,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        paymetnOptionList[index].subTitle!,
                        style: TextStyle(
                          color: black,
                          fontSize: 12,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(width: 10,),
                Icon(Icons.arrow_forward_ios
                )
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }
  void onVehicleSelect(int index) {
    for(int i = 0;i < vehicleList.length;i++){
      vehicleList[i].isSelected = false;
    }
    vehicleList[index].isSelected = true;
    selectIndex = index;

    setState(() {

    });
  }
}
class VehicleDetails {
  String? imagePath;
  String? amt;
  String? vehicleName;
  String? time;
  bool? isSelected = false;
  VehicleDetails(String image,String amount,String name,String awayTime){
    imagePath = image;
    amt = amount;
    vehicleName = name;
    time = awayTime;
  }



}
class PaymentOptions1 {
  String? title;
  String? subTitle;
  PaymentOptions1(String text,String text1){
    title = text;
    subTitle = text1;
  }
}
