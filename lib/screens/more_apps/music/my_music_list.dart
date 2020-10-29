import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'music_dashboard_bloc.dart';
import 'music_tile.dart';

class MyMusicList extends StatefulWidget {
  @override
  _MyMusicListState createState() => _MyMusicListState();
}

class _MyMusicListState extends State<MyMusicList> {
  List<String> imgList = [
    "https://storage.googleapis.com/assets-pam-blog/2018/12/Dj-Neptune-Greatness.jpg",
    "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
    "https://i.ytimg.com/vi/MuXtUDQ8Sug/maxresdefault.jpg",
    "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g",
    "https://www.gstatic.com/tv/thumb/persons/1045961/1045961_v9_ba.jpg",
    "https://www.grammy.com/sites/com/files/styles/news_detail_header/public/frankfieber_20181022_8-sm-scaled.jpg?itok=OdyzBPFd",
    "https://upload.wikimedia.org/wikipedia/commons/f/fa/Tiwa_Savage%27s_studio_portrait.jpg",
    "https://kgo.googleusercontent.com/profile_vrt_raw_bytes_1587515408_10954.jpg"
  ];
  MusicDashboardBloc _hotelDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _hotelDashboardBloc = Provider.of<MusicDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _hotelDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: imgList
                  .map(
                    (element) => Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: MusicTileGeneral(
                          image: element,
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
