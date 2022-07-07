import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
  String? nextPage; //For pagination.
  String userSearchedText = '';
  bool searchMomentLoading = false;
  List<SearchMomentModel> searchMomentModelList = [];
  ScrollController _scrollController = ScrollController();

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
    debugPrint('NEXT PAGE --> $nextPage');
    debugPrint('ZERO RESULT --> ${searchMomentModelList.length}');

    MomentsService()
        .searchMoment(nextPage: nextPage, searchText: searchedText)
        .then((value) {
      debugPrint('FIRST RESULT --> ${searchMomentModelList.length}');

      debugPrint('SECOND RESULT --> ${value.result.length}');

      searchMomentModelList.addAll(value.result);
      debugPrint('FINAL RESULT --> ${searchMomentModelList.length}');
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomizedTextFormField(
                hintText: 'Search',
                autoFocus: true,
                onChanged: (value) {
                  userSearchedText = value;
                  nextPage = null;
                  searchMomentModelList.clear();
                  debugPrint('LIST - $searchMomentModelList');
                  searchMomentLoading = true;
                  if (mounted) setState(() {});

                  _getSearchedMoments(searchedText: value);
                },
              ),
              SizedBox(height: 10),
              searchMomentLoading
                  ? Center(
                      child: CircularLoadingIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        itemCount: searchMomentModelList.length + 1,
                        itemBuilder: (context, index) {
                          if (searchMomentModelList.isEmpty) {
                            return Center(
                              child: Text(
                                'Search for a moment',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }
                          if (index == searchMomentModelList.length) {
                            if (nextPage != null) {
                              _getSearchedMoments();
                            }
                            return Center(
                              child: Opacity(
                                opacity: nextPage != null ? 1 : 0,
                                child: CircularLoadingIndicator(
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }
                          return SearchMomentSingleWidget(
                            userTextToSearch: userSearchedText,
                            searchMomentModel: searchMomentModelList[index],
                          );
                        },
                      ),
                    )
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
                            truncateString(str: searchMomentModel.owner!, lengthToTruncateAt: 35),
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
                          width: 30,
                          height: 30,
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: blackFont, width: 2),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                searchMomentModel.avatar!,
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
