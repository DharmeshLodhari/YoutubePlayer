import 'dart:async';
import 'dart:developer';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/moments/screens/moment_detail/single_moment_detail.dart';
import 'package:Slydo/utils/cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/LoadingIndicator.dart';
import '../../../more_apps/shopping/models/store.dart';
import '../../models/moments_model.dart';
import '../../moments_bloc.dart';
import '../moments_service.dart';

class MomentsDetailsScreen extends StatefulWidget {
  String? nextPageUrl;

  /* 'indexOfMoment'
  * This is the index of the moment that was clicked from 'moments_screen'.
  * When the user comes to this page, the moment that will be shown at first is the
  * moment the user clicked (through this index).*/
  int indexOfMoment;
  final List<String> listOfConnectionNames;
  List<List<MomentsModel>> momentsModelList;

  MomentsDetailsScreen({
    Key? key,
    this.nextPageUrl,
    this.listOfConnectionNames = const [],
    required this.indexOfMoment,
    this.momentsModelList = const [],
  }) : super(key: key);

  @override
  _MomentsDetailsScreenState createState() => _MomentsDetailsScreenState();
}

class _MomentsDetailsScreenState extends State<MomentsDetailsScreen> {
  bool loadingMoments = false;

  /* This variable is to show a loading indicator when the user has gotten to the end
  *  of the list and there are more moments to load through widget.nextPageUrl*/
  bool nextPageUrlLoading = false;

  /*This holds the number of previous and next moments to load when the user
  * comes to this page*/
  int numberOfMomentsToLoad = 2;
  int currentVerticalPageIndex = 0;
  late PageController _verticalScrollPageViewCtrl;
  int? horizoallyPageIndex;

  List<CachedVideoPlayerController> _videoPlayerControllers = [];
  List<PhotoViewController> _photoViewController = [];

  @override
  void initState() {
    super.initState();

    // debugPrint('contact list:::${}');
    _verticalScrollPageViewCtrl =
        PageController(initialPage: getInitialPageIndex());
    if (widget.listOfConnectionNames.isNotEmpty) {
      getListOfMomentsModelList();
    }
  }

  // To get the initial page that the pageview will show when the user gets this screen and
  // the previous and next two moments(if there is) have been loaded.
  int getInitialPageIndex() {
    if (widget.momentsModelList != null && widget.momentsModelList.isNotEmpty) {
      return widget.indexOfMoment;
    } else {
      if (widget.indexOfMoment > 2) {
        return 2;
      } else {
        return widget.indexOfMoment;
      }
    }
  }

  @override
  void dispose() {
    try {
      clearAllMedia();
      _verticalScrollPageViewCtrl.dispose();
    } catch (error) {}
    super.dispose();
  }

  // To know where to start looping from while trying to get the moment with owner's name.
  // Ideally we should get the previous two and the next two moments of what the user clicked on from the previous page.
  int getLoopStartingPoint({
    required List<String> mList,
    // If we are loading the nextPageUrl, we do not neec to load the previous moments only the next ones;
    bool loadingNextPageUrl = false,
  }) {
    if (!loadingNextPageUrl) {
      if (mList.indices
          .contains(widget.indexOfMoment - numberOfMomentsToLoad)) {
        return widget.indexOfMoment - numberOfMomentsToLoad;
      } else if (mList.indices.contains(widget.indexOfMoment - 1)) {
        return widget.indexOfMoment - 1;
      } else {
        return widget.indexOfMoment;
      }
    } else {
      return widget.indexOfMoment;
    }
  }

  int getLoopEndingPoint({required List<String> mList}) {
    // To check if the list 'mList' contains a particular index.
    if (mList.indices.contains(widget.indexOfMoment + numberOfMomentsToLoad)) {
      return widget.indexOfMoment + numberOfMomentsToLoad;
    } else if (mList.indices.contains(widget.indexOfMoment + 1)) {
      return widget.indexOfMoment + 1;
    } else {
      return widget.indexOfMoment;
    }
  }

  Future<List<String>?> getNextPageListOfConnectionNames(
      {required String nextPageUrl}) async {
    Map<String, dynamic>? result = await MomentsService().getContactMoments(
      next: widget.nextPageUrl,
    );

    if (result == null) {
      return null;
    }
    widget.nextPageUrl = result['next'];
    var resultList = result['results'] as List<MomentsModel>;

    return resultList.map((e) => e.owner!).toList();
  }

