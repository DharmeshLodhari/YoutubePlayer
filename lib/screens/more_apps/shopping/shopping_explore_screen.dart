import 'dart:math';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingExploreScreen extends StatefulWidget {
  @override
  _ShoppingExploreScreenState createState() => _ShoppingExploreScreenState();
}

class _ShoppingExploreScreenState extends State<ShoppingExploreScreen> {
  List<String> imgList = [
    "https://cdn-images.farfetch-contents.com/14/74/09/49/14740949_23544540_600.jpg",
    "https://i.pinimg.com/236x/11/94/65/1194653fe7741dd89aa7a931391c4b80.jpg",
    "https://images-na.ssl-images-amazon.com/images/I/41Leu3gBUFL.jpg",
    "https://assetscdn1.paytm.com/images/catalog/product/F/FO/FOOCLYMB-MEN-S-ONUS48054F58F7F3D/1593856301469_0..jpeg",
    "https://images-na.ssl-images-amazon.com/images/I/81HSzsIkJdL._AC_SL1500_.jpg"
  ];

  CarouselController _carouselController = CarouselController();

  var _dashboardBloc;

  BasketBloc basketBloc;

  @override
  Widget build(BuildContext context) {
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
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
        "Shopping",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        goToCartWidget(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget goToCartWidget() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Badge(
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: getBadgeContent(),
        padding: basketBloc.items.length == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.all(4),
        position: BadgePosition(right: 0, top: 0),
        child: Icon(
          SlydoAppIcon.cart,
          size: 16,
          color: blackFont,
        ),
      ),
      onTap: () {
        _dashboardBloc.index = 3;
        Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'];
    });
    return totalItem;
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
        eventCategoryWithOutDetail(categoryName: "Today's deal"),
        SizedBox(
          height: 16,
        ),
        exploreByCity(
          categoryName: "Trending Products",
          moviePoster:
              "https://images-na.ssl-images-amazon.com/images/I/41Leu3gBUFL.jpg",
          movieName: "The Cloud Of Northland Thunder",
        ),
        SizedBox(
          height: 16,
        ),
        foodFestivalEvent(categoryName: "Deal's upto 75% off"),
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
            Navigator.of(context).pushNamed('/search-event');
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
            .map(
              (item) => GestureDetector(
                onTap: () {
                  AuthService()
                      .getProduct("f0a6eed3-b8db-44b0-9b06-e20e02a01e0a")
                      .then((value) {
                    Navigator.pushNamed(context, '/product',
                        arguments: {"product": value});
                  });
                },
                child: Container(
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
                ),
              ),
            )
            .toList(),
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
                    Navigator.of(context).pushNamed("/event-category");
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
                    5,
                    (index) => Container(
                      margin: EdgeInsets.only(right: 12),
                      child: cityCard(
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

  Widget cityCard({String movieName, String moviePoster}) {
    return GestureDetector(
      onTap: () {
        AuthService()
            .getProduct("f0a6eed3-b8db-44b0-9b06-e20e02a01e0a")
            .then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
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
                  "Shoes",
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
                    moviePoster,
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

  Widget eventCategoryWithOutDetail({String categoryName}) {
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
                    Navigator.of(context).pushNamed("/event-category");
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
                  children: imgList
                      .map((element) => Container(
                            margin: EdgeInsets.only(right: 12),
                            child: eventPoster(element),
                          ))
                      .toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget foodFestivalEvent({String categoryName}) {
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
                    Navigator.of(context).pushNamed("/event-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    Container(
                      height: 244,
                      child: CustomBoxShadow(
                        child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.zero,
                            shadowColor: boxShadowTwo,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      child: CachedNetworkImage(
                                        width: double.infinity,
                                        imageUrl:
                                            "https://images-na.ssl-images-amazon.com/images/I/81HSzsIkJdL._AC_SL1500_.jpg",
                                        fit: BoxFit.fill,
                                        filterQuality: FilterQuality.high,
                                      ),
                                      onTap: () {
                                        AuthService()
                                            .getProduct(
                                                "f0a6eed3-b8db-44b0-9b06-e20e02a01e0a")
                                            .then((value) {
                                          Navigator.pushNamed(
                                              context, '/product',
                                              arguments: {"product": value});
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Thu, Oct 15 • 6:54 AM",
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: mateRed,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                "Bronx night market",
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: blackFont,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                "Humankind is now facing a global crisis...",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: darkGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 86,
                                          child: Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  SlydoAppIcon.naira,
                                                  color: navyBlue,
                                                  size: 10,
                                                ),
                                                Text(
                                                  "34.00",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: navyBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Column(
                      children: imgList
                          .map((element) => Container(
                                margin: EdgeInsets.only(bottom: 12),
                                child: EventTileWithHeart(imageUrl: element),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget eventPoster(String url) {
    bool temp = Random().nextBool();
    return GestureDetector(
      onTap: () {
        AuthService()
            .getProduct("f0a6eed3-b8db-44b0-9b06-e20e02a01e0a")
            .then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
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
