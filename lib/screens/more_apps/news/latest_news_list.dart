import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:flutter/material.dart';

class LatestNewsList extends StatefulWidget {
  @override
  _LatestNewsListState createState() => _LatestNewsListState();
}

class _LatestNewsListState extends State<LatestNewsList> {
  List<Map<String, String>> news = [
    {
      "title": "Nigerian army warns 'trouble makers' amid protests",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg"
    },
    {
      "title":
          "End Sars: How Nigeria's anti-police brutality protests went global",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg"
    },
    {
      "title":
          "End Sars protests: Osun governor escapes 'assassination attempt'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg"
    },
    {
      "title":
          "End Sars: How Nigeria's anti-police brutality protests went global",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg"
    },
    {
      "title":
          "End Sars protests: Osun governor escapes 'assassination attempt'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg"
    },
    {
      "title": "End Sars: Hated Nigerian police unit's founder 'feels guilty'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/762D/production/_114935203_sarsfounder-1_moment.jpg"
    },
    {
      "title": "Nigeria state imposes curfew amid jailbreak",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/19/b77112bd-285c-45c2-8293-c3ceafef3577.png"
    },
    {
      "title": "Nigerian army warns 'trouble makers' amid protests",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg"
    },
  ];

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
          children: news
              .map((post) => GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          NewsTile(
                            title: post["title"],
                            image: post["image"],
                          ),
                          SizedBox(
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
    );
  }
}
