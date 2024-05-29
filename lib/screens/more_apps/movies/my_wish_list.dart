import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/movies/movie_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/MovieItem.dart';
import 'movie_auth.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  List<MovieItem> movieItem = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    movieItem.clear();
    if (mounted) setState(() {});

    movieItem = await MovieAuthService().getMovieList();

    isLoading = false;
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
      body: isLoading
          ? Center(
              child: CircularLoadingIndicator(),
            )
          : SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: movieItem
                        .map(
                          (movie) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: MovieTileWithHeart(movieItem: movie)),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
