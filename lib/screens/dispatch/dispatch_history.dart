import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/yarn/widgets/category_chip.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class DispatchHistoryScreen extends StatefulWidget {
  const DispatchHistoryScreen({super.key});

  @override
  State<DispatchHistoryScreen> createState() => _DispatchHistoryScreenState();
}

class _DispatchHistoryScreenState extends State<DispatchHistoryScreen> {
  bool showShcduleList = false;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget?,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(8.0),
        child:_buildBody(),
      ),
    );
  }
  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(
        'Activity',
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
      actions: _buildAppBarActions(),
      elevation: 0.5,
    );
  }
  List<Widget> _buildAppBarActions() {
    return [
     RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: const Icon(
        Icons.access_time_sharp,
        color: Colors.black,
        size: 20,
      ),
      onTap: () async {

      },
      backgroundColor: iconBtnGrey,
      enableMargin: false,
    ),
      const SizedBox(width: 15),
      RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: const Icon(
          Icons.filter_alt_rounded,
          size: 20,
        ),
        onTap: () async {

        },
        backgroundColor: iconBtnGrey,
        enableMargin: true,
      ),
      const SizedBox(width: 20),
    ];
  }

  Widget _buildBody(){
    return Column(
      children: [
        Row(
          children: [
            CategoryChip(
              onTap: () {
                showShcduleList =false;
                setState(() {});
              },
              title: 'Past',
              categoryColor: showShcduleList ?boxBorderColor :lightBlue,
              selectedCategoryTextColor:showShcduleList ?lightBlackFont:navyBlue,

            ),
            const SizedBox(width: 10,),
            CategoryChip(
              onTap: () {
                showShcduleList =true;
                setState(() {});
              },
              title: 'Schedule',
              categoryColor: showShcduleList ? lightBlue:boxBorderColor,
              selectedCategoryTextColor:showShcduleList ? navyBlue :lightBlackFont,

            ),
          ],
        ),
        const SizedBox(height: 10,),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (con,index){
            return _buildSingleRow();
          
          }),
        )
      ],
    );
  }
  Widget _buildSingleRow(){
    return  GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, Routes.TRIP_DETAILS);
      },
      child:
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
              const SizedBox(height: 10,),

              Row(
                children: [
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
              const SizedBox(height: 10,),
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
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14),
                        ),
                        const SizedBox(height: 10,),

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
            ],
          ),
        ),
      ),
    );
  }
}
