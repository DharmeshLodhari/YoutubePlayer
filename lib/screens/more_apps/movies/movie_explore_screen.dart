import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MovieExploreScreen extends StatefulWidget {
  @override
  _MovieExploreScreenState createState() => _MovieExploreScreenState();
}

class _MovieExploreScreenState extends State<MovieExploreScreen> {
  List<String> imgList = [
    "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
    "https://occ-0-92-1723.1.nflxso.net/dnm/api/v6/X194eJsgWBDE2aQbaNdmCXGUP-Y/AAAABfyfVmzawFldwvYxxIfCr5xg_lsH9NZoQMVve9upZzDxlhuUaeJIMvwH8HiEvISV6X8lJ3CtsOst33FYzzearPngMTxq1CI90Rz9UCPJ-uu8c4QegoJm-lzHI-uC.jpg",
    "https://deythere.com/wp-content/uploads/2019/12/zero-hour.png",
    "https://m.media-amazon.com/images/M/MV5BMDljNjk3MWYtYjA4Zi00MDUyLWI2ZmUtOTQ3ZTI4YWUxYTI5XkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg",
    "https://www.bellanaija.com/wp-content/uploads/2017/01/Arbitration2-723x1024.jpg"
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
        "Movies",
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
        movieCarouselSlider(),
        SizedBox(
          height: 40,
        ),
        movieCategoryWithDetail(
          categoryName: "Most recent discovery",
          moviePoster:
              "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
          movieName: "The Cloud Of Northland Thunder",
        ),
        movieCategoryWithOutDetail(categoryName: "Indie Picks"),
        SizedBox(
          height: 16,
        ),
        movieCategoryWithDetail(
          categoryName: "Now available to rent",
          moviePoster:
              "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
          movieName: "Dawn Of Thunder",
        ),
        SizedBox(
          height: 10,
        ),
      ],
    ));
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
            Navigator.of(context).pushNamed('/search-movie');
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

  Widget movieCarouselSlider() {
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
        items: imgList
            .map((item) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Center(
                      child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: item,
                      fit: BoxFit.fill,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  )),
                ))
            .toList(),
      ),
    );
  }

  Widget movieCategoryWithDetail(
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
                    Navigator.of(context).pushNamed("/movie-category");
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
                  children: List.generate(
                    100,
                    (index) => Container(
                      margin: EdgeInsets.only(right: 12),
                      child: movieItemWithDetail(
                          moviePoster: moviePoster, movieName: movieName),
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

  Widget movieItemWithDetail({String movieName, String moviePoster}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/movie-detail");
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    moviePoster,
                    height: 80,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  movieName,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                SizedBox(
                  height: 1,
                ),
                Row(
                  children: [
                    Icon(
                      SlydoAppIcon.naira,
                      color: navyBlue,
                      size: 8,
                    ),
                    Text(
                      "34.00",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: navyBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          SlydoAppIcon.star,
                          color: starYellow,
                          size: 12,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "7.8",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        )
                      ],
                    ),
                    flexibleSpace(),
                    Text(
                      "2020 • Action",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: darkGrey,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget movieCategoryWithOutDetail({String categoryName}) {
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
                    Navigator.of(context).pushNamed("/movie-category");
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
                    100,
                    (index) => Container(
                      margin: EdgeInsets.only(right: 12),
                      child: moviePoster(),
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

  Widget moviePoster() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/movie-detail");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: "https://i.ytimg.com/vi/Jd6FuSkDkmU/maxresdefault.jpg",
          height: 132,
          width: 218,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
