import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'hotel_auth.dart';
import 'hotel_dashboard_bloc.dart';
import 'hotel_tile.dart';
import 'models/HotelRoomItem.dart';

class MyHotelList extends StatefulWidget {
  @override
  _MyHotelListState createState() => _MyHotelListState();
}

class _MyHotelListState extends State<MyHotelList> {
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
      child: Scaffold(
        backgroundColor: Colors.white,
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
}
