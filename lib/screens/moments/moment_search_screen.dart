import 'dart:async';

import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../routes/route_constants.dart';
import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import '../../widget/customized_textform_field.dart';
import 'moment_detail_page.dart';
import 'moments_service.dart';

class MomentSearchScreen extends StatefulWidget {
  const MomentSearchScreen({Key? key}) : super(key: key);

  @override
  _MomentSearchScreenState createState() => _MomentSearchScreenState();
}

class _MomentSearchScreenState extends State<MomentSearchScreen> {
  Timer? typingTimer;
  String? nextPage; //For pagination.
  String? lastInputValue;
  String userSearchedText = '';
  bool searchMomentLoading = false;
  List<SearchMomentModel> searchMomentModelList = [];
  List<SearchMomentModel> tempSearchMomentModelList = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        debugPrint('GRID VIEW SCROLL CONTROLLER');
        _getSearchedMoments();
      }
    });
  }

  // We intend to call getMoments after every 1 second that the user typed in something.
  _onChanged(String value) {
    /*To prevent the changed function to be called when keyboard dismisses, we have this check here.  */
    if (value.isNotEmpty && lastInputValue != value) {
      lastInputValue = value;
      const duration = Duration(seconds: 1);
      if (typingTimer != null) {
        setState(() => typingTimer!.cancel()); // clear timer
      }
      typingTimer = new Timer(
        duration,
        () => getMoments(value),
      );
    }
  }

  getMoments(String value) {
    nextPage = null;
    userSearchedText = value;
    searchMomentModelList.clear();
    searchMomentLoading = true;
    if (mounted) setState(() {});

    _getSearchedMoments(searchedText: value);
  }

  AppBar appBar() {
    return AppBar(
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
        "Search moment",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _getSearchedMoments({String? searchedText}) {
    MomentsService()
        .searchMoment(nextPage: nextPage, searchText: searchedText)
        .then((value) {
      tempSearchMomentModelList.addAll(value.result);

      tempSearchMomentModelList.forEach((element) {
        if (!(searchMomentModelList.contains(element))) {
          searchMomentModelList.add(element);
        }
      });

      nextPage = value.next;
      searchMomentLoading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              CustomizedTextFormField(
                hintText: 'Search',
                autoFocus: true,
                onChanged: _onChanged,
              ),
              SizedBox(height: 10),
              searchMomentLoading
                  ? shimmerGridview()
                  : Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisExtent: 300,
                          maxCrossAxisExtent: 200,
                        ),
                        itemCount: searchMomentModelList.length,
                        itemBuilder: (context, index) {
                          if (searchMomentModelList.isEmpty) {
                            return Text(
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
                            // return Center(
                            //   child: nextPage != null
                            //       ? shimmerGridview()
                            //       : SizedBox.shrink(),
                            // );
                          }
                          return SearchMomentSingleWidget(
                            userTextToSearch: userSearchedText,
                            searchMomentModel: searchMomentModelList[index],
                          );
                        },
                      ),
                    ),
              searchMomentLoading
                  ? Expanded(
                      child: shimmerGridview(),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

class SearchMomentSingleWidget extends StatelessWidget {
  final String userTextToSearch;
  final SearchMomentModel searchMomentModel;
  const SearchMomentSingleWidget(
      {Key? key,
      required this.userTextToSearch,
      required this.searchMomentModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        MomentsService()
            .getSingleMoment(momentId: searchMomentModel.id!)
            .then((momentsModelList) {
          NavigationUtil.push(
            context,
            screen: MomentsDetailsScreen(
              indexOfMoment: 0,
              // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
              momentsModelList: [momentsModelList],
            ),
          );
        }).catchError((e) {
          showToast(message: 'ERROR -> $e');
        });
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
                searchMomentModel: searchMomentModel, context: context),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SizedBox(
                  width: 25,
                  child: getCircularUserAvatar(searchMomentModel.avatar!),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      truncateString(
                        str: searchMomentModel.ownerName!,
                        lengthToTruncateAt: 20,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: Offset(0.0, 0),
                          ),
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      truncateString(
                        str: messageDecoderWithEmoji(searchMomentModel.text!)!,
                        lengthToTruncateAt: 74,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: blackFont,
                            offset: Offset(0.0, 0),
                          ),
                        ],
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
            // Align(
            //   alignment: Alignment.topRight,
            //   child: momentListLengthWidget(
            //     exploreMomentsModelList[index].moments!.length,
            //   ),
            // ),
          ],
        ),
      ),
    );

    return InkWell(
        onTap: () {
          MomentsService()
              .getSingleMoment(momentId: searchMomentModel.id!)
              .then((momentsModelList) {
            NavigationUtil.push(
              context,
              screen: MomentsDetailsScreen(
                indexOfMoment: 0,
                // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
                momentsModelList: [momentsModelList],
              ),
            );
          }).catchError((e) {
            showToast(message: 'ERROR -> $e');
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.zero,
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Text(
                            truncateString(
                                str: searchMomentModel.ownerName!,
                                lengthToTruncateAt: 35),
                            maxLines: 1,
                            style: TextStyle(
                                color: blackFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          Text(' • '),
                          Text(
                            getGetMomentDetailDateTime(
                                searchMomentModel.createdAt!),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle: SingleChildScrollView(
                        child: Row(
                          children: getSubtitleTextWidget(
                              userTextToSearch: userTextToSearch),
                        ),
                      ),
                      leading: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.USER_PROFILE,
                              arguments: {
                                "searchedUserName": searchMomentModel.owner,
                              });
                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                            border: Border.all(color: blackFont, width: 2),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: searchMomentModel.avatar == ""
                                  ? defaultImage
                                  : searchMomentModel.avatar!,
                              colorBlendMode: BlendMode.darken,
                              fit: BoxFit.cover,
                              errorWidget: imageErrorWidget,
                              height: double.infinity,
                              filterQuality: FilterQuality.high,
                              placeholder: (context, _) => CachedNetworkImage(
                                imageUrl: defaultImage,
                                colorBlendMode: BlendMode.darken,
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Padding(
  // padding: const EdgeInsets.symmetric(vertical: 2.0),
  // child: Card(
  // color: Colors.white,
  // shape: RoundedRectangleBorder(
  // borderRadius: BorderRadius.circular(6),
  // ),
  // child: ListTile(
  // leading: Container(
  // width: 30,
  // height: 30,
  // padding: EdgeInsets.all(6),
  // decoration: BoxDecoration(
  // border: Border.all(color: blackFont, width: 2),
  // shape: BoxShape.circle,
  // image: DecorationImage(
  // fit: BoxFit.cover,
  // image: CachedNetworkImageProvider(
  // searchMomentModel.avatar!,
  // ),
  // ),
  // ),
  // ),
  // title: Text(searchMomentModel.owner!),
  // subtitle: SingleChildScrollView(
  // scrollDirection: Axis.horizontal,
  // child: Row(
  // children: getSubtitleText(userTextToSearch: userTextToSearch),
  // ),
  // ),
  // ),
  // ),
  // )

  List<Widget> getSubtitleTextWidget({required String userTextToSearch}) {
    List<Widget> widgets = [];

    searchMomentModel.tags!.forEach((tag) {
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
    });
    return widgets.take(3).toList();
  }
}

Widget shimmerGridview() {
  return Shimmer.fromColors(
    baseColor: Colors.white,
    highlightColor: greyBorderColor,
    child: GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
        fit: BoxFit.fill,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.3).toInt(),
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
        fit: BoxFit.fill,
        memCacheHeight: (MediaQuery.of(context).size.height * 0.3).toInt(),
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
