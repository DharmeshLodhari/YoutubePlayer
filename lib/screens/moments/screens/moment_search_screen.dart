import 'dart:async';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../../widget/customized_textform_field.dart';
import 'moment_detail/moment_detail_page.dart';
import 'moments_service.dart';

class MomentSearchScreen extends StatefulWidget {
  const MomentSearchScreen({super.key});

  @override
  State<MomentSearchScreen> createState() => _MomentSearchScreenState();
}

class _MomentSearchScreenState extends State<MomentSearchScreen> {
  Timer? typingTimer;
  String? nextPage; //For pagination.
  String? lastInputValue;
  bool _isLoading = false;
  String userSearchedText = '';
  bool searchMomentLoading = false;
  List<SearchMomentModel> searchMomentModelList = [];
  List<SearchMomentModel> tempSearchMomentModelList = [];
  final ScrollController _scrollController = ScrollController();
  bool noItemInList = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (nextPage != null) {
          _getSearchedMoments();
        }
      }
    });
  }

  // We intend to call getMoments after every 1 second that the user typed in something.
  void _onChanged(String value) {
    /*To prevent the changed function to be called when keyboard dismisses, we have this check here.  */
    if (value.isNotEmpty && lastInputValue != value) {
      lastInputValue = value;
      const duration = Duration(seconds: 1);
      if (typingTimer != null) {
        setState(() => typingTimer!.cancel()); // clear timer
      }
      typingTimer = Timer(
        duration,
        () => getMoments(value),
      );
    }
  }

  void getMoments(String value) {
    nextPage = null;
    userSearchedText = value;
    searchMomentModelList.clear();
    searchMomentLoading = true;
    if (mounted) setState(() {});

    _getSearchedMoments(searchedText: value);
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Search",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _getSearchedMoments({String? searchedText}) {
    MomentsService()
        .searchMoment(nextPage: nextPage, searchText: searchedText)
        .then((value) {
      tempSearchMomentModelList.clear();
      tempSearchMomentModelList.addAll(value.result);

      if (tempSearchMomentModelList.isEmpty) {
        noItemInList = true;
        searchMomentLoading = false;
        if (mounted) setState(() {});
        return;
      }

      searchMomentModelList.clear();
      for (var element in tempSearchMomentModelList) {
        if (!(searchMomentModelList.contains(element))) {
          searchMomentModelList.add(element);
        }
      }

      nextPage = value.next;
      searchMomentLoading = false;

      if (searchMomentModelList.isNotEmpty) {
        noItemInList = false;
        if (mounted) setState(() {});
      } else if (searchMomentModelList.isEmpty) {
        if (mounted) {
          noItemInList = true;
          if (mounted) setState(() {});
        }
      } else if (nextPage == null && searchMomentModelList.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: appBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomizedTextFormField(
                    hintText: 'Search',
                    autoFocus: true,
                    onChanged: _onChanged,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildResultList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultList() {
    return searchMomentLoading
        ? shimmerGridview()
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context)!.noResultFound,
              )
            : GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 300,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: searchMomentModelList.length,
                itemBuilder: (context, index) {
                  if (searchMomentModelList.isEmpty) {
                    return const Text(
                      'Search for a moment',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    );
                  }
                  if (index == searchMomentModelList.length) {
                    if (nextPage != null) {
                      _getSearchedMoments();
                    }
                  }
                  return SearchMomentSingleWidget(
                    onTap: () {
                      searchMomentSingleWidgetOnTap(
                          searchMomentModelList[index]);
                    },
                    userTextToSearch: userSearchedText,
                    searchMomentModel: searchMomentModelList[index],
                  );
                },
              );
  }

  void searchMomentSingleWidgetOnTap(SearchMomentModel searchMomentModel) {
    if (_isLoading == true) return;
    if (mounted) setState(() {});
    _isLoading = true;
    MomentsService()
        .getSingleMoment(momentId: searchMomentModel.id!)
        .then((momentsModelList) {
      if (mounted) setState(() {});
      _isLoading = false;
      NavigationUtil.push(
        context,
        screen: MomentsDetailsScreen(
          indexOfMoment: 0,
// Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
          momentsModelList: [momentsModelList],
        ),
      );
    }).catchError((e) {
      if (mounted) setState(() {});
      _isLoading = false;
      showToast(message: 'ERROR -> $e');
    });
  }
}

class SearchMomentSingleWidget extends StatefulWidget {
  final Function onTap;
  final String userTextToSearch;
  final SearchMomentModel searchMomentModel;
  const SearchMomentSingleWidget(
      {super.key,
      required this.onTap,
      required this.userTextToSearch,
      required this.searchMomentModel});

  @override
  State<SearchMomentSingleWidget> createState() =>
      _SearchMomentSingleWidgetState();
}

class _SearchMomentSingleWidgetState extends State<SearchMomentSingleWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Card(
        color: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _getMediaRenderer(
                searchMomentModel: widget.searchMomentModel, context: context),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 10),
                child: SizedBox(
                  width: 25,
                  child:
                      getCircularUserAvatar(widget.searchMomentModel.avatar!),
                ),
              ),
            ),
            if (isLoading)
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8),
                      child: CircularLoadingIndicator(),
                    )),
              )
            else
              const SizedBox.shrink(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    userNameWithVerifiedIcon(
                      name: widget.searchMomentModel.ownerName!,
                      isVerified: false,
                      textStyle: TextStyle(
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: const Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: 100,
                      child: Text(
                        truncateString(
                          str: messageDecoderWithEmoji(
                              widget.searchMomentModel.text!)!,
                          lengthToTruncateAt: 74,
                        ),
                        style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: blackFont,
                                offset: const Offset(0.0, 0),
                              ),
                            ],
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                    // Text(
                    //   getTime(exploreMomentsModelList[index]
                    //       .moments!
                    //       .first
                    //       .createdAt!),
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.w800,
                    //     shadows: [
                    //       Shadow(
                    //         blurRadius: 4.0,
                    //         color: blackFont,
                    //         offset: Offset(0.0, 0),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return InkWell(
    //     onTap: () {
    //       MomentsService()
    //           .getSingleMoment(momentId: widget.searchMomentModel.id!)
    //           .then((momentsModelList) {
    //         NavigationUtil.push(
    //           context,
    //           screen: MomentsDetailsScreen(
    //             indexOfMoment: 0,
    //             // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
    //             momentsModelList: [momentsModelList],
    //           ),
    //         );
    //       }).catchError((e) {
    //         showToast(message: 'ERROR -> $e');
    //       });
    //     },
    //     child: Container(
    //       padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    //       child: Card(
    //         shape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //         margin: EdgeInsets.zero,
    //         shadowColor: boxShadowTwo,
    //         elevation: 0,
    //         child: Container(
    //           decoration: decorateBox(),
    //           child: Column(
    //             children: <Widget>[
    //               Padding(
    //                 padding: EdgeInsets.symmetric(vertical: 8),
    //                 child: ListTile(
    //                   dense: true,
    //                   title: Row(
    //                     children: [
    //                       Text(
    //                         truncateString(
    //                             str: widget.searchMomentModel.ownerName!,
    //                             lengthToTruncateAt: 35),
    //                         maxLines: 1,
    //                         style: TextStyle(
    //                             color: blackFont,
    //                             fontWeight: FontWeight.w600,
    //                             fontSize: 14),
    //                       ),
    //                       Text(' • '),
    //                       Text(
    //                         MomentsUtils().getGetMomentDetailDateTime(
    //                             widget.searchMomentModel.createdAt!),
    //                         textAlign: TextAlign.end,
    //                         style: TextStyle(
    //                           fontSize: 12,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   subtitle: SingleChildScrollView(
    //                     child: Row(
    //                       children: getSubtitleTextWidget(
    //                           userTextToSearch: widget.userTextToSearch),
    //                     ),
    //                   ),
    //                   leading: InkWell(
    //                     onTap: () {
    //                       Navigator.pushNamed(context, Routes.USER_PROFILE,
    //                           arguments: {
    //                             "searchedUserName":
    //                                 widget.searchMomentModel.owner,
    //                           });
    //                     },
    //                     child: Container(
    //                       height: 48,
    //                       width: 48,
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(
    //                           25,
    //                         ),
    //                         border: Border.all(color: blackFont, width: 2),
    //                       ),
    //                       child: ClipOval(
    //                         child: CachedNetworkImage(
    //                           imageUrl: widget.searchMomentModel.avatar == ""
    //                               ? defaultImage
    //                               : widget.searchMomentModel.avatar!,
    //                           colorBlendMode: BlendMode.darken,
    //                           fit: BoxFit.cover,
    //                           errorWidget: imageErrorWidget,
    //                           height: double.infinity,
    //                           filterQuality: FilterQuality.high,
    //                           placeholder: (context, _) => CachedNetworkImage(
    //                             imageUrl: defaultImage,
    //                             colorBlendMode: BlendMode.darken,
    //                             fit: BoxFit.fitWidth,
    //                             filterQuality: FilterQuality.high,
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ));
  }

  // Padding(
  List<Widget> getSubtitleTextWidget({required String userTextToSearch}) {
    final List<Widget> widgets = [];

    for (var tag in widget.searchMomentModel.tags!) {
      widgets.add(
        Text(
          '#$tag ',
          style: TextStyle(
              color: darkGrey,
              fontSize: 12,
              //If the tag contains what the user enters, that particular tag will be displayed as bold (or normal if otherwise).
              fontWeight: tag.contains(userTextToSearch)
                  ? FontWeight.bold
                  : FontWeight.normal),
        ),
      );
    }
    return widgets.take(3).toList();
  }
}

Widget shimmerGridview() {
  return Shimmer.fromColors(
    baseColor: Colors.white,
    highlightColor: greyBorderColor,
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 300,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    ),
  );
}

Widget _getMediaRenderer(
    {required SearchMomentModel searchMomentModel,
    required BuildContext context}) {
  if (searchMomentModel.mediaPoster != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: searchMomentModel.mediaPoster!,
        fit: BoxFit.cover,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
      ),
    );
  }
  // Image.asset(
  //   'assets/images/moment_placeholder_image.png',
  //   fit: BoxFit.cover,
  // ),
  if (searchMomentModel.mediaType == "image") {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: searchMomentModel.media!,
        fit: BoxFit.cover,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.8).toInt(),
      ),
    );
  }

  if (searchMomentModel.mediaType == "video") {
    if (searchMomentModel.mediaPoster == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/images/moment_placeholder_image.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container();
    }
  } else {
    return Container();
  }
}
