import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventList extends StatefulWidget {
  final CustomerProfile? user;
  EventList({@required this.user, Key? key}) : super(key: key);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  bool isEventLoading = false;
  int? eventCount = 0;
  String? eventNext = "";
  String? eventPrevious = "";
  List<Review> eventList = [];
  final ScrollController _eventScrollController = ScrollController();

  bool noEventInList = false;
  final GlobalKey<ScaffoldState> _eventScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _eventMessengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _eventRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    this.getReviewList();
    _eventScrollController.addListener(() {
      if (_eventScrollController.position.pixels ==
              _eventScrollController.position.maxScrollExtent &&
          _eventScrollController.position.pixels != 0) {
        getReviewList();
      }
    });

    super.initState();
  }

  void _onReviewRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        eventCount = 0;
        eventNext = "";
        eventPrevious = "";
        eventList = [];
        debugPrint("Refresh called on reviews!!  ");
        getReviewList();
        _eventRefreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _eventRefreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _eventMessengerScaffoldKey,
      child: Scaffold(
        key: _eventScaffoldKey,
        body: Container(
          color: lightGrey,
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _eventRefreshController,
            onRefresh: _onReviewRefresh,
            child: _buildReviewList(),
          ),
        ),
      ),
    );
  }

  Future<void> getReviewList() async {
    // if (!isEventLoading) {
    //   if (eventNext != null && !isEventLoading) {
    //     isEventLoading = true;
    //     if (mounted) setState(() {});
    //
    //     Map<String, dynamic>? result = await ReviewAuth()
    //         .fetchUserReviews(userName: widget.user!.userName);
    //
    //     if (result == null) {
    //       isEventLoading = false;
    //       if (mounted) {
    //         setState(() {});
    //       }
    //       return;
    //     }
    //
    //     String? error = result['error'];
    //     if (error != null && error.toLowerCase().contains('review not found')) {
    //       noEventInList = true;
    //       isEventLoading = false;
    //       if (mounted) {
    //         setState(() {});
    //       }
    //       return;
    //     }
    //
    //     eventCount = result['count'];
    //     eventNext = result['next'];
    //     eventPrevious = result['previous'];
    //     List tempList = result['results'] as List;
    //
    //     List<Review> reviews = [];
    //     tempList.forEach((element) {
    //       reviews.add(Review.fromJson(element));
    //     });
    //
    //     if (mounted) {
    //       setState(() {
    //         noEventInList = false;
    //         isEventLoading = false;
    //         eventList.addAll(reviews);
    //       });
    //     }
    //   }
    // }
    if (eventList.isEmpty) {
      if (mounted) {
        setState(() {
          noEventInList = true;
        });
      }
    }
    // else if (eventNext == null && eventList.length > 6) {
    //   _eventMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
    //     content:
    //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
    //     duration: Duration(milliseconds: 500),
    //   ));
    // }
  }

  Widget _buildReviewList() {
    return noEventInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
          )
        : ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            controller: _eventScrollController,
            itemCount: eventList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == eventList.length) {
                return _buildReviewIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ReviewTile(
                      review: eventList[index], reviewedUser: widget.user),
                );
              }
            },
          );
  }

  Widget _buildReviewIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
            opacity: isEventLoading ? 1.0 : 00,
            child: isEventLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }
}
