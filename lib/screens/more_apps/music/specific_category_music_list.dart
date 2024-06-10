import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/PartialMusicItem.dart';
import 'music_auth.dart';
import 'music_tile.dart';

class SpecificCategoryMusicList extends StatefulWidget {
  const SpecificCategoryMusicList({super.key});

  @override
  _SpecificCategoryMusicListState createState() =>
      _SpecificCategoryMusicListState();
}

class _SpecificCategoryMusicListState extends State<SpecificCategoryMusicList> {
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
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
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
                              ),
                            ),
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
