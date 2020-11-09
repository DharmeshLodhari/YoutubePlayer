import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/music/models/PartialMusicItem.dart';
import 'package:Slydo/screens/more_apps/music/music_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import 'music_tile.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  List<PartialMusicItem> musicList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    musicList.clear();
    if (mounted) setState(() {});

    musicList = await MusicAuthService().getMusicItemList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: navyBlue);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularLoadingIndicator(),
            )
          : SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: musicList
                        .map(
                          (musicItem) => Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: MusicTileWithHeart(
                                musicItem: musicItem,
                              )),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
