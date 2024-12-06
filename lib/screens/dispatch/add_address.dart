import 'package:Slydo/screens/yarn/widgets/category_chip.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class AddAddressScreen extends StatefulWidget {
   AddAddressScreen({this.arguments, super.key});
  final dynamic arguments;
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late CameraPosition _initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> _markers = {};
  bool saveAddressForFuture = false;
  bool isEditView = false;
  @override
  void initState() {
    if(widget.arguments != null){
      isEditView =widget.arguments['isEdit'] ;
    }

    _initialCameraPosition =
    const CameraPosition(target: LatLng(6.605874, 3.349149), zoom: 11.5);
    _addMarker();
    super.initState();
  }
  void _addMarker() async{
    final Marker marker =  Marker(
      markerId: MarkerId('marker_1'),

      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.0), // Increase the pixel ratio for a larger icon
          "assets/images/dispatch/vehicle_marker.png"
      ),
      position: LatLng(23.040060, 72.666630), // Example coordinates (San Francisco)

    );

    setState(() {
      _markers.add(marker);
    });
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
      title: Text(
        'Add Address',
        style: TextStyle(
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            addAddressField(),
           const SizedBox(height: 10,),
            addAddressLine2(),
            const SizedBox(height: 10,),
            _getTextView('Mark your entrance'),
            _getTextLightView('Help Courier reach you faster'),

            const SizedBox(height: 10,),
            _mapUi(),
            const SizedBox(height: 10,),
            _getTextView('Add a Label'),
            _getTextLightView('Identify this address more easily.'),
        
            const SizedBox(height: 10,),
            _buildAddLableView() ,
            const SizedBox(height: 10,),
            CustomizedTextFormField(
          labelText: "",
          showLabelOrPassword: false,
          initialValue:  "",
          hintText: 'Jacob’s Address',
          validator: (val) {
            if (val.isNotEmpty) {
              return null;
            }
            return "This field should not be empty";
          },
          onChanged: (val) {
            // shippingAddress.line_1 = val;
          },
        ),
            const SizedBox(height: 10,),
            _getTextView('Who is receiving the pacakge?'),
            const SizedBox(height: 10,),
            CustomizedTextFormField(
              labelText: "Recipient Name",
              initialValue:  "Jacob",
              validator: (val) {
                if (val.isNotEmpty) {
                  return null;
                }
                return "This field should not be empty";
              },
              onChanged: (val) {
                // shippingAddress.line_1 = val;
              },
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                _getTextLightView('Phone number'),
                const Spacer(),
                Text(
                  'Contacts',
                  style: TextStyle(
                    color: navyBlue,
                    fontSize: 12,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            TextFormField(
              style:  TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
              initialValue: '+234 8034771077',
              decoration: InputDecoration(
                prefixIcon:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/app_logo_navyBlue.png',
                    height: 14,
                    width: 14,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: greyBorderColor,
                    width: 1.0,
                  ),
                ),
              )
            ),
            const SizedBox(height: 10,),
            CustomizedTextFormField(
              labelText: "Email Address ",
              initialValue:  "Toyin@gmail.com",
              validator: (val) {
                if (val.isNotEmpty) {
                  return null;
                }
                return "This field should not be empty";
              },
              onChanged: (val) {
                // shippingAddress.line_1 = val;
              },
            ),
            const SizedBox(height: 10,),
            if(!isEditView )
              toggleActiveTag(),
          /*  Row(
             children: [
                InkWell(
                  onTap: (){
                    saveAddressForFuture = !saveAddressForFuture;
                    setState(() {});
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    child: saveAddressForFuture ?Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Icon(Icons.done,
                      color: white,
                        size: 20,
                      ),
                    ) : SizedBox(),
                    decoration:BoxDecoration(
                      color: saveAddressForFuture ?navyBlue :white,
                      border: Border.all(
                          color: navyBlue), // replace with navyBlue if defined
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
               const SizedBox(width: 10,),
               // Checkbox(value:false, onChanged: (val){}),
               Expanded(child: _getTextView('Save For Future Reference'))
             ],
           ),*/

            const SizedBox(height: 10,),
            if(!isEditView )
            CurvedButton(
              onPressed: () {

                Navigator.pop(context, "back pressed");
              },
              textColor: Colors.white,
              backgroundColor: navyBlue,
              text: "Save",
            ),
            if(isEditView)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Expanded(child:   CurvedButton(
                    onPressed: () {

                      Navigator.pop(context, "back pressed");
                    },
                    textColor: Colors.white,
                    backgroundColor: mateRed,
                    text: "Delete",
                  ),),
                const SizedBox(width: 20,),

                  Expanded(child:   CurvedButton(
                    onPressed: () {

                      Navigator.pop(context, "back pressed");
                    },
                    textColor: Colors.white,
                    backgroundColor: navyBlue,
                    text: "Update",
                  ),),

              ],
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
  Widget toggleActiveTag() {
    return CustomizedCheckBoxField(
      onTap: () {

      },
      isChecked: false,
      title: "Save For Future Reference",
    );
  }
  Widget addAddressField() {
    return CustomizedTextFormField(
      labelText: "Address",
      initialValue:  "",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field should not be empty";
      },
      onChanged: (val) {
       // shippingAddress.line_1 = val;
      },
    );
  }
  Widget addAddressLine2() {
    return Row(
      children: [
        Expanded(
          child: CustomizedTextFormField(
            labelText: "Building Name",
            initialValue:  "",
            validator: (val) {
              if (val.isNotEmpty) {
                return null;
              }
              return "This field should not be empty";
            },
            onChanged: (val) {
              // shippingAddress.line_1 = val;
            },
          ),
        ),
        const SizedBox(width: 20,),
        Expanded(
          child: CustomizedTextFormField(
            labelText: "Unit/Floor",
            initialValue:  "",
            validator: (val) {
              if (val.isNotEmpty) {
                return null;
              }
              return "This field should not be empty";
            },
            onChanged: (val) {
              // shippingAddress.line_1 = val;
            },
          ),
        ),
      ],
    );
  }
  Widget _mapUi(){
    return Container(
      height: 200,
      child: GoogleMap(
        onMapCreated: (controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(23.040060, 72.666630),
          zoom: 15.0,
        ),
        markers: _markers,
        onTap: (LatLng location) {
        //  _changeLocation(location);
        },
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
          ),
        },
      ),
    );
  }

  Widget _getTextView(String text){
   return Text(
     text,
      style: TextStyle(
        color: black,
        fontSize: 14,
        fontFamily: "Inter",
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getTextLightView(String text){
    return Text(
      text,
      style: TextStyle(
        color: black,
        fontSize: 12,
        fontFamily: "Inter",
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildAddLableView(){
    return Row(
      children: [
        CategoryChip(
          onTap: () {
            // showShcduleList =false;
            setState(() {});
          },
          title: 'Home',
          categoryColor:boxBorderColor,
          selectedCategoryTextColor:Colors.black,

        ),
        const SizedBox(width: 10,),
        CategoryChip(
          onTap: () {
            // showShcduleList =false;
            setState(() {});
          },
          title: 'Office',
          categoryColor:boxBorderColor,
          selectedCategoryTextColor:Colors.black,

        ),
        const SizedBox(width: 10,),
        CategoryChip(
          onTap: () {
            // showShcduleList =false;
            setState(() {});
          },
          title: 'Customer',
          categoryColor:navyBlue,
          selectedCategoryTextColor:Colors.white,

        ),
      ],
    );
  }

}
