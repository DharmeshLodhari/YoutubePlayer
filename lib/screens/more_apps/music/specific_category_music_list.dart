import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

import 'music_tile.dart';

class SpecificCategoryMusicList extends StatefulWidget {
  @override
  _SpecificCategoryMusicListState createState() =>
      _SpecificCategoryMusicListState();
}

class _SpecificCategoryMusicListState extends State<SpecificCategoryMusicList> {
  List<String> imgList = [
    "https://storage.googleapis.com/assets-pam-blog/2018/12/Dj-Neptune-Greatness.jpg",
    "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
    "https://i.ytimg.com/vi/MuXtUDQ8Sug/maxresdefault.jpg",
    "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g"
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: imgList
                  .map(
                    (image) => Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: MusicTileWithHeart(
                        image: image,
                      ),
                    ),
                  )
                  .toList(),
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
