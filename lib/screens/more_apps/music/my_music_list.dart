import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/PartialMusicItem.dart';
import 'music_auth.dart';
import 'music_dashboard_bloc.dart';
import 'music_player.dart';
import 'music_tile.dart';

// ignore: must_be_immutable
class MyMusicList extends StatefulWidget {
  MusicPlayer? musicPlayer;

  MyMusicList({this.musicPlayer});

  @override
  _MyMusicListState createState() => _MyMusicListState();
}

class _MyMusicListState extends State<MyMusicList> {
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
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
  }

  late MusicDashboardBloc _musicDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _musicDashboardBloc = Provider.of<MusicDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _musicDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: musicList
                          .map(
                            (partialMusicItem) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: MusicTileGeneral(
                                  partialMusicItem: partialMusicItem,
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
