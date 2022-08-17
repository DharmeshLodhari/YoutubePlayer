import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import 'add_topic_screen.dart';
import 'ask_detail_screen.dart';
import 'ask_viewmodel.dart';
import 'components/ask_options.dart';
import 'components/ask_posts_view.dart';

class AskByCategoryScreen extends StatefulWidget {
  @override
  State<AskByCategoryScreen> createState() => _AskByCategoryScreenState();
}

class _AskByCategoryScreenState extends State<AskByCategoryScreen> {

  late PageController _pageViewCtrl;

  @override
  void initState(){
    _pageViewCtrl = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AskViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              backgroundColor: blackFont,
              child: Icon(Icons.add, color: Colors.white,),
              onPressed: () {

                NavigationUtil.push(
                  context,
                  screen: AddTopicScreen(),
                );

              },
            ),
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.newlySelectedCategory!,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: blackFont,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '12k Member   267 Topics',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: blackFont.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: blackFont,
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: navyBlue,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Join',
                          style: TextStyle(
                            color: white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 17),
                  ],
                ),
              ],
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: navyBlue,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 17),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          pageViewTabItem(
                              onPageTap: () {
                                model.updateCurrentAskTapOnHome(i: 0);
                                _pageViewCtrl.jumpToPage(0);
                              },
                              pageNum: 0,
                              title: 'Latest',
                              currentTapIndex: model.currentAskTapOnHome
                          ),
                          pageViewTabItem(
                              onPageTap: () {
                                model.updateCurrentAskTapOnHome(i: 1);
                                _pageViewCtrl.jumpToPage(1);
                              },
                              pageNum: 1,
                              title: 'Trending',
                              currentTapIndex: model.currentAskTapOnHome
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      onPageChanged: (currentPage) {
                        model.updateCurrentAskTapOnHome(i: currentPage);
                      },
                      controller: _pageViewCtrl,
                      children: [
                        AskListView(listLength: 2),
                        AskListView(listLength: 3)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget pageViewTabItem({
    required int pageNum,
    required String title,
    int? currentTapIndex,
    Function? onPageTap
  }) {
    return InkWell(
      onTap: () => onPageTap!(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: currentTapIndex == pageNum
              ? navyBlue.withOpacity(0.1)
              : Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: currentTapIndex == pageNum ? navyBlue : blackFont,
            fontSize: 14,
            fontWeight: currentTapIndex == pageNum
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget AskListView({int? listLength}) {
    RefreshController _postRefreshController = RefreshController(initialRefresh: false);

    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _postRefreshController,
            onRefresh: (){},
            child: AskLists(listLength: listLength),
          ),
        ),
      ],
    );
  }

  Widget AskLists({int? listLength}) {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 22),
      itemCount: listLength,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            NavigationUtil.push(
              context,
              screen: AskDetailScreen(),
            );
          },
          child: AskPosts(
            showTag: false,
            onOptionsAction: (){
              showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    child: AskOptions(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}