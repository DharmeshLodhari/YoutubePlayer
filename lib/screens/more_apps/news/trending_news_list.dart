import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:flutter/material.dart';

class TrendingNewsList extends StatefulWidget {
  @override
  _TrendingNewsListState createState() => _TrendingNewsListState();
}

class _TrendingNewsListState extends State<TrendingNewsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
            15,
            (index) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      NewsTile(),
                      SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                )),
      ),
    );
  }
}
