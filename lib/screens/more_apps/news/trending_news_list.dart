import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/news_list_item.dart';
import 'news_auth.dart';

class TrendingNewsList extends StatefulWidget {
  const TrendingNewsList({super.key});

  @override
  State<TrendingNewsList> createState() => _TrendingNewsListState();
}

class _TrendingNewsListState extends State<TrendingNewsList> {
  List<NewsListItem> newsListItem = [];
  bool isLoading = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    newsListItem.clear();
    if (mounted) {
      setState(() {});
    }

    newsListItem = await NewsAuthService().getNewsList();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
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
      backgroundColor: lightGrey,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return isLoading
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
              child: Column(
                  children: newsListItem
                      .map((news) => GestureDetector(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  NewsTile(newsListItem: news),
                                  const SizedBox(
                                    height: 16,
                                  )
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed("/news-detail");
                            },
                          ))
                      .toList()),
            ),
          );
  }
}
