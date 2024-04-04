import 'dart:math';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/music/models/PartialCelebrityItem.dart';
import 'package:Slydo/screens/more_apps/music/models/PartialMusicAlbum.dart';
import 'package:Slydo/screens/more_apps/music/models/PartialMusicItem.dart';
import 'package:Slydo/screens/more_apps/music/music_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'music_player.dart';

// ignore: must_be_immutable
class MusicExploreScreen extends StatefulWidget {
  MusicPlayer? musicPlayer;

  MusicExploreScreen({this.musicPlayer});

  @override
  _MusicExploreScreenState createState() => _MusicExploreScreenState();
}

class _MusicExploreScreenState extends State<MusicExploreScreen> {
  final CarouselController _carouselController = CarouselController();

  List<PartialMusicItem> mostRecentDiscoveryList = [];
  bool isMostRecentDiscoveryLoading = false;

  List<PartialMusicAlbum> sliderList = [];
  bool isSliderLoading = false;

  List<PartialMusicAlbum> mostPopularAlbumList = [];
  bool isMostPopularAlbumLoading = false;

  List<PartialCelebrityItem> topCelebrityList = [];
  bool isTopCelebrityLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() {
    getMostRecentDiscoveryListItem();
    getSliderListItem();
    getMostPopularAlbumList();
    getTopCelebrity();
  }

  void getMostRecentDiscoveryListItem() async {
    isMostRecentDiscoveryLoading = true;
    mostRecentDiscoveryList.clear();
    if (mounted) setState(() {});

    mostRecentDiscoveryList = await MusicAuthService().getMusicItemList();

    isMostRecentDiscoveryLoading = false;
    if (mounted) setState(() {});
  }

  void getSliderListItem() async {
    isSliderLoading = true;
    sliderList.clear();
    if (mounted) setState(() {});

    sliderList = await MusicAuthService().getPartialMusicAlbumList();

    isSliderLoading = false;
    if (mounted) setState(() {});
  }

  void getMostPopularAlbumList() async {
    isMostPopularAlbumLoading = true;
    mostPopularAlbumList.clear();
    if (mounted) setState(() {});

    mostPopularAlbumList = await MusicAuthService().getPartialMusicAlbumList();

    isMostPopularAlbumLoading = false;
    if (mounted) setState(() {});
  }

  void getTopCelebrity() async {
    isTopCelebrityLoading = true;
    topCelebrityList.clear();
    if (mounted) setState(() {});

    topCelebrityList = await MusicAuthService().getCelebrity();

    isTopCelebrityLoading = false;
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
        "Music",
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
            musicSlider(),
            const SizedBox(
              height: 40,
            ),
            mostRecentDiscovery(),
            mostPopularAlbum(),
            const SizedBox(
              height: 16,
            ),
            topCelebrity(),
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

  Widget musicSlider() {
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
                        Navigator.of(context).pushNamed("/album-detail",
                            arguments: {"musicPlayer": widget.musicPlayer});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: item.poster!,
                            fit: BoxFit.fill,
                            color: Colors.black12,
                            colorBlendMode: BlendMode.darken,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Most Recent Discovery",
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
            child: isMostRecentDiscoveryLoading
                ? Container(
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: mostRecentDiscoveryList
                            .map(
                              (partialMusicItem) => Container(
                                margin: const EdgeInsets.only(
                                    right: 12, top: 16, bottom: 16),
                                child: musicCard(
                                    partialMusicItem: partialMusicItem),
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

  Widget musicCard({required PartialMusicItem partialMusicItem}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/album-detail",
            arguments: {"musicPlayer": widget.musicPlayer});
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: partialMusicItem.poster!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                    errorWidget: imageErrorWidget,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partialMusicItem.name!,
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
                          partialMusicItem.price!,
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

  Widget topCelebrity() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Top celebrate",
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
              child: isTopCelebrityLoading
                  ? Container(
                      child: Center(
                        child: CircularLoadingIndicator(),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: topCelebrityList
                              .map((element) => Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: celebrityCard(celebrityItem: element)))
                              .toList(),
                        ),
                      ),
                    ))
        ],
      ),
    );
  }

  Widget celebrityCard({required PartialCelebrityItem celebrityItem}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/album-detail",
            arguments: {"musicPlayer": widget.musicPlayer});
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
                  celebrityItem.name!,
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
                    imageUrl: celebrityItem.image!,
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

  Widget mostPopularAlbum() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Most popular album",
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isMostPopularAlbumLoading
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
                        children: mostPopularAlbumList
                            .map(
                              (partialAlbum) => Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          "/album-detail",
                                          arguments: {
                                            "musicPlayer": widget.musicPlayer
                                          });
                                    },
                                    child: albumPoster(
                                        partialAlbum: partialAlbum)),
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

  Widget albumPoster({required PartialMusicAlbum partialAlbum}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: partialAlbum.poster!,
        height: 132,
        width: 218,
        fit: BoxFit.fill,
        errorWidget: imageErrorWidget,
      ),
    );
  }

  Widget eventPoster(String url) {
    bool temp = Random().nextBool();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/music-detail",
            arguments: {"musicPlayer": widget.musicPlayer});
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
                errorWidget: imageErrorWidget,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                temp ? "Beach event" : "Mongola",
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
