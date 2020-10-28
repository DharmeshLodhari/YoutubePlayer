import 'package:Slydo/screens/more_apps/review/main_review.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'music_dashboard_bloc.dart';
import 'music_tile.dart';

class MusicDetailPage extends StatefulWidget {
  @override
  _MusicDetailPageState createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  MusicDashboardBloc _hotelDashboardBloc;

  List<String> imgList = [
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
  ];

  List<String> hotelImgList = [
    "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
    "https://www.thebalancesmb.com/thmb/R5CjZrWUBXBTVj48-MBx3PFIh5U=/3000x2000/filters:fill(auto,1)/hotel_room-627892060-5a7a30d1642dca00370179e6.jpg",
    "https://media.istockphoto.com/photos/3d-rendering-modern-luxury-bedroom-suite-and-bathroom-picture-id928431714?k=6&m=928431714&s=612x612&w=0&h=IBnf0aE9zEmsaJ3nLep6UmK4u-KYQPdEQa6LY30Ivn4=",
    "https://gritdaily.com/wp-content/uploads/2019/07/http-cdn.cnn_.com-cnnnext-dam-assets-190711000204-haneda-excel-hotel-tokyu-03.jpg",
    "https://blisssaigon.com/wp-content/uploads/2019/10/iwood-R5v8Xtc0ecg-unsplash-1.jpg"
  ];

  List<String> availableDates = ["18", "25", "01", "08", "15"];
  int selectedDate = 0;

