import 'package:Slydo/screens/yarn/widgets/category_chip.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget?,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        // padding: EdgeInsets.all(8.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(
        'Trip Details',
        style: TextStyle(
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
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
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.all(6.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '21 November,2023',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: lightBlackFont,
                          ),
                        ),
                        const Spacer(),
                        CategoryChip(
                          onTap: () {},
                          title: 'Completed',
                          categoryColor: lightGreenBg,
                          selectedCategoryTextColor: green,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/dispatch/dummy_driver_pic.jpeg',
                          // Replace with the URL of the image you want to use
                          width: 24,
                          height: 24,
                          fit: BoxFit
                              .cover, // Optional: Use BoxFit to control how the image fits
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Bimpe Ajoshin',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₦2500',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: fontLightGrey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '4 Items (18kg)',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: yarnBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Section
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SvgPicture.asset(
                            'assets/images/rider/ic_route.svg',
                            height: 50,
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
                                style:
                                    TextStyle(fontFamily: 'Inter', fontSize: 14),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '20, Pedro Street, Alausa, Ikeja',
                                style:
                                    TextStyle(fontFamily: 'Inter', fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                        color: black,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
        
                    Row(
                      children: [
                        Text(
                          'Dispatch Slyder',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: lightBlackFont,
                              fontFamily: 'Inter',
                              fontSize: 14),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/images/dispatch/dummy_driver_pic.jpeg',
                            // Replace with the correct path to your asset image
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Jacob James',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: lightBlackFont,
                              fontFamily: 'Inter',
                              fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Distance Covered :', '23km'),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Duration :', '1hr 30mins'),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Items (4) :', '18 kg'),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600,
                        color: black,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Base Fare ', '₦2000'),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Booking Fee', '₦500'),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Rounding Fee', '₦300'),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildCommonData('Discount', '-₦300',tag: true),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: black,
                                fontFamily: 'Inter',
                                fontSize: 18),
                          ),
                          const Spacer(),
                          Text(
                            '₦2500',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: black,
                                fontFamily: 'Inter',
                                fontSize: 18),
                          ),
                        ],
                      ),
                    _buildCommonData('Payment Mode', 'Via Slydo'),
        
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0), // Set radius here
              child: Image.asset(
                'assets/images/dispatch/parcel_image.png',
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            const SizedBox(height: 10,),
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Review',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: black,
                              fontFamily: 'Inter',
                              fontSize: 18),
                        ),
                        const Spacer(),
                        Icon(Icons.edit)
                      ],
                    ),
                    Text(
                      'Polite and fast.',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: blackFont,
                          fontFamily: 'Inter',
                          fontSize: 12),
                    ),
        
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonData(String title, String data,{bool tag = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: tag ? navyBlue:lightBlackFont,
              fontFamily: 'Inter',
              fontSize: 14),
        ),
        const Spacer(),
        const SizedBox(
          width: 10,
        ),
        Text(
          data,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color:  tag ? navyBlue:lightBlackFont,
              fontFamily: 'Inter',
              fontSize: 14),
        ),
      ],
    );
  }
}
