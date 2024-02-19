import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/news/news_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/enums.dart';
import '../../post_detail_page.dart';
import 'models/NewsListItem.dart';
import 'news_tile.dart';

class LatestNewsList extends StatefulWidget {
  @override
  _LatestNewsListState createState() => _LatestNewsListState();
}

class _LatestNewsListState extends State<LatestNewsList> {
  List<NewsListItem> newsListItem = [];
  bool isLoading = false;
  RefreshController _refreshController =
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
              child: Container(
                padding: EdgeInsets.only(top: 32),
                child: Column(
                    children: newsListItem
                        .map((news) => GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    NewsTile(newsListItem: news),
                                    SizedBox(
                                      height: 16,
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                // Navigator.of(context).pushNamed("/news-detail");
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return PostDetailPage(
                                    postId: '',
                                    onDeleteBlog: () {},
                                    postType: PostType.news,
                                  );
                                }));
                              },
                            ))
                        .toList()),
              ),
            ),
          );
  }
}
