import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'hotel_auth.dart';
import 'hotel_tile.dart';
import 'models/HotelRoomItem.dart';

class SpecificCategoryHotelList extends StatefulWidget {
  @override
  State<SpecificCategoryHotelList> createState() =>
      _SpecificCategoryHotelListState();
}

class _SpecificCategoryHotelListState extends State<SpecificCategoryHotelList> {
  List<HotelRoomItem> hotelRooms = [];
  bool isLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    hotelRooms.clear();
    if (mounted) setState(() {});

    hotelRooms = await HotelAuthService().getHotelRoomList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: hotelRooms
                    .map(
                      (element) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: HotelRoomImagesTile(
                            hotelRoom: element,
                          )),
                    )
                    .toList(),
              ),
            ),
          ),
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Popular in London",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
