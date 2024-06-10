import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
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

  MyMusicList({super.key, this.musicPlayer});

  @override
  _MyMusicListState createState() => _MyMusicListState();
}

class _MyMusicListState extends State<MyMusicList> {
  List<PartialMusicItem> musicList = [];
  final RefreshController _refreshController =
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
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  late MusicDashboardBloc _musicDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _musicDashboardBloc = Provider.of<MusicDashboardBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          _musicDashboardBloc.index = 0;
          return;
        }
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
