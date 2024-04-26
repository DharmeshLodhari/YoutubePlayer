import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/hotels/hotel_auth.dart';
import 'package:Slydo/screens/more_apps/hotels/models/HotelRoomItem.dart';
import 'package:Slydo/screens/more_apps/hotels/models/PartialHotelRoomItem.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'hotel_tile.dart';
import 'models/CityData.dart';

class HotelExploreScreen extends StatefulWidget {
  @override
  _HotelExploreScreenState createState() => _HotelExploreScreenState();
}

class _HotelExploreScreenState extends State<HotelExploreScreen> {
  final CarouselController _carouselController = CarouselController();

  List<PartialHotelRoomItem> sliderItem = [];
  bool isSliderLoading = false;

  List<HotelRoomItem> nearByItem = [];
  bool isNearByItemLoading = false;

  List<PartialHotelRoomItem> mostRecentDiscovery = [];
  bool isMostRecentDiscoveryLoading = false;

  List<CityData> listOfCity = [];
  bool isExploreByCityLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() {
    getSliderItems();
    getNearByItem();
    getMostRecentDiscoveryItem();
    getExploreByCityItem();
  }

  void getSliderItems() async {
    isSliderLoading = true;
    sliderItem.clear();
    if (mounted) setState(() {});

    sliderItem = await HotelAuthService().getPartialHotelRoomList();

    isSliderLoading = false;
    if (mounted) setState(() {});
  }

  void getNearByItem() async {
    isNearByItemLoading = true;
    nearByItem.clear();
    if (mounted) setState(() {});

    nearByItem = await HotelAuthService().getHotelRoomList();

    isNearByItemLoading = false;
    if (mounted) setState(() {});
  }

  void getMostRecentDiscoveryItem() async {
    isMostRecentDiscoveryLoading = true;
    mostRecentDiscovery.clear();
    if (mounted) setState(() {});

    mostRecentDiscovery = await HotelAuthService().getPartialHotelRoomList();

    isMostRecentDiscoveryLoading = false;
    if (mounted) setState(() {});
  }

  void getExploreByCityItem() async {
    isExploreByCityLoading = true;
    listOfCity.clear();
    if (mounted) setState(() {});

    listOfCity = await HotelAuthService().getCityList();

    isExploreByCityLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
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
        "Hotels",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        locationChip(),
        const SizedBox(
          width: 16,
        )
      ],
    );
  }

  Widget locationChip() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          color: navyBlue.withOpacity(0.1)),
      child: Row(
        children: [
          Icon(
            SlydoAppIcon.location,
            color: blackFont,
            size: 14,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            "London",
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget scaffoldBody() {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),
            searchBox(),
            const SizedBox(
              height: 32,
            ),
            cityCarouselSlider(),
            const SizedBox(
              height: 40,
            ),
            nearByYou(),
            mostRecentDiscoveryList(),
            const SizedBox(
              height: 16,
            ),
            exploreByCity(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/search-hotel');
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefix: const Padding(
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
      child: isSliderLoading
          ? Container(
              height: 180,
              child: Center(
                child: CircularLoadingIndicator(),
              ),
            )
          : CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                viewportFraction: 0.9,
                enlargeCenterPage: false,
                autoPlay: true,
                aspectRatio: 2,
                initialPage: 0,
              ),
              items: sliderItem
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed("/hotel-detail");
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Center(
                                child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: CachedNetworkImage(
                                imageUrl: item.image!,
                                fit: BoxFit.fill,
                                color: Colors.black12,
                                colorBlendMode: BlendMode.darken,
                                height: double.infinity,
                                width: double.infinity,
                                errorWidget: imageErrorWidget,
                              ),
                            )),
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Homestay",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget mostRecentDiscoveryList() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Most recent discovery",
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
            height: 230,
            color: Colors.white,
            child: isMostRecentDiscoveryLoading
                ? Center(
                    child: CircularLoadingIndicator(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: mostRecentDiscovery
                            .map(
                              (hotelRoom) => Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: PartialHotelRoomItemTile(
                                  hotelRoom: hotelRoom,
                                ),
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

  Widget exploreByCity() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Explore by City",
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
          height: 210,
          color: Colors.white,
          child: isExploreByCityLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: listOfCity
                          .map(
                            (city) => Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: CityItemCard(
                                city: city,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
        )
      ],
    );
  }

  Widget nearByYou() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Nearby you",
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
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isNearByItemLoading
                ? Container(
                    height: 220,
                    width: double.infinity,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        bottom: 12,
                      ),
                      child: Row(
                        children: nearByItem
                            .map((element) => Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child:
                                      HotelRoomImagesTile(hotelRoom: element),
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
}
