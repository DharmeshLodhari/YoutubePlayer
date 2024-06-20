import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hotel_dashboard_bloc.dart';
import 'my_hotel_list.dart';
import 'my_wish_list.dart';

class MyHotelsScreen extends StatefulWidget {
  const MyHotelsScreen({super.key});

  @override
  State<MyHotelsScreen> createState() => _MyHotelsScreenState();
}

class _MyHotelsScreenState extends State<MyHotelsScreen> {
  int currentIndex = 0;

  late HotelDashboardBloc _hotelDashboardBloc;
  @override
  Widget build(BuildContext context) {
    _hotelDashboardBloc = Provider.of<HotelDashboardBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          _hotelDashboardBloc.index = 0;
          return;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: tabViews(),
        ),
      ),
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
          _hotelDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "My hotels",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar() as PreferredSizeWidget?,
    );
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "My hotels",
                style: TextStyle(
                  color: currentIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "Wishlist",
                style: TextStyle(
                  color: currentIndex == 1 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: const [
        MyHotelList(),
        MyWishList(),
      ],
    );
  }
}
