import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/events/event_auth.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/screens/more_apps/events/models/EventPoster.dart';
import 'package:Slydo/screens/more_apps/events/models/PartialEventItem.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../messaging/chat/utils.dart';
import 'models/CityData.dart';

class EventExploreScreen extends StatefulWidget {
  @override
  _EventExploreScreenState createState() => _EventExploreScreenState();
}

class _EventExploreScreenState extends State<EventExploreScreen> {
  List<EventPoster> eventPosterSlider = [];
  bool isSliderLoading = false;

  List<EventPoster> popularInLocation = [];
  bool isPopularInLocationLoading = false;

  List<CityData> listOfCity = [];
  bool isExploreByCityLoading = false;

  List<PartialEventItem> eventList = [];
  bool isEventListLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() {
    getSliderItem();
    getPopularInLocationItem();
    getExploreByCityItem();
    getEventListItem();
  }

  void getSliderItem() async {
    isSliderLoading = true;
    eventPosterSlider.clear();
    if (mounted) setState(() {});

    eventPosterSlider = await EventAuthService().getEventPosterList();

    isSliderLoading = false;
    if (mounted) setState(() {});
  }

  void getPopularInLocationItem() async {
    isPopularInLocationLoading = true;
    popularInLocation.clear();
    if (mounted) setState(() {});

    popularInLocation = await EventAuthService().getEventPosterList();

    isPopularInLocationLoading = false;
    if (mounted) setState(() {});
  }

  void getExploreByCityItem() async {
    isExploreByCityLoading = true;
    listOfCity.clear();
    if (mounted) setState(() {});

    listOfCity = await EventAuthService().getCityList();

    isExploreByCityLoading = false;
    if (mounted) setState(() {});
  }

  void getEventListItem() async {
    isEventListLoading = true;
    eventList.clear();
    if (mounted) setState(() {});

    eventList = await EventAuthService().getPartialEventList();

    isEventListLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
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
        "Events",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
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
          eventCarouselSlider(),
          const SizedBox(
            height: 40,
          ),
          nearByEvents(),
          const SizedBox(
            height: 16,
          ),
          exploreByCity(),
          const SizedBox(
            height: 16,
          ),
          foodFestivalEvent(categoryName: "Food festival events"),
          const SizedBox(
            height: 10,
          ),
        ],
      )),
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

  Widget eventCarouselSlider() {
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
              items: eventPosterSlider
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed("/event-detail");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: item.image!,
                            fit: BoxFit.fill,
                            height: double.infinity,
                            width: double.infinity,
                            errorWidget: imageErrorWidget,
                          ),
                        )),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget exploreByCity() {
    return Container(
      child: Column(
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
                    Navigator.of(context).pushNamed("/event-category");
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
                              (cityData) => Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: cityCard(cityData: cityData),
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

  Widget cityCard({required CityData cityData}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/event-detail");
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cityData.name!,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: cityData.image!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nearByEvents() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Popular in London",
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isPopularInLocationLoading
                ? Container(
                    height: 100,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: popularInLocation
                            .map((element) => Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: eventPoster(eventPoster: element),
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

  Widget foodFestivalEvent({required String categoryName}) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    Navigator.of(context).pushNamed(Routes.EVENT_CATEGORY);
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    Container(
                      height: 244,
                      child: isEventListLoading
                          ? Center(
                              child: CircularLoadingIndicator(),
                            )
                          : CustomBoxShadow(
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
                                              imageUrl: eventList[0].image!,
                                              errorWidget: imageErrorWidget,
                                              fit: BoxFit.fill,
                                              filterQuality: FilterQuality.high,
                                            ),
                                            onTap: () {
                                              Navigator.of(context)
                                                  .pushNamed("/event-detail");
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      eventList[0].dateTime!,
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                        color: mateRed,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      eventList[0].title!,
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        color: blackFont,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      eventList[0]
                                                          .shortDescription!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      getUserCurrencySymbol(
                                                          context),
                                                      Text(
                                                        eventList[0].price!,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
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
                    const SizedBox(
                      height: 12,
                    ),
                    isEventListLoading
                        ? Container(
                            height: 180,
                            child: Center(
                              child: CircularLoadingIndicator(),
                            ),
                          )
                        : Column(
                            children: eventList
                                .map((partialEvent) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: EventTileWithHeart(
                                          partialEvent: partialEvent),
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

  Widget eventPoster({required EventPoster eventPoster}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/event-detail");
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
                imageUrl: eventPoster.image!,
                fit: BoxFit.fill,
                errorWidget: imageErrorWidget,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                eventPoster.name!,
                style: const TextStyle(
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
