import 'dart:math';

import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/city_data.dart';
import 'models/partial_property_item.dart';
import 'models/property_item.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

class PropertyExploreScreen extends StatefulWidget {
  const PropertyExploreScreen({super.key});

  @override
  State<PropertyExploreScreen> createState() => _PropertyExploreScreenState();
}

class _PropertyExploreScreenState extends State<PropertyExploreScreen> {
  List<PropertyItem> nearByItem = [];
  bool isNearByItemLoading = false;

  List<PartialPropertyItem> mostRecentDiscovery = [];
  bool isMostRecentDiscoveryLoading = false;

  List<CityData> listOfCity = [];
  bool isExploreByCityLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  PropertyFilterBloc? _propertyFilterBloc;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() {
    getNearByItem();
    getMostRecentDiscoveryItem();
    getExploreByCityItem();
  }

  void getNearByItem() async {
    isNearByItemLoading = true;
    nearByItem.clear();
    if (mounted) setState(() {});

    nearByItem = await PropertyAuthService().getPropertyList();

    isNearByItemLoading = false;
    if (mounted) setState(() {});
  }

  void getMostRecentDiscoveryItem() async {
    isMostRecentDiscoveryLoading = true;
    mostRecentDiscovery.clear();
    if (mounted) setState(() {});

    mostRecentDiscovery = await PropertyAuthService().getPartialPropertyList();

    isMostRecentDiscoveryLoading = false;
    if (mounted) setState(() {});
  }

  void getExploreByCityItem() async {
    isExploreByCityLoading = true;
    listOfCity.clear();
    if (mounted) setState(() {});

    listOfCity = await PropertyAuthService().getCityList();

    isExploreByCityLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    _propertyFilterBloc = Provider.of<PropertyFilterBloc>(context);
    return Scaffold(
      backgroundColor: lightGrey,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        "Property",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
            nearByYou(),
            mostRecentDiscoveryList(),
            const SizedBox(
              height: 16,
            ),
            exploreByCity(
              categoryName: "Explore by City",
              moviePoster:
                  "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
              movieName: "The Cloud Of Northland Thunder",
            ),
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
            Navigator.of(context).pushNamed('/search-property',
                arguments: {"filterBloc": _propertyFilterBloc});
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

  Widget mostRecentDiscoveryList() {
    return Column(
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
                  Navigator.of(context).pushNamed("/property-category");
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
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: mostRecentDiscovery
                          .map(
                            (property) => Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: PartialPropertyItemTile(
                                property: property,
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

  Widget exploreByCity(
      {required String categoryName, String? movieName, String? moviePoster}) {
    return Column(
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
                  Navigator.of(context).pushNamed("/property-category");
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

  Widget cityCard({required String cityName, String? cityPoster}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
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
                  cityName,
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
                  child: Image.network(
                    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
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

  Widget nearByYou() {
    return Column(
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
                  Navigator.of(context).pushNamed("/property-category");
                },
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: isNearByItemLoading
              ? SizedBox(
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
                                child: RentPropertyTile(
                                  property: element,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        )
      ],
    );
  }

  Widget eventPoster(String url) {
    final bool temp = Random().nextBool();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/property-detail");
      },
      child: SizedBox(
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
