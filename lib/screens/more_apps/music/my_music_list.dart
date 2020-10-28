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
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
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
                        child: MusicTileGeneral()),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
