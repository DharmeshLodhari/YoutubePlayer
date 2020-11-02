import 'dart:math';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'music_player.dart';

class MusicExploreScreen extends StatefulWidget {
  MusicPlayer musicPlayer;

  MusicExploreScreen({this.musicPlayer});

  @override
  _MusicExploreScreenState createState() => _MusicExploreScreenState();
}

class _MusicExploreScreenState extends State<MusicExploreScreen> {
  List<Map<String, String>> singerList = [
    {
      "name": "Wizkid",
      "image":
          "https://www.gstatic.com/tv/thumb/persons/1045961/1045961_v9_ba.jpg"
    },
    {
      "name": "Davido",
      "image":
          "https://www.grammy.com/sites/com/files/styles/news_detail_header/public/frankfieber_20181022_8-sm-scaled.jpg?itok=OdyzBPFd"
    },
    {
      "name": "Tiwa Savage",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/f/fa/Tiwa_Savage%27s_studio_portrait.jpg"
    },
    {
      "name": "Sinach",
      "image":
          "https://kgo.googleusercontent.com/profile_vrt_raw_bytes_1587515408_10954.jpg"
    },
  ];
  List<String> albumImgList = [
    "https://storage.googleapis.com/assets-pam-blog/2018/12/Dj-Neptune-Greatness.jpg",
    "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
    "https://i.ytimg.com/vi/MuXtUDQ8Sug/maxresdefault.jpg",
    "https://www.musicinafrica.net/sites/default/files/styles/article_slider_large/public/images/article/202008/djcuppy21.jpg?itok=ruxfue_g"
  ];

  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar(),
      body: scaffoldBody(),
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
        "Music",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 6,
          ),
          searchBox(),
          SizedBox(
            height: 32,
          ),
          cityCarouselSlider(),
          SizedBox(
            height: 40,
          ),
          rentDetail(
            categoryName: "Most recent discovery",
            moviePoster:
                "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
            movieName: "The Cloud Of Northland Thunder",
          ),
          albumList(categoryName: "Most popular album"),
          SizedBox(
            height: 16,
          ),
          exploreByCity(
            categoryName: "Top celebrate",
            moviePoster:
                "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
            movieName: "The Cloud Of Northland Thunder",
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionHandleColor: navyBlue,
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/search-music');
          },
          child: IgnorePointer(
            ignoring: true,
            child: TextFormField(
              readOnly: true,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
              ),
              cursorWidth: 1.5,
              cursorColor: navyBlue,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGrey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    SlydoAppIcon.search,
                    color: darkGrey,
                    size: 14,
                  ),
                  onPressed: () {},
                ),
                hintText: "Search",
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefix: Padding(
                  padding: EdgeInsets.only(left: 16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: navyBlue,
                    width: 1.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cityCarouselSlider() {
    return Container(
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
          viewportFraction: 0.9,
          enlargeCenterPage: false,
          autoPlay: true,
          aspectRatio: 2,
          initialPage: 0,
        ),
        items: albumImgList
            .map(
              (item) => GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/music-detail",arguments: {"musicPlayer":widget.musicPlayer});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Center(
                      child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: item,
                      fit: BoxFit.fill,
                      color: Colors.black12,
                      colorBlendMode: BlendMode.darken,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  )),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget rentDetail(
      {String categoryName, String movieName, String moviePoster}) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/music-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 242,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  children: albumImgList
                      .map(
                        (image) => Container(
                          margin:
                              EdgeInsets.only(right: 12, top: 16, bottom: 16),
                          child:
                              rentCard(cityPoster: image, cityName: movieName),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget rentCard({String cityName, String cityPoster}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/album-detail",arguments: {"musicPlayer":widget.musicPlayer});
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    cityPoster,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Run it down",
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: blackFont,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "₦",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: navyBlue,
                              fontFamily: "Roborto"),
                        ),
                        Text(
                          "34.00",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget exploreByCity(
      {String categoryName, String movieName, String moviePoster}) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/music-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  children: singerList
                      .map(
                        (element) => Container(
                          margin: EdgeInsets.only(right: 12),
                          child: cityCard(
                              cityPoster: element["image"],
                              cityName: element["name"]),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cityCard({String cityName, String cityPoster}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/album-detail",arguments: {"musicPlayer":widget.musicPlayer});
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cityName,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    cityPoster,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget albumList({String categoryName}) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/music-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      margin: EdgeInsets.only(right: 12),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/music-detail",arguments: {"musicPlayer":widget.musicPlayer});
                          },
                          child: albumPoster()),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget albumPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl:
            "https://www.naijaloaded.com.ng/wp-content/uploads/2019/10/erigga.jpg",
        height: 132,
        width: 218,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget eventPoster(String url) {
    bool temp = Random().nextBool();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/music-detail",arguments: {"musicPlayer":widget.musicPlayer});
      },
      child: Container(
        height: 132,
        width: 218,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black12,
                colorBlendMode: BlendMode.darken,
                imageUrl: url,
                fit: BoxFit.fill,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                temp ? "Beach event" : "Mongola",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