  void getListOfMomentsModelList({bool loadingNextPageUrl = false}) async {
    showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: true);

    try {
      int startIndex = getLoopStartingPoint(
          mList: widget.listOfConnectionNames,
          loadingNextPageUrl: loadingNextPageUrl);

      int endIndex = getLoopEndingPoint(mList: widget.listOfConnectionNames);

      for (int i = startIndex; i <= endIndex; i++) {
        List<MomentsModel> momentsModelList = await MomentsService()
            .getMomentsWithOwnerName(
                ownerName: widget.listOfConnectionNames[i]);
        widget.momentsModelList = List.from(widget.momentsModelList)
          ..add(momentsModelList);
      }

      showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: false);
    } catch (e) {
      showLoadingIndicator(loadingNextPageUrl: loadingNextPageUrl, show: false);

      NavigationUtil.pop(context);
      showToast(message: 'Could not load your moments, try again.');
    }
  }

  showLoadingIndicator({required bool loadingNextPageUrl, required bool show}) {
    if (loadingNextPageUrl) {
      setState(() {
        nextPageUrlLoading = show;
      });
    } else {
      setState(() {
        loadingMoments = show;
      });
    }
  }

  void getNextOrPreviousListOfMomentsWithConnectionNames(
      {required int verticalScrollIndex, required bool getNextList}) async {
    // The 'index' is the index of the moment in the vertical scroll pageview

    int count = getNextList ? 1 : 4;

    do {
      int nextIndex = widget.listOfConnectionNames.indexOf(widget
              .momentsModelList[verticalScrollIndex][0]
              .owner!) + // We can use position 0 here so we can just get the owner's name(we can also use 1 or 2 or whatever cos it is still that  particular user's moment)
          count;
      int previousIndex = widget.listOfConnectionNames
              .indexOf(widget.momentsModelList[verticalScrollIndex][0].owner!) -
          count;

      // Whether previous or next index depending on if the user has gotten to the top or end of the vertical list respectively.
      int indexToWorkWith = getNextList ? nextIndex : previousIndex;

      debugPrint('ERROR FETCHING MOMENT :: ${indexToWorkWith}');

      if (widget.listOfConnectionNames.indices.contains(indexToWorkWith)) {
        try {
          List<MomentsModel> momentsModelList = await MomentsService()
              .getMomentsWithOwnerName(
                  ownerName: widget.listOfConnectionNames[indexToWorkWith]);
          if (getNextList) {
            widget.momentsModelList.add(momentsModelList);
          } else {
            widget.momentsModelList.insert(0, momentsModelList);
          }

          setState(() {});
        } catch (e) {
          debugPrint('ERROR FETCHING MOMENT WITH OWNER NAME :: $e');

          NavigationUtil.pop(context);
          showToast(message: 'Could not load your moments, try again.');
        }
      }
      if (getNextList) {
        count++;
      } else {
        count--;
      }
    } while (getNextList ? count <= 4 : count >= 0);
  }

  void clearAllMedia() {
    log("DISPOSING VIDEO CONTROLLERS:- ${_videoPlayerControllers.length} PHOTO CONTROLLERS:- ${_photoViewController.length}");
    _videoPlayerControllers.forEach((element) {
      try {
        element.dispose();
      } catch (error) {}
    });
    _photoViewController.forEach((element) {
      try {
        element.dispose();
      } catch (error) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingMoments) {
      return Scaffold(
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        clearAllMedia();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Align(
          alignment: Alignment.topLeft,
          // This allows us to scroll vertically to move to the next or previous user's moments.
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: widget.momentsModelList.length,
                  controller: _verticalScrollPageViewCtrl,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (verticalScrollIndex) async {
                    // To check if the pageview has gotten to the top of the list.

                    currentVerticalPageIndex -= 1;

                    if (verticalScrollIndex == 0) {
                      if (widget
                              .momentsModelList[verticalScrollIndex][0].owner !=
                          widget.listOfConnectionNames[0]) {
                        getNextOrPreviousListOfMomentsWithConnectionNames(
                            verticalScrollIndex: verticalScrollIndex,
                            getNextList: false);
                      }
                    }

                    // To check if the pageview has gotten to the end of the list.
                    else if (verticalScrollIndex + 1 ==
                        widget.momentsModelList.length) {
                      // This is to check if the owner of the last moment that's showing is the same as the last name
                      // in widget.listOfConnectionNames (this helps us to know whether to load the next moments using the
                      // names that are left in widget.listOfConnectionNames or using the url(endpoint) in widget.nextPageUrl).
                      if (widget
                              .momentsModelList[verticalScrollIndex][0].owner !=
                          widget.listOfConnectionNames.last) {
                        getNextOrPreviousListOfMomentsWithConnectionNames(
                            verticalScrollIndex: verticalScrollIndex,
                            getNextList: true);
                      } else {
                        if (widget.nextPageUrl != null) {
                          List<String>? newListOfConnectionNames =
                              await getNextPageListOfConnectionNames(
                                  nextPageUrl: widget.nextPageUrl!);

                          widget.indexOfMoment =
                              widget.listOfConnectionNames.length;

                          widget.listOfConnectionNames
                              .addAll(newListOfConnectionNames!);

                          getListOfMomentsModelList(loadingNextPageUrl: true);
                        }
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: MediaRendererPageView(
                          videoPlayerControllers: _videoPlayerControllers,
                          photoViewController: _photoViewController,
                          momentsModelList: widget.momentsModelList[index],
                          onPageChanged: (pageViewIndex) {
                            setState(() {
                              horizoallyPageIndex = pageViewIndex;
                            });
                          },
                          onMomentPop: () {
                            clearAllMedia();
                          }),
                    );
                  },
                ),
              ),
              Visibility(
                visible: nextPageUrlLoading,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CircularLoadingIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaRendererPageView extends StatefulWidget {
  final ValueChanged<int> onPageChanged;
  final List<MomentsModel> momentsModelList;
  final List<CachedVideoPlayerController> videoPlayerControllers;
  final List<PhotoViewController> photoViewController;

  final void Function() onMomentPop;

  const MediaRendererPageView({
    Key? key,
    required this.onPageChanged,
    required this.videoPlayerControllers,
    required this.photoViewController,
    required this.momentsModelList,
    required this.onMomentPop,
  }) : super(key: key);

  @override
  MediaRendererPageViewState createState() => MediaRendererPageViewState();
}

class MediaRendererPageViewState extends State<MediaRendererPageView> {
  bool isLiked = false;
  PageController? _pageCtrl;
  Product? product;
  late UserBloc? userBloc;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<MomentsBloc>(context, listen: false).numberOfComments =
          widget.momentsModelList.map((e) => e.numberOfComments!).toList();

      debugPrint(
          'NUMBER OF COMMENTS ${Provider.of<MomentsBloc>(context, listen: false).numberOfComments}');
    });
  }

  @override
  void deactivate() {
    try {
      _pageCtrl?.dispose();
    } catch (error) {}

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    //PageView to scroll horizontally to view a single user's list of moments.
    return PageView.builder(
      controller: _pageCtrl,
      onPageChanged: widget.onPageChanged,
      scrollDirection: Axis.horizontal,
      itemCount: widget.momentsModelList.length,
      itemBuilder: (context, index) {

        return SingleMomentDetailScreen(
          momentsModelList: widget.momentsModelList,
          videoPlayerControllers: widget.videoPlayerControllers,
          photoViewController: widget.photoViewController,
          index: index,
          currentMoment: widget.momentsModelList[index],
          onLeftSwipe: () {
            _pageCtrl!.previousPage(
                duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          },
          onRightSwipe: () {
            _pageCtrl!.nextPage(
                duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          },
          onMomentPop: widget.onMomentPop,
          pageCtrl: _pageCtrl!,
        );
      },
    );
  }
}

extension ListExtensions on List {
  Range get indices => Range.fromLength(this.length);
}

class Range extends Iterable<int> {
  const Range(this.start, this.end) : assert(start <= end);
  const Range.fromLength(int length) : this(0, length - 1);

  final int start;
  final int end;

  int get length => end - start + 1;

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i).iterator;

  @override
  bool contains(Object? index) {
    if (index == null || index is! int) return false;
    return index >= start && index <= end;
  }

  @override
  String toString() => '[$start, $end]';
}
