import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
class SearchAddressScreen extends StatefulWidget {
  const SearchAddressScreen({super.key});

  @override
  State<SearchAddressScreen> createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  TextEditingController controller = TextEditingController();


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
    //  titleSpacing: 16,
      title: Row(
        children: [
          /*IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context, "back pressed");
            },
          ),*/
          InkWell(
            onTap: (){
              Navigator.pop(context, "back pressed");
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
              size: 24,
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: greyTagColor
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
            
                  const SizedBox(width: 10,),
                  Icon(Icons.search,
                  size: 24,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 10),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent), // Transparent bottom line
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent), // Transparent on focus
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: (){

                      controller.text  = '';
                      setState(() {});
                    },
                    child: Icon(Icons.close,
                      size: 24,
                      color: black,
                    ),
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
            ),
          ),
        ],
      ),
      elevation: 0,

    );
  }
  Widget _buildBody(){
    return Container(
      child: ListView.builder(
          itemCount:3,
          shrinkWrap: true,
          itemBuilder: (context,index){

            return Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 30,right: 10,top: 4),

              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(Routes.ADD_NEW_ADDRESS);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                    size: 24,
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jacob James',
                            style: TextStyle(
                              color: black,
                              fontSize: 14,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '101, Lagos-Ikorodu Expressway,',
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

                  ],
                ),
              ),
            );
      }),
    );
  }

  placesAutoCompleteTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey:"AIzaSyAs0AD96236ASgq_7l8u4q9OHW0bOuESV8",
        inputDecoration: InputDecoration(
          hintText: "Search your location",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: ["in", "fr"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },

        itemClick: (Prediction prediction) {
          controller.text = prediction.description ?? "";
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,


        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },

        isCrossBtnShown: true,

        // default 600 ms ,
      ),
    );
  }
}
