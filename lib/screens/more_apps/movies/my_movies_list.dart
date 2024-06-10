import 'package:Slydo/screens/more_apps/movies/movie_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/movie_item.dart';
import 'movie_auth.dart';

class MyMovieList extends StatefulWidget {
  const MyMovieList({super.key});

  @override
  State<MyMovieList> createState() => _MyMovieListState();
}

class _MyMovieListState extends State<MyMovieList> {
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
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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
                              child: MovieTile(movieItem: movie)),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
