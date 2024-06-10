import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserReviewList extends StatefulWidget {
  CustomerProfile? user;
  UserReviewList({@required this.user, super.key});

  @override
  _UserReviewListState createState() => _UserReviewListState();
}

class _UserReviewListState extends State<UserReviewList> {
  bool isReviewLoading = false;
  int? reviewCount = 0;
  String? reviewNext = "";
  String? reviewPrevious = "";
  List<Review> reviewList = [];
  final ScrollController _reviewScrollController = ScrollController();

  bool noReviewInList = false;
  final GlobalKey<ScaffoldState> _reviewScaffoldKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _reviewMessengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _reviewRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getReviewList();
    _reviewScrollController.addListener(() {
      if (_reviewScrollController.position.pixels ==
              _reviewScrollController.position.maxScrollExtent &&
          _reviewScrollController.position.pixels != 0) {
        getReviewList();
      }
    });

    super.initState();
  }

  void _onReviewRefresh() async {
    if (await checkConnection(context)) {
      reviewCount = 0;
      reviewNext = "";
      reviewPrevious = "";
      reviewList = [];
      debugPrint("Refresh called on reviews!!  ");
      getReviewList();
      _reviewRefreshController.refreshCompleted();
    } else {
      _reviewRefreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _reviewMessengerScaffoldKey,
      child: Scaffold(
        key: _reviewScaffoldKey,
        body: Container(
          color: lightGrey,
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _reviewRefreshController,
            onRefresh: _onReviewRefresh,
            child: _buildReviewList(),
          ),
        ),
      ),
    );
  }

  Future<void> getReviewList() async {
    if (!isReviewLoading) {
      if (reviewNext != null && !isReviewLoading) {
        isReviewLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ReviewAuth()
            .fetchUserReviews(userName: widget.user!.userName);

        if (result == null) {
          isReviewLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        final String? error = result['error'];
        if (error != null && error.toLowerCase().contains('review not found')) {
          noReviewInList = true;
          isReviewLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        reviewCount = result['count'];
        reviewNext = result['next'];
        reviewPrevious = result['previous'];
        final List tempList = result['results'] as List;

        final List<Review> reviews = [];
        tempList.forEach((element) {
          reviews.add(Review.fromJson(element));
        });

        if (mounted) {
          setState(() {
            noReviewInList = false;
            isReviewLoading = false;
            reviewList.addAll(reviews);
          });
        }
      }
    }
    if (reviewList.isEmpty) {
      if (mounted) {
        setState(() {
          noReviewInList = true;
        });
      }
    } else if (reviewNext == null && reviewList.length > 6) {
      _reviewMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
        content:
            Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        duration: const Duration(milliseconds: 500),
      ));
    }
  }

  Widget _buildReviewList() {
    return noReviewInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noReviews,
          )
        : isReviewLoading && reviewList.isEmpty
            ? buildLoadingIndicator(isLoading: isReviewLoading)
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                controller: _reviewScrollController,
                itemCount: reviewList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == reviewList.length) {
                    return buildJumpingLoadingIndicator(
                        isLoading: isReviewLoading);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ReviewTile(
                          review: reviewList[index], reviewedUser: widget.user),
                    );
                  }
                },
              );
    /*StaggeredGridView.countBuilder(
      physics: const ClampingScrollPhysics(),
      controller: _reviewScrollController,
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      mainAxisSpacing: 20,
      itemCount: reviewList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == reviewList.length) {
          return buildLoadingIndicator(isLoading: isReviewLoading);
        } else {
          return ReviewTile(
            review: reviewList[index],
          );
        }
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.count(2, 0.85),
    );

    ListView.builder(
            physics: ClampingScrollPhysics(),
            controller: _reviewScrollController,
            itemCount: reviewList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == reviewList.length) {
                return _buildReviewIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 24.0,
                    right: 24.0,
                    top: 24.0,
                  ),
                  child: ReviewTile(
                    review: reviewList[index],
                  ),
                );
              }
            },
          );*/
  }
}
