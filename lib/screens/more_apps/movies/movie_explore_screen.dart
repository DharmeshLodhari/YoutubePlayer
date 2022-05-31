import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/movies/models/MovieItem.dart';
import 'package:Slydo/screens/more_apps/movies/models/PartialMovieItem.dart';
import 'package:Slydo/screens/more_apps/movies/movie_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../messaging/chat/utils.dart';

class MovieExploreScreen extends StatefulWidget {
  @override
  _MovieExploreScreenState createState() => _MovieExploreScreenState();
}

class _MovieExploreScreenState extends State<MovieExploreScreen> {
  CarouselController _carouselController = CarouselController();

  List<MovieItem> mostRecentDiscoveryList = [];
  bool isMostRecentDiscoveryLoading = false;

  List<PartialMovieItem> sliderList = [];
  bool isSliderLoading = false;

  List<MovieItem> nowAvailableTORent = [];
  bool nowAvailableToRentLoading = false;

  List<PartialMovieItem> indiePicksList = [];
  bool isIndiePicksLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() {
    getMostRecentDiscoveryListItem();
    getSliderListItem();
    getNowAvailableToRentListItem();
    getIndiePicksListItem();
  }

  void getMostRecentDiscoveryListItem() async {
    isMostRecentDiscoveryLoading = true;
    mostRecentDiscoveryList.clear();
    if (mounted) setState(() {});

    mostRecentDiscoveryList = await MovieAuthService().getMovieList();

    isMostRecentDiscoveryLoading = false;
    if (mounted) setState(() {});
  }

  void getSliderListItem() async {
    isSliderLoading = true;
    sliderList.clear();
    if (mounted) setState(() {});

    sliderList = await MovieAuthService().getPartialMovieList();

    isSliderLoading = false;
    if (mounted) setState(() {});
  }

  void getNowAvailableToRentListItem() async {
    nowAvailableToRentLoading = true;
    nowAvailableTORent.clear();
    if (mounted) setState(() {});

    nowAvailableTORent = await MovieAuthService().getMovieList();

    nowAvailableToRentLoading = false;
    if (mounted) setState(() {});
  }

  void getIndiePicksListItem() async {
    isIndiePicksLoading = true;
    indiePicksList.clear();
    if (mounted) setState(() {});

    indiePicksList = await MovieAuthService().getPartialMovieList();

    isIndiePicksLoading = false;
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
        "Movies",
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
          mostRecentDiscovery(),
          indiePicks(),
          SizedBox(
            height: 16,
          ),
          nowAvailableToRent(),
          SizedBox(
            height: 10,
          ),
        ],
      )),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
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
              items: sliderList
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed("/movie-detail");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: item.poster!,
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

  Widget mostRecentDiscovery() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                    Navigator.of(context).pushNamed("/movie-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            color: Colors.white,
            child: isMostRecentDiscoveryLoading
                ? Center(
                    child: CircularLoadingIndicator(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: mostRecentDiscoveryList
                            .map(
                              (movie) => Container(
                                margin: EdgeInsets.only(right: 12),
                                child: movieItemWithDetail(movieItem: movie),
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

  Widget nowAvailableToRent() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Now available to rent",
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
            child: nowAvailableToRentLoading
                ? Center(
                    child: CircularLoadingIndicator(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: nowAvailableTORent
                            .map(
                              (movie) => Container(
                                margin: EdgeInsets.only(right: 12),
                                child: movieItemWithDetail(movieItem: movie),
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

  Widget movieItemWithDetail({required MovieItem movieItem}) {
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
                  child: CachedNetworkImage(
                    imageUrl: movieItem.poster!,
                    errorWidget: imageErrorWidget,
                    height: 80,
                    width: 130,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  movieItem.name!,
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
                    getUserCurrencySymbol(context, fontSize: 14),
                    Text(
                      movieItem.price!,
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
                          movieItem.rating!,
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
                      "${movieItem.year} • ${movieItem.genre}",
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

  Widget indiePicks() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Indie Picks",
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
            child: isIndiePicksLoading
                ? Container(
                    height: 132,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: indiePicksList
                            .map(
                              (movie) => Container(
                                margin: EdgeInsets.only(right: 12),
                                child: moviePoster(partialMovieItem: movie),
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

  Widget moviePoster({required PartialMovieItem partialMovieItem}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/movie-detail");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: partialMovieItem.poster!,
          errorWidget: imageErrorWidget,
          height: 132,
          width: 218,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
