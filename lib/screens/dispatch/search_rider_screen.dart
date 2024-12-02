import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class SearchingRiderScreen extends StatelessWidget {
  const SearchingRiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        color: blackFont,
        child: Stack(
          children: [

            _buildSelectDestination(context),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/rider_img.png",

                    //   color: navyBlue,
                    colorBlendMode: BlendMode.darken,
                    // fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    'Searching for a driver',
                    style: TextStyle(
                        color: white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSelectDestination(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.21,
      maxChildSize: 0.21,
      minChildSize: 0.21,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: _buildAddressSelection(context),
        ),
      ),
    );
  }
  Widget _buildAddressSelection(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(Routes.SLYDER_ARRIVING);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border:
          Border.all(color: Colors.blue), // replace with navyBlue if defined
          borderRadius: BorderRadius.circular(10),
        ),
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
    );
  }
}
