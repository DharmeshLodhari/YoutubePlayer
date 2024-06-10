import 'package:Slydo/screens/more_apps/music/models/partial_music_item.dart';
import 'package:Slydo/screens/more_apps/music/music_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'music_tile.dart';

class MyWishList extends StatefulWidget {
  const MyWishList({super.key});

  @override
  State<MyWishList> createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
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
      _refreshController.refreshCompleted();
    }
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: musicList
                        .map(
                          (musicItem) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
