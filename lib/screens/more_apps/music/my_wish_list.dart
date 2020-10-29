import 'package:flutter/material.dart';

import 'music_tile.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  List<String> imgList = [
    "https://storage.googleapis.com/assets-pam-blog/2018/12/Dj-Neptune-Greatness.jpg",
    "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
    "https://i.ytimg.com/vi/MuXtUDQ8Sug/maxresdefault.jpg",
    "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: imgList
                .map(
                  (element) => Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: MusicTileWithHeart(
                        image: element,
                      )),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
