import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class DriverArrivingScreen extends StatefulWidget {
  const DriverArrivingScreen({super.key});

  @override
  State<DriverArrivingScreen> createState() => _DriverArrivingScreenState();
}

class _DriverArrivingScreenState extends State<DriverArrivingScreen> {
  late CameraPosition _initialCameraPosition;
  GoogleMapController? googleMapController;
  BitmapDescriptor? pin;
  // Marker and Polyline variables
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  bool requiestAccept = false;
  bool driverArriving = false;
  bool driverArrived = true;
  @override
  void initState() {
    _initialCameraPosition =
    const CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);
    _addMarker();
    _addPolyline();
    _addCircle();
    super.initState();

  }
  void _addCircle() {
    final Circle circle = Circle(
      circleId: CircleId('circle_1'),
      center: LatLng(23.040060, 72.666630),
      radius: 700, // 1000 meters
      fillColor: Colors.blue.withOpacity(0.3),
      strokeColor: Colors.blue,
      strokeWidth: 2,

    );

    setState(() {
      _circles.add(circle);
    });
  }
  void _addMarker() {
    final Marker marker =  Marker(
      markerId: MarkerId('marker_1'),
      position: LatLng(23.040060, 72.666630), // Example coordinates (San Francisco)
      infoWindow: InfoWindow(title: 'San Francisco'),
    );

    setState(() {
      _markers.add(marker);
    });
  }
  void _addPolyline() {
    final Polyline polyline = Polyline(
      polylineId: PolylineId('polyline_1'),
      points: [
        LatLng(23.040060, 72.666630),
        LatLng(23.071360,72.656387),
      ],
      color: navyBlue,
      width: 5,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: Stack(
        children: [
          MapUI(),
          _buildDriverInfoView(),
          if(requiestAccept)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: _buidReqAcceptText(context),
          ),
        ],
      ),
    );
  }
  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
           Icons.home,
          color: black,
          size: 24,
        ),
        onPressed: () {
         /* isDriverStartedMoving = !isDriverStartedMoving;
          setState(() {});
          Navigator.of(context).pop();*/
        },
      ),
      title: Text(
         "Arriving",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget MapUI(){

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target:LatLng(23.040060, 72.666630), // San Francisco as the default view
        zoom: 13,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
      },
         markers:  driverArrived ?{}:_markers,
      polylines: driverArrived ? {}  : _polylines,
      circles: _circles,
    );
  }
  Widget _buildDriverInfoView() {
    return DraggableScrollableSheet(
      initialChildSize: _getDraggableScrollableSheetSize(),
      maxChildSize: _getDraggableScrollableSheetSize(),
      minChildSize: _getDraggableScrollableSheetSize(),
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: getDriverInfo(),
        ),
      ),
    );
  }
  Widget getDriverInfo() {
   // final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/dispatch/dummy_driver_pic.jpeg', // Replace with the correct path to your asset image
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tolani James",
                      style: TextStyle(
                          color: blackFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "@tolani.james",
                      style: TextStyle(
                          color: blackFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          ),
          _buildSubInfoView(context),
          if(driverArriving)
          _buildAddressSelection(context),
          const SizedBox(height: 20,),
          getDriverActions()

        ],
      ),
    );
  }

  Widget _buildSubInfoView(BuildContext context){
    if(driverArriving){
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 15,),
          Text(
            "₦",
            style: TextStyle(
              fontSize: 13,
              color: black,
              fontWeight: FontWeight.w700,
              fontFamily: "Inter",
            ),
          ),
          Text(
            "1000",
            style: TextStyle(
              fontSize: 24,
              color: black,
              fontWeight: FontWeight.w700,
              fontFamily: "Inter",
            ),
          ),
        ],
      );
    }
    if(driverArrived){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Tosin has arrived",
              style: TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Please load your package into the delivery vehicle, to continue the delivery.",
              style: TextStyle(
                fontSize: 13,
                color: black,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      );
    }

    return Container();

  }

  Widget _buildAddressSelection(BuildContext context) {
    return InkWell(
      onTap: (){
       // Navigator.of(context).pop();
        //Navigator.of(context).pushNamed(Routes.SLYDER_ARRIVING);
      },
      child:
      Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SvgPicture.asset(
                  'assets/images/rider/ic_route.svg',
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
        
              // Address List Section (Static items)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        
                    Text(
                      '24 Bashir Musa Road, Agege',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14),
                    ),
                    const SizedBox(height: 30,),
                    Text(
                      '20, Pedro Street, Alausa, Ikeja',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14),
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

  Widget getDriverActions() {
    if(driverArrived){
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getActionBtn(iconPath: 'assets/images/dispatch/call-ringing.svg', onTap: () {}),
          getActionBtn(iconPath: 'assets/images/dispatch/chats.svg', onTap: () {}),
          getActionBtn(iconPath: 'assets/images/dispatch/call-ringing.svg', onTap: () {}),
        ],
      ),
    );
  }
  Widget getActionBtn({String? iconPath, Function? onTap}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Card(
        elevation: 5,
        borderOnForeground: true,
        shadowColor: dividerColor.withAlpha(125),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: SizedBox(
          height: 70,
          width: 70,
          child: Center(
            child:SvgPicture.asset(
              iconPath!.toSVG(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buidReqAcceptText(BuildContext context){
    return Container(
      height: 40,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: white,
      ),
      child: Row(
        children: [
          const SizedBox(width: 10,),
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: navyBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10,),
          Text('Tosin accepted your request and is on his way.',
          style: TextStyle(
              fontFamily: "Inter",
              color: black,
              fontSize: 12,
              fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _buildDriverArrivedView(BuildContext context){
    return Container();
  }
  double _getDraggableScrollableSheetSize(){
    if(requiestAccept){
      return 0.30;
    }
    if(driverArrived){
      return 0.30;
    }
    return 0.50;
  }

}