  bool isWishList = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hotelDashboardBloc = Provider.of<MusicDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () {
        _hotelDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: scaffoldBody(),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      actions: <Widget>[
        shareBtn(),
        SizedBox(
          width: 8,
        ),
        addToCartBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget shareBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget addToCartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.cart,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          eventPoster(),
          Column(
            children: [
              SizedBox(
                height: 24,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: eventNameAndHostInformation(),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Divider(
                      thickness: 1,
                      color: dividerColor,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    features(),
                    SizedBox(
                      height: 16,
                    ),
                    Divider(
                      thickness: 1,
                      color: dividerColor,
                      height: 0,
                    ),
                    selectDate(),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                      thickness: 1,
                      color: dividerColor,
                      height: 0,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    availabilitySection(),
                    SizedBox(
                      height: 16,
                    ),
                    Divider(
                      thickness: 1,
                      color: dividerColor,
                      height: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          propertyFeature(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Divider(
                  thickness: 1,
                  color: dividerColor,
                  height: 16,
                ),
                SizedBox(
                  height: 8,
                ),
                aboutEvent(),
                SizedBox(
                  height: 12,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                ),
                SizedBox(
                  height: 12,
                ),
                eventLocation(),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                  height: 0,
                ),
                SizedBox(
                  height: 12,
                ),
                reviewsList(),
                aboutPartnerList(),
                SizedBox(
                  height: 12,
                ),
                askQuestionBtn(),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          rentDetail(
            categoryName: "Recommended for you",
            moviePoster:
                "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
            movieName: "The Cloud Of Northland Thunder",
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget eventPoster() {
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            CachedNetworkImage(
              width: double.infinity,
              height: double.infinity,
              imageUrl:
                  "https://www.gannett-cdn.com/-mm-/05b227ad5b8ad4e9dcb53af4f31d7fbdb7fa901b/c=0-64-2119-1259/local/-/media/USATODAY/USATODAY/2014/08/13/1407953244000-177513283.jpg",
              fit: BoxFit.fill,
            ),
            Positioned(
              right: 12,
              top: 12,
              child: InkWell(
                child: Icon(
                  isWishList ? SlydoAppIcon.heart_1 : SlydoAppIcon.heart_empty,
                  color: Colors.white,
                  size: 22,
                ),
                onTap: () {
                  isWishList = !isWishList;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventNameAndHostInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lake side cottage',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              children: [
                Icon(
                  SlydoAppIcon.star,
                  color: starYellow,
                  size: 11,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  "7.8",
                  style: TextStyle(fontSize: 14, color: blackFont),
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          '3 beds • 2 bath • 1 livingroom',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        ),
        SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Container(
              height: 32,
              width: 32,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      "https://cdn.thewhistler.ng/wp-content/uploads/2020/06/ChiNna-Okoroafor-2.jpg",
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              "Bond street dojo",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            )
          ],
        )
      ],
    );
  }

  Widget features() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Feature",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 8,
        ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      RoundedBackgroundIcon(
                        backgroundColor: starYellow.withOpacity(0.08),
                        height: 32,
                        width: 32,
                        borderRadius: 12,
                        icon: Icon(
                          SlydoAppIcon.star,
                          size: 14,
                          color: starYellow,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          "Top Rated",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: blackFont),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      RoundedBackgroundIcon(
                        backgroundColor: naturalGreen.withOpacity(0.08),
                        height: 32,
                        borderRadius: 12,
                        width: 32,
                        icon: Icon(
                          SlydoAppIcon.achievement,
                          size: 14,
                          color: naturalGreen,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          "Fresh Listing",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: blackFont),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      RoundedBackgroundIcon(
                        backgroundColor: mateRed.withOpacity(0.08),
                        borderRadius: 12,
                        height: 32,
                        width: 32,
                        icon: Icon(
                          SlydoAppIcon.fire,
                          size: 14,
                          color: mateRed,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Hot area",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackFont),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ],
    );
  }

  Widget propertyFeature() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Property features",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.garden,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Garden",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.kitchen,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Kitchen",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.washer,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Washer",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.tv,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "TV",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.free_wifi,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Free wifi",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    RoundedBackgroundIcon(
                      backgroundColor: lightGrey,
                      borderRadius: 12,
                      height: 32,
                      width: 32,
                      icon: Icon(
                        SlydoAppIcon.bathroom,
                        size: 14,
                        color: blackFont,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Bathroom",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
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
                    Navigator.of(context).pushNamed("/hotel-category");
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
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: Row(
                  children: hotelImgList
                      .map(
                        (image) => Container(
                          margin: EdgeInsets.only(right: 12),
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
        Navigator.of(context).pushNamed("/hotel-detail");
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "From ",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: blackFont,
                                ),
                              ),
                              Text(
                                "₦",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: blackFont,
                                    fontFamily: "Roborto"),
                              ),
                              Text(
                                "34.00",
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: blackFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "/ month ",
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: darkGrey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "3 beds in London",
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: blackFont,
                      ),
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

  Widget dateAndTimeTile(String type, String date) {
    bool isSelected = false;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: boxShadowTwo,
            offset: Offset(0.0, 0.0),
            blurRadius: 20.0,
          ),
        ],
        color: isSelected ? navyBlue : Colors.white,
        borderRadius: BorderRadius.all(
          const Radius.circular(10.0),
        ),
        border: new Border.all(
            color: isSelected ? navyBlue : lightGrey,
            width: 1.0,
            style: BorderStyle.solid),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        children: [
          Text(
            type,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : blackFont),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            date,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : blackFont),
          ),
        ],
      ),
    );
  }

  Widget aboutEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          '''Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.''',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget eventLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Location",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Text(
              "Direction",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w400, color: navyBlue),
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          height: 180,
          width: 335,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: CachedNetworkImage(
            imageUrl:
                "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/e97dfc8dfdfa529c0da2248948fff5caba872d65/location.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget reviewsList() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reviews",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: blackFont,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Column(
            children: List.generate(
                3,
                (index) => Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ReviewTile(),
                    )),
          ),
        ],
      ),
    );
  }

  Widget aboutPartnerList() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About the partner",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: blackFont,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Column(
            children: List.generate(
                1,
                (index) => Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/partner-detail");
                          },
                          child: PartnerTile()),
                    )),
          ),
        ],
      ),
    );
  }

  Widget availabilitySection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Availability",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: blackFont,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          OutlineCurvedButton(
            text: "Add your dates",
            onPressed: () {},
            textColor: navyBlue,
          ),
        ],
      ),
    );
  }

  Widget selectDate() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: blackFont,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(child: dateAndTimeTile("Check in", "Oct 25")),
              SizedBox(
                width: 20,
              ),
              Expanded(child: dateAndTimeTile("Check out", "Nov 25")),
            ],
          ),
        ],
      ),
    );
  }

  Widget askQuestionBtn() {
    return OutlineCurvedButton(
      text: "Ask a question",
      onPressed: () {},
      textColor: navyBlue,
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: _buildBuyButtonWidget(),
      ),
    );
  }

  Widget addToCartWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {},
    );
  }

  Widget _buildBuyButtonWidget() {
    return CurvedButton(
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "BOOK",
      onPressed: () {},
    );
  }
}
